module api.dm.gui.controls.meters.scales.statics.base_scale_static;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.scales.base_minmax_scale : BaseMinMaxScale;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites.sprites2d.textures.vectors.vector_texture : VectorTexture;
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
abstract class BaseScaleStatic : BaseMinMaxScale
{
    double prefLabelWidth = 0;

    Texture2d scaleShape;

    Sprite2d minorTickProto;
    Sprite2d delegate(Sprite2d) onMinorTickProtoCreate;
    void delegate(Sprite2d) onMinorTickProtoCreated;

    Sprite2d majorTickProto;
    Sprite2d delegate(Sprite2d) onMajorTickProtoCreate;
    void delegate(Sprite2d) onMajorTickProtoCreated;

    Text labelProto;
    Text delegate(Text) onLabelProtoCreate;
    void delegate(Text) onLabelProtoCreated;

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

        if (!minorTickProto)
        {
            auto newProto = newMinorTickProto;
            minorTickProto = onMinorTickProtoCreate ? onMinorTickProtoCreate(newProto) : newProto;
            buildInitCreate(minorTickProto);
            if (auto texture = cast(Texture2d) minorTickProto)
            {
                texture.bestScaleMode;
            }

            if (onMinorTickProtoCreated)
            {
                onMinorTickProtoCreated(minorTickProto);
            }
        }

        if (!majorTickProto)
        {
            auto newProto = newMajorTickProto;
            majorTickProto = onMajorTickProtoCreate ? onMajorTickProtoCreate(newProto) : newProto;
            buildInitCreate(majorTickProto);
            if (auto texture = cast(Texture2d) majorTickProto)
            {
                texture.bestScaleMode;
            }

            if (onMajorTickProtoCreated)
            {
                onMajorTickProtoCreated(majorTickProto);
            }
        }

        if (!labelProto)
        {
            auto newProto = newLabelProto;
            labelProto = onLabelProtoCreate ? onLabelProtoCreate(newProto) : newProto;
            buildInitCreate(labelProto);

            if (onLabelProtoCreated)
            {
                onLabelProtoCreated(labelProto);
            }
        }
    }

    Sprite2d newMinorTickProtoShape(double width, double height, double angle, GraphicStyle style)
    {
        return theme.rectShape(width, height, angle, style);
    }

    Sprite2d newMajorTickProtoShape(double width, double height, double angle, GraphicStyle style)
    {
        return newMinorTickProtoShape(width, height, angle, style);
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

        if (minorTickProto)
        {
            minorTickProto.dispose;
        }

        if (majorTickProto)
        {
            majorTickProto.dispose;
        }

        if (labelProto)
        {
            labelProto.dispose;
        }
    }

}
