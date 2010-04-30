//
//  phonegap_macAppDelegate.h
//  phonegap-mac
//
//  Created by shazron on 10-04-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ContentView.h"

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface phonegap_macAppDelegate : NSObject  {
#else
@interface phonegap_macAppDelegate : NSObject <NSApplicationDelegate> {
#endif
	IBOutlet NSWindow* window;
	IBOutlet ContentView* contentView;
}

@property (nonatomic, retain) NSWindow* window;
@property (nonatomic, retain) ContentView* contentView;

@end
