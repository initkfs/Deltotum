module api.dm.gui.controls.indicators.color_bars.radial_color_bar;

import api.dm.gui.controls.indicators.color_bars.base_color_bar: BaseColorBar;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.indicators.color_bars.color_bar_value: ColorBarValue;
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
        double minAngleDeg = 0;
        double maxAngleDeg = 0;
        
        ColorBarValue[] data;

        this(double width, double height, GraphicStyle style)
        {
            super(width, height, style);
        }

        override void createTextureContent()
        {
            auto ctx = canvas;
            style.lineWidth *= 2;

            const lineWidth = style.lineWidth;
            canvas.lineWidth = lineWidth;

            auto xCenter = width / 2;
            auto yCenter = height / 2;

            double sum = 0;
            foreach (ref colorRange; data)
            {
                sum += colorRange.value;
            }

            double startAngle = minAngleDeg;

            auto radius = Math.max(width, height) / 2 - style.lineWidth;

            const angleRange = minAngleDeg < maxAngleDeg ? maxAngleDeg - minAngleDeg : minAngleDeg - maxAngleDeg;
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
    };

}

class RadialColorBar : BaseColorBar
{
    Sprite2d bar;

    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    this(double diameter = 0, double minAngleDeg = 0, double maxAngleDeg = 90)
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
        loadControlSizeTheme;

        if (rangeData.length == 0)
        {
            auto step = 100 / 3;
            rangeData = [
                ColorBarValue(step, theme.colorSuccess),
                ColorBarValue(step, theme.colorWarning),
                ColorBarValue(step, theme.colorDanger),
            ];
        }
    }

    override void create()
    {
        super.create;

        //TODO placeholder
        if(!capGraphics.isVectorGraphics){
            return;
        }

        auto style = createStyle;

        auto shape = new ColorBarShape(width, height, style);
        shape.data = rangeData;
        shape.minAngleDeg = minAngleDeg;
        shape.maxAngleDeg = maxAngleDeg;

        addCreate(shape);
    }

    double colorRangeSum()
    {
        double sum = 0;
        foreach (r; rangeData)
        {
            sum += r.value;
        }
        return sum;
    }

}
