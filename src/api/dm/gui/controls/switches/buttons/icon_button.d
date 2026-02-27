module api.dm.gui.controls.switches.buttons.icon_button;

import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class IconButton : Button
{

    this(dchar iconName = dchar.init,
        float width = 0,
        float height = 0,
        dstring text = null
    )
    {
        super(text, width, height, iconName, 0);

        isBorder = false;
        isBackground = false;
        isEnablePadding = false;
    }

    override void loadTheme()
    {
        loadIconButtonTheme;
    }

    void loadIconButtonTheme()
    {
        if (isSetNullWidthFromTheme && width == 0)
        {
            initWidth = theme.iconSize;
        }

        if (isSetNullHeightFromTheme && height == 0)
        {
            initHeight = theme.iconSize;
        }
    }

}
