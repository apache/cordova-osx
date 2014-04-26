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

#import <SenTestingKit/SenTestingKit.h>

#import "CDVWebViewTest.h"
#import "CDVViewController.h"
#import "AppDelegate.h"



@interface CDVStartPageTest : CDVWebViewTest
@end

@implementation CDVStartPageTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDefaultStartPage
{
    [self viewController];
    NSString* geHREF = @"window.location.href";
    NSString* href = [self.webView stringByEvaluatingJavaScriptFromString:geHREF];
    STAssertTrue([href hasSuffix:@"index.html"], @"href should point to index.html");
}


// currently fails

//- (void)testParametersInStartPage
//{
//    self.startPage = @"index.html?delta=true";
//    [self reloadWebView];
//    NSString* geHREF = @"window.location.href";
//    NSString* href = [self.webView stringByEvaluatingJavaScriptFromString:geHREF];
//    STAssertTrue([href hasSuffix:@"index.html?delta=true"], @"href should point to index.html?delta=true");
//}

@end
