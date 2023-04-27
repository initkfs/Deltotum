module deltotum.kit.screens.screen;

//TODO remove bindbc
import deltotum.sys.sdl.sdl_screen : SDLScreen;
import deltotum.kit.screens.single_screen : SingleScreen;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class Screen
{
    private
    {
        SDLScreen nativeScreen;
        Logger logger;
    }

    this(Logger logger, SDLScreen screen)
    {
        assert(screen);
        assert(logger);
        nativeScreen = screen;
        this.logger = logger;
    }

    SingleScreen[] all()
    {
        size_t screenCount;
        if (const err = nativeScreen.getCount(screenCount))
        {
            logger.error(err.toString);
        }

        SingleScreen[] screens;
        foreach (i; 0 .. screenCount)
        {
            screens ~= SingleScreen(logger, nativeScreen, i);
        }

        return screens;
    }

}
