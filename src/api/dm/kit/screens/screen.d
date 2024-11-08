module api.dm.kit.screens.screen;

import api.dm.com.graphics.com_screen : ComScreen;
import api.dm.kit.screens.single_screen : SingleScreen;

import api.core.loggers.logging : Logging;

/**
 * Authors: initkfs
 */
class Screen
{
    private
    {
        ComScreen nativeScreen;
        Logging logging;
    }

    this(Logging logging, ComScreen screen)
    {
        assert(screen);
        assert(logging);
        nativeScreen = screen;
        this.logging = logging;
    }

    size_t count()
    {
        size_t screenCount;
        if (const err = nativeScreen.getCount(screenCount))
        {
            logging.logger.error(err.toString);
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
        return SingleScreen(logging, nativeScreen, 0);
    }

    SingleScreen[] all()
    {
        auto screenCount = count;
        SingleScreen[] screens;
        foreach (i; 0 .. screenCount)
        {
            screens ~= SingleScreen(logging, nativeScreen, i);
        }

        return screens;
    }

}
