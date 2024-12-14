module api.dm.gui.controls.meters.scales.statics.base_scale_static;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.scales.base_drawable_scale : BaseDrawableScale;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.kit.graphics.colors.rgba : RGBA;
import Math = api.math;

import std.conv : to;

/**
 * Authors: initkfs
 */
abstract class BaseScaleStatic : BaseDrawableScale
{
    double prefLabelWidth = 0;

    Texture2d scaleShape;

    bool isCreateMinorTickProto = true;
    Sprite2d minorTickProto;
    Sprite2d delegate(Sprite2d) onNewMinorTickProto;
    void delegate(Sprite2d) onMinorTickProtoCreated;

    bool isCreateMajorTickProto = true;
    Sprite2d majorTickProto;
    Sprite2d delegate(Sprite2d) onNewMajorTickProto;
    void delegate(Sprite2d) onMajorTickProtoCreated;

    bool isCreateLabelProto = true;
    Text labelProto;
    Text delegate(Text) onNewLabelProto;
    void delegate(Text) onLabelProtoCreated;

    protected
    {
        Vec2d minorProtoDsize;
        Vec2d majorProtoDsize;
    }

    this(double width = 0, double height = 0)
    {
        this._width = width;
        this.height = height;
    }

    override void create()
    {
        super.create;

        if (axisColor == RGBA.init)
        {
            axisColor = theme.colorDanger;
        }

        if (!minorTickProto && isCreateMinorTickProto)
        {
            auto newProto = newMinorTickProto;
            minorTickProto = onNewMinorTickProto ? onNewMinorTickProto(newProto) : newProto;
            if (!minorTickProto.isBuilt)
            {
                buildInitCreate(minorTickProto);
            }

            if (auto texture = cast(Texture2d) minorTickProto)
            {
                texture.bestScaleMode;
                texture.blendModeBlend;
            }

            minorTickProto.isResizedByParent = false;

            if (onMinorTickProtoCreated)
            {
                onMinorTickProtoCreated(minorTickProto);
            }
        }

        if (!majorTickProto && isCreateMajorTickProto)
        {
            auto newProto = newMajorTickProto;
            majorTickProto = onNewMajorTickProto ? onNewMajorTickProto(newProto) : newProto;
            if (!majorTickProto.isBuilt)
            {
                buildInitCreate(majorTickProto);
            }

            if (auto texture = cast(Texture2d) majorTickProto)
            {
                texture.bestScaleMode;
                texture.blendModeBlend;
            }

            majorTickProto.isResizedByParent = false;

            if (onMajorTickProtoCreated)
            {
                onMajorTickProtoCreated(majorTickProto);
            }
        }

        if (!labelProto && isCreateLabelProto)
        {
            auto newProto = newLabelProto;
            labelProto = onNewLabelProto ? onNewLabelProto(newProto) : newProto;
            buildInitCreate(labelProto);

            if (onLabelProtoCreated)
            {
                onLabelProtoCreated(labelProto);
            }
        }
    }

    Sprite2d newMinorTickProtoShape(double width, double height, double angle, GraphicStyle style)
    {
        auto shapeProto = theme.rectShape(width, height, angle, style);
        buildInitCreate(shapeProto);
        shapeProto.isResizable = false;
        shapeProto.isResizedByParent = false;

        if (auto shapeTexture = cast(Texture2d) shapeProto)
        {
            auto maxBox = shapeTexture.boundingBoxMax;

            auto shape = shapeTexture.copyTo(maxBox.width, maxBox.height, isToCenter:
                true);
            shape.bestScaleMode;
            shape.isResizable = false;
            shape.isResizedByParent = false;

            const dw = shape.width - shapeTexture.width;
            const dh = shape.height - shapeTexture.height;

            minorProtoDsize = Vec2d(dw, dh);

            shapeProto.dispose;

            return shape;
        }

        return shapeProto;
    }

    Sprite2d newMajorTickProtoShape(double width, double height, double angle, GraphicStyle style)
    {
        auto shape = newMinorTickProtoShape(width, height, angle, style);
        shape.isResizable = false;
        shape.isResizedByParent = false;

        if (auto shapeTexture = cast(Texture2d) shape)
        {
            auto maxBox = shape.boundingBoxMax;
            auto newShape = shapeTexture.copyTo(maxBox.width, maxBox.height, isToCenter:
                true);
            newShape.bestScaleMode;
            newShape.isResizable = false;
            newShape.isResizedByParent = false;

            const dw = newShape.width - shapeTexture.width;
            const dh = newShape.height - shapeTexture.height;

            majorProtoDsize = Vec2d(dw, dh);

            shape.dispose;

            return newShape;
        }

        return shape;
    }

    Sprite2d newMinorTickProto()
    {
        auto minorTickProtoStyle = createFillStyle;

        auto proto = newMinorTickProtoShape(tickMinorWidth, tickMinorHeight, 0, minorTickProtoStyle);
        return proto;
    }

    Sprite2d newMajorTickProto()
    {
        auto majorTickProtoStyle = createFillStyle;
        if (!majorTickProtoStyle.isPreset)
        {
            majorTickProtoStyle.lineColor = theme.colorDanger;
            majorTickProtoStyle.fillColor = theme.colorDanger;
        }

        auto proto = newMajorTickProtoShape(tickMajorWidth, tickMajorHeight, 0, majorTickProtoStyle);
        return proto;
    }

    Text newLabelProto()
    {
        import api.dm.kit.assets.fonts.font_size : FontSize;

        auto proto = new Text("!");
        proto.fontSize = FontSize.small;
        return proto;
    }

    override void dispose()
    {
        super.dispose;

        if (minorTickProto && !minorTickProto.isDisposed)
        {
            minorTickProto.dispose;
        }

        if (majorTickProto && !majorTickProto.isDisposed)
        {
            majorTickProto.dispose;
        }

        if (labelProto && !labelProto.isDisposed)
        {
            labelProto.dispose;
        }
    }

}
