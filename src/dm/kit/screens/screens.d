module dm.kit.screens.screen;

import dm.com.graphics.com_screen: ComScreen;
import dm.kit.screens.single_screen : SingleScreen;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class Screen
{
    private
    {
        ComScreen nativeScreen;
        Logger logger;
    }

    this(Logger logger, ComScreen screen)
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
