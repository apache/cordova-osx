//
//  phonegap_macAppDelegate.m
//  phonegap-mac
//
//  Created by shazron on 10-04-08.
//  Copyright 2010 Nitobi Software Inc. All rights reserved.
//

#import "phonegap_macAppDelegate.h"

@implementation phonegap_macAppDelegate

@synthesize window, contentView;

- (void) applicationDidFinishLaunching:(NSNotification*)aNotification 
{
	[[NSNotificationCenter defaultCenter] addObserver:self.contentView 
											 selector:@selector(windowResized:) 
												 name:NSWindowDidResizeNotification 
											   object:[self window]];
	
    NSURL* fileUrl = [NSURL fileURLWithPath:[[Utils sharedInstance] pathForResource:kStartPage]];
	[self.contentView.webView setMainFrameURL:[fileUrl description]];
}

@end
