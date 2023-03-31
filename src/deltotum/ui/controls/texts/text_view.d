module deltotum.ui.controls.texts.text_view;

import deltotum.ui.controls.control : Control;
import deltotum.ui.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.maths.shapes.rect2d : Rect2d;
import deltotum.maths.vector2d : Vector2d;
import deltotum.toolkit.display.flip : Flip;
import deltotum.ui.fonts.glyphs.glyph : Glyph;
import deltotum.ui.controls.texts.text : Text;

import std.stdio;

struct TextRow
{
    Glyph[] glyphs;
}

/**
 * Authors: initkfs
 */
class TextView : Text
{
    protected
    {
        double scrollPosition = 0;
    }

    this(string text = "text")
    {
        super(text);
    }

    override void drawContent()
    {
        if (text.length == 0)
        {
            return;
        }

        if (width == 0 || height == 0)
        {
            return;
        }

        if (oldText != text)
        {
            updateRows;
            oldText = text;
        }

        if (rows.length == 0)
        {
            return;
        }

        import std.conv : to;

        //TODO Gap buffer, TextRow[]?
        const lastRowIndex = rows.length - 1;
        const rowsInViewport = to!(int)((height - padding.height) / rowHeight);
        if (rows.length <= rowsInViewport)
        {
            renderText(rows);
        }
        else
        {
            import std.math.rounding : round;

            //TODO only one hanging line in text
            size_t mustBeLastRowIndex = lastRowIndex;
            if(mustBeLastRowIndex > rowsInViewport){
                mustBeLastRowIndex-= rowsInViewport - 1;
            }

            size_t mustBeStartRowIndex = to!size_t(round(scrollPosition * mustBeLastRowIndex));
            size_t mustBeEndRowIndex = mustBeStartRowIndex + rowsInViewport - 1;
            if (mustBeEndRowIndex > lastRowIndex)
            {
                mustBeEndRowIndex = lastRowIndex;
            }

            auto rowsForView = rows[mustBeStartRowIndex  .. mustBeEndRowIndex + 1];
            renderText(rowsForView);
        }
    }

    void scrollTo(double value)
    {
        scrollPosition = value;
    }
}
