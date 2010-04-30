//
//  WebViewDelegate.h
//  phonegap-mac
//
//  Created by shazron on 10-04-30.
//  Copyright 2010 Nitobi Software Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class Sound;

@interface WebViewDelegate : NSObject {
	Sound* sound;
}

@property (nonatomic, retain) Sound* sound;

@end
