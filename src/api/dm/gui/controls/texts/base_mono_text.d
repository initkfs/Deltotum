module api.dm.gui.controls.texts.base_mono_text;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.assets.fonts.bitmaps.bitmap_font : BitmapFont;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.math.pos2.flip : Flip;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.layouts.simple_text_layout : SimpleTextLayout;
import api.dm.gui.controls.texts.buffers.base_text_buffer : BaseTextBuffer;
import api.dm.gui.controls.texts.buffers.array_text_buffer : ArrayTextBuffer;

import api.math.geom2.vec2 : Vec2f;
import api.math.geom2.rect2 : Rect2f;

import Math = api.math;
import std.conv : to;

/**
 * Authors: initkfs
 */
class BaseMonoText : Control
{
    float spaceWidth = 5;
    float rowHeight = 0;
    float maxRowWidth = 0;

    BitmapFont fontTexture;

    RGBA _color;
    FontSize fontSize = FontSize.medium;

    bool isReduceWidthHeight = true;
    bool isAddLastLineBreak = true;
    bool isShowNewLineGlyph;
    bool isAllowWrapLine = true;
    bool isRebuildRows;

    bool delegate(ref KeyEvent) onEnter;
    void delegate() onTextChange;

    SimpleTextLayout textLayout;

    protected
    {
        BaseTextBuffer!Glyph _textBuffer;

        float scrollPosition = 0;

        dstring tempText;
    }

    this(string text)
    {
        import std.conv : to;

        this(text.to!dstring);
    }

    this(dstring text = "", typeof(_textBuffer) newBuffer = null, bool isFocusable = true)
    {
        _textBuffer = newBuffer ? newBuffer : new ArrayTextBuffer!Glyph;
        this.isFocusable = isFocusable;

        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        this.layout = new ManagedLayout;

        tempText = text;
    }

    ref inout(typeof(_textBuffer)) buffer() inout => _textBuffer;
    size_t bufferLength() => _textBuffer.length;
    Glyph[] allGlyphs() => _textBuffer.buffer;
    const(Glyph)[] allGlyphsConst() const => _textBuffer.buffer;
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

    override void initialize()
    {
        super.initialize;
        //TODO check run once
        invalidateListeners ~= () { updateRows; };

        if (!_textBuffer.itemProvider)
        {
            _textBuffer.itemProvider = (ch) => charToGlyph(ch);
        }
    }

    bool bufferCreate()
    {
        if (tempText.length == 0)
        {
            return false;
        }

        _textBuffer.create(tempText);
        tempText = null;
        updateRows;
        return true;
    }

    override void create()
    {
        super.create;

        setColorTexture;
        bufferCreate;
    }

