module api.dm.kit.factories.texture_factory;

import api.dm.kit.components.graphics_component : GraphicsComponent;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.textures.rgba_texture : RgbaTexture;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class TextureFactory : GraphicsComponent
{
    Texture2d texture(double newWidth = 100, double newHeight = 100, void delegate() contentDrawer = null)
    {
        auto newTexture = new class RgbaTexture
        {
            this()
            {
                super(newWidth, newHeight);
            }

            override void createTextureContent()
            {
                if (contentDrawer)
                {
                    contentDrawer();
                }
                else
                {
                    import api.dm.kit.graphics.colors.rgba : RGBA;
                    import api.math.geom2.rect2 : Rect2d;

                    graphics.fillRect(0, 0, width, height, RGBA.white);
                }
            }
        };
        buildInitCreate(newTexture);
        return newTexture;
    }

}
