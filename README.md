# JJAFAcceleratedDownloadRequestOperation

I was curious if downloading ranges of a file would be faster than 1 request. At the same time I was curious about creating an AFNetworking "extension". Putting those two ideas together creates `JJAFAcceleratedDownloadRequestOperation`, a subclass of  `AFHTTPOperation` that will break up a download request into multiple request "chunks" to download at the same time. 

Here is a video of it in action:

[JJAFAcceleratedDownloadRequestOperation video](http://jsh.in/KfBi)

## JJChunkedProgressView ##

This project also contains `JJChunkedProgressView` which allows you to update progress for different parts of a download operation. Potentially needs to be broken out into it's own project. It does support UIAppearance on:

```objective-c
@property (nonatomic, strong) UIColor *progressColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *trackBorderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *trackBackgroundColor UI_APPEARANCE_SELECTOR;
```

## AFNetworking ##

This is built on top of the amazing AFNetworking library targeting the latest branch: tagged 1.0.1.

## TODO ##

- Add Resume support for when the download is paused
- Error handling for when the worst happens
- Test with (and create progress view for) AppKit downloading on OS X
- Lots of testing
- Add overall download progress to Progress View

## Usage ##

```objective-c
    // Setup Request
    NSURL *url = [NSURL URLWithString:@"<URL to big file>"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Setup Operation
    JJAFAcceleratedDownloadRequestOperation *operation = [[JJAFAcceleratedDownloadRequestOperation alloc] initWithRequest:request];
    [operation setMaximumChunkSize:JJAFAcceleratedDownloadChunkSizeRecommended];
    
    // Get Progress Updates
    [operation setProgressBlock:^(NSUInteger chunkIndex, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){
        float percentDoneForChunk = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToRead));
        // Use the percentage
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // responseObject is NSData of the downloaded file
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Download Failed");
    }];

    [operation start];
```

## Contributing

As stated above, this is mostly an experimental project build out of curiosity. Probabably no where near ready for use in a production app. However, if you'd like to hack on it, please do and I'd be glad to check it out. 

__rake__

I've added some build tools using [xcoder](https://github.com/rayh/xcoder) and __rake__ that can help get you started and will soon be able to run some unit tests. 

Rake is a ruby tool that can be installed on your machine. The best setup is to use __bundler__ via:

    `gem install bundle`

After cloning from github, `cd` into the project directory and run:

    `bundle install`

Finally, setup the project by running:

    `rake tools:setup`

Other commands available:

    rake build:sample  # Build Sample

## Contact

- [Josh Johnson](http://jnjosh.com) [@jnjosh](http://twitter.com/jnjosh)

## License

`JJAFAcceleratedDownloadRequestOperation` is available under the MIT License, please see the [LICENSE file for more information](http://jnjosh.mit-license.org/).