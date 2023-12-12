module dm.kit.screens.single_screen;

import dm.math.shapes.rect2d : Rect2d;
import dm.com.graphics.com_screen : ComScreen, ScreenMode, ScreenDpi, ScreenOrientation;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
struct SingleScreen
{
    const size_t index;

    private
    {
        ComScreen nativeScreen;
        Logger logger;
    }

    this(Logger logger, ComScreen screen, size_t index = 0)
    {
        assert(screen);
        assert(logger);
        this.logger = logger;
        nativeScreen = screen;
        this.index = index;
    }

    Rect2d bounds()
    {
        int x, y, width, height;
        if (const err = nativeScreen.getBounds(cast(int) index, x, y, width, height))
        {
            logger.errorf("Error getting screen bounds with index %s: %s", index, err.toString);
        }
        return Rect2d(x, y, width, height);
    }

    string name()
    {
        const(char)* namePtr;
        if (const err = nativeScreen.getName(cast(int) index, namePtr))
        {
            logger.errorf("Error getting screen name with index %s: %s", index, err.toString);
        }
        import std.string : fromStringz;

        return namePtr.fromStringz.idup;
    }

    ScreenMode mode()
    {
        import dm.com.graphics.com_screen : ScreenMode, ScreenDpi;

        ScreenMode m;
        if (const err = nativeScreen.getMode(cast(int) index, m))
        {
            logger.errorf("Error getting screen mode, index: %s: %s", index, err.toString);
        }

        return ScreenMode(m.width, m.height, m.rateHz);
    }

    ScreenDpi dpi()
    {
        ScreenDpi dpi;
        if (const err = nativeScreen.getDPI(cast(int) index, dpi))
        {
            logger.errorf("Error getting screen dpi, index %s: %s", index, err.toString);
        }
        return dpi;
    }

    ScreenOrientation orientation()
    {
        ScreenOrientation result;
        if (const err = nativeScreen.getOrientation(cast(int) index, result))
        {
            logger.errorf("Error getting screen orientation with index %s: %s", index, err.toString);
        }
        return result;
    }

}
