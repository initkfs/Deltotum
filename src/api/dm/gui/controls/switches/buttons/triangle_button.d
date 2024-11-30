module api.dm.gui.controls.switches.buttons.triangle_button;

import api.dm.gui.controls.switches.buttons.base_button : BaseButton;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;
import api.dm.addon.math.geom2.triangulations.delaunator;

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
        double width = 0,
        double height = 0,
        string iconName = null,
        double graphicsGap = 0
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

    protected override Sprite createShape(double width, double height, double angle, GraphicStyle style)
    {
        Sprite shape;

        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites.textures.vectors.shapes.vtriangle : VTriangle;

            shape = new VTriangle(width, height, style);
        }
        else
        {
            import api.dm.kit.sprites.shapes.triangle : Triangle;

            shape = new Triangle(width, height, style);
        }

        assert(shape);
        shape.angle = angle;

        return shape;
    }
}
