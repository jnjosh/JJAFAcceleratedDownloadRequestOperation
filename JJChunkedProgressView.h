//
//  JJChunkedProgressView.h
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

#import <UIKit/UIKit.h>

@interface JJChunkedProgressView : UIView

@property (nonatomic, strong) UIColor *progressColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *trackBorderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *trackBackgroundColor UI_APPEARANCE_SELECTOR;

/** Set the division of the chunks to draw
 * @discussion This causes all chunk's progress to fail and be reset to zero
 * @param chunks integer count of chunks to track progress on
 */
- (void)setChunks:(NSUInteger)chunks;

/** Set the progress of the view targeting the specific range
 * @param progress of the given chunk
 * @param chunkIndex index of the chunk to set progress on
 */
- (void)setProgress:(CGFloat)progress chunkIndex:(NSUInteger)chunkIndex;

/** Progress at the specific chunk index
 * @param chunkIndex index of the chunk
 */
- (CGFloat)progressAtChunkIndex:(NSUInteger)chunkIndex;

/** Overall progress of all chunks
 * @return CGFloat percentage of 1.0. (e.g. 0.902323 ~= 90%)
 */
- (CGFloat)overallProgress;
 
@end
