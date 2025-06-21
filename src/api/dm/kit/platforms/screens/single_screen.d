module api.dm.kit.screens.single_screen;
import api.dm.com.graphics.com_screen : ComScreenId, ComScreenMode;
import api.math.geom2.rect2 : Rect2d;

/**
 * Authors: initkfs
 */
struct SingleScreen
{
    ComScreenId id;
    string name;
    Rect2d bounds;
    Rect2d usableBounds;
    ComScreenMode mode;
}
