//
//  Utils.h
//  phonegap-mac
//
//  Shazron Abdullah
//  Copyright 2010 Nitobi Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEG_EPS 0.001
#define fequal(a,b) (fabs((a) - (b)) < DEG_EPS)
#define fequalzero(a) (fabs(a) < DEG_EPS)

@class LoadingView;

@interface Utils : NSObject {
}

- (float) titleBarHeight:(NSWindow*)aWindow;
- (NSString*) pathForResource:(NSString*)resourcepath;


+ (Utils*) sharedInstance;

@end
