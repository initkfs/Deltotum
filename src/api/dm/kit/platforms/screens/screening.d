module api.dm.kit.platforms.screens.screening;

import api.dm.com.graphic.com_screen : ComScreenId, ComScreen;
import api.dm.com.graphic.com_screen : ComScreenId, ComScreen, ComScreenMode, ComScreenDpi, ComScreenOrientation;
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

    SingleScreen single(ComScreenId id)
    {
        string screenName = name(id);
        Rect2d screenBounds = bounds(id);
        Rect2d usable = usableBounds(id);
        ComScreenMode screenMode = mode(id);
        return SingleScreen(id, screenName, screenBounds, usable, screenMode);
    }

    void onScreens(scope bool delegate(ComScreenId) nothrow onScreenIdIsContinue)
    {
        comScreen.onScreens(onScreenIdIsContinue);
    }

    Rect2d bounds(ComScreenId id)
    {
        int x, y, width, height;
        if (!comScreen.getBounds(id, x, y, width, height))
        {
            logging.logger.errorf("Error getting screen bounds with id: ", id, comScreen
                    .getLastErrorStr);
        }
        return Rect2d(x, y, width, height);
    }

    Rect2d usableBounds(ComScreenId id)
    {
        int x, y, width, height;
        if (!comScreen.getUsableBounds(id, x, y, width, height))
        {
            logging.logger.errorf("Error getting screen bounds with id %s: %s", id, comScreen
                    .getLastErrorStr);
        }
        return Rect2d(x, y, width, height);
    }

    string name(ComScreenId id) => comScreen.getNameNew(id);
    string driverName() => comScreen.getDriverNameNew;

    ComScreenMode mode(ComScreenId id)
    {
        ComScreenMode mode;
        if (!comScreen.getMode(id, mode))
        {
            logging.logger.errorf("Error getting screen mode with id %s: %s", id, comScreen
                    .getLastErrorStr);
        }

        return mode;
    }

    ComScreenOrientation orientation(ComScreenId id)
    {
        ComScreenOrientation result;
        if (!comScreen.getOrientation(id, result))
        {
            logging.logger.errorf("Error getting screen orientation with index %s: %s", id, comScreen.getLastErrorStr);
        }
        return result;
    }
}
