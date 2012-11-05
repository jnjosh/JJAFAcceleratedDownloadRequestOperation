//
//  JJChunkedProgressView.m
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

#import "JJChunkedProgressView.h"

static const CGFloat kJJChunkedProgressBarHeight = 22.0f;
static UIColor *jj_chunkedProgressViewDefaultBorderColor = nil;
static UIColor *jj_chunkedProgressViewDefaultProgressColor = nil;
static UIColor *jj_chunkedProgressViewDefaultBackgroundColor = nil;

@interface JJChunkedProgressView ()

@property (nonatomic, assign) NSUInteger chunkCount;
@property (nonatomic, strong) NSMutableArray *progressStore;

@end

@implementation JJChunkedProgressView

#pragma mark - Class Methods

+ (void)initialize
{
	if (self == [JJChunkedProgressView class]) {
		jj_chunkedProgressViewDefaultBorderColor = [UIColor whiteColor];
		jj_chunkedProgressViewDefaultProgressColor = [UIColor whiteColor];
		jj_chunkedProgressViewDefaultBackgroundColor = [UIColor grayColor];
	}
}

#pragma mark - Properties

- (void)setFrame:(CGRect)frame
{
	frame.size.height = kJJChunkedProgressBarHeight;
	[super setFrame:frame];
}

- (void)setChunks:(NSUInteger)chunks
{
	NSParameterAssert(chunks > 0);
	
	self.chunkCount = chunks;
	
	NSMutableArray *chunkArray = [NSMutableArray arrayWithCapacity:chunks];
	for (NSUInteger i = 0; i < chunks; i++) {
		[chunkArray addObject:@0.0f];
	}
	
	self.progressStore = chunkArray;
	[self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawPathForRect:(CGRect)drawingRect context:(CGContextRef)context radius:(CGFloat)radius
{
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, CGRectGetMinX(drawingRect), CGRectGetMidY(drawingRect));
	CGContextAddArcToPoint(context, CGRectGetMinX(drawingRect), CGRectGetMinY(drawingRect), CGRectGetMidX(drawingRect), CGRectGetMinY(drawingRect), radius);
	CGContextAddArcToPoint(context, CGRectGetMaxX(drawingRect), CGRectGetMinY(drawingRect), CGRectGetMaxX(drawingRect), CGRectGetMidY(drawingRect), radius);
	CGContextAddArcToPoint(context, CGRectGetMaxX(drawingRect), CGRectGetMaxY(drawingRect), CGRectGetMidX(drawingRect), CGRectGetMaxY(drawingRect), radius);
	CGContextAddArcToPoint(context, CGRectGetMinX(drawingRect), CGRectGetMaxY(drawingRect), CGRectGetMinX(drawingRect), CGRectGetMidY(drawingRect), radius);
	CGContextClosePath(context);
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);

	UIColor *borderColor = self.trackBorderColor ?: jj_chunkedProgressViewDefaultBorderColor;
	UIColor *progressColor = self.progressColor ?: jj_chunkedProgressViewDefaultProgressColor;
	UIColor *trackBackgroundColor = self.trackBackgroundColor ?: jj_chunkedProgressViewDefaultBackgroundColor;
	
	// Draw border
	CGRect drawingRect = CGRectInset(rect, 1.0f, 1.0f);
	CGFloat radius = drawingRect.size.height * 0.5f;
	[borderColor setStroke];

	CGContextSetLineWidth(context, 2.0f);
	[self drawPathForRect:drawingRect context:context radius:radius];
	CGContextDrawPath(context, kCGPathStroke);
	
	// Draw Track Background
	drawingRect = CGRectInset(drawingRect, 3.0f, 3.0f);
	radius = drawingRect.size.height * 0.5f;
	[trackBackgroundColor setFill];
	[self drawPathForRect:drawingRect context:context radius:radius];
	CGContextFillPath(context);
    
	// Draw Progress Segments
	CGFloat segmentWidth = drawingRect.size.width / self.chunkCount;
	CGRect segmentRect =  (CGRect){ drawingRect.origin, { segmentWidth, drawingRect.size.height }};
	[progressColor setFill];
	[self drawPathForRect:drawingRect context:context radius:radius];
	CGContextClip(context);

	for (NSUInteger segment = 0; segment < self.chunkCount; segment++) {
		CGFloat progress = [self progressAtChunkIndex:segment];
		CGRect segmentDrawRect = CGRectIntegral(segmentRect);
		segmentDrawRect.size.width *= progress;
		
		CGContextFillRect(context, segmentDrawRect);

		segmentRect.origin.x += segmentWidth;
	}
	
	CGContextRestoreGState(context);
}

#pragma mark - Progress Methods

- (void)setProgress:(CGFloat)progress chunkIndex:(NSUInteger)chunkIndex
{
	NSNumber *number = [self.progressStore objectAtIndex:chunkIndex];
	number = @(progress);
	[self.progressStore setObject:number atIndexedSubscript:chunkIndex];
	[self setNeedsDisplay];
}

- (CGFloat)progressAtChunkIndex:(NSUInteger)chunkIndex
{
	NSNumber *number = [self.progressStore objectAtIndex:chunkIndex];
	return [number floatValue];
}

- (CGFloat)overallProgress
{
	return 0.0f;
}

@end
