//
//  SyphonInjectController.m
//  SyphonInject
//
//  Created by Zakk on 7/26/13.
/*
 The MIT License (MIT)
 Copyright (c) 2014, Zachary Girouard (zakk@rsdio.com)
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/


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
    
        self.applicationPredicate = [NSPredicate predicateWithFormat:@"activationPolicy = %@", @(NSApplicationActivationPolicyRegular)];
        
        
        self.sharedWorkspace = [NSWorkspace sharedWorkspace];
        
    }
    return self;
    
    
    
    
}






- (void)eventDidFail:(const AppleEvent *)event withError:(NSError *)error
{
        
    return;
}


- (IBAction)doFastToggle:(id)sender
{
    
    for (NSRunningApplication *toInject in applicationArrayController.selectedObjects)
    {
        
        
        
        pid_t pid = toInject.processIdentifier;
        
        SBApplication *sbapp = [SBApplication applicationWithProcessIdentifier:pid];
        
        [sbapp setDelegate:self];
        
        
        
        
        [sbapp setTimeout:10*60];
        
        [sbapp setSendMode:kAENoReply];
        [sbapp sendEvent:'SASI' id:'fast' parameters:0];
        
    }
}

- (IBAction)doChangeDimensions:(id)sender
{
    
    for (NSRunningApplication *toInject in applicationArrayController.selectedObjects)
    {
        
        
        
        pid_t pid = toInject.processIdentifier;
        
        SBApplication *sbapp = [SBApplication applicationWithProcessIdentifier:pid];
        
        [sbapp setDelegate:self];
        
        
        
        
        [sbapp setTimeout:10*60];
        
        [sbapp setSendMode:kAENoReply];
        [sbapp sendEvent:'SASI' id:'ofst' parameters:'xofs', @(self.x_offset), 'yofs', @(self.y_offset), 0];
        [sbapp sendEvent:'SASI' id:'reso' parameters:'wdth', @(self.width), 'hght', @(self.height), 0];
        
     }

    
}

- (IBAction)doChangeBuffer:(id)sender
{
    
    for (NSRunningApplication *toInject in applicationArrayController.selectedObjects)
    {
        
        
        
        pid_t pid = toInject.processIdentifier;
        
        SBApplication *sbapp = [SBApplication applicationWithProcessIdentifier:pid];
        
        [sbapp setDelegate:self];
        
        
        
        
        [sbapp setTimeout:10*60];
        
        [sbapp setSendMode:kAENoReply];
        [sbapp sendEvent:'SASI' id:'chbf' parameters:0];
    }
}

- (IBAction)doInject:(id)sender
{
    
    for (NSRunningApplication *toInject in applicationArrayController.selectedObjects)
    {
        
    
        
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
