module api.dm.gui.controls.indicators.colorbars.radial_colorbar;

import api.dm.gui.controls.indicators.colorbars.base_mono_colorbar : BaseMonoColorBar;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.indicators.colorbars.colorbar_data : ColorBarData;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
private
{
    import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;

    class ColorBarShape : VShape
    {
        float minAngleDeg = 0;
        float maxAngleDeg = 0;

        ColorBarData[] data;

        this(float width, float height, GraphicStyle style)
        {
            super(width, height, style);
        }

        override void createContent()
        {
            auto ctx = canvas;
            style.lineWidth *= 2;

            const lineWidth = style.lineWidth;
            canvas.lineWidth = lineWidth;

            auto xCenter = width / 2;
            auto yCenter = height / 2;

            float sum = 0;
            foreach (ref colorRange; data)
            {
                sum += colorRange.value;
            }

            float startAngle = minAngleDeg;

            auto radius = Math.max(width, height) / 2 - style.lineWidth;

            const angleRange = minAngleDeg < maxAngleDeg ? maxAngleDeg - minAngleDeg
                : minAngleDeg - maxAngleDeg;
            const rangeDt = angleRange / sum;

            foreach (ref rangeData; data)
            {
                auto angleEnd = startAngle + rangeData.value * rangeDt;
                ctx.color = rangeData.color;
                ctx.arc(xCenter, yCenter, radius, Math.degToRad(startAngle), Math.degToRad(
                        angleEnd));

                ctx.stroke;
                startAngle = angleEnd;
            }

        }
    }

}

class RadialColorBar : BaseMonoColorBar
{
    float minAngleDeg = 0;
    float maxAngleDeg = 0;

    this(float diameter = 0, float minAngleDeg = 0, float maxAngleDeg = 360)
    {
        super(diameter, diameter);

        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadRadialColorBarTheme;
    }

    void loadRadialColorBarTheme()
    {
        auto barSize = theme.controlDefaultWidth / 2;
        if (width == 0)
        {
            initWidth = barSize;
        }

        if (height == 0)
        {
            initHeight = barSize;
        }
    }

    override void createColorBar(Sprite2d bar)
    {

    }

    override Sprite2d newBar()
    {
        auto style = createStyle;

        if (!platform.cap.isVectorGraphics)
        {
            import api.dm.kit.sprites2d.shapes.circle : Circle;

            auto placeholder = new Circle(Math.max(width, height), style);
            return placeholder;
        }

        auto shape = new ColorBarShape(width, height, style);
        shape.data = rangeData;
        shape.minAngleDeg = minAngleDeg;
        shape.maxAngleDeg = maxAngleDeg;
        return shape;
    }

}
