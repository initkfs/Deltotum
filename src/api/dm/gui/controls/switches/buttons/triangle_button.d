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

    this(dstring text = defaultButtonText, dchar iconName, void delegate(ref ActionEvent) onAction)
    {
        this(text, 0, 0, iconName, 0);
        if (onAction)
        {
            this.onAction ~= onAction;
        }
    }

    this(dstring text, void delegate(ref ActionEvent) onAction)
    {
        this(text, 0, 0, dchar.init, 0);
        if (onAction)
        {
            this.onAction ~= onAction;
        }
    }

    this(
        dstring text,
        float width = 0,
        float height = 0,
        dchar iconName = dchar.init,
        float graphicsGap = 0
    )
    {
        super(text, width, height, iconName, graphicsGap);
    }

    override void loadTheme()
    {
        import Math = api.math;

        //for simplify centroid
        auto size = Math.max(theme.buttonWidth, theme.buttonHeight);
        if (isSetNullWidthFromTheme && width == 0)
        {
            initWidth = size;
        }

        if (isSetNullHeightFromTheme && height == 0)
        {
            initHeight = size;
        }
    }

    override void applyLayout()
    {
        import Math = api.math;

        super.applyLayout;

        if (_icon)
        {
            const bounds = boundsRect;

            float centroidX = 0;
            float centroidY = 0;

            if (angle == 0)
            {
                centroidX = bounds.halfWidth;
                centroidY = bounds.width * 2 / 3;
            }
            else
            {
                const wc = bounds.width / 6.0;
                centroidX = bounds.halfWidth - wc * Math.sinDeg(angle);
                centroidY = bounds.halfWidth + wc * Math.cosDeg(angle);
            }

            _icon.x = x + centroidX - _icon.halfWidth;
            _icon.y = y + centroidY - _icon.halfHeight;

        }
    }

    override Sprite2d newLabelIcon()
    {
        auto newIcon = super.newLabelIcon;
        newIcon.isLayoutManaged = false;
        return newIcon;
    }

    alias createShape = Control.createShape;

    protected override Sprite2d createShape(float width, float height, float angle, GraphicStyle style)
    {
        Sprite2d shape = theme.triangleShape(width, height, angle, style);
        return shape;
    }
}
