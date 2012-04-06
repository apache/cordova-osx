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

#import "AppDelegate.h"

@implementation AppDelegate


@synthesize window, contentView;

- (void) applicationDidStartLaunching:(NSNotification *)aNotification {}

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification
{
[[NSNotificationCenter defaultCenter] addObserver:self.contentView 
										 selector:@selector(windowResized:) 
											 name:NSWindowDidResizeNotification 
										   object:[self window]];

NSURL* fileUrl = [NSURL fileURLWithPath:[[Utils sharedInstance] pathForResource:kStartPage]];
[self.contentView.webView setMainFrameURL:[fileUrl description]];

/* useful colors
 NSColor *brown = [NSColor colorWithCalibratedRed:0.184 green:0.180 blue:0.176 alpha:1.000];
 NSColor *red = [NSColor colorWithCalibratedRed:0.918 green:0.000 blue:0.000 alpha:1.000];
 NSColor *orange = [NSColor colorWithCalibratedRed:0.918 green:0.518 blue:0.000 alpha:1.000];
 NSColor *yellow = [NSColor colorWithCalibratedRed:0.918 green:0.914 blue:0.000 alpha:1.000];
 NSColor *green = [NSColor colorWithCalibratedRed:0.000 green:0.918 blue:0.106 alpha:1.000];
 NSColor *skyBlue = [NSColor colorWithCalibratedRed:0.000 green:0.918 blue:0.906 alpha:1.000];
 NSColor *blue = [NSColor colorWithCalibratedRed:0.000 green:0.020 blue:0.918 alpha:1.000];
 NSColor *clearColor = [NSColor clearColor];
 */

if (kStartFolder == @"www/phonegap-docs/template/phonegap/") {
	
    //NSColor *brown = [NSColor colorWithCalibratedRed:0.184 green:0.180 blue:0.176 alpha:1.000];
    //[window setBackgroundColor:brown];
    //[self.contentView.webView setBackgroundColor:brown]; //it ignores "WebView" may not respond to 'setBackGroundColor:' @RandyMcMillan
    self.window.backgroundColor = [NSColor colorWithCalibratedRed:0.933 green:0.933 blue:0.933 alpha:1.000];
	
}else{
	
    //NSColor *windowBackGroundColor = [NSColor colorWithCalibratedRed:0.918 green:0.918 blue:0.918 alpha:1.000];
    //NSColor *webViewBackGroundColor = [NSColor colorWithCalibratedRed:0.082 green:0.133 blue:0.192 alpha:1.000];
    //[window setBackgroundColor:windowBackGroundColor];
    //[self.contentView.webView setBackgroundColor:webViewBackGroundColor]; //it ignores "WebView" may not respond to 'setBackGroundColor:' @RandyMcMillan
    self.window.backgroundColor = [NSColor colorWithCalibratedRed:0.933 green:0.933 blue:0.933 alpha:1.000];
}//end else

}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {

self.contentView.webView.alphaValue = 1.0;
self.contentView.alphaValue = 1.0;
}

@end
