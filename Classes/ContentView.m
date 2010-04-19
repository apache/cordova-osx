//
//  ContentView.m
//  phonegap-mac
//
//  Created by shazron on 10-04-19.
//  Copyright 2010 Nitobi Software Inc. All rights reserved.
//

#import "ContentView.h"
#import "phonegap_macAppDelegate.h"

@implementation ContentView

@synthesize webView;

- (void) awakeFromNib
{
	[self.webView setFrameLoadDelegate:self];
	[self.webView setUIDelegate:self];
	[self.webView setResourceLoadDelegate:self];
	[self.webView setDownloadDelegate:self];
	[self.webView setPolicyDelegate:self];				
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		// init here
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

- (void)windowResized:(NSNotification *)notification;
{
	NSWindow* window = (NSWindow*)notification.object;
	NSSize size = [window frame].size;
	
	NSLog(@"window width = %f, window height = %f", size.width, size.height);
	[self.webView setFrame:NSMakeRect(0, 0, size.width, size.height - [phonegap_macAppDelegate titleBarHeight:window])];
}

- (void)webView:(WebView *)webView windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject;
{
	[windowScriptObject setValue:self forKey:@"phonegap"];
}

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)message;
{
	if (![message isKindOfClass:[NSDictionary class]]) return;
	
	//NSLog(@"js console: %@", [message description]);
	NSLog(@"js: %@:%@: %@", 
		  [[message objectForKey:@"sourceURL"] lastPathComponent],	//could be nil
		  [message objectForKey:@"lineNumber"],
		  [message objectForKey:@"message"]);
}

- (void) playSound:(NSString*)soundFile
{
    NSURL* fileUrl  = [NSURL fileURLWithPath:[phonegap_macAppDelegate pathForResource:soundFile]];
	NSLog(@"SoundFile:%@", [fileUrl description]);

	NSSound* sound = [[NSSound alloc] initWithContentsOfURL:fileUrl byReference:YES];
	[sound play];
}

#pragma mark WebScripting protocol

//------------------------------------------------------------------------------
//		• + isSelectorExcludedFromWebScript:
//------------------------------------------------------------------------------
//	loops through the list to see if the given selector is acceptable.

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
	BOOL	result = YES;
	
	int			i = 0;
	static SEL	*acceptableList = NULL;
	SEL			currentSelector;
	
	if (acceptableList == NULL && (acceptableList = calloc(256, sizeof(SEL))))	//up to 256 selectors
	{
		acceptableList[i++] = @selector(playSound:);
	}
	
	i = 0;
	while (result == YES && (currentSelector = acceptableList[i++]))
	{
		//checking for exclusions
		result = !(selector == currentSelector);
	}
	
	return result;
}

// helper so we don't have to have underscores and stuff in js to refer to the right method
+ (NSString *)webScriptNameForSelector:(SEL)aSelector;
{
	id		result = nil;
	
	if (aSelector == @selector(playSound:))
		result = @"playSound";
	
	
	return result;
}

// right now exclude all properties (eg keys) until we re-factor
+ (BOOL)isKeyExcludedFromWebScript:(const char *)name;
{
	return YES;
}



@end
