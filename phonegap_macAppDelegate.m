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


+ (NSString*) pathForResource:(NSString*)resourcepath
{
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSMutableArray *directoryParts = [NSMutableArray arrayWithArray:[resourcepath componentsSeparatedByString:@"/"]];
    NSString       *filename       = [directoryParts lastObject];
    [directoryParts removeLastObject];
	
    NSString *directoryStr = [NSString stringWithFormat:@"%@/%@", @"www", [directoryParts componentsJoinedByString:@"/"]];
    return [mainBundle pathForResource:filename
								ofType:@""
						   inDirectory:directoryStr];
}

/* TODO: put this in a utils class or something */
+ (float) titleBarHeight:(NSWindow*)aWindow
{
    NSRect frame = [aWindow frame];
    NSRect contentRect = [NSWindow contentRectForFrameRect: frame
										  styleMask: NSTitledWindowMask];
	
    return (frame.size.height - contentRect.size.height);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	[[NSNotificationCenter defaultCenter] addObserver:self.contentView
											 selector:@selector(windowResized:) 
												 name:NSWindowDidResizeNotification 
											   object:[self window]];
	
	[self.contentView.webView setCustomUserAgent:USER_AGENT_IPHONE_OS];
	
    NSURL* fileUrl   = [NSURL fileURLWithPath:[phonegap_macAppDelegate pathForResource:@"index.html"]];
	[self.contentView.webView setMainFrameURL:[fileUrl description]];
}

@end
