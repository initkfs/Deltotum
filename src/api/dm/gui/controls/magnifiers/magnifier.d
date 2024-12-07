module api.dm.gui.controls.magnifiers.magnifier;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites.sprites2d.layouts.layout2d : Layout2d;
import api.dm.kit.sprites.sprites2d.layouts.hlayout : HLayout;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.rect2 : Rect2d;
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
        Texture2d magnifier;
        Sprite2d _original;
    }

    Source source = Source.screen;

    double scale = 1;
    double defaultWidth = 100;
    double defaultHeight = 100;

    this()
    {
        import api.dm.kit.sprites.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;

        onPointerEnter ~= (ref e) {
            if (magnifier && !isLastIndex(magnifier))
            {
                changeIndexToLast(magnifier);
            }
            magnifier.isVisible = true;
            input.systemCursor.hide;
        };

        onPointerMove ~= (ref e) {
            auto pointerPos = input.pointerPos;

            auto magnCenterX = magnifier.boundsRect.halfWidth;
            auto magnCenterY = magnifier.boundsRect.halfHeight;

            auto magnPosX = pointerPos.x - magnCenterX;
            auto magnPosY = pointerPos.y - magnCenterY;

            magnifier.x = magnPosX;
            magnifier.y = magnPosY;

            auto mouseXRel = pointerPos.x - x;
            auto mouseYRel = pointerPos.y - y;

            auto originalXRel = (_original.width * mouseXRel) / magnifier.width;
            auto originalYRel = (_original.height * mouseYRel) / magnifier.height;

            auto originalBoundsX = originalXRel + magnifier.boundsRect.halfWidth;
            auto originalBoundsY = originalYRel + magnifier.boundsRect.halfHeight;

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
                        import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;

                        Texture2d originalTexture = cast(Texture2d) _original;
                        assert(originalTexture, "Source is not a texture");
                        magnifier.setRendererTarget;
                        textureBounds = Rect2d(originalBoundsX, originalBoundsY, magnifier.width, magnifier
                                .height);
                        auto destBounds = Rect2d(0, 0, magnifier.width, magnifier.height);
                        originalTexture.drawTexture(textureBounds, destBounds);
                        magnifier.restoreRendererTarget;
                        break;
                }
            };

            onPointerExit ~= (ref e) {
                magnifier.isVisible = false;
                input.systemCursor.show;
            };
        }

        override void create()
        {
            super.create;

            magnifier = new Texture2d(defaultWidth * scale, defaultHeight * scale);
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

        void original(Sprite2d sprite)
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
