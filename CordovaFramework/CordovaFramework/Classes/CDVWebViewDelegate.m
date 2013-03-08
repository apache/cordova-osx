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


#import "CDVWebViewDelegate.h"
#import "CDVConsole.h"
#import "CDVBridge.h"

@implementation CDVWebViewDelegate

@synthesize console;

- (void) webView:(WebView*)webView windowScriptObjectAvailable:(WebScriptObject*)windowScriptObject
{
	if (self.console == nil) {
        self.console = [CDVConsole new];
    }
	[windowScriptObject setValue:self.console forKey:@"console"];
	
	if (self.bridge == nil) {
        self.bridge = [[CDVBridge alloc] initWithWebView:webView andViewController:self.viewController];
    }
    [windowScriptObject setValue:self.bridge forKey:@"cordovabridge"];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    id win = [sender windowScriptObject];
    NSString* nativeReady = @"try{cordova.require('cordova/channel').onNativeReady.fire();}catch(e){window._nativeReady = true;}";
    [win evaluateWebScript:nativeReady];
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

#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{	
    NSString* url = [[request URL] description];
    NSLog(@"navigating to %@", url);

    [listener use];
}


@end
