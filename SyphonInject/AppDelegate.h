//
//  AppDelegate.h
//  SyphonInject
//
//  Created by Zakk on 7/26/13.
//  Copyright (c) 2013 Zakk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SyphonInjectController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet SyphonInjectController* syphoninjectcontroller;

@property (assign) IBOutlet NSWindow *window;

@end
