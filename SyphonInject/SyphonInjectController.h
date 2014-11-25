//
//  SyphonInjectController.h
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
@property (assign) int x_offset;
@property (assign) int y_offset;
@property (assign) int width;
@property (assign) int height;



- (IBAction)doChangeBuffer:(id)sender;

- (IBAction)doInject:(id)sender;
- (IBAction)doChangeDimensions:(id)sender;

- (void)eventDidFail:(const AppleEvent *)event withError:(NSError *)error;


@end
