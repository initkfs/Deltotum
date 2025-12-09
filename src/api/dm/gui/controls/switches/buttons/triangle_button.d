module api.dm.gui.controls.switches.buttons.triangle_button;

import api.dm.gui.controls.switches.buttons.base_button : BaseButton;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class TriangleButton : BaseButton
{
    this(dstring text = defaultButtonText)
    {
        this(text, 0, 0, iconName, 0);
    }

    this(dstring text = defaultButtonText, string iconName, void delegate(ref ActionEvent) onAction)
    {
        this(text, 0, 0, iconName, 0);
        if (onAction)
        {
            this.onAction ~= onAction;
        }
    }

    this(dstring text, void delegate(ref ActionEvent) onAction)
    {
        this(text, 0, 0, null, 0);
        if (onAction)
        {
            this.onAction ~= onAction;
        }
    }

    this(
        dstring text,
        float width = 0,
        float height = 0,
        string iconName = null,
        float graphicsGap = 0
    )
    {
        super(text, width, height, iconName, graphicsGap);
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseButtonTheme;
    }

    alias createShape = Control.createShape;

    protected override Sprite2d createShape(float width, float height, float angle, GraphicStyle style)
    {
        Sprite2d shape = theme.triangleShape(width, height, angle, style);
        return shape;
    }
}
