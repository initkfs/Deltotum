module deltotum.kit.screen.screens;

//TODO remove bindbc
import deltotum.sys.sdl.sdl_screen : SDLScreen;
import deltotum.kit.screen.screen : Screen;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class Screens
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

    Screen[] all()
    {
        size_t screenCount;
        if (const err = nativeScreen.getCount(screenCount))
        {
            logger.error(err.toString);
        }

        Screen[] screens;
        foreach (i; 0 .. screenCount)
        {
            screens ~= Screen(logger, nativeScreen, i);
        }

        return screens;
    }

}