    void updateRows(bool isForce = false)
    {
        if (!isBuilt && !isForce)
        {
            isRebuildRows = true;
            return;
        }

        updateTextLayout;
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

    Vec2f viewportRowIndex() => viewportRowIndex(scrollPosition);
    Vec2f viewportRowIndex(float scrollPosition)
    {
        if (textLayout.lineBreaks.length == 0)
        {
            return allGlyphs.length == 0 ? Vec2f(0, 0) : Vec2f(1, 1);
        }

        const rowsInViewport = this.rowsInViewport;
        if (rowsInViewport == 0)
        {
            return Vec2f(0, 0);
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

        return Vec2f(mustBeStartRowIndex, mustBeEndRowIndex);
    }

    Glyph[] viewportRows(out size_t firstRowIndex) => viewportRows(
        firstRowIndex, scrollPosition);

    Glyph[] viewportRows(out size_t firstRowIndex, float scrollPosition)
    {
        //TODO first line without \n
        if (textLayout.lineBreaks.length == 0)
        {
            return allGlyphs;
        }

        Vec2f rowIndex = viewportRowIndex(scrollPosition);

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
        if (rowHeight <= 0 || height <= 0)
        {
            return 0;
        }

        float heightDt = height - padding.height;
        if (heightDt <= 0)
        {
            heightDt = height;
        }

        return cast(size_t)(heightDt / rowHeight);
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

        const float startRowTextX = 0;
        const float endRowTextX = maxWidth - padding.width;
        const float startRowTextY = 0;

        float glyphPosX = startRowTextX;
        float glyphPosY = startRowTextY;

        maxRowWidth = 0;
        float lastRowWidth = 0;

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

            if (isAllowWrapLine)
            {
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

        if (isAddLastLineBreak && !_textBuffer.buffer[lastIndex].isNEL)
        {
            textLayout ~= lastIndex;
        }

        auto fullRowWidth = maxRowWidth + padding.width;

        enum sizeDt = 1;

        if ((fullRowWidth - width) > sizeDt)
        {
            width = Math.min(maxWidth, fullRowWidth);
        }
        else
        {
            if (isReduceWidthHeight && (width - maxRowWidth) > sizeDt)
            {
                //TODO check minHeight;
                width = maxRowWidth;
            }
        }

        const linesCount = textLayout.lineBreaks.length > 0 ? textLayout.lineBreaks.length : 1;
        auto newHeight = linesCount * rowHeight + padding.height;
        if ((newHeight - height) > sizeDt)
        {
            import std.algorithm.comparison : min;

            height = Math.min(maxHeight, newHeight);
        }
        else
        {
            if (isReduceWidthHeight && (newHeight - height) > sizeDt)
            {
                //TODO check minHeight;
                height = newHeight;
            }
        }
    }

    override void drawContent()
    {
        super.drawContent;

        if (allGlyphs.length == 0)
        {
            return;
        }

        size_t rowStartIndex;
        Glyph[] glyphs = viewportRows(rowStartIndex);
        renderText(glyphs, rowStartIndex);
    }

    void updateViewport()
    {
        onViewportGlyphs((ref glyph, i) { return true; });
    }

    protected void onViewportGlyphs(scope bool delegate(ref Glyph, size_t) onGlyphIndexIsContinue)
    {
        if (width == 0 || height == 0 || rowHeight == 0)
        {
            return;
        }

        size_t rowStartIndex;
        Glyph[] glyphs = viewportRows(rowStartIndex);
        if (glyphs.length == 0)
        {
            return;
        }

        if (lineBreaks.length == 0)
        {
            foreach (ri, ref Glyph glyph; glyphs)
            {
                if (!onGlyphIndexIsContinue(glyph, ri))
                {
                    break;
                }
            }
            return;
        }

        const float startRowTextY = 0;
        float glyphPosY = startRowTextY;

        import std.range : assumeSorted;

        auto sortedLineBreaks = textLayout.lineBreaks.assumeSorted;

        foreach (ri, ref Glyph glyph; glyphs)
        {
            glyph.pos.y = glyphPosY;

            if (sortedLineBreaks.contains(rowStartIndex + ri))
            {
                glyphPosY += rowHeight;
            }

            if (glyph.isNEL)
            {
                continue;
            }

            if (!onGlyphIndexIsContinue(glyph, ri))
            {
                break;
            }
        }
    }

    protected void renderText(Glyph[] glyphs, size_t startIndex)
    {
        if (width == 0 || height == 0 || glyphs.length == 0)
        {
            return;
        }

        const startPos = startGlyphPos;

        onViewportGlyphs((ref glyph, i) {

            Rect2f textureBounds = glyph.geometry;
            Rect2f destBounds = Rect2f(startPos.x + glyph.pos.x, startPos.y + glyph.pos.y, glyph
                .geometry.width, glyph
                .geometry.height);
            fontTexture.drawTexture(textureBounds, destBounds, angle, Flip
                .none);
            return true;
        });
    }

    float startGlyphX() => boundsRect.x + padding.left;
    float startGlyphY() => boundsRect.y + padding.top;
    Vec2f startGlyphPos() => Vec2f(startGlyphX, startGlyphY);

    override void update(float delta)
    {
        super.update(delta);

        if (tempText.length > 0)
        {
            updateRows;
            isRebuildRows = false;
            tempText = null;
        }

        if (isRebuildRows)
        {
            updateRows;
            isRebuildRows = false;
        }
    }

    void onFontTexture(scope bool delegate(Texture2d, const(Glyph*) glyph) onTextureIsContinue)
    {
        assert(fontTexture);

        foreach (ref glyph; allGlyphs)
        {
            if (!onTextureIsContinue(fontTexture, &glyph))
            {
                break;
            }
        }
    }

    override bool canChangeWidth(float value)
    {
        if (maxRowWidth > 0 && value < (maxRowWidth + padding.width))
        {
            return false;
        }
        return super.canChangeWidth(value);
    }

    float calcTextWidth(const(dchar)[] str)
    {
        return calcTextWidth(str, fontSize);
    }

    float calcTextWidth(const(dchar)[] str, FontSize fontSize)
    {
        float sum = 0;
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

    dstring text() const
    {
        if (!isBuilt)
        {
            return tempText;
        }

        import std.array : appender;

        auto builder = appender!dstring;
        foreach (ref glyph; allGlyphsConst)
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
        if (t.length == 0 && _textBuffer.length == 0)
        {
            tempText = null;
            return;
        }

        if (!isBuilt || !isCreated)
        {
            isRebuildRows = true;
            tempText = t;
            return;
        }

        if (!_textBuffer.create(t))
        {
            logger.error("Error creating buffer text: '", t, "'");
            return;
        }

        if (onTextChange && isTriggerListeners)
        {
            onTextChange();
        }

        updateRows(isForce : true);
    }

    bool scrollTo(float value0to1)
    {
        import Math = api.math;

        scrollPosition = Math.clamp(value0to1, 0, 1.0);
        return true;
    }

    void copyTo(Texture2d texture, Rect2f destBounds)
    {
        assert(texture);
        assert(fontTexture);

        import api.math.geom2.rect2 : Rect2f;

        //TODO remove duplication with render()
        foreach (ref glyph; allGlyphs)
        {
            Rect2f textureBounds = glyph.geometry;
            texture.copyFrom(fontTexture, textureBounds, destBounds);
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

    override void dispose()
    {
        super.dispose;
        textLayout.destroy;
    }
}
