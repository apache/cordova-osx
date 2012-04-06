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


#import "WebViewDelegate.h"
#import "Sound.h"

@implementation WebViewDelegate

@synthesize sound;

- (void) webView:(WebView*)webView windowScriptObjectAvailable:(WebScriptObject*)windowScriptObject
{
	if (self.sound == nil) { self.sound = [Sound new]; }
	[windowScriptObject setValue:self.sound forKey:@"sound"];
}

/* This logs all errors from Javascript, nifty */
- (void) webView:(WebView*)webView addMessageToConsole:(NSDictionary*)message
{
	if (![message isKindOfClass:[NSDictionary class]]) { 
		return;
	}
	
	NSLog(@"JavaScript error: %@:%@: %@", 
		  [[message objectForKey:@"sourceURL"] lastPathComponent],	// could be nil
		  [message objectForKey:@"lineNumber"],
		  [message objectForKey:@"message"]);
}

#pragma mark WebScripting protocol

/* checks whether a selector is acceptable to be called from JavaScript */
+ (BOOL) isSelectorExcludedFromWebScript:(SEL)selector
{
	return YES;
}

// right now exclude all properties (eg keys)
+ (BOOL) isKeyExcludedFromWebScript:(const char*)name
{
	return YES;
}


@end
