//
//  AFAcceleratedDownloadRequestOperation.h
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

#import "AFHTTPRequestOperation.h"

typedef NS_ENUM(NSUInteger, AFAcceleratedDownloadChunkSize) {
	AFAcceleratedDownloadChunkSizeSingle = 1,
	AFAcceleratedDownloadChunkSizeMinimal = 2,
	AFAcceleratedDownloadChunkSizeRecommended = 3,
	AFAcceleratedDownloadChunkSizeLudicrous = 4
};

typedef void(^AFAcceleratedDownloadRequestProgressBlock)(NSUInteger chunkIndex, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

@interface AFAcceleratedDownloadRequestOperation : AFHTTPRequestOperation

/** Defines the maximum size of single chunks for downloading a file */
@property (nonatomic, assign) AFAcceleratedDownloadChunkSize maximumChunkSize;

/** Progress Block on the download */
@property (nonatomic, copy) AFAcceleratedDownloadRequestProgressBlock progressBlock;

/** Designated Initializer to create a download operation with resume support
 * @param urlRequest request to the resource being downloaded
 * @param shouldResume should the download request be resumed from a prior attempt or start over
 * @return instance of class AFAcceleratedDownloadRequestOperation
 */
- (id)initWithRequest:(NSURLRequest *)urlRequest shouldResume:(BOOL)shouldResume;

@end