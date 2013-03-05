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

#import "CDVBridge.h"
#import <WebKit/WebKit.h>
#import <AppKit/AppKit.h>
#import <Foundation/NSJSONSerialization.h>

@implementation CDVBridge

- (BOOL) isArray:(id)item
{
    id win = [self.webView windowScriptObject];
    NSNumber* result = [win callWebScriptMethod:@"__isArray__" withArguments:[NSArray arrayWithObject:item]];

    return [result boolValue];
}

- (BOOL) isDictionary:(id)item
{
    id win = [self.webView windowScriptObject];
    NSNumber* result = [win callWebScriptMethod:@"__isObject__" withArguments:[NSArray arrayWithObject:item]];
    return [result boolValue];
}

- (NSDictionary*) convertWebScriptObjectToNSDictionary:(WebScriptObject*)webScriptObject
{
    // Assumption: webScriptObject has already been tested using isDictionary:

    id win = [self.webView windowScriptObject];

    WebScriptObject* keysObject = [win callWebScriptMethod:@"__dictionaryKeys__" withArguments:[NSArray arrayWithObject:webScriptObject]];
    NSArray* keys = [self convertWebScriptObjectToNSArray:keysObject];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:[keys count]];

    NSEnumerator* enumerator = [keys objectEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        [dict setObject:[webScriptObject valueForKey:key] forKey:key];
    }
    
    return dict;
}

- (NSArray*) convertWebScriptObjectToNSArray:(WebScriptObject*)webScriptObject
{
    // Assumption: webScriptObject has already been tested using isArray:
    
    NSUInteger count = [[webScriptObject valueForKey:@"length"] integerValue];
    NSMutableArray *a = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        id item = [webScriptObject webScriptValueAtIndex:i];
        if ([item isKindOfClass:[WebScriptObject class]]) {
            if ([self isArray:item]) {
                [a addObject:[self convertWebScriptObjectToNSArray:item]];
            } else if ([self isDictionary:item]) {
                [a addObject:[self convertWebScriptObjectToNSDictionary:item]];
            };
        } else {
            [a addObject:item];
        }
    }
    
    return a;
}

- (void) registerJavaScriptHelpers
{
    NSString* isArray = [NSString stringWithFormat:@"function __isArray__(obj) { return obj.constructor == Array; };"];
    NSString* isObject = [NSString stringWithFormat:@"function __isObject__(obj) { return obj.constructor == Object; };"];
    NSString* dictionaryKeys = [NSString stringWithFormat:
                                @" \
                                function __dictionaryKeys__(obj) { \
                                    var a = []; \
                                    for (var key in obj) { \
                                        if (!obj.hasOwnProperty(key)) { \
                                            continue; \
                                        } \
                                        a.push(key); \
                                    } \
                                    return a; \
                                }"
                                ];
    
    id win = [self.webView windowScriptObject];
    [win evaluateWebScript:isArray];
    [win evaluateWebScript:isObject];
    [win evaluateWebScript:dictionaryKeys];
}

- (id) initWithWebView:(WebView *)webView
{
    if ((self = [super init]) != nil) {
        self.webView = webView;
        [self registerJavaScriptHelpers];
    }
    
    return self;
}

- (void) exec:(NSString*)callbackId withService:(NSString*)service andAction:(NSString*)action andArguments:(WebScriptObject*)webScriptObject
{
    // We are going with the iOS method of passing in a callbackId.
    // Note that we can use the JavaScriptCore C API to pass in the JavaScript function references
    // and context and call them directly, but this is done this way for possible plugin sharing
    // between iOS and OS X. Also we are going async as well.
    
    // we're just going to assume the webScriptObject passed in is an NSArray
    NSArray* arguments = [self convertWebScriptObjectToNSArray:webScriptObject];
#pragma unused(arguments)
    
	NSLog(@"TODO: flesh out exec to dispatch the commands, possibly re-use iOS code");
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
		acceptableList[i++] = @selector(exec:withService:andAction:andArguments:);
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
	
	if (aSelector == @selector(exec:withService:andAction:andArguments:)) {
		result = @"exec";
	}
	
	return result;
}

// right now exclude all properties (eg keys)
+ (BOOL) isKeyExcludedFromWebScript:(const char*)name
{
	return YES;
}

@end
