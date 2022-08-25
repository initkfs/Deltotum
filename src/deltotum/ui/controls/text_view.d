module deltotum.ui.controls.text_view;

import deltotum.ui.controls.control : Control;
import deltotum.ui.texts.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;
import deltotum.display.flip : Flip;
import deltotum.i18n.langs.glyph : Glyph;
import deltotum.ui.controls.text : Text;

import std.stdio;

/**
 * Authors: initkfs
 */
class TextView : Text
{

    this(string text = "text")
    {
        super(text);
    }

    override void create(){
        super.create;
        backgroundFactory = (width, height) {
            import deltotum.graphics.shapes.rectangle : Rectangle;

            auto background = new Rectangle(width, height, backgroundStyle);
            background.opacity = graphics.theme.controlOpacity;
            background.isLayoutManaged = false;
            return background;
        };

        createBackground(width, height);
    }

    override protected void renderText(Glyph[] glyphs)
    {
        if (width == 0 || height == 0)
        {
            return;
        }

        Vector2d position = Vector2d(x, y);
        position.x += padding.left;
        position.y += padding.top;

        //TODO from font?
        enum rowHeight = 15;

        foreach (Glyph glyph; glyphs)
        {
            if (position.x + glyph.geometry.width > (x + width - padding.right))
            {
                position.y += rowHeight;
                position.x = padding.left;
            }

            if (position.y + glyph.geometry.height > (y + height - padding.bottom))
            {
                break;
            }

            if (glyph.isEmpty)
            {
                position.x += glyph.geometry.width;
                continue;
            }

            Rect2d textureBounds = glyph.geometry;
            Rect2d destBounds = Rect2d(position.x, position.y, glyph.geometry.width, glyph
                    .geometry.height);
            window.renderer.drawTexture(assets.defaultBitmapFont.nativeTexture, textureBounds, destBounds, angle, Flip
                     .none);

            position.x += glyph.geometry.width;
        }
    }
}
