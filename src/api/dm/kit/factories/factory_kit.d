module api.dm.kit.factories.factory_kit;

import api.dm.kit.components.graphics_component : GraphicsComponent;

import api.dm.kit.factories.image_factory : ImageFactory;
import api.dm.kit.factories.shape_factory : ShapeFactory;
import api.dm.kit.factories.texture_factory : TextureFactory;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class FactoryKit : GraphicsComponent
{
    ImageFactory images;
    ShapeFactory shapes;
    TextureFactory textures;

    this(ImageFactory images, ShapeFactory shapes, TextureFactory textures)
    {
        import std.exception : enforce;

        enforce(images, "Image factory must not be null");
        enforce(shapes, "Shape2d factory must not be null");
        enforce(textures, "Texture2d factory must not be null");

        this.images = images;
        this.shapes = shapes;
        this.textures = textures;
    }

    Texture2d placeholder(double pWidth = 50, double pHeight = 50, RGBA color = RGBA.lightcoral)
    {
        return textures.texture(pWidth, pHeight, () {
            import api.math.geom2.vec2 : Vec2d;

            graphics.fillRect(Vec2d(0, 0), pWidth, pHeight, color);
        });
    }

}
