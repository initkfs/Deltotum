module api.dm.kit.factories.factory_kit;

import api.dm.kit.components.window_component : WindowComponent;

import api.dm.kit.factories.image_factory : ImageFactory;
import api.dm.kit.factories.shape_factory : ShapeFactory;
import api.dm.kit.factories.texture_factory : TextureFactory;
import api.dm.kit.sprites.sprite : Sprite;

import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class FactoryKit : WindowComponent
{
    ImageFactory images;
    ShapeFactory shapes;
    TextureFactory textures;

    this(ImageFactory images, ShapeFactory shapes, TextureFactory textures)
    {
        import std.exception : enforce;

        enforce(images, "Image factory must not be null");
        enforce(shapes, "Shape factory must not be null");
        enforce(textures, "Texture factory must not be null");

        this.images = images;
        this.shapes = shapes;
        this.textures = textures;
    }

    Sprite placeholder(double pWidth = 50, double pHeight = 50, RGBA color = RGBA.lightcoral)
    {
        return textures.texture(pWidth, pHeight, () {
            import api.math.geom2.vec2 : Vec2d;

            graphics.fillRect(Vec2d(0, 0), pWidth, pHeight, color);
        });
    }

}
