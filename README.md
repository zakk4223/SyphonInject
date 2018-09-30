SyphonInject
============

****SyphonInject NO LONGER WORKS IN macOS 10.14 (Mojave). Apple closed up the loophole that allows scripting additions in global directories to load into any process. Trying to inject into any process will silently fail. It will work if SIP is disabled, but that's a terrible idea and I'm not going to suggest or help anyone do that****


****BINARIES HERE**** http://krylon.rsdio.com/zakk/syphoninject/

Syphonize an application at runtime


Ever wished that a random opengl application would serve its frames via Syphon? Well, now you can make that happen!

What is this?


SyphonInject is a OSX utility that uses Scripting Additions or mach_inject, mach_override and JRSwizzle to insert a Syphon 
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

First: Install the pkg. This installs the SyphonInject application and the Scripting Addition bundle. The Scripting Addition
is installed into /Library/ScriptingAdditions

Once this is done launch SyphonInject. You'll see a list of processes, select the one (or multiple..) you want and click the
"Inject" button. That's it.

The syphon server will start up as soon as you inject the code into the process. Ok, technically it starts on the next
call to the overridden functions, but that's close enough.

If the process doesn't do any OpenGL rendering nothing will happen.

How do I stop it?

Quit the application you injected the server into. Once it is injected it cannot be stopped.


Todo:


 
1) If not using scripting additions, figure out all the crazy SMJobBless stuff that is required to run things with
   elevated privs. I think it requires an actual Apple Dev account, though. And appears to be a pain in the ass.
   
2) Figure out if there's a way to get non-OpenGL applications into this. I have some ideas...

3) Limit it to specific windows if the application has multiple ones.

4) Ability Force a width/height if you know it gets it wrong all the time for a particular application.

5) Framerate limiter/don't send if no clients are connected.

6) What secrets does WindowServer hold....?




