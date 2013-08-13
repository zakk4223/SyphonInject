//
//  SyphonInjectController.m
//  SyphonInject
//
//  Created by Zakk on 7/26/13.
//  Copyright (c) 2013 Zakk. All rights reserved.
//

#import "SyphonInjectController.h"
#import <mach_inject_bundle.h>
#import <load_bundle.h>
#import <mach-o/dyld.h>
#import <ScriptingBridge/ScriptingBridge.h>


@implementation SyphonInjectController





- (id) init
{
    if (self = [super init])
    {
    
        self.sharedWorkspace = [NSWorkspace sharedWorkspace];
        self.runningApplications = [self.sharedWorkspace runningApplications];
        [[self.sharedWorkspace notificationCenter] addObserver:self
                                           selector:@selector(appLaunched:)
                                               name:NSWorkspaceDidLaunchApplicationNotification
                                             object:self.sharedWorkspace];
        
    }
    return self;
    
    
    
    
}


-(void) appLaunched:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *bundleId = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    
    NSLog(@"BUNDLE ID %@", bundleId);
    
    
    pid_t pid = [[userInfo objectForKey:@"NSApplicationProcessIdentifier"] intValue];
    
    
    NSLog(@"PROC ID %d", pid);
    
    
    SBApplication *sbapp = [SBApplication applicationWithProcessIdentifier:pid];
    
    [sbapp setDelegate:self];
    
    
    /*
     NSString *scriptString = [[NSString alloc] initWithFormat:@"tell application \"%s\" to «event SASIinjc»", [self.injectTarget.localizedName UTF8String]];
     
     
     NSAppleScript *scriptObj = [[NSAppleScript alloc] initWithSource:scriptString];
     
     [scriptObj executeAndReturnError:nil];
     */
    
    
    //[sbapp setTimeout:10*60];
    
    //[sbapp setSendMode:kAEWaitReply];
    //[sbapp sendEvent:'ascr' id:'gdut' parameters:0];
//    [sbapp setSendMode:kAENoReply];
  //  [sbapp sendEvent:'SASI' id:'injc' parameters:0];

    
    
}
- (void)eventDidFail:(const AppleEvent *)event withError:(NSError *)error
{
        
    return;
}

- (IBAction)doInject:(id)sender
{
    
    for (NSRunningApplication *toInject in applicationArrayController.selectedObjects)
    {
        
    
        NSLog(@"WILL INJECT INTO APPLICATION %s", [toInject.localizedName UTF8String]);
        
        pid_t pid = toInject.processIdentifier;
        
        SBApplication *sbapp = [SBApplication applicationWithProcessIdentifier:pid];
        
        [sbapp setDelegate:self];
        
        
        
        
        [sbapp setTimeout:10*60];
        
        [sbapp setSendMode:kAEWaitReply];
        [sbapp sendEvent:'ascr' id:'gdut' parameters:0];
        [sbapp setSendMode:kAENoReply];
        [sbapp sendEvent:'SASI' id:'injc' parameters:0];
    }
    
}

@end
