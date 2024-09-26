module api.dm.gui.controls.charts.pie_chart;

import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.graphics.colors.rgba : RGBA;

import api.math.vector2 : Vector2;
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

    void delegate(size_t, RGBA color, double, Vector2) onColorRadiusAnglesDeg;

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

        import api.math.vector2 : Vector2;

        auto centerPos = Vector2(width / 2, height / 2);
        auto radius = width / 2;

        canvas.translate(centerPos.x, centerPos.y);

        import api.dm.kit.graphics.colors.hsv : HSV;

        auto startColor = RGBA.random.toHSV;
        startColor.saturation = HSV.maxSaturation;

        foreach (i, ref PieData data; values)
        {
            auto color = startColor.toRGBA;

            canvas.color(color);

            startColor.hue = (startColor.hue + 100) % HSV.maxHue;
            startColor.value = HSV.maxValue;

            double v = data.value;
            double dataAngleDeg = (v * fullAngleDeg) / totalValue;
            auto endAngleDeg = startAngleDeg + dataAngleDeg;

            if (onColorRadiusAnglesDeg)
            {
                onColorRadiusAnglesDeg(i, color, radius, Vector2(startAngleDeg, endAngleDeg));
            }

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

class LabelInfo : Container
{
    import api.dm.kit.sprites.layouts.hlayout : HLayout;
    import api.dm.kit.sprites.textures.texture : Texture;
    import api.dm.kit.sprites.textures.vectors.shapes.vcircle : VCircle;

    Text textLabel;
    Texture colorLabel;
    RGBA color;

    double startAngleDeg = 0;
    double endAngleDeg = 0;
    double radius = 0;

    this()
    {
        isVisibilityForChildren = true;
        layout = new HLayout(5);
        layout.isAutoResize = true;
        layout.isAlignY = true;
        //isBackground = true;
        isDrawBounds = true;
    }

    override void create()
    {
        super.create;

        enableInsets;

        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        colorLabel = new VCircle(5, GraphicStyle(1, RGBA.white, true, RGBA.white));
        addCreate(colorLabel);
        colorLabel.blendModeBlend;

        textLabel = new Text();
        textLabel.setSmallSize;
        addCreate(textLabel);
    }
}

/**
 * Authors: initkfs
 */
class PieChart : Container
{
    bool isShowLabels;

    protected
    {
        double totalValue = 0;
        PieData[] values;

        LabelInfo[] labels;

        double chartAreaWidth;
        double chartAreaHeight;

        PieTexture texture;

        size_t labelsCount;
    }

    this(double chartAreaWidth = 100, double chartAreaHeight = 100)
    {
        this.chartAreaWidth = chartAreaWidth;
        this.chartAreaHeight = chartAreaHeight;

        _width = chartAreaWidth;
        _height = chartAreaHeight;

        import api.dm.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout(5);
        layout.isAutoResize = true;
        isDrawBounds = true;
    }

    override void create()
    {
        super.create;

        texture = new PieTexture(chartAreaWidth, chartAreaHeight);
        addCreate(texture);

        texture.onColorRadiusAnglesDeg = (i, color, radius, angles) {
            assert(i < values.length);
            auto data = values[i];

            assert(i < labels.length);
            auto label = labels[i];

            auto percent = data.value / totalValue * 100;

            import std.format: format;

            label.textLabel.text = format("%s (%s%%)", data.name, percent);
            
            label.colorLabel.color = color;
            //TODO from texture?
            label.color = color;

            label.startAngleDeg = angles.x;
            label.endAngleDeg = angles.y;
            label.radius = radius;
        };
    }

    override void applyLayout()
    {
        super.applyLayout;

        if (!isCreated || !isShowLabels || labels.length == 0)
        {
            return;
        }

        foreach (LabelInfo label; labels[0 .. labelsCount])
        {
            auto outerRadius = 5;
            auto radius = label.radius + outerRadius;
            auto middleAngleDeg = label.startAngleDeg + (
                (label.endAngleDeg - label.startAngleDeg) / 2);

            auto outerPos = Vector2.fromPolarDeg(middleAngleDeg, radius);
            auto outerCenterPos = bounds.center.add(outerPos);

            double labelX = outerCenterPos.x;
            double labelY = outerCenterPos.y;

            if (middleAngleDeg >= 0 && middleAngleDeg <= 90)
            {
                //label.y = labelY - label.bounds.halfHeight;
                label.layout.isFillFromStartToEnd = true;
            }
            else if (middleAngleDeg > 90 && middleAngleDeg <= 270)
            {
                labelX -= label.bounds.width;
                label.layout.isFillFromStartToEnd = false;
            }
            else if (middleAngleDeg > 270 && middleAngleDeg < 360)
            {
                labelY -= label.bounds.height;
                label.layout.isFillFromStartToEnd = true;
            }

            label.x = labelX;
            label.y = labelY;

            label.isVisible = true;

            auto pointerStartPos = Vector2.fromPolarDeg(middleAngleDeg, label.radius).add(
                bounds.center);
            auto pointerEndPos = label.colorLabel.bounds.center;

            graphics.line(pointerStartPos, pointerEndPos, label.color);
        }
    }

    void data(PieData[] values)
    {
        totalValue = 0;
        foreach (ref v; values)
        {
            totalValue += v.value;
        }

        if (labels.length < values.length)
        {
            auto poolDiff = values.length - labels.length;

            labels.reserve(labels.length + poolDiff);

            foreach (_; 0 .. poolDiff)
            {
                auto labelInfo = new LabelInfo;
                labelInfo.isLayoutManaged = false;
                labelInfo.isResizedByParent = false;
                addCreate(labelInfo);
                labelInfo.isVisible = false;
                labels ~= labelInfo;
            }
        }

        this.values = values;

        labelsCount = values.length;

        if (texture)
        {
            texture.totalValue = totalValue;
            texture.values = values;
            texture.recreate;
        }

    }

}
