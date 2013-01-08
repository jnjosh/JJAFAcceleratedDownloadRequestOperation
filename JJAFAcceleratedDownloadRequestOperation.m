//
//  JJAFAcceleratedDownloadRequestOperation.m
//
//  Copyright (c) 2012 Josh Johnson
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//  and associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute,
//  sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
//  NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JJAFAcceleratedDownloadRequestOperation.h"
#import <tgmath.h>

#if !__has_feature(objc_arc)
#error "JJAFAcceleratedDownloadRequestOperation requires compiling with ARC."
#endif

typedef NS_ENUM(NSInteger, JJAFHTTPStatusCode) {
	JJAFHTTPStatusCodeOk = 200,
	JJAFHTTPStatusCodePartial = 206
};

NSString * const kJJAFInternalCachedURLFolderPrefix = @"jjaf_";
NSString * const kJJAFInternalCachedFolderName = @"Incomplete";
NSString * const kJJAFInternalDownloadInformation = @"jjaf_download.plist";
static const NSUInteger kJJAFInternalDefaultMaximumChunkSize = 4;

@interface JJAFAcceleratedDownloadRequestOperation ()

@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, assign, getter = shouldResume) BOOL resume;
@property (nonatomic, strong) NSOperationQueue *innerQueue;

@property (nonatomic, strong) NSMutableArray *downloadedData;

+ (NSString *)downloadCacheFolder;
+ (NSURL *)downloadCacheURLForURL:(NSURL *)url;

- (NSOperation *)HEADOperationForURL:(NSURL *)url;
- (NSSet *)operationsForURL:(NSURL *)url contentSize:(NSUInteger)contentSize chunks:(NSUInteger)chunks;

@end

@implementation JJAFAcceleratedDownloadRequestOperation

#pragma mark - Class methods

+ (NSString *)downloadCacheFolder
{
	static dispatch_once_t downloadFolder_onceToken;
	static NSString *jjaf_internal_acceleratedDownloadRequestCacheFolder = nil;

	dispatch_once(&downloadFolder_onceToken, ^{
		jjaf_internal_acceleratedDownloadRequestCacheFolder = [NSTemporaryDirectory() stringByAppendingString:kJJAFInternalCachedFolderName];
		
		NSError *folderError;
		[[NSFileManager defaultManager] createDirectoryAtPath:jjaf_internal_acceleratedDownloadRequestCacheFolder
								  withIntermediateDirectories:YES
												   attributes:nil
														error:&folderError];
		
		if (folderError) {
			NSLog(@"Failed to create cache folder for download: %@", jjaf_internal_acceleratedDownloadRequestCacheFolder);
		}
	});
	
	return jjaf_internal_acceleratedDownloadRequestCacheFolder;
}

+ (NSURL *)downloadCacheURLForURL:(NSURL *)url
{
	NSURL *folderURL = [NSURL fileURLWithPath:[self downloadCacheFolder] isDirectory:YES];
	NSString *folderName = [NSString stringWithFormat:@"%@%u", kJJAFInternalCachedURLFolderPrefix, url.absoluteString.hash];
	
	NSURL *urlCacheFolderURL = [folderURL URLByAppendingPathComponent:folderName isDirectory:YES];
	
	static dispatch_once_t urlFolder_onceToken;
	dispatch_once(&urlFolder_onceToken, ^{
		NSError *folderError;
		[[NSFileManager defaultManager] createDirectoryAtURL:urlCacheFolderURL
								 withIntermediateDirectories:YES
												  attributes:nil
													   error:&folderError];
		if (folderError) {
			NSLog(@"Failed to create cache folder: %@ for URL: %@", [urlCacheFolderURL absoluteString], url);
		}

	});
	
	return urlCacheFolderURL;
}

#pragma mark - Life cycle

- (id)initWithRequest:(NSURLRequest *)urlRequest shouldResume:(BOOL)shouldResume
{
	if (self = [super initWithRequest:urlRequest]) {
		_innerQueue = [[NSOperationQueue alloc] init];
		[_innerQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
		_resume = shouldResume;
		_maximumChunkSize = kJJAFInternalDefaultMaximumChunkSize;
		_downloadedData = [NSMutableArray array];
	}
	return self;
}

- (id)initWithRequest:(NSURLRequest *)urlRequest
{
	return [self initWithRequest:urlRequest shouldResume:YES];
}

#pragma mark - JJAFHTTPRequestOperation overrides

- (void)start
{
	// Build Info Dictionary
	// TODO: Setup for resuming
	
	// Start HEAD request to begin downloading process
	NSOperation *headOperation = [self HEADOperationForURL:[self.request URL]];
	[self.innerQueue addOperation:headOperation];
}

#pragma mark - Properties

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
	__block typeof(self) weak_self = self;
	[self setCompletionBlock:^{
		if (success) {
			success(weak_self, weak_self.responseData);
		}
	}];
}

