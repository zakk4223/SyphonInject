//
//  SyphonPayload.m
//  SyphonInject
//
//  Created by Zakk on 7/26/13.
//  Copyright (c) 2013 Zakk. All rights reserved.
//

#import "SyphonPayload.h"
#import "mach_override.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import "JRSwizzle.h"
#import <OpenGL/glu.h>
#import <objc/runtime.h>

extern CGLError CGLFlushDrawable(CGLContextObj);



static SyphonPayload *_instance = nil;
static SyphonServer *_syphonServer = nil;
int wait_for_nsopengl = 0;
int nsopengl_called = 0;
NSSize saved_frame_size;







typedef CGLError (*CGLFlushDrawableProc)(CGLContextObj);

CGLFlushDrawableProc orig_CGLFlushDrawable;





@interface NSOpenGLContext (NSOpenGLContextSyphon)

    -(void) flushBufferSyphon;
    


@end


@implementation NSOpenGLContext (NSOpenGLContextSyphon)

-(void) flushBufferSyphon
{

    BOOL ctx_changed = NO;
    
    CGLContextObj ctx = [self CGLContextObj];
    
    nsopengl_called = 1;
    NSSize my_size = self.view.bounds.size;
    
    int my_width = my_size.width;
    int my_height = my_size.height;
    
    if (!_syphonServer)
    {
        _syphonServer = [[SyphonServer alloc] initWithName:@"InjectedSyphonNSOGL" context:[self CGLContextObj] options:nil];
        
    }
    
    
    
    
    
    if (ctx != _syphonServer.context)
    {
        NSLog(@"CGL Context changed CTX: %p syphon %p", ctx, _syphonServer.context);
        [_syphonServer replaceCGLContext:ctx];
        //Kick it so it generates a new FBO/surface...hackhackhack
        [_syphonServer bindToDrawFrameOfSize:my_size];
        ctx_changed = YES;
        
        
    }
    
    
    
    [self flushBufferSyphon];
    
    if (ctx_changed)
    {
        return;
    }
    
    if (!NSEqualSizes(my_size, saved_frame_size))
    {
        saved_frame_size.width = my_width;
        saved_frame_size.height = my_height;

        [_syphonServer bindToDrawFrameOfSize:my_size];
        return;
    }
    
    
    
    
    GLint savedReadBuf;

    
    
    
    GLint saved_texture;
    
    glGetIntegerv(GL_READ_BUFFER, &savedReadBuf);
        
    glReadBuffer(GL_FRONT);

    SyphonImage *sImage = [_syphonServer newFrameImage];

    glGetIntegerv(GL_TEXTURE_BINDING_RECTANGLE_EXT, &saved_texture);
    
    
    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, [sImage textureName]);
    glCopyTexSubImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, 0, 0, 0,0, my_width, my_height);
    [_syphonServer bindToDrawFrameOfSize:my_size];
    [_syphonServer unbindAndPublish];
    [sImage release];
    glReadBuffer(savedReadBuf);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, saved_texture);
    
    

}
@end



CGLError CGLFlushDrawableOverride(CGLContextObj ctx)
{
    
    //Wait ten frames, if no nsopengl_called then it's probably using CGFlushDrawable directly, so go ahead and take over.
    
    
    if (wait_for_nsopengl <= 10)
    {
        wait_for_nsopengl++;
    }
    
    
    if (nsopengl_called || wait_for_nsopengl <= 10)
    {
        return orig_CGLFlushDrawable(ctx);
    }
    
    
    BOOL ctx_changed = NO;
    
    if (!_syphonServer)
    {
        _syphonServer = [[SyphonServer alloc] initWithName:@"InjectedSyphonCGL" context:ctx options:nil];
        
    }
    
    
    GLint renderBufDim[4];

    GLint savedReadBuf;
    
    glGetIntegerv(GL_VIEWPORT, renderBufDim);
    
    NSSize my_size = NSMakeSize(renderBufDim[2], renderBufDim[3]);
    
    if (ctx != _syphonServer.context)
    {
        NSLog(@"CGL Context changed CTX: %p syphon %p", ctx, _syphonServer.context);
        [_syphonServer replaceCGLContext:ctx];
        //Kick it so it generates a new FBO/surface...hackhackhack
        [_syphonServer bindToDrawFrameOfSize:my_size];
        ctx_changed = YES;
        
        
    }
   
    
    
    CGLError ret = orig_CGLFlushDrawable(ctx);
    
    
    if (ctx_changed)
    {
        return ret;
    }

    
    if (!NSEqualSizes(my_size, saved_frame_size))
    {
        saved_frame_size.width = my_size.width;
        saved_frame_size.height = my_size.height;
        
        [_syphonServer bindToDrawFrameOfSize:my_size];
        return ret;
    }

    
    
    
    glGetIntegerv(GL_READ_BUFFER, &savedReadBuf);
    

    glReadBuffer(GL_FRONT);
    
    
    
    SyphonImage *sImage = [_syphonServer newFrameImage];
    GLint saved_texture;
    
    glGetIntegerv(GL_TEXTURE_BINDING_RECTANGLE_EXT, &saved_texture);
    
    
    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, [sImage textureName]);
    glCopyTexSubImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, 0, 0, renderBufDim[0], renderBufDim[1], renderBufDim[2], renderBufDim[3]);
    
    [_syphonServer bindToDrawFrameOfSize:my_size];
    [_syphonServer unbindAndPublish];
    [sImage release];
    
    glReadBuffer(savedReadBuf);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, saved_texture);
    return ret;
    

}




@implementation SyphonPayload

+ (void)load {
    
    
    
    NSLog(@"Loading Syphon Payload");
    
    
    if (!_instance) {
        _instance = [[SyphonPayload alloc] init];
        saved_frame_size = NSMakeSize(0,0);
    }
    
    
    [[NSOpenGLContext class] jr_swizzleMethod:@selector(flushBuffer) withMethod:@selector(flushBufferSyphon) error:nil];
    
    
    NSLog(@"Loaded SyphonPayload into %d", getpid());
    void *orig_ptr = dlsym(RTLD_DEFAULT, "CGLFlushDrawable");
    mach_error_t err;
    
    
    err = mach_override_ptr((void *)orig_ptr, (void*)&CGLFlushDrawableOverride, (void **)&orig_CGLFlushDrawable);
    if (err)
    {
        NSLog(@"MACH OVERRIDE ERR %d", err);
    }
    
    
}







@end


