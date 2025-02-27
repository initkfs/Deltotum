module api.dm.com.graphics.com_window;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.destroyable : Destroyable;
import api.dm.com.graphics.com_screen : ComScreenId;

import api.math.geom2.rect2 : Rect2d;

alias ComWindowId = int;

enum ComWindowTheme
{
    none,
    dark,
    light
}

/**
 * Authors: initkfs
 */
interface ComWindow : Destroyable
{
nothrow:

    ComResult create();
    ComResult create(int width, int height, ulong flags);
    ComResult create(ComNativePtr newPtr);

    ComResult show();
    ComResult hide();
    ComResult close();
    ComResult restore();

    ComResult setParent(ComWindow parent);
    ComResult setModal(bool value);

    ComResult isShown(out bool value);
    ComResult isHidden(out bool value);

    ComResult getId(out ComWindowId id);
    ComResult getScreenId(out ComScreenId index);

    ComResult focusRequest();

    ComResult getFlags(out ulong flags);

    ComResult getPos(out int x, out int y);
    ComResult setPos(int x, int y);

    ComResult getMinimized(out bool value);
    ComResult setMinimized();

    ComResult getMaximized(out bool value);
    ComResult setMaximized();

    ComResult setDecorated(bool isDecorated);
    ComResult getDecorated(out bool isDecorated);

    ComResult setResizable(bool isResizable);
    ComResult getResizable(out bool isResizable);

    ComResult setFullScreen(bool isFullScreen);
    ComResult getFullScreen(out bool isFullScreen);

    ComResult setOpacity(double value0to1);
    ComResult getOpacity(out double value0to1);

    ComResult getSize(out int width, out int height);
    ComResult getWidth(out int width);
    ComResult getHeight(out int height);
    ComResult setSize(int width, int height);

    ComResult getSafeBounds(out Rect2d bounds);

    ComResult setMaxSize(int w, int h);
    ComResult setMinSize(int w, int h);

    ComResult getTitle(out dstring title);
    ComResult setTitle(const(dchar[]) title);

    ComResult setIcon(ComSurface surf);

    //https://wiki.libsdl.org/SDL3/BestKeyboardPractices
    ComResult setTextInputStart();
    ComResult setTextInputStop();
    ComResult setTextInputArea(Rect2d area, int cursor);
    ComResult getIsTextInputActive(out bool isActive);

    ComResult getSystemTheme(out ComWindowTheme theme);

    ComResult nativePtr(out ComNativePtr ptr);

}
