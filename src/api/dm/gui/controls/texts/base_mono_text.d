module api.dm.gui.controls.texts.base_mono_text;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.layouts.simple_text_layout : SimpleTextLayout;
import api.dm.gui.controls.texts.buffers.base_text_buffer : BaseTextBuffer;
import api.dm.gui.controls.texts.buffers.array_text_buffer : ArrayTextBuffer;

import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;

import Math = api.math;
import std.conv : to;

/**
 * Authors: initkfs
 */
class BaseMonoText : Control
{
    double spaceWidth = 5;
    double rowHeight = 0;

    RGBA _color;
    FontSize fontSize = FontSize.medium;

    bool isReduceWidthHeight = true;
    bool isShowNewLineGlyph;
    bool isRebuildRows;

    void delegate(ref KeyEvent) onEnter;
    void delegate() onTextChange;

    SimpleTextLayout textLayout;

    protected
    {
        BaseTextBuffer!Glyph _textBuffer;

        double scrollPosition = 0;
    }

    this(typeof(_textBuffer) newBuffer = null, bool isFocusable = true)
    {
        _textBuffer = newBuffer ? newBuffer : new ArrayTextBuffer!Glyph;
        this.isFocusable = isFocusable;
    }

    ref inout(typeof(_textBuffer)) buffer() inout => _textBuffer;
    size_t bufferLength() => _textBuffer.length;
    Glyph[] allGlyphs() => _textBuffer.buffer;
    size_t lastGlyphIndex() => _textBuffer.length == 0 ? 0 : _textBuffer.length - 1;

    size_t[] lineBreaks() => textLayout.lineBreaks;

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

    override void create()
    {
        super.create;
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

        updateTextLayout;
    }

    Vec2d viewportRowIndex() => viewportRowIndex(scrollPosition);
    Vec2d viewportRowIndex(double scrollPosition)
    {
        if (textLayout.lineBreaks.length == 0)
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

        size_t lastRowIndex = textLayout.lineBreaks.length;
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
        if (textLayout.lineBreaks.length == 0)
        {
            return null;
        }

        Vec2d rowIndex = viewportRowIndex(scrollPosition);

        size_t startRowIndex = cast(size_t) rowIndex.x;
        size_t endRowIndex = cast(size_t) rowIndex.y;

        size_t maxEndIndex = textLayout.lineBreaks.length;
        if (maxEndIndex > 0)
        {
            maxEndIndex--;
        }

        if (endRowIndex > maxEndIndex)
        {
            endRowIndex = maxEndIndex;
        }

        auto startBreakIndex = textLayout.lineBreaks[startRowIndex];
        auto endBreakIndex = textLayout.lineBreaks[endRowIndex];

        size_t glyphLastIndex = lastGlyphIndex;

        size_t startGlyphIndex;
        size_t endGlyphIndex = (endBreakIndex <= glyphLastIndex) ? endBreakIndex + 1 : endBreakIndex;

        if (startBreakIndex != 0 && startRowIndex > 0)
        {
            auto prevLineBreaks = textLayout.lineBreaks[startRowIndex - 1];
            //TODO check last index >= glyph.length
            startGlyphIndex = prevLineBreaks < glyphLastIndex ? prevLineBreaks + 1 : prevLineBreaks;
        }

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

    void updateTextLayout()
    {
        textLayout.reset;

        if (_textBuffer.length == 0)
        {
            return;
        }

        rowHeight = 0;

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
            auto newRowHeight = glyph.geometry.height;
            if (newRowHeight > rowHeight)
            {
                rowHeight = newRowHeight;
            }

            auto nextGlyphPosX = glyphPosX + glyph.geometry.width;

            if (glyph.isNEL)
            {
                textLayout ~= i;

                glyph.pos.x = glyphPosX;
                glyph.pos.y = glyphPosY;

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
                    glyph.pos.x = glyphPosX;
                    glyph.pos.y = glyphPosY;

                    glyphPosX = startRowTextX;
                    glyphPosY += rowHeight;
                    lastRowWidth = 0;

                    size_t currPosIndexDiff = i - j;
                    //TODO loop goes through some characters twice 
                    i -= currPosIndexDiff;
                    textLayout ~= j;
                    continue;
                }

                textLayout ~= (i == 0 ? 0 : i - 1);
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
            textLayout ~= lastIndex;
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

        auto newHeight = textLayout.lineBreaks.length * rowHeight + padding.height;
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

    size_t rowCount() => textLayout.lineBreaks.length;

    dstring text()
    {
        if (!isBuilt)
        {
            return "";
        }

        import std.array : appender;

        auto builder = appender!dstring;
        foreach (ref glyph; allGlyphs)
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

        if (!_textBuffer.create(t))
        {
            logger.error("Error creating buffer text: ", t);
            return;
        }

        updateRows(isForce : true);

        if (onTextChange && isTriggerListeners)
        {
            onTextChange();
        }
    }

    void scrollTo(double value0to1)
    {
        import Math = api.math;

        scrollPosition = Math.clamp(value0to1, 0, 1.0);
    }

    override void dispose()
    {
        super.dispose;
        textLayout.destroy;
    }
}
