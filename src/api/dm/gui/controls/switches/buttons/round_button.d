module api.dm.gui.controls.switches.buttons.round_button;

import api.dm.gui.controls.switches.buttons.base_round_button : BaseRoundButton;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class RoundButton : BaseRoundButton
{
    this(dstring text = defaultButtonText)
    {
        super(text);
    }

    this(dstring text, void delegate(ref ActionEvent) onAction)
    {
        super(text, onAction);
    }

    this(
        dstring text,
        double diameter = 0,
        string iconName = null,
        double graphicsGap = 0,
    )
    {
        super(text, diameter, iconName, graphicsGap);
    }

    alias createShape = Control.createShape;

    protected override Sprite2d createShape(double width, double height, double angle, GraphicStyle style)
    {
        return theme.roundShape(_diameter, style);
    }
}
