module api.dm.gui.controls.buttons.convex_poly_button;

import api.dm.gui.controls.buttons.base_rounded_button : BaseRoundedButton;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class ConvexPolyButton : BaseRoundedButton
{
    protected
    {
        double _bevelSize = 0;
    }

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
        size_t bevelSize = 0,
        double diameter = 0,
        double graphicsGap = 0,
        string iconName = null,
    )
    {
        super(text, diameter, graphicsGap, iconName);

        this._bevelSize = bevelSize;
    }

    override void loadTheme()
    {
        loadLabeledTheme;
        loadRhombusButtonTheme;
    }

    void loadRhombusButtonTheme()
    {
        if (_bevelSize == 0)
        {
            _bevelSize = theme.convexPolyShapeBevel;
        }

        if (_width == 0)
        {
            _width = theme.convexPolyShapeSize;
        }
        if (_height == 0)
        {
            _height = theme.convexPolyShapeSize;
        }
    }

    protected override Sprite createShape(double width, double height, GraphicStyle style)
    {
        Sprite shape;
        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            shape = new VConvexPolygon(width, height, style, _bevelSize);
        }
        else
        {
            import api.dm.kit.sprites.shapes.convex_polygon : ConvexPolygon;

            shape = new ConvexPolygon(width, height, style, _bevelSize);
        }
        return shape;
    }
}
