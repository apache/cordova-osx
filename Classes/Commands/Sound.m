//
//  Sound.m
//  phonegap-mac
//
//  Created by shazron on 10-04-30.
//  Copyright 2010 Nitobi Software Inc. All rights reserved.
//

#import "Sound.h"


@implementation Sound


- (void) play:(NSString*)file
{
	NSURL* fileUrl  = [NSURL fileURLWithPath:[[Utils sharedInstance] pathForResource:file]];
	DebugNSLog(@"Sound file:%@", [fileUrl description]);
	
	NSSound* sound = [[[NSSound alloc] initWithContentsOfURL:fileUrl byReference:YES] autorelease];
	[sound play];
}

#pragma mark WebScripting Protocol

/* checks whether a selector is acceptable to be called from JavaScript */
+ (BOOL) isSelectorExcludedFromWebScript:(SEL)selector
{
	BOOL	result = YES;
	
	int			i = 0;
	static SEL	* acceptableList = NULL;
	SEL			currentSelector;
	
	if (acceptableList == NULL && (acceptableList = calloc(256, sizeof(SEL))))	// up to 256 selectors
	{
		acceptableList[i++] = @selector(play:);
	}
	
	i = 0;
	while (result == YES && (currentSelector = acceptableList[i++]))
	{
		//checking for exclusions
		result = !(selector == currentSelector);
	}
	
	return result;
}

/* helper function so we don't have to have underscores and stuff in js to refer to the right method */
+ (NSString*) webScriptNameForSelector:(SEL)aSelector
{
	id	result = nil;
	
	if (aSelector == @selector(play:)) {
		result = @"play";
	}
	
	return result;
}

// right now exclude all properties (eg keys)
+ (BOOL) isKeyExcludedFromWebScript:(const char*)name
{
	return YES;
}

@end
