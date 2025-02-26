module api.dm.kit.screens.screen;

import api.dm.com.graphics.com_screen : ComScreenId, ComScreen;
import api.dm.com.graphics.com_screen : ComScreenId, ComScreen, ComScreenMode, ComScreenDpi, ComScreenOrientation;
import api.dm.kit.screens.single_screen : SingleScreen;

import api.math.geom2.rect2 : Rect2d;

import api.core.loggers.logging : Logging;

/**
 * Authors: initkfs
 */
class Screen
{
    protected
    {
        ComScreen nativeScreen;
        Logging logging;
    }

    this(ComScreen nativeScreen, Logging logging)
    {
        assert(nativeScreen);
        assert(logging);

        this.logging = logging;
        this.nativeScreen = nativeScreen;
    }

    SingleScreen screen(ComScreenId id)
    {
        string screenName = name(id);
        Rect2d screenBounds = bounds(id);
        ComScreenMode screenMode = mode(id);
        return SingleScreen(id, screenName, screenBounds, screenMode);
    }

    void onScreens(scope bool delegate(ComScreenId) nothrow onScreenIdIsContinue)
    {
        if (const err = nativeScreen.onScreens(onScreenIdIsContinue))
        {
            logging.logger.error(err.toString);
        }
    }

    Rect2d bounds(ComScreenId id)
    {
        int x, y, width, height;
        if (const err = nativeScreen.getBounds(id, x, y, width, height))
        {
            logging.logger.errorf("Error getting screen bounds with id %s: %s", id, err.toString);
        }
        return Rect2d(x, y, width, height);
    }

    string name(ComScreenId id)
    {
        string screenName;
        if (const err = nativeScreen.getName(id, screenName))
        {
            logging.logger.errorf("Error getting screen name with id %s: %s", id, err.toString);
        }
        return screenName;
    }

    ComScreenMode mode(ComScreenId id)
    {
        import api.dm.com.graphics.com_screen : ComScreenMode, ComScreenDpi;

        ComScreenMode mode;
        if (const err = nativeScreen.getMode(id, mode))
        {
            logging.logger.errorf("Error getting screen mode with id %s: %s", id, err.toString);
        }

        return mode;
    }

    ComScreenOrientation orientation(ComScreenId id)
    {
        ComScreenOrientation result;
        if (const err = nativeScreen.getOrientation(id, result))
        {
            logging.logger.errorf("Error getting screen orientation with index %s: %s", id, err
                    .toString);
        }
        return result;
    }
}
