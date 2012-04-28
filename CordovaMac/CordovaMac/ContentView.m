/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "ContentView.h"
#import "WebViewDelegate.h"
#import "AppDelegate.h"

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
	
	//DebugNSLog(@"window width = %f, window height = %f", size.width, size.height);
	[self.webView setFrame:NSMakeRect(0, 0, size.width, size.height - [[Utils sharedInstance] titleBarHeight:window])];
    [self.webView stringByEvaluatingJavaScriptFromString:@"var e = document.createEvent('Events'); e.initEvent('orientationchange', true, false); document.dispatchEvent(e); "];
}


@end
