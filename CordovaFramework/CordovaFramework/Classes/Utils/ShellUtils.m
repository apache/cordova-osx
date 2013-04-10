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


#import "ShellUtils.h"
#import <Cocoa/Cocoa.h>
#import <Security/Authorization.h>

@implementation ShellUtils

+ (BOOL) restartComputer
{
	NSAppleScript* script = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to restart"];
	NSDictionary* errorInfo;
	NSAppleEventDescriptor* descriptor = [script executeAndReturnError:&errorInfo];
    
	return (descriptor != nil);
}

+ (void) quitApp
{
    [[NSApplication sharedApplication] terminate:nil];    
}

+ (NSTask*) shellTask:(NSString*)command
{
	NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
	[task setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
    [task setArguments: @[@"-c", command]];
    
    return task;
}

+ (NSString*) executeShellTask:(NSString*)command
{
    NSPipe* pipe = [NSPipe pipe];
    NSFileHandle* fileHandle = [pipe fileHandleForReading];
    
	NSTask* task = [[self class] shellTask:command];
    [task setStandardOutput:pipe];
	[task setStandardError:pipe];
    [task launch];
    
    NSData* outputData = [fileHandle readDataToEndOfFile];
    
	return [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
}

+ (oneway void) executeShellTaskAsync:(NSString*)command
{
	[[[self class] shellTask:command] launch];
    
	return;
}

@end
