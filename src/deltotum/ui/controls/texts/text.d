module deltotum.ui.controls.texts.text;

import deltotum.ui.controls.control : Control;
import deltotum.ui.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.maths.shapes.rect2d : Rect2d;
import deltotum.maths.vector2d : Vector2d;
import deltotum.toolkit.display.flip : Flip;
import deltotum.ui.fonts.glyphs.glyph : Glyph;
import deltotum.toolkit.graphics.colors.rgba : RGBA;

import std.stdio;

protected
{
    struct TextRow
    {
        Glyph[] glyphs;
    }
}

/**
 * Authors: initkfs
 * TODO optimizations oldText == text
 */
class Text : Control
{
    string text;
    int spaceWidth = 5;
    //TODO from font?
    int rowHeight = 16;

    RGBA color = RGBA.white;

    protected
    {
        string oldText;
        TextRow[] rows;
    }

    this(string text = "text")
    {
        //TODO validate
        this.text = text;
        this.maxWidth = 100;
        this.maxHeight = 50;
    }

    override void initialize()
    {
        super.initialize;
        backgroundFactory = null;
    }

    override void create()
    {
        super.create;
        drawContent;
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
        Glyph[] newGlyphs;
        newGlyphs.reserve(mustBeText.length);

        foreach (dchar letter; mustBeText)
        {
            if (letter.isSpace)
            {
                Rect2d emptyGeometry = Rect2d(0, 0, spaceWidth, 0);
                //TODO alphabet?
                newGlyphs ~= Glyph(letter, emptyGeometry, true, null);
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

    protected TextRow[] textToRows(string text)
    {
        TextRow[] newRows;

        auto glyphs = textToGlyphs(text);
        if (glyphs.length == 0)
        {
            return newRows;
        }

        //TODO move to render\update
        width = padding.width;
        //max height?
        rowHeight = cast(int) glyphs[0].geometry.height;

        double glyphPosX = padding.left;
        TextRow row;
        foreach (Glyph glyph; glyphs)
        {
            //TODO move to render, bool check flags
            double newWidth = width + glyph.geometry.width;
            if (newWidth <= maxWidth)
            {
                width = newWidth;
            }

            if (glyphPosX + glyph.geometry.width > (x + width - padding.right))
            {
                newRows ~= row;
                row = TextRow();
                glyphPosX = padding.left;
            }

            row.glyphs ~= glyph;
            glyphPosX += glyph.geometry.width;
        }

        if (row.glyphs.length > 0)
        {
            newRows ~= row;
        }

        height = newRows.length * rowHeight + padding.height;

        return newRows;
    }

    void updateRows()
    {
        this.rows = textToRows(text);
    }

    void addRows(string text)
    {
        this.rows ~= textToRows(text);
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
                if (const err = window.renderer.drawTexture(assets.defaultBitmapFont.nativeTexture, textureBounds, destBounds, angle, Flip
                        .none))
                {
                    //TODO logging
                }

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

    void appendText(string text)
    {
        if (rows.length == 0)
        {
            this.text = text;
        }
        else
        {
            addRows(text);
            this.text ~= text;
            this.oldText = text;
        }
    }
}
