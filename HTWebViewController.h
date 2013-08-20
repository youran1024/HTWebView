//
//  HTWebViewController.h
//  HTWebView
//
//  Created by Mr.Yang on 13-8-2.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTProgressView;
@protocol HTWebViewDelegate;

@interface HTWebView :UIWebView 
@property (nonatomic, assign) id <HTWebViewDelegate> progressDelegate;

@end

@interface HTWebViewController : UIViewController

@property (nonatomic, retain)   NSURL *url;
@property (nonatomic, retain, readonly) HTWebView *webView;
@property (nonatomic, retain)   HTProgressView *progressView;

@end
