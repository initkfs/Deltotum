module api.dm.gui.controls.texts.text_view;

import api.dm.gui.controls.texts.editable_text : EditableText, DocStruct;
import api.dm.gui.controls.texts.buffers.array_text_buffer : ArrayTextBuffer;
import api.dm.gui.controls.control : Control;
import api.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.math.flip : Flip;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.gui.controls.texts.text : Text;

import std.stdio;
import core.stdc.stdlib;
import Math = api.math;
import std.conv : to;

/**
 * Authors: initkfs
 */
class TextView : EditableText
{
    protected
    {
        double scrollPosition = 0;
    }

    BitmapFont fontTexture;

    bool isRebuildRows;

    protected
    {
        double lastRowWidth = 0;
        size_t textBufferCount;
        dstring tempText;

        Glyph*[] lastViewport;
    }

    this(string text)
    {
        import std.conv : to;

        this(text.to!dstring);
    }

    this(dstring text = "")
    {
        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        this.layout = new ManagedLayout;
        tempText = text;
    }

    override void initialize()
    {
        super.initialize;
        invalidateListeners ~= () { updateRows; };

        if (!_textBuffer.itemProvider)
        {
            _textBuffer.itemProvider = (ch) => charToGlyph(ch);
        }
    }

    void bufferCreate()
    {
        _textBuffer.create(tempText);
        tempText = null;
    }

    override size_t[] lineBreaks() => docStruct.lineBreaks;
    override Glyph[] allGlyphs() => _textBuffer.buffer;
    override size_t bufferLength() => _textBuffer.length;

    override void create()
    {
        super.create;

        bufferCreate;
        setColorTexture;

        updateRows;
    }

    override void update(double delta)
    {
        super.update(delta);

        if (isRebuildRows)
        {
            updateRows;
            isRebuildRows = false;
        }
    }

