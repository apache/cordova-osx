//
//  ContentView.h
//  phonegap-mac
//
//  Created by shazron on 10-04-19.
//  Copyright 2010 Nitobi Software Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface ContentView : NSView {
	IBOutlet WebView* webView;

}

@property (retain) WebView* webView;


@end
