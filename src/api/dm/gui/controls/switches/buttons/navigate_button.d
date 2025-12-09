module api.dm.gui.controls.switches.buttons.navigate_button;

import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

enum NavigateDirection
{
    toLeft,
    toRight,
    toTop,
    toBottom
}

/**
 * Authors: initkfs
 */
class NavigateButton : Button
{
    NavigateDirection direction;

    float buttonSize = 0;

    this(NavigateDirection direction = NavigateDirection.toTop)
    {
        this(null, 0, 0, iconName, 0);
        this.direction = direction;
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

    static
    {
        NavigateButton newHPrevButton() => new NavigateButton(NavigateDirection.toLeft);
        NavigateButton newHNextButton() => new NavigateButton(NavigateDirection.toRight);
        NavigateButton newVPrevButton() => new NavigateButton(NavigateDirection.toBottom);
        NavigateButton newVNextButton() => new NavigateButton(NavigateDirection.toTop);
    }

    override void loadTheme()
    {
        loadNavigateButtonTheme;
        super.loadTheme;
    }

    void loadNavigateButtonTheme()
    {
        if (buttonSize == 0)
        {
            import Math = api.math;

            buttonSize = Math.round(theme.iconSize / 1.5);
            initSize(buttonSize, buttonSize);
        }
    }

    alias createShape = Control.createShape;

    protected override Sprite2d createShape(float width, float height, float angle, GraphicStyle style)
    {
        if (!style.isPreset)
        {
            style.isFill = true;
            style.fillColor = style.lineColor;
        }
        Sprite2d shape = theme.triangleShape(buttonSize, buttonSize, 0, style);

        final switch (direction) with (NavigateDirection)
        {
            case toTop:
                break;
            case toLeft:
                shape.angle = -90;
                break;
            case toRight:
                shape.angle = 90;
                break;
            case toBottom:
                shape.angle = 180;
                break;
        }
        return shape;
    }
}
