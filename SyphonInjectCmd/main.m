//
//  main.m
//  SyphonInjectCmd
//
//  Created by Zakk on 7/26/13.
//  Copyright (c) 2013 Zakk. All rights reserved.
//

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

