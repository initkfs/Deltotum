module deltotum.com.gui.com_window;

import deltotum.com.platforms.results.com_result : ComResult;
import deltotum.com.lifecycles.destroyable: Destroyable;

/**
 * Authors: initkfs
 */
interface ComWindow : Destroyable
{

    ComResult initialize() @nogc nothrow;
    ComResult create() nothrow;

    ComResult obtainId(out int id) @nogc nothrow;

    ComResult show() @nogc nothrow;
    ComResult hide() @nogc nothrow;
    ComResult close() @nogc nothrow;
    ComResult focusRequest() @nogc nothrow;

    ComResult getPos(out int x, out int y) @nogc nothrow;
    ComResult setPos(int x, int y) @nogc nothrow;

    ComResult minimize() @nogc nothrow;
    ComResult maximize() @nogc nothrow;
    ComResult restore() @nogc nothrow;

    ComResult setDecorated(bool isDecorated) @nogc nothrow;
    ComResult setResizable(bool isResizable) @nogc nothrow;
    ComResult setFullScreen(bool isFullScreen) @nogc nothrow;
    ComResult setOpacity(double value0to1) @nogc nothrow;

    ComResult getSize(out int width, out int height) @nogc nothrow;
    ComResult setSize(int width, int height) @nogc nothrow;

    ComResult setMaxSize(int w, int h) @nogc nothrow;
    ComResult setMinSize(int w, int h) @nogc nothrow;

    ComResult getTitle(ref const(char)[] title) @nogc nothrow;
    ComResult setTitle(const(char)* title) @nogc nothrow;

    ComResult getScreenIndex(out size_t screenIndex) @nogc nothrow;

    ComResult nativePtr(out void* ptr) @nogc nothrow;

}
