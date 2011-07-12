//
//  ContentView.m
//  phonegap-mac
//
//  Created by shazron on 10-04-19.
//  Copyright 2010 Nitobi Software Inc. All rights reserved.
//

#import "ContentView.h"
#import "WebViewDelegate.h"
#import "phonegap_macAppDelegate.h"

@implementation ContentView

@synthesize webView, delegate;

- (void) awakeFromNib
{
	self.delegate = [[[WebViewDelegate alloc] init] autorelease];
	[self.webView setFrameLoadDelegate:self.delegate];
	[self.webView setUIDelegate:self.delegate];
	[self.webView setResourceLoadDelegate:self.delegate];
	[self.webView setDownloadDelegate:self.delegate];
	[self.webView setPolicyDelegate:self.delegate];	
    //self.window.backgroundColor = [NSColor colorWithCalibratedRed:0.933 green:0.933 blue:0.933 alpha:1.000];
}

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
		// init here
    }
    return self;
}

- (void) drawRect:(NSRect)dirtyRect 
{
    // Drawing code here.
}

- (void) windowResized:(NSNotification*)notification;
{
	NSWindow* window = (NSWindow*)notification.object;
	NSSize size = [window frame].size;
	
	DebugNSLog(@"window width = %f, window height = %f", size.width, size.height);
	[self.webView setFrame:NSMakeRect(0, 0, size.width, size.height - [[Utils sharedInstance] titleBarHeight:window])];
    [self.webView stringByEvaluatingJavaScriptFromString:@"var e = document.createEvent('Events'); e.initEvent('orientationchange', true, false); document.dispatchEvent(e); "];
}


@end
