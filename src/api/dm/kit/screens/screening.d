module api.dm.kit.screens.screening;

import api.dm.com.graphics.com_screen : ComScreenId, ComScreen;
import api.dm.com.graphics.com_screen : ComScreenId, ComScreen, ComScreenMode, ComScreenDpi, ComScreenOrientation;
import api.dm.kit.screens.single_screen : SingleScreen;

import api.math.geom2.rect2 : Rect2d;

import api.core.loggers.logging : Logging;

/**
 * Authors: initkfs
 */
class Screening
{
    protected
    {
        ComScreen comScreen;
        Logging logging;
    }

    this(ComScreen comScreen, Logging logging)
    {
        assert(comScreen);
        assert(logging);

        this.logging = logging;
        this.comScreen = comScreen;
    }

    SingleScreen screen(ComScreenId id)
    {
        string screenName = name(id);
        Rect2d screenBounds = bounds(id);
        Rect2d usable = usableBounds(id);
        ComScreenMode screenMode = mode(id);
        return SingleScreen(id, screenName, screenBounds, usable, screenMode);
    }

    void onScreens(scope bool delegate(ComScreenId) nothrow onScreenIdIsContinue)
    {
        if (const err = comScreen.onScreens(onScreenIdIsContinue))
        {
            logging.logger.error(err.toString);
        }
    }

    Rect2d bounds(ComScreenId id)
    {
        int x, y, width, height;
        if (const err = comScreen.getBounds(id, x, y, width, height))
        {
            logging.logger.errorf("Error getting screen bounds with id %s: %s", id, err.toString);
        }
        return Rect2d(x, y, width, height);
    }

    Rect2d usableBounds(ComScreenId id)
    {
        int x, y, width, height;
        if (const err = comScreen.getUsableBounds(id, x, y, width, height))
        {
            logging.logger.errorf("Error getting screen bounds with id %s: %s", id, err.toString);
        }
        return Rect2d(x, y, width, height);
    }

    string name(ComScreenId id)
    {
        string screenName;
        if (const err = comScreen.getName(id, screenName))
        {
            logging.logger.errorf("Error getting screen name with id %s: %s", id, err.toString);
        }
        return screenName;
    }

    ComScreenMode mode(ComScreenId id)
    {
        import api.dm.com.graphics.com_screen : ComScreenMode, ComScreenDpi;

        ComScreenMode mode;
        if (const err = comScreen.getMode(id, mode))
        {
            logging.logger.errorf("Error getting screen mode with id %s: %s", id, err.toString);
        }

        return mode;
    }

    ComScreenOrientation orientation(ComScreenId id)
    {
        ComScreenOrientation result;
        if (const err = comScreen.getOrientation(id, result))
        {
            logging.logger.errorf("Error getting screen orientation with index %s: %s", id, err
                    .toString);
        }
        return result;
    }
}
