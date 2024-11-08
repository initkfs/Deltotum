module api.dm.kit.screens.screen;

import api.dm.com.graphics.com_screen : ComScreen;
import api.dm.kit.screens.single_screen : SingleScreen;

import api.core.loggers.loggers : Logging;

/**
 * Authors: initkfs
 */
class Screen
{
    private
    {
        ComScreen nativeScreen;
        Logging loggers;
    }

    this(Logging loggers, ComScreen screen)
    {
        assert(screen);
        assert(loggers);
        nativeScreen = screen;
        this.loggers = loggers;
    }

    size_t count()
    {
        size_t screenCount;
        if (const err = nativeScreen.getCount(screenCount))
        {
            loggers.logger.error(err.toString);
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
        return SingleScreen(loggers, nativeScreen, 0);
    }

    SingleScreen[] all()
    {
        auto screenCount = count;
        SingleScreen[] screens;
        foreach (i; 0 .. screenCount)
        {
            screens ~= SingleScreen(loggers, nativeScreen, i);
        }

        return screens;
    }

}
