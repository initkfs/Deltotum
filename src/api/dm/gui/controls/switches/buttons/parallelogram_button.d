module api.dm.gui.controls.switches.buttons.parallelogram_button;

import api.dm.gui.controls.switches.buttons.base_button : BaseButton;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class ParallelogramButton : BaseButton
{
    float angleDeg = 0;
    bool isInverted;

    this(dstring text = defaultButtonText, float angleDeg = 0)
    {
        this(text, 0, 0, iconName, 0, angleDeg);
    }

    this(dstring text = defaultButtonText, dchar iconName, void delegate(ref ActionEvent) onAction, float angleDeg = 0)
    {
        this(text, 0, 0, iconName, 0, angleDeg);
        if(onAction){
            this.onAction ~= onAction;
        }
    }

    this(dstring text, void delegate(ref ActionEvent) onAction, float angleDeg = 0)
    {
        this(text, 0, 0, dchar.init, 0, angleDeg);
        if(onAction){
            this.onAction ~= onAction;
        }
    }

    this(
        dstring text,
        float width = 0,
        float height = 0,
        dchar iconName = dchar.init,
        float graphicsGap = 0,
        float angleDeg = 0
    )
    {
        super(text, width, height, iconName, graphicsGap);
        this.angleDeg = angleDeg;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadParallelogramButtonTheme;
    }

    void loadParallelogramButtonTheme()
    {
        if (angleDeg == 0)
        {
            angleDeg = theme.parallelogramShapeAngleDeg;
        }
    }

    alias createShape = Control.createShape;

    protected override Sprite2d createShape(float width, float height, float angle, GraphicStyle style)
    {

        if (platform.cap.isVector)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vparallelogram : VParallelogram;

            auto vShape = new VParallelogram(width, height, angleDeg, isInverted, style);
            return vShape;
        }

        import api.math.geom2.parallelogram2 : Parallelogram2f;
        import api.dm.kit.sprites2d.shapes.parallelogram : Parallelogram;

        auto pShape = new Parallelogram(width, height, angleDeg, isInverted, style);
        pShape.angle = angle;

        return pShape;
    }
}
