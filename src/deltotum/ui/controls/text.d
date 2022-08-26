module deltotum.ui.controls.text;

import deltotum.ui.controls.control : Control;
import deltotum.ui.texts.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;
import deltotum.display.flip : Flip;
import deltotum.i18n.langs.glyph : Glyph;

import std.stdio;

public
{
    struct TextRow
    {
        Glyph[] glyphs = [];
    }
}

/**
 * Authors: initkfs
 * TODO optimizations oldText == text
 */
class Text : Control
{
    @property string text;
    @property int spaceWidth = 5;
    //TODO from font?
    @property int rowHeight = 16;

    protected
    {
        @property string oldText;
        @property TextRow[] rows = [];
    }

    this(string text = "text")
    {
        super();
        //TODO validate
        this.text = text;
        this.width = 100;
        this.height = 50;
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

        //import std.uni : byGrapheme;
        //import std.range.primitives : walkLength;

        dstring mustBeText = to!dstring(textString);

        //Grapheme walkLength?
        Glyph[] newGlyphs = [];
        newGlyphs.reserve(mustBeText.length);

        foreach (dchar letter; mustBeText)
        {
            if (letter.isSpace)
            {
                Rect2d emptyGeometry = Rect2d(0, 0, spaceWidth, 0);
                //TODO alphabet?
                newGlyphs ~= Glyph(null, letter, emptyGeometry, true);
                continue;
            }

            foreach (i, glyph; assets.defaultBitmapFont.glyphs)
            {
                if (glyph.grapheme == letter)
                {
                    newGlyphs ~= glyph;
                    break;
                }
            }
        }

        return newGlyphs;
    }

    void updateRows()
    {
        this.rows = [];
        if (width == 0 || height == 0)
        {
            return;
        }

        auto glyphs = textToGlyphs(text);

        double glyphPosX = 0;
        TextRow row;
        foreach (Glyph glyph; glyphs)
        {
            if (glyphPosX + glyph.geometry.width > (x + width - padding.right))
            {
                rows ~= row;
                row = TextRow();
                glyphPosX = padding.left;
            }

            row.glyphs ~= glyph;
            glyphPosX += glyph.geometry.width;
        }

        if (row.glyphs.length > 0)
        {
            rows ~= row;
        }
    }

    protected void renderText(TextRow[] rows)
    {
        if (width == 0 || height == 0)
        {
            return;
        }

        Vector2d position = Vector2d(x, y);
        position.x += padding.left;
        position.y += padding.top;

        foreach (TextRow row; rows)
        {
            foreach (Glyph glyph; row.glyphs)
            {
                if (position.x + glyph.geometry.width > (x + width - padding.right))
                {
                    position.y += rowHeight;
                    position.x = padding.left;
                }

                if (position.y + rowHeight > (y + height - padding.bottom))
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

    override void drawContent()
    {
        if (text.length == 0)
        {
            return;
        }

        if (oldText != text)
        {
            updateRows;
            oldText = text;
        }

        renderText(rows);
    }
}
