module deltotum.com.windows.com_window;

import deltotum.com.results.platform_result : PlatformResult;
import deltotum.com.objects.destroyable: Destroyable;

/**
 * Authors: initkfs
 */
interface ComWindow : Destroyable
{

    PlatformResult initialize() @nogc nothrow;
    PlatformResult create() nothrow;

    PlatformResult obtainId(out int id) @nogc nothrow;

    PlatformResult show() @nogc nothrow;
    PlatformResult hide() @nogc nothrow;
    PlatformResult close() @nogc nothrow;
    PlatformResult focusRequest() @nogc nothrow;

    PlatformResult getPos(out int x, out int y) @nogc nothrow;
    PlatformResult setPos(int x, int y) @nogc nothrow;

    PlatformResult minimize() @nogc nothrow;
    PlatformResult maximize() @nogc nothrow;
    PlatformResult restore() @nogc nothrow;

    PlatformResult setDecorated(bool isDecorated) @nogc nothrow;
    PlatformResult setResizable(bool isResizable) @nogc nothrow;
    PlatformResult setFullScreen(bool isFullScreen) @nogc nothrow;
    PlatformResult setOpacity(double value0to1) @nogc nothrow;

    PlatformResult getSize(out int width, out int height) @nogc nothrow;
    PlatformResult setSize(int width, int height) @nogc nothrow;

    PlatformResult setMaxSize(int w, int h) @nogc nothrow;
    PlatformResult setMinSize(int w, int h) @nogc nothrow;

    PlatformResult getTitle(ref const(char)[] title) @nogc nothrow;
    PlatformResult setTitle(const(char)* title) @nogc nothrow;

    PlatformResult getScreenIndex(out size_t screenIndex) @nogc nothrow;

    PlatformResult nativePtr(out void* ptr) @nogc nothrow;

}
