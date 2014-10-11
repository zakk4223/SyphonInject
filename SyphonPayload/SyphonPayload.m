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







typedef CGLError (*CGLFlushDrawableProc)(CGLContextObj);

CGLFlushDrawableProc orig_CGLFlushDrawable;


void __SyphonInjectorPublish(CGLContextObj for_ctx, NSSize texture_size)
{
    
    
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
    
    
    
    
    GLint saved_texture;
    
    glGetIntegerv(GL_READ_BUFFER, &savedReadBuf);
    
    glReadBuffer(GL_FRONT);
    
    
    glGetIntegerv(GL_TEXTURE_BINDING_RECTANGLE_ARB, &saved_texture);
    
    
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, [sImage textureName]);
    glCopyTexSubImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, 0, 0, 0,0, texture_size.width, texture_size.height);

    [_syphonServer bindToDrawFrameOfSize:texture_size];
    [_syphonServer unbindAndPublish];

    [sImage release];
    glReadBuffer(savedReadBuf);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, saved_texture);
    
    

    
}

void SyphonDrawMouse()
{
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);

    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glEnable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    
    glBegin(GL_QUADS);
    glColor3f(1.0f, 0.0f, 0.0f);
    glVertex2f(320.0f, 200.0f);     // Define vertices in counter-clockwise (CCW) order
    glVertex2f(320.0f-20.0f, 200.0f);     //  so that the normal (front-face) is facing you
    glVertex2f(320.0f-20.0f, 200.0f+20.0f);
    glVertex2f(320.0f, 200.0f+20.0f);
    glEnd();
    //glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    
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
    NSSize my_size = self.view.bounds.size;
    [self flushBufferSyphon];
    
    __SyphonInjectorPublish(ctx, my_size);
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
    
    glGetIntegerv(GL_VIEWPORT, renderBufDim);
    
    NSSize my_size = NSMakeSize(renderBufDim[2], renderBufDim[3]);
    
    CGLError ret = orig_CGLFlushDrawable(ctx);

    __SyphonInjectorPublish(ctx, my_size);
    
    return ret;
    

}




@implementation SyphonPayload

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


