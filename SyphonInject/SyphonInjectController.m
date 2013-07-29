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



@implementation SyphonInjectController






- (IBAction)doInject:(id)sender
{
    
    
    NSLog(@" load bundle undefined symbol %d", err_load_bundle_undefined_symbol);
    
	NSLog(@"load bundle link failed %d", err_load_bundle_link_failed);
	NSLog(@"load bundle url from path %d", err_load_bundle_url_from_path);
    NSLog(@"load bundle create bundle %d",err_load_bundle_create_bundle);
	NSLog(@" load bundle package exec url %d", err_load_bundle_package_executable_url);
	NSLog(@" load bundle path from url %d", err_load_bundle_path_from_url);
    NSLog(@" load bundle NSObjectFileImageFailure %d", err_load_bundle_NSObjectFileImageFailure);
    NSLog(@" load bundle NSObjectFileImageInappropriateFile %d",err_load_bundle_NSObjectFileImageInappropriateFile);
    NSLog(@" load bundle NSObjectFileImageArch %d", err_load_bundle_NSObjectFileImageArch);
    NSLog(@" load bundle NSObjectFileImageFormat %d", err_load_bundle_NSObjectFileImageFormat);
    NSLog(@" load bundle NSObjectFileImageAccess %d",  err_load_bundle_NSObjectFileImageAccess);

    NSLog(@"WILL INJECT INTO PID %d", self.injectPID);
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"SyphonPayload" ofType:@"bundle"];
    
    mach_error_t err;
    
    NSLog(@"Bundle path: %@", bundlePath);
    err = mach_inject_bundle_pid([bundlePath fileSystemRepresentation], self.injectPID);
    
    if (err == err_none) {
        NSLog(@"Inject successful!");
    } else {
        NSLog(@"Inject error: %d", err);
    }
    
    
}

@end
