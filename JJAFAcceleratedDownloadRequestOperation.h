//
//  JJAFAcceleratedDownloadRequestOperation.h
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

typedef NS_ENUM(NSUInteger, JJAFAcceleratedDownloadChunkSize) {
	JJAFAcceleratedDownloadChunkSizeSingle = 1,
	JJAFAcceleratedDownloadChunkSizeMinimal = 2,
	JJAFAcceleratedDownloadChunkSizeRecommended = 3,
	JJAFAcceleratedDownloadChunkSizeLudicrous = 4
};

typedef void(^JJAFAcceleratedDownloadRequestProgressBlock)(NSUInteger chunkIndex, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
typedef void(^JJAFAcceleratedDownloadRequestChangeChunkSizeBlock)(NSUInteger newChunkSize);

@interface JJAFAcceleratedDownloadRequestOperation : AFHTTPRequestOperation

/** Defines the maximum size of single chunks for downloading a file */
@property (nonatomic, assign) JJAFAcceleratedDownloadChunkSize maximumChunkSize;

/** Progress Block on the download */
@property (nonatomic, copy) JJAFAcceleratedDownloadRequestProgressBlock progressBlock;

/** Block to notify owner of changes in block size 
 @discussion Since support for this ranged download request is dependent on the server being called, the 
			 JJAFAcceleratedDownloadRequestOperation may change the amount of chunks being downloaded
			 dynamically. This is an opportunity to change any state on the progress control displaying
			 multiple downloads (like a JJChunkedProgressView).
 */
@property (nonatomic, copy) JJAFAcceleratedDownloadRequestChangeChunkSizeBlock chunkSizeChangeBlock;

/** Designated Initializer to create a download operation with resume support
 * @param urlRequest request to the resource being downloaded
 * @param shouldResume should the download request be resumed from a prior attempt or start over
 * @return instance of class JJAFAcceleratedDownloadRequestOperation
 */
- (id)initWithRequest:(NSURLRequest *)urlRequest shouldResume:(BOOL)shouldResume;

@end