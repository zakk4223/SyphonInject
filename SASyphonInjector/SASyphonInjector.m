//
//  SASyphonInjector.m
//  SyphonInject
//
//  Created by Zakk on 7/31/13.
//  Copyright (c) 2013 Zakk. All rights reserved.
//

#import "SASyphonInjector.h"
#import <Cocoa/Cocoa.h>

@interface SyphonPayload: NSObject 
    
    + (void) load;

@end


@implementation SASyphonInjector

@end





OSErr SASIhandleInject(const AppleEvent *ev, AppleEvent *reply, long refcon) {


    NSLog(@"IN INJECTION START");
    NSBundle* SASIBundle = [NSBundle bundleForClass:[SASyphonInjector class]];
    NSLog(@"SASIBUNDLE %@", SASIBundle);
    NSString *SyphonPayloadPath = [SASIBundle pathForResource:@"SyphonPayload" ofType:@"bundle"];
    NSLog(@"SyphonPayload PATH %@", SyphonPayloadPath);
    NSBundle *SyphonPayloadBundle = [NSBundle bundleWithPath:SyphonPayloadPath];
    NSLog(@"Syphon Payload Bundle %@", SyphonPayloadBundle);
    
    if (!SyphonPayloadBundle)
    {
        NSLog(@"Couldn't find SyphonPayload Bundle!");
        return 2;
    }
    
    NSError *error;
    
    if (![SyphonPayloadBundle loadAndReturnError:&error]) {
        NSLog(@"Couldn't load SyphonPayload!");
        return 2;
    }
    
    /*
    SyphonPayload *injectedClass = (SyphonPayload *)[SyphonPayloadBundle principalClass];
    
    if (!injectedClass)
    {
        NSLog(@"No principal class found in bundle %@", SyphonPayloadBundle);
        return 2;
    }
    
    if ([injectedClass respondsToSelector:@selector(load)]) {
        NSLog(@"Injecting into process...");
        [[injectedClass class] load];
    } else {
        NSLog(@"Class not responding to selector load");
    }
     */
    return noErr;
    
    
}