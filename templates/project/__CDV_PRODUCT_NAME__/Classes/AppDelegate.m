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
#import "MainViewController.h"

@implementation AppDelegate


@synthesize window;

- (id)init
{
	self = [super init];
  if (self) {
    //register URL handler
    //actual URL scheme to handle needs to be defined in the info.plist file
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleOpenLocationAppleEvent:withReplyEvent:)forEventClass:'GURL' andEventID:'GURL'];
  }
      
	return self;
}

- (void) applicationDidStartLaunching:(NSNotification*) aNotification 
{
}

- (void) applicationWillFinishLaunching:(NSNotification*)aNotification
{
}

- (void) applicationDidFinishLaunching:(NSNotification*)aNotification 
{
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
  //you can create your WindowController here and pass it the filename
  return FALSE;
}

- (BOOL)application:(NSApplication*)theApplication openLocation:(NSURL*)url
{
	return FALSE;
}

//GURL event handler
- (void) handleOpenLocationAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)reply {
	// get the descriptor
	NSAppleEventDescriptor *directObjectDescriptor = [event paramDescriptorForKeyword:keyDirectObject];
	if (directObjectDescriptor) {
		// get the complete string
		NSString *urlString = [directObjectDescriptor stringValue];
		if (urlString) {
			// get the complete URL
			NSURL *objectURL = [[NSURL alloc] initWithString:urlString];
			if (objectURL) {
				[self application:NSApp openLocation:objectURL];
			}
		}
	}
}

@end
