module api.dm.kit.screens.single_screen;

import api.math.geom2.rect2 : Rect2d;
import api.dm.com.graphics.com_screen : ComScreen, ComScreenMode, ComScreenDpi, ComScreenOrientation;

import api.core.loggers.loggers : Logging;

/**
 * Authors: initkfs
 */
struct SingleScreen
{
    const size_t index;

    private
    {
        ComScreen nativeScreen;
        Logging loggers;
    }

    this(Logging loggers, ComScreen screen, size_t index = 0)
    {
        assert(screen);
        assert(loggers);
        this.loggers = loggers;
        nativeScreen = screen;
        this.index = index;
    }

    Rect2d bounds()
    {
        int x, y, width, height;
        if (const err = nativeScreen.getBounds(cast(int) index, x, y, width, height))
        {
            loggers.logger.errorf("Error getting screen bounds with index %s: %s", index, err.toString);
        }
        return Rect2d(x, y, width, height);
    }

    dstring name()
    {
        dstring screenName;
        if (const err = nativeScreen.getName(cast(int) index, screenName))
        {
            loggers.logger.errorf("Error getting screen name with index %s: %s", index, err.toString);
        }
        import std.string : fromStringz;

        return screenName;
    }

    ComScreenMode mode()
    {
        import api.dm.com.graphics.com_screen : ComScreenMode, ComScreenDpi;

        ComScreenMode m;
        if (const err = nativeScreen.getMode(cast(int) index, m))
        {
            loggers.logger.errorf("Error getting screen mode, index: %s: %s", index, err.toString);
        }

        return ComScreenMode(m.width, m.height, m.rateHz);
    }

    ComScreenDpi dpi()
    {
        ComScreenDpi dpi;
        if (const err = nativeScreen.getDPI(cast(int) index, dpi))
        {
            loggers.logger.errorf("Error getting screen dpi, index %s: %s", index, err.toString);
        }
        return dpi;
    }

    ComScreenOrientation orientation()
    {
        ComScreenOrientation result;
        if (const err = nativeScreen.getOrientation(cast(int) index, result))
        {
            loggers.logger.errorf("Error getting screen orientation with index %s: %s", index, err.toString);
        }
        return result;
    }

}
