module api.dm.gui.controls.magnifiers.magnifier;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.sprites.layouts.layout : Layout;
import api.dm.kit.sprites.layouts.hlayout : HLayout;
import api.dm.gui.controls.texts.text : Text;
import api.math.rect2d : Rect2d;
import Math = api.dm.math;

enum Source
{
    screen,
    texture
}

/**
 * Authors: initkfs
 */
class Magnifier : Control
{
    protected
    {
        //TODO container
        Texture magnifier;
        Sprite _original;
    }

    Source source = Source.screen;

    double scale = 1;
    double defaultWidth = 100;
    double defaultHeight = 100;

    this()
    {
        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;

        onPointerEntered ~= (ref e) {
            if (magnifier && !isLastIndex(magnifier))
            {
                changeIndexToLast(magnifier);
            }
            magnifier.isVisible = true;
            input.systemCursor.hide;
        };

        onPointerMove ~= (ref e) {
            auto pointerPos = input.pointerPos;

            auto magnCenterX = magnifier.bounds.halfWidth;
            auto magnCenterY = magnifier.bounds.halfHeight;

            auto magnPosX = pointerPos.x - magnCenterX;
            auto magnPosY = pointerPos.y - magnCenterY;

            magnifier.x = magnPosX;
            magnifier.y = magnPosY;

            auto mouseXRel = pointerPos.x - x;
            auto mouseYRel = pointerPos.y - y;

            auto originalXRel = (_original.width * mouseXRel) / magnifier.width;
            auto originalYRel = (_original.height * mouseYRel) / magnifier.height;

            auto originalBoundsX = originalXRel + magnifier.bounds.halfWidth;
            auto originalBoundsY = originalYRel + magnifier.bounds.halfHeight;

            Rect2d textureBounds = {
                originalBoundsX, originalBoundsY, magnifier.width, magnifier.height};

                final switch (source) with (Source)
                {
                    case screen:
                        magnifier.lock;
                        graphics.readPixels(textureBounds, magnifier.format, magnifier.pitch, magnifier
                                .pixels);
                        magnifier.unlock;
                        break;
                    case texture:
                        import api.dm.kit.sprites.textures.texture : Texture;

                        Texture originalTexture = cast(Texture) _original;
                        assert(originalTexture, "Source is not a texture");
                        magnifier.setRendererTarget;
                        textureBounds = Rect2d(originalBoundsX, originalBoundsY, magnifier.width, magnifier
                                .height);
                        auto destBounds = Rect2d(0, 0, magnifier.width, magnifier.height);
                        originalTexture.drawTexture(textureBounds, destBounds);
                        magnifier.resetRendererTarget;
                        break;
                }
            };

            onPointerExited ~= (ref e) {
                magnifier.isVisible = false;
                input.systemCursor.show;
            };
        }

        override void create()
        {
            super.create;

            magnifier = new Texture(defaultWidth * scale, defaultHeight * scale);
            build(magnifier);
            magnifier.isLayoutManaged = false;
            magnifier.isVisible = false;

            final switch (source) with (Source)
            {
                case screen:
                    magnifier.createMutRGBA32;
                    break;
                case texture:
                    magnifier.createTargetRGBA32;
                    break;
            }
            addCreate(magnifier);
        }

        void original(Sprite sprite)
        {
            assert(magnifier, "Magnifier not created");
            _original = sprite;

            assert(magnifier.width > 0 && magnifier.height > 0);
            auto widthZoom = sprite.width / magnifier.width;
            auto heightZoom = sprite.height / magnifier.height;
            if (magnifier.width < widthZoom)
            {
                magnifier.width = widthZoom;
            }
            if (magnifier.height < heightZoom)
            {
                magnifier.height = heightZoom;
            }
        }

    }
