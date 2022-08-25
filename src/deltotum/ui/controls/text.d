module deltotum.ui.controls.text;

import deltotum.ui.controls.control : Control;
import deltotum.ui.texts.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;
import deltotum.display.flip : Flip;
import deltotum.i18n.langs.glyph : Glyph;

import std.stdio;

/**
 * Authors: initkfs
 * TODO optimizations oldText == text
 */
class Text : Control
{
    @property string text;
    @property int spaceWidth = 5;

    protected
    {
        @property string oldText;
        @property Glyph[] glyphs;
    }

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
        if (textString.length == 0)
        {
            return [];
        }

        import std.uni : isSpace;
        import std.conv : to;

        dstring mustBeText = to!dstring(textString);

        //Grapheme walkLength?
        Glyph[] glyphs = new Glyph[mustBeText.length];

        foreach (dchar letter; mustBeText)
        {
            //TODO isSpace?
            if (letter.isSpace)
            {
                Rect2d emptyGeometry = Rect2d(0, 0, spaceWidth, 0);
                //TODO alphabet?
                glyphs ~= Glyph(null, letter, emptyGeometry, true);
                continue;
            }

            foreach (i, glyph; assets.defaultBitmapFont.glyphs)
            {
                if (glyph.grapheme == letter)
                {
                    glyphs ~= glyph;
                    break;
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

        foreach (glyph; glyphs)
        {
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

    override void drawContent()
    {
        if (text.length == 0)
        {
            return;
        }

        if (oldText != text)
        {
            glyphs = textToGlyphs(text);
            oldText = text;
        }

        renderText(glyphs);
    }
}
