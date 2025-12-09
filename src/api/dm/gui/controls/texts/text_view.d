module api.dm.gui.controls.texts.text_view;

import api.dm.gui.controls.texts.base_mono_text : BaseMonoText;
import api.dm.gui.controls.texts.base_editable_text : BaseEditableText;
import api.dm.gui.controls.control : Control;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;

/**
 * Authors: initkfs
 */
class TextView : BaseEditableText
{
    this(string text)
    {
        super(text);
    }

    this(dstring text = "")
    {
        super(text);
    }

    override bool insertText(size_t pos, dchar text)
    {
        dchar[1] str = text;
        if (_textBuffer.insert(cast(int) pos, str[]))
        {
            return true;
        }
        return false;
    }

    override bool removePrevText(size_t pos, size_t bufferLength)
    {
        auto size = _textBuffer.removePrev(pos, bufferLength);
        return size == bufferLength;
    }
}

unittest
{
    import api.math.geom2.rect2 : Rect2f;
    import api.math.geom2.vec2 : Vec2f;

    auto textView = new TextView("Hello world\nThis is a very short text for the experiment");
    textView.buffer.itemProvider = (ch) {
        return Glyph(ch, Rect2f(0, 0, 10, 10), Vec2f(0, 0), null, false, ch == '\n');
    };
    textView.width = 123;
    textView.maxWidth = textView.width;
    textView.height = 40;
    textView.maxHeight = textView.height;

    textView.bufferCreate;

    textView.updateTextLayout;

    assert(textView.rowCount == 5);
    assert(textView.textLayout.lineBreaks == [11u, 21, 32, 45, 55]);

    assert(textView.rowsInViewport == 4);
    assert(textView.viewportRowIndex == Vec2f(0, 3));
    assert(textView.viewportRowIndex(1) == Vec2f(4, 4));

    size_t firstRowIndex;
    Glyph[] rows = textView.viewportRows(firstRowIndex);
    assert(rows.length == 46);

    dstring rowsStr = textView.glyphsToStr(rows);
    assert(rowsStr == "Hello world\nThis is a very short text for the ");

    Glyph[] endRows = textView.viewportRows(firstRowIndex, 1);
    dstring rowsStr1 = textView.glyphsToStr(endRows);
    assert(rowsStr1 == "experiment");
}
