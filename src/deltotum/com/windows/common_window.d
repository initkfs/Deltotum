module deltotum.com.windows.common_window;

import deltotum.com.results.platform_result : PlatformResult;

/**
 * Authors: initkfs
 */
interface CommonWindow
{

    PlatformResult initialize() nothrow;
    PlatformResult create() nothrow;

    PlatformResult obtainId(out int id) nothrow;

    PlatformResult show() nothrow;
    PlatformResult hide() nothrow;
    PlatformResult focusRequest() nothrow;

    PlatformResult minimize() nothrow;
    PlatformResult maximize() nothrow;

    PlatformResult setDecorated(bool isDecorated) nothrow;
    PlatformResult setResizable(bool isResizable) nothrow;

    PlatformResult setOpacity(double value0to1) nothrow;

    PlatformResult inputFocus() nothrow;
    PlatformResult fullscreen() nothrow;
    void maxSize(int w, int h) nothrow;
    void minSize(int w, int h) nothrow;

}
