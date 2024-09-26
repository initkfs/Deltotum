module api.dm.gui.controls.charts.pie_chart;

import api.dm.gui.containers.container : Container;

import Math = api.math;

//TODO mutable texture
import api.dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;
import api.math.angle;

struct PieData
{
    dstring name;
    double value = 0;
}

class PieTexture : VectorTexture
{
    double totalValue = 0;
    PieData[] values;

    this(double width, double height)
    {
        super(width, height);
    }

    override void createTextureContent()
    {
        super.createTextureContent;

        if (totalValue == 0 || values.length == 0)
        {
            return;
        }

        import api.dm.kit.graphics.colors.rgba : RGBA;

        double startAngleDeg = 0;
        double fullAngleDeg = 360;

        import api.math.vector2: Vector2;
 
        auto centerPos = Vector2(width / 2, height / 2);
        auto radius = width / 2;

        canvas.translate(centerPos.x, centerPos.y);

        import api.dm.kit.graphics.colors.hsv: HSV;

        auto startColor = RGBA.random.toHSV;
        startColor.saturation = HSV.maxSaturation;

        foreach (ref PieData data; values)
        {
            canvas.color(startColor.toRGBA);
            startColor.hue = (startColor.hue + 100) % HSV.maxHue;
            startColor.value = HSV.maxValue;

            double v = data.value;
            double dataAngleDeg = (v * fullAngleDeg) / totalValue;
            auto endAngleDeg = startAngleDeg + dataAngleDeg;

            import Math = api.math;
            
            canvas.beginPath;
            canvas.moveTo(0, 0);
            canvas.arc(0, 0, radius, Math.degToRad(startAngleDeg), Math.degToRad(endAngleDeg));
            canvas.fill;
            canvas.closePath;
            startAngleDeg = endAngleDeg;
        }

        canvas.stroke;
    }
}

/**
 * Authors: initkfs
 */
class PieChart : Container
{
    protected
    {
        double totalValue = 0;
        PieData[] values;

        double chartAreaWidth;
        double chartAreaHeight;

        PieTexture texture;
    }

    this(double chartAreaWidth = 100, double chartAreaHeight = 100)
    {
        this.chartAreaWidth = chartAreaWidth;
        this.chartAreaHeight = chartAreaHeight;

        import api.dm.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout(5);
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        texture = new PieTexture(chartAreaWidth, chartAreaHeight);
        addCreate(texture);
    }

    void data(PieData[] values)
    {
        totalValue = 0;
        foreach (ref v; values)
        {
            totalValue += v.value;
        }

        this.values = values;

        if (texture)
        {
            texture.totalValue = totalValue;
            texture.values = values;
            texture.recreate;
        }

    }

}
