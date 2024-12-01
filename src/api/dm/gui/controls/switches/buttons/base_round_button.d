module api.dm.gui.controls.switches.buttons.base_round_button;

import api.dm.gui.controls.switches.buttons.base_button : BaseButton;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class BaseRoundButton : BaseButton
{
    protected
    {
        double _diameter = 0;
    }

    this(dstring text = defaultButtonText)
    {
        this(text, 0, null, 0);
    }

    this(dstring text, void delegate(ref ActionEvent) onAction)
    {
        this(text, 0, null, 0);
        if (onAction)
        {
            this.onAction ~= onAction;
        }
    }

    this(
        dstring text,
        double diameter = 0,
        string iconName = null,
        double graphicsGap = 0,
    )
    {
        super(text, diameter, diameter, iconName, graphicsGap, isCreateLayout:
            false);

        this._diameter = diameter;

        import api.dm.kit.sprites.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResizeAndAlignOne = true;
        this.layout.isAlign = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseRoundButtonTheme;
    }

    void loadBaseRoundButtonTheme()
    {
        if (_diameter == 0)
        {
            _diameter = theme.roundShapeDiameter;
        }

        _width = _diameter;
        _height = _diameter;
    }

    override bool containsPoint(double x, double y)
    {
        if (hasBackground)
        {
            return background.get.containsPoint(x, y);
        }

        return super.containsPoint(x, y);
    }

    override bool intersectBounds(Sprite2d other)
    {
        if (hasBackground)
        {
            return background.get.intersectBounds(other);
        }
        return super.intersectBounds(other);
    }

    double diameter() => _diameter;

    bool diameter(double v)
    {
        if (_diameter == v)
        {
            return false;
        }
        _diameter = v;
        setInvalid;
        return true;
    }
}