    override bool insertText(size_t pos, dchar text)
    {
        dchar[1] newText = [text];
        if (_textBuffer.insert(cast(int) pos, newText[]))
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

    protected void textToGlyphsBuffer(const(dchar)[] textString, bool isAppend = false)
    {
        const textLength = textString.length;

        if (textLength == 0)
        {
            return;
        }
    }

    void glyphsToDocStruct()
    {
        //TODO reuse array
        docStruct = DocStruct.init;

        if (_textBuffer.length == 0)
        {
            return;
        }

        //rowHeight = cast(int) glyphs[0].geometry.height;

        const double startRowTextX = padding.left;
        const double endRowTextX = maxWidth - padding.right;

        const double startRowTextY = padding.top;

        double glyphPosX = startRowTextX;
        double glyphPosY = startRowTextY;

        double maxRowWidth = 0;
        lastRowWidth = 0;

        size_t lastIndex;
        foreach (ref i, ref item; _textBuffer.buffer)
        {
            lastIndex = i;

            Glyph* glyph = &item;
            auto newRowHeight = cast(int) glyph.geometry.height;
            if (newRowHeight > rowHeight)
            {
                rowHeight = newRowHeight;
            }

            auto nextGlyphPosX = glyphPosX + glyph.geometry.width;

            if (glyph.isNEL)
            {
                docStruct.lineBreaks ~= i;
                glyphPosX = startRowTextX;
                glyphPosY += rowHeight;
                lastRowWidth = 0;
                continue;
            }
            else if (nextGlyphPosX > endRowTextX)
            {
                bool isLeftSpace;
                size_t j = i;
                searchLeftSpace: while (j >= 0)
                {
                    auto leftGlyph = _textBuffer.buffer[j];
                    if (leftGlyph.grapheme == ' ' || leftGlyph.isNEL)
                    {
                        isLeftSpace = true;
                        break searchLeftSpace;
                    }
                    j--;
                }

                if (isLeftSpace)
                {
                    glyphPosX = startRowTextX;
                    glyphPosY += rowHeight;
                    lastRowWidth = 0;

                    size_t currPosIndexDiff = i - j;
                    //TODO loop goes through some characters twice 
                    i -= currPosIndexDiff;
                    docStruct.lineBreaks ~= j;
                    continue;
                }

                docStruct.lineBreaks ~= (i == 0 ? 0 : i - 1);
                glyphPosX = startRowTextX;
                glyphPosY += rowHeight;
                lastRowWidth = 0;
            }

            //control glyphs reset width
            lastRowWidth += glyph.geometry.width;
            if (lastRowWidth > maxRowWidth)
            {
                maxRowWidth = lastRowWidth;
            }

            glyph.pos.x = glyphPosX;
            glyph.pos.y = glyphPosY;
            glyphPosX += glyph.geometry.width;
        }

        docStruct.lineBreaks ~= lastIndex;

        auto fullRowWidth = maxRowWidth + padding.width;

        if (fullRowWidth > width)
        {
            width = Math.min(maxWidth, fullRowWidth);
        }
        else
        {
            if (isReduceWidthHeight)
            {
                //TODO check minHeight;
                width = maxRowWidth;
            }
        }

        auto newHeight = docStruct.lineBreaks.length * rowHeight + padding.height;
        if (newHeight > height)
        {
            import std.algorithm.comparison : min;

            height = Math.min(maxHeight, newHeight);
        }
        else
        {
            if (isReduceWidthHeight)
            {
                //TODO check minHeight;
                height = newHeight;
            }
        }
    }

    override void updateRows(bool isForce = false)
    {
        if (!isBuilt && !isForce)
        {
            isRebuildRows = true;
            return;
        }

        isAllowInvalidate = false;
        scope (exit)
        {
            isAllowInvalidate = true;
        }

        glyphsToDocStruct;
    }

    void addRows(const(dchar)[] text)
    {
        // textToGlyphsBuffer(text, isAppend:
        //     true);
        // //TODO only append
        // this.rows = glyphsBufferToRows;
    }

    override bool canChangeWidth(double value)
    {
        if (lastRowWidth > 0 && value < (lastRowWidth + padding.width))
        {
            return false;
        }
        return super.canChangeWidth(value);
    }

    protected void renderText(Glyph[] glyphs, size_t startIndex)
    {
        if (width == 0 || height == 0 || glyphs.length == 0)
        {
            return;
        }

        const thisBounds = boundsRect;

        auto rowHeight = cast(int) glyphs[0].geometry.height;

        const double startRowTextY = padding.top;
        double glyphPosY = startRowTextY;

        import std.range : assumeSorted;

        auto sortedLineBreaks = docStruct.lineBreaks.assumeSorted;
        size_t lastIndex = glyphs.length - 1;

        foreach (ri, ref Glyph glyph; glyphs)
        {
            glyph.pos.y = glyphPosY;

            if (sortedLineBreaks.contains(startIndex + ri))
            {
                glyphPosY += rowHeight;
            }

            if (glyph.isNEL)
            {
                continue;
            }

            Rect2d textureBounds = glyph.geometry;
            Rect2d destBounds = Rect2d(thisBounds.x + glyph.pos.x, thisBounds.y + glyph.pos.y, glyph
                    .geometry.width, glyph
                    .geometry.height);
            fontTexture.drawTexture(textureBounds, destBounds, angle, Flip
                    .none);
        }
    }

    void onFontTexture(scope bool delegate(Texture2d, const(Glyph*) glyph) onTextureIsContinue)
    {
        // foreach (TextRow row; rows)
        // {
        //     foreach (Glyph* glyph; row.glyphs)
        //     {
        //         if (!onTextureIsContinue(fontTexture, glyph))
        //         {
        //             break;
        //         }
        //     }
        // }
    }

    double rowGlyphWidth()
    {
        double result = 0;
        // foreach (TextRow row; rows)
        // {
        //     foreach (Glyph* glyph; row.glyphs)
        //     {
        //         result += glyph.geometry.width;
        //     }
        // }
        return result;
    }

    double rowGlyphHeight()
    {
        double result = 0;
        // foreach (TextRow row; rows)
        // {
        //     foreach (Glyph* glyph; row.glyphs)
        //     {
        //         auto h = glyph.geometry.height;
        //         if (h > result)
        //         {
        //             result = h;
        //         }
        //     }
        // }
        return result;
    }

    void copyTo(Texture2d texture, Rect2d destBounds)
    {
        assert(texture);

        import api.math.geom2.rect2 : Rect2d;

        //TODO remove duplication with render()
        // foreach (TextRow row; rows)
        // {
        //     foreach (Glyph* glyph; row.glyphs)
        //     {
        //         Rect2d textureBounds = glyph.geometry;
        //         texture.copyFrom(fontTexture, textureBounds, destBounds);
        //     }
        // }
    }

    void appendText(const(dchar)[] text)
    {
        addRows(text);
        setInvalid;
    }

    void text(string t, bool isTriggerListeners = true)
    {
        import std.conv : to;

        this.text(t.to!dstring, isTriggerListeners);
    }

    void text(dstring t, bool isTriggerListeners = true)
    {
        if (!isBuilt || !isCreated)
        {
            isRebuildRows = true;
            return;
        }

        updateRows(isForce : true);

        if (onTextChange && isTriggerListeners)
        {
            onTextChange();
        }
    }

    auto textTo(T)() => text.to!T;
    string textString() => textTo!string;

    Glyph[] bufferText()
    {
        // assert(_textBuffer.length >= textBufferCount);
        // return _textBuffer[0 .. textBufferCount];
        return _textBuffer.buffer;
    }

    dstring text()
    {
        if (!isBuilt)
        {
            return "";
        }

        import std.array : appender;

        auto builder = appender!dstring;
        foreach (ref glyph; bufferText)
        {
            builder ~= glyph.grapheme;
        }
        return builder.data;
    }

    protected void setColorTexture()
    {
        if (!asset.hasColorBitmap(_color, fontSize))
        {
            fontTexture = asset.fontBitmap(fontSize).copyBitmap;
            fontTexture.color = _color;
            fontTexture.blendModeBlend;
            asset.addFontColorBitmap(fontTexture, _color, fontSize);
            logger.tracef("Create new font with size %s, color %s", fontSize, _color);
        }
        else
        {
            fontTexture = asset.fontColorBitmap(_color, fontSize);
        }
    }

    RGBA color()
    {
        return _color;
    }

    void color(RGBA color)
    {
        _color = color;
        if (fontTexture)
        {
            setColorTexture;
        }
        setInvalid;
    }

    size_t rowsInViewport()
    {
        if (rowHeight == 0)
        {
            return 0;
        }

        return to!(size_t)((height - padding.height) / rowHeight);
    }

    Vec2d viewportRowIndex() => viewportRowIndex(scrollPosition);

    Vec2d viewportRowIndex(double scrollPosition)
    {
        if (docStruct.lineBreaks.length == 0)
        {
            return Vec2d(0, 0);
        }

        const rowsInViewport = this.rowsInViewport;
        if (rowsInViewport == 0)
        {
            return Vec2d(0, 0);
        }

        size_t lastRowIndex = docStruct.lineBreaks.length;
        if (lastRowIndex > 0)
        {
            lastRowIndex--;
        }

        //TODO only one hanging line in text
        size_t mustBeLastRowIndex = lastRowIndex;
        if (mustBeLastRowIndex > rowsInViewport)
        {
            mustBeLastRowIndex -= rowsInViewport - 1;
        }

        import std.math.rounding : round;

        size_t mustBeStartRowIndex = to!size_t(round(scrollPosition * mustBeLastRowIndex));

        size_t mustBeEndRowIndex = mustBeStartRowIndex + rowsInViewport - 1;
        //[start..end+1]
        const maxEndIndex = lastRowIndex;
        if (mustBeEndRowIndex > maxEndIndex)
        {
            mustBeEndRowIndex = maxEndIndex;
        }

        return Vec2d(mustBeStartRowIndex, mustBeEndRowIndex);
    }

    override Glyph[] viewportRows(out size_t firstRowIndex) => viewportRows(
        firstRowIndex, scrollPosition);

    Glyph[] viewportRows(out size_t firstRowIndex, double scrollPosition)
    {
        //TODO first line without \n
        if (docStruct.lineBreaks.length == 0)
        {
            return null;
        }

        Vec2d rowIndex = viewportRowIndex(scrollPosition);

        size_t startRowIndex = cast(size_t) rowIndex.x;
        size_t endRowIndex = cast(size_t) rowIndex.y;

        size_t maxEndIndex = docStruct.lineBreaks.length;
        if (maxEndIndex > 0)
        {
            maxEndIndex--;
        }

        if (endRowIndex > maxEndIndex)
        {
            endRowIndex = maxEndIndex;
        }

        //DocStruct([], [11, 23, 35, 47, 55])

        auto startBreakIndex = docStruct.lineBreaks[startRowIndex];
        auto endBreakIndex = docStruct.lineBreaks[endRowIndex];

        size_t glyphLastIndex = _textBuffer.length;
        if (glyphLastIndex > 0)
        {
            glyphLastIndex--;
        }

        size_t startGlyphIndex;
        size_t endGlyphIndex = (endBreakIndex <= glyphLastIndex) ? endBreakIndex + 1 : endBreakIndex;

        if (startBreakIndex != 0 && startRowIndex > 0)
        {
            auto prevLineBreaks = docStruct.lineBreaks[startRowIndex - 1];
            //TODO check last index >= glyph.length
            startGlyphIndex = prevLineBreaks < glyphLastIndex ? prevLineBreaks + 1 : prevLineBreaks;
        }

        // if (endRowIndex == maxEndIndex)
        // {
        //     endGlyphIndex++;
        // }

        Glyph[] glyphs = _textBuffer.buffer[startGlyphIndex .. endGlyphIndex];

        firstRowIndex = startGlyphIndex;
        return glyphs;
    }

    override void drawContent()
    {
        if (docStruct.lineBreaks.length == 0)
        {
            return;
        }

        size_t rowStartIndex;
        Glyph[] glyphs = viewportRows(rowStartIndex);
        renderText(glyphs, rowStartIndex);
    }

    void scrollTo(double value)
    {
        scrollPosition = value;
    }

    size_t rowCount() => docStruct.lineBreaks.length;
}

unittest
{
    import api.math.geom2.rect2 : Rect2d;
    import api.math.geom2.vec2 : Vec2d;

    auto textView = new TextView("Hello world\nThis is a very short text for the experiment");
    textView.textBuffer.itemProvider = (ch) {
        return Glyph(ch, Rect2d(0, 0, 10, 10), Vec2d(0, 0), null, false, ch == '\n');
    };
    textView.width = 123;
    textView.maxWidth = textView.width;
    textView.height = 40;
    textView.maxHeight = textView.height;

    textView.bufferCreate;

    textView.glyphsToDocStruct;

    assert(textView.rowCount == 5);
    assert(textView.docStruct == DocStruct([], [11, 22, 34, 46, 55]));

    assert(textView.rowsInViewport == 4);
    assert(textView.viewportRowIndex == Vec2d(0, 3));
    assert(textView.viewportRowIndex(1) == Vec2d(4, 4));

    size_t firstRowIndex;
    Glyph[] rows = textView.viewportRows(firstRowIndex);
    assert(rows.length == 47);

    dstring rowsStr = textView.glyphsToStr(rows);
    assert(rowsStr == "Hello world\nThis is a very short text for the e");

    Glyph[] endRows = textView.viewportRows(firstRowIndex, 1);
    dstring rowsStr1 = textView.glyphsToStr(endRows);
    assert(rowsStr1 == "xperiment");
}
