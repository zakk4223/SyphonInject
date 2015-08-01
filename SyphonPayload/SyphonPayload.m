//
//  SyphonPayload.m
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
int forced_width = 0;
int forced_height = 0;
GLint texture_x_offset = 0;
GLint texture_y_offset = 0;
GLenum capture_buffer = GL_FRONT;
int syphon_publish = 1;
IOSurfaceID surfaceID;






typedef CGLError (*CGLFlushDrawableProc)(CGLContextObj);

CGLFlushDrawableProc orig_CGLFlushDrawable;


void __SyphonInjectorPublish(CGLContextObj for_ctx, NSSize texture_size)
{
    
    GLint saved_texture;
    glGetIntegerv(GL_TEXTURE_BINDING_RECTANGLE_EXT, &saved_texture);
    
    
    if (!_syphonServer)
    {
        
        _syphonServer = [[SyphonServer alloc] initWithName:@"InjectedSyphon" context:for_ctx options:nil];
        
        
    }

    
    
    SyphonImage *sImage = [_syphonServer newFrameImage];
    

    
    
    if (for_ctx != _syphonServer.context)
    {
        NSLog(@"CGL Context changed CTX: %p syphon %p", for_ctx, _syphonServer.context);
        [_syphonServer replaceCGLContext:for_ctx];
        //Kick it so it generates a new FBO/surface...hackhackhack
        [_syphonServer bindToDrawFrameOfSize:texture_size];
        return;
    }

    if (!NSEqualSizes(texture_size, sImage.textureSize))
    {
        
        [_syphonServer bindToDrawFrameOfSize:texture_size];
        return;
    }
    
    
    
    
    GLint savedReadBuf;
    
    
    
    
    
    
    glGetIntegerv(GL_READ_BUFFER, &savedReadBuf);
    
    glReadBuffer(capture_buffer);
    
    
    
    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, [sImage textureName]);
    
    
    
    
    glCopyTexSubImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, 0,0,texture_x_offset, texture_y_offset, texture_size.width, texture_size.height);
    
    if (syphon_publish || (surfaceID != sImage.surfaceID))
    {
        [_syphonServer bindToDrawFrameOfSize:texture_size];
        [_syphonServer unbindAndPublish];
    }
    
    surfaceID = sImage.surfaceID;
    

    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, saved_texture);
    
    [sImage release];

    glReadBuffer(savedReadBuf);
    
    
    

    
}


@interface NSOpenGLContext (NSOpenGLContextSyphon)

    -(void) flushBufferSyphon;
    


@end



@implementation NSOpenGLContext (NSOpenGLContextSyphon)

-(void) flushBufferSyphon
{

    BOOL ctx_changed = NO;
    
    CGLContextObj ctx = [self CGLContextObj];
    
    nsopengl_called = 1;
    NSSize my_size;
    if (forced_height > 0 && forced_width > 0)
    {
        my_size = NSMakeSize(forced_width, forced_height);
    } else {
        GLint renderBufDim[4];
        glGetIntegerv(GL_VIEWPORT, renderBufDim);
        my_size = NSMakeSize(renderBufDim[2], renderBufDim[3]);
    }

    if (capture_buffer == GL_BACK)
    {
        __SyphonInjectorPublish(ctx, my_size);
    }

    [self flushBufferSyphon];
    
    if (capture_buffer == GL_FRONT)
    {
        __SyphonInjectorPublish(ctx, my_size);
    }
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
    GLint renderBufDim[4];

    GLint savedReadBuf;
    NSSize my_size;
    
    if (forced_height > 0 && forced_width > 0)
    {
        my_size = NSMakeSize(forced_width, forced_height);
    } else {
        glGetIntegerv(GL_VIEWPORT, renderBufDim);
    
        my_size = NSMakeSize(renderBufDim[2], renderBufDim[3]);
    }
    
    
    if (capture_buffer == GL_BACK)
    {
        __SyphonInjectorPublish(ctx, my_size);
    }
    
    CGLError ret = orig_CGLFlushDrawable(ctx);
    
    if (capture_buffer == GL_FRONT)
    {
        __SyphonInjectorPublish(ctx, my_size);
    }



    
    return ret;
    

}




@implementation SyphonPayload



+(void) toggleFast
{
    syphon_publish = !syphon_publish;
}

+(UInt32) getSurfaceID
{
    return surfaceID;
}


+(void) setOffsetX:(int)x OffsetY:(int)y
{
    texture_x_offset = x;
    texture_y_offset = y;
}


+(void) setWidth:(int)width height:(int)height
{
    
    forced_width = width;
    forced_height = height;
}

+(void) changeBuffer
{
    if (capture_buffer == GL_FRONT)
    {
        capture_buffer = GL_BACK;
    } else {
        capture_buffer = GL_FRONT;
    }
}

+(NSDictionary *)queryParams
{
    int buf_num;
    
    buf_num = (capture_buffer == GL_FRONT ? 1 : 0);
    
    return @{@"x_offset": @(texture_x_offset),
             @"y_offset": @(texture_y_offset),
             @"width":  @(forced_width),
             @"height": @(forced_height),
             @"buffer": @(buf_num),
             @"fast": @(!syphon_publish)
             };
}


+(void)handleFlip
{
    NSLog(@"FLIP IN PAYLOAD");
}


+ (void)load {
    
    
    
    NSLog(@"Loading Syphon Payload");
    
    
    if (!_instance) {
        _instance = [[SyphonPayload alloc] init];
        saved_frame_size = NSMakeSize(0,0);
    }

    NSLog(@"Loaded SyphonPayload into %d", getpid());
    [[NSOpenGLContext class] jr_swizzleMethod:@selector(flushBuffer) withMethod:@selector(flushBufferSyphon) error:nil];
    void *orig_ptr = dlsym(RTLD_DEFAULT, "CGLFlushDrawable");
    mach_error_t err;
    err = mach_override_ptr((void *)orig_ptr, (void*)&CGLFlushDrawableOverride, (void **)&orig_CGLFlushDrawable);
    if (err)
    {
            NSLog(@"MACH OVERRIDE ERR %d", err);
    }
}







@end


