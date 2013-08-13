SyphonInject
============

Syphonize an application at runtime


Ever wished that a random opengl application would serve its frames via Syphon? Well, now you can make that happen!

What is this?


SyphonInject is a OSX command line utility that uses mach_inject, mach_override and JRSwizzle to insert a Syphon 
server into a running process. It'll only work for applications that are doing OpenGL based rendering.


How does it work?

I'll leave the details of mach_inject/override and ObjC metthod Swizzling to your own research. There lies dragons etc.
Once the SyphonInject bundle is injected into the target process it takes over all calls to CGLRefreshDrawable and 
-[NSOpenGLContext flushBuffer]. When those are called it copies the OpenGL front buffer to a syphon server and publishes
the frame. The Injector prefers to use NSOpenGLContext, as there's some stuff related to fullscreen applications that
don't work as well from CGLRefreshDrawable (related to the size of the window).

What'll break?

Hopefully nothing. That said, you're injecting random code into some process. Things could blow up, the NSA could show
up. Who knows.

If the application has two OpenGL windows or for some reason maintains multiple contexts things are going to go all
sideways quickly. It handles the case where an application uses a different context when fullscreen vs windowed 
(only one thing I've tested so far did that) so if the contexts are actually different it's just going to keep swapping
between them constantly. That probably isn't what you want. 

How do I use it?

First: ignore the GUI application it builds. It doesn't do anything useful. Inside the application bundle is a command
line utility called SyphonInjectCmd. Use that.

YOU MUST BE ROOT (or in the procmod group) to mach_inject other processes. Just run the utility via 'sudo' and it'll
work just fine. You also have to match the architecture of the target process. Instead of bothering to figure it out
just try both. If you need to run the command as a 32-bit process just do 'sudo arch -i386 ./SyphonInjectCmd [pid]'.
The command only takes one argument; the process id of the process you want to inject.

The syphon server will start up as soon as you inject the code into the process. Ok, technically it starts on the next
call to the overridden functions, but that's close enough.

If the process doesn't do any OpenGL rendering nothing will happen.

How do I stop it?

Quit the application you injected the server into. Once it is injected it cannot be stopped.


Todo:

1) Considering using Scripting Additions to inject the SyphonPayload. The advantages here are that it doesn't require
   root privileges and it means you can just start the Syphon server via an applescript command. Possibly you'll be able
   to stop it too, but I'm not sure. The downside is that not all apps support AppleScript/Scripting Additions, but I'm
   not sure how many do or don't. 
 
2) If not using scripting additions, figure out all the crazy SMJobBless stuff that is required to run things with
   elevated privs. I think it requires an actual Apple Dev account, though. And appears to be a pain in the ass.
   
3) Figure out if there's a way to get non-OpenGL applications into this. I have some ideas...

4) Limit it to specific windows if the application has multiple ones.

5) Ability Force a width/height if you know it gets it wrong all the time for a particular application.

6) Framerate limiter/don't send if no clients are connected.

7) What secrets does WindowServer hold....?




