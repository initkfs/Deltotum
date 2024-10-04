module api.dm.gui.controls.texts.text_view;

import api.dm.gui.controls.control : Control;
import api.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d;
import api.math.flip : Flip;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.gui.controls.texts.text : Text;

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

    this(dstring text = "text")
    {
        super(text);
    }

    override void drawContent()
    {
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
