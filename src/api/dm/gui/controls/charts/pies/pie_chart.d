module api.dm.gui.controls.charts.pies.pie_chart;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

//TODO mutable texture
import api.dm.kit.sprites2d.textures.vectors.vtexture : VTexture;
import api.math.geom2.plane_angle;

struct PieData
{
    dstring name;
    float value = 0;
}

class PieTexture : VTexture
{
    float totalValue = 0;
    PieData[] values;

    void delegate(size_t, RGBA color, float, Vec2f) onColorRadiusAnglesDeg;

    this(float width, float height)
    {
        super(width, height);
    }

    override void createContent()
    {
        //TODO vectors
        if (!platform.cap.isVector)
        {
            return;
        }

        super.createContent;

        if (totalValue == 0 || values.length == 0)
        {
            return;
        }

        import api.dm.kit.graphics.colors.rgba : RGBA;

        float startAngleDeg = 0;
        float fullAngleDeg = 360;

        import api.math.geom2.vec2 : Vec2f;

        auto centerPos = Vec2f(width / 2, height / 2);
        auto radius = width / 2;

        canvas.translate(centerPos.x, centerPos.y);

        import api.dm.kit.graphics.colors.hsla : HSLA;

        auto startColor = RGBA.random.toHSLA;
        startColor.l = 0.55;
        startColor.s = 0.9;
        const setCount = values.length;
        foreach (i, ref PieData data; values)
        {
            auto color = startColor.toRGBA;

            canvas.color(color);

            startColor.h = Math.round((i * HSLA.maxHue) / setCount);

            float v = data.value;
            float dataAngleDeg = (v * fullAngleDeg) / totalValue;
            auto endAngleDeg = startAngleDeg + dataAngleDeg;

            if (onColorRadiusAnglesDeg)
            {
                onColorRadiusAnglesDeg(i, color, radius, Vec2f(startAngleDeg, endAngleDeg));
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
    import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
    import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
    import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;

    Text textLabel;
    Sprite2d colorLabel;
    RGBA color;

    float startAngleDeg = 0;
    float endAngleDeg = 0;
    float radius = 0;

    this()
    {
        isVisibilityForChildren = true;
        layout = new HLayout;
        layout.isAutoResize = true;
        layout.isAlignY = true;
        //isBackground = true;
    }

    override void create()
    {
        super.create;

        enablePadding;

        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        colorLabel = theme.circleShape(5, GraphicStyle(1, RGBA.white, true, RGBA.white));
        addCreate(colorLabel);

        if (auto colorTexture = cast(Texture2d) colorLabel)
        {
            colorTexture.blendModeBlend;
        }

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
        float totalValue = 0;
        PieData[] values;

        LabelInfo[] labels;

        float chartAreaWidth;
        float chartAreaHeight;

        PieTexture texture;
        bool isCreateTexture = true;
        PieTexture delegate(PieTexture) onNewTexture;
        void delegate(PieTexture) onConfiguredTexture;
        void delegate(PieTexture) onCreatedTexture;

        size_t labelsCount;
    }

    this(float chartAreaWidth = 100, float chartAreaHeight = 100)
    {
        this.chartAreaWidth = chartAreaWidth;
        this.chartAreaHeight = chartAreaHeight;

        _width = chartAreaWidth;
        _height = chartAreaHeight;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        if (!platform.cap.isVector)
        {
            return;
        }

        if (!texture && isCreateTexture)
        {
            auto t = newTexture(chartAreaWidth, chartAreaHeight);
            texture = !onNewTexture ? t : onNewTexture(t);

            texture.onColorRadiusAnglesDeg = (i, color, radius, angles) {
                assert(i < values.length);
                auto data = values[i];

                assert(i < labels.length);
                auto label = labels[i];

                auto percent = data.value / totalValue * 100;

                import std.format : format;

                label.textLabel.text = format("%s (%s%%)", data.name, percent);

                if (auto colorTexture = cast(Texture2d) label.colorLabel)
                {
                    colorTexture.color = color;
                }

                //TODO from texture?
                label.color = color;

                label.startAngleDeg = angles.x;
                label.endAngleDeg = angles.y;
                label.radius = radius;
            };

            if (onConfiguredTexture)
            {
                onConfiguredTexture(texture);
            }

            addCreate(texture);
            if (onCreatedTexture)
            {
                onCreatedTexture(texture);
            }
        }
    }

    PieTexture newTexture(float w, float h)
    {
        return new PieTexture(w, h);
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

            auto outerPos = Vec2f.fromPolarDeg(middleAngleDeg, radius);
            auto outerCenterPos = boundsRect.center.add(outerPos);

            float labelX = outerCenterPos.x;
            float labelY = outerCenterPos.y;

            if (middleAngleDeg >= 0 && middleAngleDeg <= 90)
            {
                //label.y = labelY - label.boundsRect.halfHeight;
                label.layout.isFillStartToEnd = true;
            }
            else if (middleAngleDeg > 90 && middleAngleDeg <= 270)
            {
                labelX -= label.boundsRect.width;
                label.layout.isFillStartToEnd = false;
            }
            else if (middleAngleDeg > 270 && middleAngleDeg < 360)
            {
                labelY -= label.boundsRect.height;
                label.layout.isFillStartToEnd = true;
            }

            label.x = labelX;
            label.y = labelY;

            label.isVisible = true;

            auto pointerStartPos = Vec2f.fromPolarDeg(middleAngleDeg, label.radius).add(
                boundsRect.center);
            auto pointerEndPos = label.colorLabel.boundsRect.center;

            graphic.line(pointerStartPos, pointerEndPos, label.color);
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
