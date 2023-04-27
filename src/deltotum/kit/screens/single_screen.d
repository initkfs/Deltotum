module deltotum.kit.screens.single_screen;

import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.kit.screens.screen_mode : ScreenMode;
import deltotum.kit.screens.screen_orientation : ScreenOrientation;

import std.logger.core : Logger;

//TODO remove bindbc
import deltotum.sys.sdl.sdl_screen : SDLScreen;

/**
 * Authors: initkfs
 */
struct SingleScreen
{
    const size_t index;

    private
    {
        SDLScreen nativeScreen;
        Logger logger;
    }

    this(Logger logger, SDLScreen screen, size_t index = 0)
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
        import deltotum.sys.sdl.sdl_screen : SDLScreenMode, SDLDpi;

        SDLScreenMode m;
        if (const err = nativeScreen.getMode(cast(int) index, m))
        {
            logger.errorf("Error getting screen mode, index: %s: %s", index, err.toString);
        }
        SDLDpi dpi;
        if (const err = nativeScreen.getDPI(cast(int) index, dpi))
        {
            logger.errorf("Error getting screen dpi, index %s: %s", index, err.toString);
        }
        return ScreenMode(m.width, m.height, m.rateHz, dpi.diagonalDPI, dpi.horizontalDPI, dpi
                .verticalDPI);
    }

    ScreenOrientation orientation()
    {
        import deltotum.sys.sdl.sdl_screen : SDLScreenOrientation;

        SDLScreenOrientation result;
        if (const err = nativeScreen.getOrientation(cast(int) index, result))
        {
            logger.errorf("Error getting screen orientation with index %s: %s", index, err.toString);
        }
        final switch (result) with (SDLScreenOrientation)
        {
        case none:
            return ScreenOrientation.none;
        case landscape:
            return ScreenOrientation.landscape;
        case landscapeFlipped:
            return ScreenOrientation.landscapeFlipped;
        case portrait:
            return ScreenOrientation.portrait;
        case portraitFlipped:
            return ScreenOrientation.portraitFlipped;
        }
    }

}
