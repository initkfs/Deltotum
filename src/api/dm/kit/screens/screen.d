module api.dm.kit.screens.screen;

import api.dm.com.graphics.com_screen : ComScreen;
import api.dm.kit.screens.single_screen : SingleScreen;

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

    size_t count()
    {
        size_t screenCount;
        if (const err = nativeScreen.getCount(screenCount))
        {
            logger.error(err.toString);
            return 0;
        }
        return screenCount;
    }

    SingleScreen first()
    {
        auto screenCount = count;
        if(screenCount == 0){
            //TODO Nullable!?
            throw new Exception("Not found screen");
        }
        return SingleScreen(logger, nativeScreen, 0);
    }

    SingleScreen[] all()
    {
        auto screenCount = count;
        SingleScreen[] screens;
        foreach (i; 0 .. screenCount)
        {
            screens ~= SingleScreen(logger, nativeScreen, i);
        }

        return screens;
    }

}
