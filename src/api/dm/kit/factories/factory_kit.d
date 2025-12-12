module api.dm.kit.factories.factory_kit;

import api.dm.kit.components.graphic_component : GraphicComponent;

import api.dm.kit.factories.image_factory : ImageFactory;
import api.dm.kit.factories.shape_factory : ShapeFactory;
import api.dm.kit.factories.texture_factory : TextureFactory;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class FactoryKit : GraphicComponent
{
    ImageFactory images;
    ShapeFactory shapes;
    TextureFactory textures;

    this(ImageFactory images, ShapeFactory shapes, TextureFactory textures)
    {
        if (!images)
        {
            throw new Exception("Image factory must not be null");
        }

        if (!shapes)
        {
            throw new Exception("Shape2d factory must not be null");
        }

        if (!textures)
        {
            throw new Exception("Texture2d factory must not be null");
        }

        this.images = images;
        this.shapes = shapes;
        this.textures = textures;
    }

    Texture2d placeholder(float pWidth = 50, float pHeight = 50, RGBA color = RGBA.lightcoral)
    {
        return textures.texture(pWidth, pHeight, () {
            import api.math.geom2.vec2 : Vec2f;

            graphic.fillRect(Vec2f(0, 0), pWidth, pHeight, color);
        });
    }

}
