module api.dm.kit.factories.texture_factory;

import api.dm.kit.components.graphics_component: GraphicsComponent;

import api.dm.kit.sprites.sprites2d.textures.texture2d: Texture2d;
import api.dm.kit.sprites.sprites2d.textures.rgba_texture: RgbaTexture;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class TextureFactory : GraphicsComponent
{
    Texture2d texture(double newWidth = 100, double newheight = 100, void delegate() contentDrawer = null){
        auto newTexture = new class RgbaTexture{
            this(){
                super(newWidth, newheight);
            }

            override void createTextureContent(){
                if(contentDrawer){
                    contentDrawer();
                }
            }
        };
        buildInitCreate(newTexture);
        return newTexture;
    }
    
}
