//
//  main.m
//  SyphonInjectCmd
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
#import <mach_inject_bundle.h>


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Command Line Injector Go!");
        char *pid_arg = argv[1];
        int inject_pid = 0;
        
        if (pid_arg)
        {
            inject_pid = atoi(pid_arg);
        }
        
        if (inject_pid > 0)
        {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"SyphonPayload" ofType:@"bundle"];
            
            mach_error_t err;
            
            NSLog(@"INJECTING INTO %d", inject_pid);
            
            err = mach_inject_bundle_pid([bundlePath fileSystemRepresentation], inject_pid);
            
            if (err == err_none) {
                NSLog(@"Inject successful!");
            } else {
                NSLog(@"Inject error: %d", err);
            }

        
        }
    }
    return 0;
}

