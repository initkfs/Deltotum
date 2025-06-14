module api.dm.gui.controls.texts.base_mono_text;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.gui.controls.texts.buffers.base_text_buffer : BaseTextBuffer;
import api.dm.gui.controls.texts.buffers.array_text_buffer : ArrayTextBuffer;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;

import Math = api.math;

import core.stdc.stdlib : malloc, free, realloc;
import std.conv : to;

struct TextStruct
{
    private
    {
        size_t[] _lineBreaks;
        size_t _length;
    }

    size_t initCapacity = 5;

    bool create()
    {
        if (_lineBreaks.length > 0)
        {
            destroy;
        }

        assert(initCapacity > 0);

        auto buffPtr = cast(size_t*) malloc(initCapacity * size_t.sizeof);
        if (!buffPtr)
        {
            return false;
        }

        _lineBreaks = buffPtr[0 .. initCapacity];
        return true;
    }

    bool isCreated() const @nogc nothrow => _lineBreaks.length > 0;

    void destroy()
    {
        if (isCreated)
        {
            free(_lineBreaks.ptr);
        }
    }

    void opOpAssign(string op : "~")(size_t rhs)
    {
        if (!isCreated && !create)
        {
            assert(false, "Error creating text struct buffer");
        }

        if (_length + 1 >= _lineBreaks.length && !grow)
        {
            assert(false, "Error text struct buffer growing");
        }

        _lineBreaks[_length] = rhs;
        _length++;
    }

    bool grow()
    {
        const newCapacity = _lineBreaks.length * 2;
        auto newBufferPtr = cast(size_t*) realloc(_lineBreaks.ptr, newCapacity * size_t.sizeof);
        if (!newBufferPtr)
        {
            return false;
        }

        _lineBreaks = newBufferPtr[0 .. newCapacity];
        return true;
    }

    void reset()
    {
        _length = 0;
    }

    inout(size_t[]) lineBreaks() inout => _lineBreaks[0 .. _length];
    size_t length() => _length;
}

/**
 * Authors: initkfs
 */
class BaseMonoText : Control
{
    int spaceWidth = 5;
    int rowHeight = 0;

    RGBA _color;
    FontSize fontSize = FontSize.medium;

    Sprite2d focusEffect;
    Sprite2d delegate() focusEffectFactory;

    void delegate(ref KeyEvent) onEnter;

    bool isReduceWidthHeight = true;

    bool isShowNewLineGlyph;
    bool isRebuildRows;

    TextStruct textStruct;

    void delegate() onTextChange;

    protected
    {
        BaseTextBuffer!Glyph _textBuffer;
        double scrollPosition = 0;
    }

    this(typeof(_textBuffer) newBuffer = null)
    {
        isFocusable = true;
        _textBuffer = newBuffer ? newBuffer : new ArrayTextBuffer!Glyph;
    }

