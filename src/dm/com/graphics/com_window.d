module dm.com.graphics.com_window;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.graphics.com_surface: ComSurface;
import dm.com.com_native_ptr: ComNativePtr;
import dm.com.destroyable : Destroyable;

/**
 * Authors: initkfs
 */
interface ComWindow : Destroyable
{
nothrow:

    ComResult initialize();
    ComResult create();
    ComResult getId(out int id);
    ComResult isShown(out bool value);
    ComResult show();
    ComResult isHidden(out bool value);
    ComResult hide();
    ComResult close();
    ComResult focusRequest();
    ComResult getPos(out int x, out int y);
    ComResult setPos(int x, int y);
    ComResult getMinimized(out bool value);
    ComResult setMinimized();
    ComResult getMaximized(out bool value);
    ComResult setMaximized();
    ComResult restore();
    ComResult setDecorated(bool isDecorated);
    ComResult getDecorated(out bool isDecorated);
    ComResult setResizable(bool isResizable);
    ComResult getResizable(out bool isResizable);
    ComResult setFullScreen(bool isFullScreen);
    ComResult getFullScreen(out bool isFullScreen);
    ComResult setOpacity(double value0to1);
    ComResult getOpacity(out double value0to1);
    ComResult getSize(out int width, out int height);
    ComResult setSize(int width, int height);
    ComResult setMaxSize(int w, int h);
    ComResult setMinSize(int w, int h);
    ComResult getTitle(out dstring title);
    ComResult setTitle(const(dchar[]) title);
    ComResult getScreenIndex(out size_t index);
    ComResult setModalFor(ComWindow parent);
    ComResult setIcon(ComSurface surf);
    ComResult nativePtr(out ComNativePtr ptr);

}
