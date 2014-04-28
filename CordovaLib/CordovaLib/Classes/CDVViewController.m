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

#import "CDVViewController.h"
#import "CDVConfigParser.h"
#import "CDVCommandDelegateImpl.h"
#import "CDVJSON.h"

@interface CDVViewController ()

@property (nonatomic, readwrite, strong) NSXMLParser* configParser;
@property (nonatomic, readwrite, strong) NSMutableDictionary* settings;
@property (nonatomic, readwrite, strong) NSMutableDictionary* pluginObjects;
@property (nonatomic, readwrite, strong) NSArray* startupPluginNames;
@property (nonatomic, readwrite, strong) NSDictionary* pluginsMap;
@property (nonatomic, readwrite, assign) BOOL loadFromString;

@end

@implementation CDVViewController

@synthesize webView;
@synthesize pluginObjects, pluginsMap, startupPluginNames;
@synthesize configParser, settings, loadFromString;
@synthesize wwwFolderName, startPage;
@synthesize commandDelegate = _commandDelegate;
@synthesize commandQueue = _commandQueue;

+ (void)registerViewController:(CDVViewController*) vc
{
    if (__CDVViewController_all_created__ == nil) __CDVViewController_all_created__ = [[NSMutableArray alloc]init];
    [__CDVViewController_all_created__ addObject:vc];
}

+ (void)unregisterViewController:(CDVViewController*) vc
{
	[__CDVViewController_all_created__ removeObject:vc];
}

+ (NSArray*)registeredViewControllers
{
    return __CDVViewController_all_created__;
}

- (void) loadRequest
{
    NSURL* appURL = nil;
    NSString* loadErr = nil;
    
    if ([self.startPage rangeOfString:@"://"].location != NSNotFound) {
        appURL = [NSURL URLWithString:self.startPage];
    } else if ([self.wwwFolderName rangeOfString:@"://"].location != NSNotFound) {
        appURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.wwwFolderName, self.startPage]];
    } else {
			
				NSString* path = self.startPage;
				NSString* opts = nil;
				NSRange r = [path rangeOfString:@"?"];
			
				//save options
				if (r.location != NSNotFound) {
					opts = [path substringFromIndex:r.location];
					path = [path substringToIndex:r.location];
				}
			
        NSString* startFilePath = [self.commandDelegate pathForResource:path];
        if (startFilePath == nil) {
            loadErr = [NSString stringWithFormat:@"ERROR: Start Page at '%@/%@' was not found.", self.wwwFolderName, self.startPage];
            NSLog(@"%@", loadErr);
            self.loadFromString = YES;
            appURL = nil;
        } else {
            appURL = [NSURL fileURLWithPath:startFilePath];
						if (opts != nil) appURL = [NSURL URLWithString:[[appURL description]stringByAppendingString:opts]];
        }
    }
    
    if (!loadErr) {
        NSURLRequest* appReq = [NSURLRequest requestWithURL:appURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
        [[self.webView mainFrame] loadRequest:appReq];
        
    } else {
        NSString* html = [NSString stringWithFormat:@"<html><body> %@ </body></html>", loadErr];
        [[self.webView mainFrame] loadHTMLString:html baseURL:nil];
    }
}

- (void) __makeFullScreen {
    NSView* contentView = [[self window]contentView];
    NSNumber* flag = [NSNumber numberWithUnsignedInt:(NSApplicationPresentationHideMenuBar|\
                                                      NSApplicationPresentationDisableAppleMenu|\
                                                      NSApplicationPresentationDisableProcessSwitching|\
                                                      NSApplicationPresentationDisableHideApplication|\
                                                      NSApplicationPresentationHideDock)];
    [contentView enterFullScreenMode:[NSScreen mainScreen] withOptions:[NSDictionary dictionaryWithObject:flag forKey:NSFullScreenModeApplicationPresentationOptions]];
}

- (void) __init
{
	[self loadSettings];
}

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self __init];
    }
    return self;
}