#pragma mark - Helpers

- (NSSet *)operationsForURL:(NSURL *)url contentSize:(NSUInteger)contentSize chunks:(NSUInteger)chunks
{
	NSParameterAssert(chunks > 0);
	
	NSMutableSet *operationSet = [NSMutableSet set];
	
	NSInteger chunkSize = contentSize / chunks;
	NSInteger chunkRemainder = fmod(contentSize, chunks);
	NSInteger chunkPosition = 0;
	NSUInteger downloadNumber = 0;
	
	[self.downloadedData removeAllObjects];
	self.downloadedData = [NSMutableArray array];
	
	__weak typeof(self) weak_self = self;
	
	for (NSInteger i = 0; i < chunks; i++) {
		NSInteger divisonBuffer = 0;
		if (i == (chunks - 1)) {
			divisonBuffer = -chunkRemainder;
		}
		
		NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
		
		NSNumber *requestSizeEnd = @(chunkPosition + chunkSize + divisonBuffer);
		NSString *rangeString = [NSString stringWithFormat:@"bytes=%i-%@/%i", chunkPosition, requestSizeEnd, contentSize];
		
		NSMutableURLRequest *downloadRequest = [NSMutableURLRequest requestWithURL:url];
		[downloadRequest setValue:@"bytes" forHTTPHeaderField:@"If-Ranges"];
		[downloadRequest setValue:rangeString forHTTPHeaderField:@"Range"];
		
		AFHTTPRequestOperation *downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:downloadRequest];
		[downloadOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
			if (weak_self.progressBlock) {
				weak_self.progressBlock(downloadNumber, bytesRead, totalBytesRead, totalBytesExpectedToRead);
			}
		}];

		[downloadOperation setOutputStream:stream];
		[weak_self.downloadedData addObject:stream];
		[operationSet addObject:downloadOperation];
		chunkPosition += chunkSize + 1;
		
		downloadNumber++;
	}
	
	return operationSet;
}

- (NSOperation *)HEADOperationForURL:(NSURL *)url
{
	NSParameterAssert(url);
	
	NSMutableURLRequest *headRequest = [NSMutableURLRequest requestWithURL:self.request.URL];
	[headRequest setHTTPMethod:@"HEAD"];
	[headRequest setValue:@"bytes" forHTTPHeaderField:@"If-Ranges"];
	[headRequest setValue:@"bytes=0-1/1" forHTTPHeaderField:@"Range"];
	
	__weak typeof(self) weak_self = self;
	
	AFHTTPRequestOperation *headOperation = [[AFHTTPRequestOperation alloc] initWithRequest:headRequest];
	[headOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSInteger statusCode = operation.response.statusCode;
		NSUInteger chunkSize = statusCode == JJAFHTTPStatusCodePartial ? weak_self.maximumChunkSize : 1;
		if (chunkSize != weak_self.maximumChunkSize) {
			if (self.chunkSizeChangeBlock) {
				self.chunkSizeChangeBlock(chunkSize);
			}
		}
			
		// TODO: Parse this content range better
		NSString *contentLengthString = [operation.response.allHeaderFields objectForKey:@"Content-Range"];
		contentLengthString = [contentLengthString stringByReplacingOccurrencesOfString:@"bytes 0-1/" withString:@""];
		NSInteger contentLength = [contentLengthString integerValue];
		
		NSSet *operations = [weak_self operationsForURL:operation.request.URL
											contentSize:contentLength
												 chunks:chunkSize];
		
		NSOperation *finishOperation = [NSBlockOperation blockOperationWithBlock:^{
			
			NSMutableData *compiledData = [NSMutableData data];
			for (id partialData in weak_self.downloadedData) {
				[compiledData appendData:[partialData propertyForKey:NSStreamDataWrittenToMemoryStreamKey]];
			}
			
			weak_self.responseData = compiledData;
			
			if (weak_self.completionBlock) {
				weak_self.completionBlock();
			}
		}];
		
		for (NSOperation *operation in operations) {
			[finishOperation addDependency:operation];
			[weak_self.innerQueue addOperation:operation];
		}
		
		[weak_self.innerQueue addOperation:finishOperation];

	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		// TODO: Handle HEAD operation error case
		
	}];
	
	return headOperation;
}

@end