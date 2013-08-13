//
//  SyphonInjectController.h
//  SyphonInject
//
//  Created by Zakk on 7/26/13.
//  Copyright (c) 2013 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>

@interface SyphonInjectController : NSObject <SBApplicationDelegate>
{
    IBOutlet NSArrayController *applicationArrayController;
    
}


@property (assign) int injectPID;
@property (retain) NSArray *runningApplications;
@property (retain) NSRunningApplication *injectTarget;
@property (retain) NSWorkspace *sharedWorkspace;



- (IBAction)doInject:(id)sender;

- (void)eventDidFail:(const AppleEvent *)event withError:(NSError *)error;


@end
