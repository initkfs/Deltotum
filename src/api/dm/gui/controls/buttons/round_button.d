module api.dm.gui.controls.buttons.round_button;

import api.dm.gui.controls.buttons.base_rounded_button: BaseRoundedButton;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class RoundButton : BaseRoundedButton
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
        double graphicsGap = 0,
        string iconName = null,
    )
    {
        super(text, diameter, graphicsGap, iconName);
    }

    override void loadTheme()
    {
        loadLabeledTheme;
        loadRoundButtonTheme;
    }

    void loadRoundButtonTheme()
    {
        if (_diameter == 0)
        {
            _diameter = theme.roundShapeDiameter;
            _width = _diameter;
            _height = _diameter;
        }
    }

    alias createShape = Control.createShape;

    protected override Sprite createShape(double width, double height, GraphicStyle style)
    {
        return theme.roundShape(_diameter, style);
    }
}
