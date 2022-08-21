module deltotum.ui.controls.text;

import deltotum.ui.controls.control : Control;
import deltotum.ui.texts.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;
import deltotum.display.flip : Flip;
import deltotum.i18n.texts.glyph : Glyph;

import std.stdio;

/**
 * Authors: initkfs
 * TODO optimizations oldText == text
 */
class Text : Control
{
    @property string text;

    this(string text = "text")
    {
        super();
        //TODO validate
        this.text = text;
    }

    override void create()
    {
        backgroundFactory = null;
        super.create;
    }

    protected Glyph[] textToGlyphs(string textString)
    {
        Glyph[] glyphs = [];

        if (textString.length == 0)
        {
            return glyphs;
        }

        import std.uni : isSpace;
        import std.conv : to;

        dstring mustBeText = to!dstring(textString);

        foreach (dchar letter; mustBeText)
        {
            //TODO isSpace?
            if (letter.isSpace)
            {
                Rect2d emptyGeometry;
                //TODO alphabet?
                glyphs ~= Glyph(null, letter, emptyGeometry, true);
                continue;
            }

            foreach (i, glyph; assets.defaultBitmapFont.glyphs)
            {
                if (glyph.grapheme == letter)
                {
                    glyphs ~= glyph;
                }
            }
        }

        return glyphs;
    }

    protected void renderText(Glyph[] glyphs)
    {
        if (glyphs.length == 0)
        {
            return;
        }
        Vector2d position = Vector2d(x, y);

        enum spaceWidth = 5;

        foreach (glyph; glyphs)
        {
            if (glyph.isEmpty)
            {
                position.x += spaceWidth;
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

    protected void renderText(string text)
    {
        Glyph[] glyphs = textToGlyphs(text);
        renderText(glyphs);
    }

    override void drawContent()
    {
        if (text.length == 0)
        {
            return;
        }

        renderText(text);
    }
}
