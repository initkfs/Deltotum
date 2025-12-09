module api.dm.kit.screens.single_screen;
import api.dm.com.graphics.com_screen : ComScreenId, ComScreenMode;
import api.math.geom2.rect2 : Rect2f;

/**
 * Authors: initkfs
 */
struct SingleScreen
{
    ComScreenId id;
    string name;
    Rect2f bounds;
    Rect2f usableBounds;
    ComScreenMode mode;
}
