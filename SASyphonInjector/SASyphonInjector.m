//
//  SASyphonInjector.m
//  SyphonInject
//
//  Created by Zakk on 7/31/13.
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

#import "SASyphonInjector.h"
#import <Cocoa/Cocoa.h>


@interface SyphonPayload: NSObject 
    
    + (void) load;
    +(void) handleFlip;
+(void) setWidth:(int)width height:(int)height;
+(void) setOffsetX:(int)x OffsetY:(int)y;
+(void) changeBuffer;



@end


static Class injectedClass;


@implementation SASyphonInjector

@end


OSErr SASIhandleChbf(const AppleEvent *ev, AppleEvent *reply, long refcon)
{
    [injectedClass changeBuffer];
}


OSErr SASIhandleOfst(const AppleEvent *ev, AppleEvent *reply, long refcon)
{
    int x = 0;
    int y = 0;
    
    AEGetParamPtr(ev, 'xofs', typeSInt32, NULL, &x, sizeof(x), NULL);
    AEGetParamPtr(ev, 'yofs', typeSInt32, NULL, &y, sizeof(y), NULL);

    [injectedClass setOffsetX:x OffsetY:y];
    return noErr;
}


OSErr SASIhandleReso(const AppleEvent *ev, AppleEvent *reply, long refcon)
{

    int width = 0;
    int height = 0;
    
    AEGetParamPtr(ev, 'wdth', typeSInt32, NULL, &width, sizeof(width), NULL);
    AEGetParamPtr(ev, 'hght', typeSInt32, NULL, &height, sizeof(height), NULL);


    [injectedClass setWidth:width height:height];
    
    
    
    return noErr;
}



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
    
    injectedClass = [SyphonPayloadBundle principalClass];
    
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