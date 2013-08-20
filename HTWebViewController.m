//
//  HTWebViewController.m
//  HTWebView
//
//  Created by Mr.Yang on 13-8-2.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import "HTWebViewController.h"

@protocol HTWebViewDelegate <NSObject>

- (void)webView:(HTWebView *)webView didReceiveDataPresent:(CGFloat)persent;

@end

@interface UIWebView ()

-(id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource;
-(void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource;
-(void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource;

@end

@interface HTProgressView : UIView

@property (nonatomic, assign)   CGFloat progressValue;
@property (nonatomic, retain)   UIColor *tintColor;

@end

@implementation HTProgressView

- (id)init
{
    self = [super init];
    if (self) {
        [self initVariables];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initVariables];
    }
    return self;
}

- (void)initVariables
{
    _tintColor = [UIColor greenColor];
    self.progressValue = 0.0f;
    self.backgroundColor = [UIColor redColor];
    
}

- (void)setProgressValue:(CGFloat)progressValue
{
    CGRect rect = self.frame;
    static CGFloat width;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        width = rect.size.width;
    });

    if (progressValue > _progressValue) {
        _progressValue = progressValue;
        rect.size.width = width * _progressValue;
        self.frame = rect;
    }
}

@end

@implementation HTWebView
{
    NSInteger totalCount;
    NSInteger receiveCount;
}

- (id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource
{
    [super webView:view identifierForInitialRequest:initialRequest fromDataSource:dataSource];
    
    return @(totalCount++);
}

- (void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource
{
    [super webView:view resource:resource didFinishLoadingFromDataSource:dataSource];
    
    receiveCount++;
    if (_progressDelegate && [_progressDelegate respondsToSelector:@selector(webView:didReceiveDataPresent:)]) {
        [_progressDelegate webView:self didReceiveDataPresent:receiveCount/totalCount ];
    }

    if (receiveCount == totalCount) {
        receiveCount = 0;
        totalCount = 0;
    }
}

- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource
{
    [super webView:view resource:resource didFailLoadingWithError:error fromDataSource:dataSource];
    
    receiveCount++;
    if (_progressDelegate && [_progressDelegate respondsToSelector:@selector(webView:didReceiveDataPresent:)]) {
        [_progressDelegate webView:self didReceiveDataPresent:(CGFloat)receiveCount/(CGFloat)totalCount ];
    }
    
    if (receiveCount == totalCount) {
        receiveCount = 0;
        totalCount = 0;
    }
}

@end


@interface HTWebViewController () <HTWebViewDelegate, UIWebViewDelegate>
{

}
@end

@implementation HTWebViewController

- (void)dealloc
{
    [_webView release];
    [_progressView release];
    [super dealloc];
}

- (void)setUrl:(NSURL *)url
{
    if (![_url isEqual:url]) {
        [_url release];
        _url = [url retain];
        [self refresh:url];
    }
}

- (void)refresh:(NSURL *)url
{
    _progressView.hidden = NO;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    if (!_webView) {
        _webView = [[HTWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        _webView.backgroundColor = [UIColor greenColor];
        _webView.progressDelegate = self;
        [self.view addSubview:_webView];
    }
    
    if (!_progressView) {
        _progressView = [[HTProgressView alloc] initWithFrame:CGRectMake(0, 0, 320, 6)];
        _progressView.backgroundColor = [UIColor redColor];
        [self.view addSubview:_progressView];
    }
    
    [_webView loadRequest:request];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)webView:(HTWebView *)webView didReceiveDataPresent:(CGFloat)persent
{
    _progressView.progressValue = persent;
    if (persent == 1.0f) {
        _progressView.hidden = YES;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    _progressView.hidden = NO;
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
