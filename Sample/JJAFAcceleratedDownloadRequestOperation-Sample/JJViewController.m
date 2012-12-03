//
//  JJViewController.m
//  AFAcceleratedDownloadRequestOperation-Sample
//
//  Created by Josh Johnson on 9/29/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#include <mach/mach_time.h>
#include <stdint.h>
#import "JJViewController.h"
#import "AFNetworking.h"
#import "JJAFAcceleratedDownloadRequestOperation.h"
#import "JJChunkedProgressView.h"

static const NSUInteger kJJConcurrentDownloads = JJAFAcceleratedDownloadChunkSizeRecommended;

@interface JJViewController ()

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet JJChunkedProgressView *chunkedProgressView;

- (IBAction)downloadAccelerated:(id)sender;
- (IBAction)downloadNormal:(id)sender;

@end

@implementation JJViewController

- (void)downloadAccelerated:(id)sender
{
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	
	mach_timebase_info_data_t info;
	mach_timebase_info(&info);
	
	[self.imageView setImage:nil];
	[self.timeLabel setText:nil];
	[self.chunkedProgressView setChunks:kJJConcurrentDownloads];

	NSURL *url = [NSURL URLWithString:@"http://api.badmovieapp.com/Raleigh-Skyline.png"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	JJAFAcceleratedDownloadRequestOperation *operation = [[JJAFAcceleratedDownloadRequestOperation alloc] initWithRequest:request];
	[operation setMaximumChunkSize:kJJConcurrentDownloads];
	
	__weak JJChunkedProgressView *weakProgress = self.chunkedProgressView;
	__weak UIImageView *weakImageView = self.imageView;
	__weak UILabel *timeLabel = self.timeLabel;
	
	[operation setProgressBlock:^(NSUInteger chunkIndex, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){
		float percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToRead));
		[weakProgress setProgress:percentDone chunkIndex:chunkIndex];
	}];
	
	const uint64_t startTime = mach_absolute_time();
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		const uint64_t endTime = mach_absolute_time();
		const uint64_t elapsedMTU = endTime - startTime;
		const double elapsedNS = (double)elapsedMTU * (double)info.numer / (double)info.denom;
		float seconds = elapsedNS / NSEC_PER_SEC;
		
		UIImage *image = [[UIImage alloc] initWithData:responseObject scale:[[UIScreen mainScreen] scale]];
		dispatch_async(dispatch_get_main_queue(), ^{
			[timeLabel setText:[NSString stringWithFormat:@"%f seconds", seconds]];
			[weakImageView setImage:image];
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Failed all");
	}];
	
	[operation start];
}

- (void)downloadNormal:(id)sender
{
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	
	mach_timebase_info_data_t info;
	mach_timebase_info(&info);
	
	[self.imageView setImage:nil];
	[self.timeLabel setText:nil];
	[self.chunkedProgressView setChunks:1];

	NSURL *url = [NSURL URLWithString:@"http://api.badmovieapp.com/Raleigh-Skyline.png"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];

	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	
	__weak JJChunkedProgressView *weakProgress = self.chunkedProgressView;
	__weak UIImageView *weakImageView = self.imageView;
	__weak UILabel *timeLabel = self.timeLabel;

	[operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
		float percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToRead));
		[weakProgress setProgress:percentDone chunkIndex:0];
	}];
	
	const uint64_t startTime = mach_absolute_time();
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		const uint64_t endTime = mach_absolute_time();
		const uint64_t elapsedMTU = endTime - startTime;
		const double elapsedNS = (double)elapsedMTU * (double)info.numer / (double)info.denom;
		float seconds = elapsedNS / NSEC_PER_SEC;

		UIImage *image = [[UIImage alloc] initWithData:responseObject];
		dispatch_async(dispatch_get_main_queue(), ^{
			[timeLabel setText:[NSString stringWithFormat:@"%f seconds", seconds]];
			[weakImageView setImage:image];
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Failed");
	}];
	
	[operation start];
	
}


@end