    size_t[] lineBreaks() => textStruct.lineBreaks;
    Glyph[] allGlyphs() => _textBuffer.buffer;
    size_t bufferLength() => _textBuffer.length;
    ref inout(typeof(_textBuffer)) textBuffer() inout => _textBuffer;

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseTextTheme;
    }

    void loadBaseTextTheme()
    {
        if (_color == RGBA.init)
        {
            _color = theme.colorText;
        }
    }

    void updateRows(bool isForce = false)
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

        updateTextStruct;
    }

    Vec2d viewportRowIndex() => viewportRowIndex(scrollPosition);

    Vec2d viewportRowIndex(double scrollPosition)
    {
        if (textStruct.lineBreaks.length == 0)
        {
            return Vec2d(0, 0);
        }

        const rowsInViewport = this.rowsInViewport;
        if (rowsInViewport == 0)
        {
            return Vec2d(0, 0);
        }

        if (scrollPosition >= 1.0)
        {
            scrollPosition = 1;
        }

        size_t lastRowIndex = textStruct.lineBreaks.length;
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

    Glyph[] viewportRows(out size_t firstRowIndex) => viewportRows(
        firstRowIndex, scrollPosition);

    Glyph[] viewportRows(out size_t firstRowIndex, double scrollPosition)
    {
        //TODO first line without \n
        if (textStruct.lineBreaks.length == 0)
        {
            return null;
        }

        Vec2d rowIndex = viewportRowIndex(scrollPosition);

        size_t startRowIndex = cast(size_t) rowIndex.x;
        size_t endRowIndex = cast(size_t) rowIndex.y;

        size_t maxEndIndex = textStruct.lineBreaks.length;
        if (maxEndIndex > 0)
        {
            maxEndIndex--;
        }

        if (endRowIndex > maxEndIndex)
        {
            endRowIndex = maxEndIndex;
        }

        //TextStruct([], [11, 23, 35, 47, 55])

        auto startBreakIndex = textStruct.lineBreaks[startRowIndex];
        auto endBreakIndex = textStruct.lineBreaks[endRowIndex];

        size_t glyphLastIndex = _textBuffer.length;
        if (glyphLastIndex > 0)
        {
            glyphLastIndex--;
        }

        size_t startGlyphIndex;
        size_t endGlyphIndex = (endBreakIndex <= glyphLastIndex) ? endBreakIndex + 1 : endBreakIndex;

        if (startBreakIndex != 0 && startRowIndex > 0)
        {
            auto prevLineBreaks = textStruct.lineBreaks[startRowIndex - 1];
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

    size_t rowsInViewport()
    {
        if (rowHeight == 0)
        {
            return 0;
        }

        return to!(size_t)((height - padding.height) / rowHeight);
    }

    Glyph charToGlyph(dchar ch)
    {
        Glyph newGlyph;
        bool isFound;
        //TODO hash map
        foreach (glyph; asset.fontBitmap(fontSize).glyphs)
        {
            if (glyph.grapheme == ch)
            {
                newGlyph = glyph;
                isFound = true;
                break;
            }
        }

        if (!isFound)
        {
            newGlyph = asset.fontBitmap.placeholder;
        }

        return newGlyph;
    }

    void textToGlyphs(const(dchar)[] textString, scope bool delegate(Glyph, size_t) onGlyphIsContinue)
    {
        const textLength = textString.length;

        if (textLength == 0)
        {
            return;
        }

        foreach (i, ref grapheme; textString)
        {
            Glyph newGlyph = charToGlyph(grapheme);
            if (!onGlyphIsContinue(newGlyph, i))
            {
                break;
            }
        }
    }

    void updateTextStruct()
    {
        textStruct.reset;

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
        double lastRowWidth = 0;

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
                textStruct ~= i;
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
                    textStruct ~= j;
                    continue;
                }

                textStruct ~= (i == 0 ? 0 : i - 1);
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

        if (!_textBuffer.buffer[lastIndex].isNEL)
        {
            textStruct ~= lastIndex;
        }

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

        auto newHeight = textStruct.lineBreaks.length * rowHeight + padding.height;
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

    double calcTextWidth(const(dchar)[] str)
    {
        return calcTextWidth(str, fontSize);
    }

    double calcTextWidth(const(dchar)[] str, FontSize fontSize)
    {
        double sum = 0;
        foreach (ref grapheme; str)
        {
            foreach (glyph; asset.fontBitmap(fontSize).glyphs)
            {
                if (glyph.grapheme == grapheme)
                {
                    sum += glyph.geometry.width;
                }
            }
        }
        return sum;
    }

    dstring glyphsToStr(Glyph[] glyphs)
    {
        import std.algorithm.iteration : map;
        import std.conv : to;

        return glyphs.map!(g => g.grapheme)
            .to!dstring;
    }

    void setLargeSize()
    {
        fontSize = FontSize.large;
    }

    void setMediumSize()
    {
        fontSize = FontSize.medium;
    }

    void setSmallSize()
    {
        fontSize = FontSize.small;
    }

    auto textTo(T)() => text.to!T;
    string textString() => textTo!string;

    size_t rowCount() => textStruct.lineBreaks.length;

    dstring text()
    {
        if (!isBuilt)
        {
            return "";
        }

        import std.array : appender;

        auto builder = appender!dstring;
        foreach (ref glyph; glyphBuffer)
        {
            builder ~= glyph.grapheme;
        }
        return builder.data;
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

        if (!_textBuffer.create(t))
        {
            logger.error("Error creating buffer text: ", t);
        }
    }

    Glyph[] glyphBuffer()
    {
        return _textBuffer.buffer;
    }

    void scrollTo(double value)
    {
        scrollPosition = value;
    }

    override void dispose()
    {
        super.dispose;

        textStruct.destroy;
    }
}