- (id)initWithWindowNibName:(NSString*)nibNameOrNil
{
    self = [super initWithWindowNibName:nibNameOrNil];
    if (self) {
        // Initialization code here.
        [self __init];
    }
    return self;
}

- (void) awakeFromNib
{
	//apply settings
	_commandDelegate = [[CDVCommandDelegateImpl alloc] initWithViewController:self];
	
	// make the linker happy since CDVWebViewDelegate is not referenced anywhere and would be stripped out
	// see http://stackoverflow.com/questions/1725881/unknown-class-myclass-in-interface-builder-file-error-at-runtime
	[CDVWebViewDelegate class];
	//self.webViewDelegate.viewController = self;
	
	// initialize items based on settings
	
	BOOL enableWebGL = [[self.settings objectForKey:@"EnableWebGL"] boolValue];
	WebPreferences* prefs = [self.webView preferences];
	[prefs setAutosaves:YES];
	
	// Note that this preference may not be Mac App Store safe
	if (enableWebGL) {
		[prefs setWebGLEnabled:YES];
	}
	
	// ensure that local storage is enable and paths are correct
	NSString* webStoragePath = [self.settings valueForKey:@"OSXLocalStoragePath"];
	if (webStoragePath == nil) {
		NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
		NSFileManager* fileManager = [[NSFileManager alloc] init];
		NSError* err = nil;
		NSURL* dir = [fileManager URLForDirectory:NSApplicationSupportDirectory
																		 inDomain:NSUserDomainMask
														appropriateForURL:nil
																			 create:YES
																				error:&err];
		if (err) {
			NSLog(@"error finding app support directory %@", err);
			webStoragePath = [NSString stringWithFormat:@"~/Library/Application Support/%@", appBundleID];
		} else {
			NSURL* folder = [[NSURL alloc] initFileURLWithPath:[dir path] isDirectory:YES];
			NSURL* storageURL = [NSURL URLWithString:appBundleID relativeToURL:folder];
			webStoragePath = storageURL.path;
		}
	}
	[prefs _setLocalStorageDatabasePath:webStoragePath];
	[prefs setLocalStorageEnabled:YES];
	NSLog(@"WebStoragePath is '%@', modify in config.xml.", webStoragePath);
	[self.webView setPreferences:prefs];
	
	BOOL enableDebugMode = [[NSUserDefaults standardUserDefaults ]boolForKey:@"EnableDebugMode"];
	
	BOOL kioskMode = [[self.settings objectForKey:@"KioskMode"] boolValue];
	
	// debugging mode
	if (enableDebugMode && kioskMode == FALSE) {
		[[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"WebKitDeveloperExtras"];
		[[NSUserDefaults standardUserDefaults]setInteger:1 forKey:@"IncludeDebugMenu"];
	} else {
		[[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"WebKitDeveloperExtras"];
		[[NSUserDefaults standardUserDefaults]setInteger:0  forKey:@"IncludeDebugMenu"];
	}
	
	// usefull for touchscreens
	BOOL hideCursor = [[self.settings objectForKey:@"HideCursor"] boolValue];
	
	if (hideCursor) {
		[NSCursor hide];
	}
	
	if (kioskMode) {
		[self performSelector:@selector(__makeFullScreen) withObject:nil afterDelay:0.0];
	}
	
	for (NSString* pluginName in self.startupPluginNames) {
		[self getCommandInstance:pluginName];
	}
}

- (void)loadSettings
{
    CDVConfigParser* delegate = [[CDVConfigParser alloc] init];
    
    // read from config.xml in the app bundle
    NSString* path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"xml"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSAssert(NO, @"ERROR: config.xml does not exist.");
        return;
    }
    
    NSURL* url = [NSURL fileURLWithPath:path];
    
    configParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    if (configParser == nil) {
        NSLog(@"Failed to initialize XML parser.");
        return;
    }
    [configParser setDelegate:((id < NSXMLParserDelegate >)delegate)];
    [configParser parse];
    
    // Get the plugin dictionary, whitelist and settings from the delegate.
    self.pluginsMap = delegate.pluginsDict;
    self.startupPluginNames = delegate.startupPluginNames;
    self.settings = delegate.settings;
    
    // And the start folder/page.
    self.wwwFolderName = @"www";
    self.startPage = delegate.startPage;
    if (self.startPage == nil) {
        self.startPage = @"index.html";
    }
    
    // Initialize the plugin objects dict.
    self.pluginObjects = [[NSMutableDictionary alloc] initWithCapacity:20];
}

- (void)registerPlugin:(CDVPlugin*)plugin withClassName:(NSString*)className
{
    if ([plugin respondsToSelector:@selector(setViewController:)]) {
        [plugin setViewController:self];
    }
    
    if ([plugin respondsToSelector:@selector(setCommandDelegate:)]) {
        [plugin setCommandDelegate:_commandDelegate];
    }
    
    [self.pluginObjects setObject:plugin forKey:className];
    [plugin pluginInitialize];
}

- (void)registerPlugin:(CDVPlugin*)plugin withPluginName:(NSString*)pluginName
{
    if ([plugin respondsToSelector:@selector(setViewController:)]) {
        [plugin setViewController:self];
    }
    
    if ([plugin respondsToSelector:@selector(setCommandDelegate:)]) {
        [plugin setCommandDelegate:_commandDelegate];
    }
    
    NSString* className = NSStringFromClass([plugin class]);
    [self.pluginObjects setObject:plugin forKey:className];
    [self.pluginsMap setValue:className forKey:[pluginName lowercaseString]];
    [plugin pluginInitialize];
}

/**
 Returns an instance of a CordovaCommand object, based on its name.  If one exists already, it is returned.
 */
- (id)getCommandInstance:(NSString*)pluginName
{
    // first, we try to find the pluginName in the pluginsMap
    // (acts as a whitelist as well) if it does not exist, we return nil
    // NOTE: plugin names are matched as lowercase to avoid problems - however, a
    // possible issue is there can be duplicates possible if you had:
    // "org.apache.cordova.Foo" and "org.apache.cordova.foo" - only the lower-cased entry will match
    NSString* className = [self.pluginsMap objectForKey:[pluginName lowercaseString]];
    
    if (className == nil) {
        return nil;
    }
    
    id obj = [self.pluginObjects objectForKey:className];
    if (!obj) {
        obj = [[NSClassFromString (className)alloc] initWithWebView:webView];
        
        if (obj != nil) {
            [self registerPlugin:obj withClassName:className];
        } else {
            NSLog(@"CDVPlugin class %@ (pluginName: %@) does not exist.", className, pluginName);
        }
    }
    return obj;
}

- (void)handleWindowMessage:(id) data {
}

- (void)postWindowMessage:(id) data {
	id win = [self.webView windowScriptObject];
	if ([data isKindOfClass:[NSString class]]) {
		//set a dummy variable we use for the post
		[win setValue:data forKey:@"_saGF11231DDsmsg_"];
	} else {
		[win setValue:[data JSONString] forKey:@"_saGF11231DDsmsg_"];
	}
	NSString* js = @"try{window.postMessage(_saGF11231DDsmsg_,\"*\");}catch(e){};delete _saGF11231DDsmsg_;";
	[win evaluateWebScript:js];
}

- (CDVViewController*) makeViewController
{
	CDVViewController* vctr = [[CDVViewController alloc]initWithWindowNibName:@"DocumentViewController"];
	return vctr;
}

- (IBAction)newDocument:(id)sender
{
    CDVViewController* vctr = [self makeViewController];
    [vctr window];
    [vctr loadRequest];
    
    //we need to retain the controllers, otherwise they are going to be released
    [CDVViewController registerViewController:vctr];
}

- (void) windowDidResize:(NSNotification*)notification
{
}

- (void) windowWillClose:(NSNotification*)notification
{
    [CDVViewController unregisterViewController:self];
}

- (void)dealloc
{
	self.contentView = nil;
	self.webView = nil;
	self.webViewDelegate = nil;
}

@end
