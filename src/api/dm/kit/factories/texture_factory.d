module api.dm.kit.factories.texture_factory;

import api.dm.kit.components.graphic_component : GraphicComponent;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.textures.rgba_texture : RgbaTexture;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class TextureFactory : GraphicComponent
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

                    graphic.fillRect(0, 0, width, height, RGBA.white);
                }
            }
        };
        buildInitCreate(newTexture);
        return newTexture;
    }

}
