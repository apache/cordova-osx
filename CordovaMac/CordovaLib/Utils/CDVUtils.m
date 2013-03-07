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

#import "CDVUtils.h"
#import "Constants.h"

@implementation CDVUtils

+ (float) titleBarHeight:(NSWindow*)aWindow
{
    NSRect frame = [aWindow frame];
    NSRect contentRect = [NSWindow contentRectForFrameRect: frame
												 styleMask: NSTitledWindowMask];
	
    return (frame.size.height - contentRect.size.height);
}

+ (NSString*) pathForResource:(NSString*)resourcepath
{
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSMutableArray *directoryParts = [NSMutableArray arrayWithArray:[resourcepath componentsSeparatedByString:@"/"]];
    NSString       *filename       = [directoryParts lastObject];
    [directoryParts removeLastObject];
	
    NSString *directoryStr = [NSString stringWithFormat:@"%@/%@", kCDVStartFolder, [directoryParts componentsJoinedByString:@"/"]];
    return [mainBundle pathForResource:filename
								ofType:@""
						   inDirectory:directoryStr];
}

@end
