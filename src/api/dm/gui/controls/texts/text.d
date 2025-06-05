module api.dm.gui.controls.texts.text;

import api.dm.gui.controls.texts.base_text: BaseText;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d;
import api.math.flip : Flip;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.math.insets : Insets;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.assets.fonts.font_size : FontSize;

import Math = api.math;

import std.conv : to;

import std.stdio;

struct TextRow
{
    Glyph*[] glyphs;
}

/**
 * Authors: initkfs
 */
class Text : BaseText
{
    BitmapFont fontTexture;

    TextRow[] rows;

    protected
    {
        double lastRowWidth = 0;
        dstring tempText;

        size_t textBufferCount;
    }

    Glyph[] _textBuffer;
    size_t textBufferInitSize = 10;

    bool isRebuildRows;

    this(string text)
    {
        import std.conv : to;

        this(text.to!dstring);
    }

    this(dstring text = "")
    {
        this.tempText = text;

        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        this.layout = new ManagedLayout;

        _textBuffer = new Glyph[textBufferInitSize];
    }

    override void initialize()
    {
        super.initialize;
        invalidateListeners ~= () { updateRows; };
    }

    override void create()
    {
        super.create;

        setColorTexture;

        if (tempText.length > 0)
        {
            updateRows;
            tempText = null;
        }
    }

    override void update(double delta)
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

    protected void textToGlyphsBuffer(const(dchar)[] textString, bool isAppend = false)
    {
        const textLength = textString.length;

        if (textLength == 0)
        {
            return;
        }

        if (!isAppend)
        {
            textBufferCount = 0;
        }

        size_t needCapacity = textBufferCount + textLength;
        if (needCapacity > _textBuffer.length)
        {
            _textBuffer.length = needCapacity;
        }

        size_t bufferOffset = isAppend ? textBufferCount : 0;
        foreach (i, ref grapheme; textString)
        {
            Glyph newGlyph;
            bool isFound;
            //TODO hash map
            foreach (glyph; asset.fontBitmap(fontSize).glyphs)
            {
                if (glyph.grapheme == grapheme)
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

            _textBuffer[bufferOffset + i] = newGlyph;
            textBufferCount++;
        }
    }

    protected TextRow[] glyphsBufferToRows()
    {
        return glyphsToRows(_textBuffer[0 .. textBufferCount]);
    }

    protected TextRow[] glyphsToRows(Glyph[] glyphs)
    {
        TextRow[] newRows;

        if (glyphs.length == 0)
        {
            return newRows;
        }

        rowHeight = cast(int) glyphs[0].geometry.height;

        const double startRowTextX = padding.left;
        const double endRowTextX = maxWidth - padding.right;

        const double startRowTextY = padding.top;

        double glyphPosX = startRowTextX;
        double glyphPosY = startRowTextY;

        double maxRowWidth = 0;

        lastRowWidth = 0;

        TextRow row;
        size_t glyphCount;
        foreach (ref glyph; glyphs)
        {
            auto nextGlyphPosX = glyphPosX + glyph.geometry.width;
            lastRowWidth += glyph.geometry.width;

            if (lastRowWidth > maxRowWidth)
            {
                maxRowWidth = lastRowWidth;
            }

            if (glyph.isNEL)
            {
                newRows ~= row;
                row = TextRow();
                glyphPosX = startRowTextX;
                glyphPosY += rowHeight;

                lastRowWidth = 0;

                if (!isShowNewLineGlyph)
                {
                    continue;
                }
            }
            else if (nextGlyphPosX > endRowTextX)
            {
                long slicePos = -1;
                foreach_reverse (j, oldGlyph; row.glyphs)
                {
                    if (oldGlyph.grapheme == ' ')
                    {
                        ptrdiff_t idt = row.glyphs.length - 1;
                        if (idt < 0)
                        {
                            continue;
                        }

                        if (j == idt)
                        {
                            continue;
                        }
                        slicePos = j;
                        break;
                    }
                }

                auto newRow = TextRow();
                glyphPosX = startRowTextX;
                glyphPosY += rowHeight;

                if (slicePos != -1)
                {
                    foreach (i; slicePos + 1 .. row.glyphs.length)
                    {
                        auto oldGlyph = row.glyphs[i];
                        oldGlyph.pos.x = glyphPosX;
                        oldGlyph.pos.y = glyphPosY;

                        newRow.glyphs ~= oldGlyph;
                        glyphPosX += oldGlyph.geometry.width;
                    }

                    row.glyphs = row.glyphs[0 .. slicePos];
                }

                newRows ~= row;
                row = newRow;
                lastRowWidth = 0;
            }

            glyph.pos.x = glyphPosX;
            glyph.pos.y = glyphPosY;

            row.glyphs ~= &glyph;
            glyphCount++;
            glyphPosX += glyph.geometry.width;
        }

        // debug
        // {
        //     if (glyphCount != glyphs.length)
        //     {
        //         import std.format : format;

        //         throw new Exception(format("Glyph count %s, but text count is %s", glyphCount, glyphs
        //                 .length));
        //     }
        // }

        if (row.glyphs.length > 0)
        {
            newRows ~= row;
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

        auto newHeight = newRows.length * rowHeight + padding.height;
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

        return newRows;
    }

    dstring glyphsToStr(Glyph[] glyphs)
    {
        import std.algorithm.iteration : map;
        import std.conv : to;

        return glyphs.map!(g => g.grapheme)
            .to!dstring;
    }

    void updateRows(const(dchar)[] newText = null, bool isForce = false)
    {
        if (!isBuilt && !isForce)
        {
            isRebuildRows = true;
            return;
        }

        auto textForUpdate = newText.length > 0 ? newText : tempText;
        if (textForUpdate.length == 0)
        {
            return;
        }

        textToGlyphsBuffer(textForUpdate);
        tempText = null;

        isAllowInvalidate = false;
        scope (exit)
        {
            isAllowInvalidate = true;
        }

        this.rows = glyphsBufferToRows;
    }

    void addRows(const(dchar)[] text)
    {
        textToGlyphsBuffer(text, isAppend:
            true);
        //TODO only append
        this.rows = glyphsBufferToRows;
    }

    override bool canChangeWidth(double value)
    {
        if (lastRowWidth > 0 && value < (lastRowWidth + padding.width))
        {
            return false;
        }
        return super.canChangeWidth(value);
    }

    protected void renderText(TextRow[] rows)
    {
        if (width == 0 || height == 0)
        {
            return;
        }

        const thisBounds = boundsRect;

        foreach (TextRow row; rows)
        {
            foreach (Glyph* glyph; row.glyphs)
            {
                Rect2d textureBounds = glyph.geometry;
                Rect2d destBounds = Rect2d(thisBounds.x + glyph.pos.x, thisBounds.y + glyph.pos.y, glyph
                        .geometry.width, glyph
                        .geometry.height);
                fontTexture.drawTexture(textureBounds, destBounds, angle, Flip
                        .none);
            }
        }
    }

    void onFontTexture(scope bool delegate(Texture2d, const(Glyph*) glyph) onTextureIsContinue)
    {
        foreach (TextRow row; rows)
        {
            foreach (Glyph* glyph; row.glyphs)
            {
                if (!onTextureIsContinue(fontTexture, glyph))
                {
                    break;
                }
            }
        }
    }

    double rowGlyphWidth()
    {
        double result = 0;
        foreach (TextRow row; rows)
        {
            foreach (Glyph* glyph; row.glyphs)
            {
                result += glyph.geometry.width;
            }
        }
        return result;
    }

    double rowGlyphHeight()
    {
        double result = 0;
        foreach (TextRow row; rows)
        {
            foreach (Glyph* glyph; row.glyphs)
            {
                auto h = glyph.geometry.height;
                if (h > result)
                {
                    result = h;
                }
            }
        }
        return result;
    }

    void copyTo(Texture2d texture, Rect2d destBounds)
    {
        assert(texture);

        import api.math.geom2.rect2 : Rect2d;

        //TODO remove duplication with render()
        foreach (TextRow row; rows)
        {
            foreach (Glyph* glyph; row.glyphs)
            {
                Rect2d textureBounds = glyph.geometry;
                texture.copyFrom(fontTexture, textureBounds, destBounds);
            }
        }
    }

    override void drawContent()
    {
        renderText(rows);
    }

    void appendText(const(dchar)[] text)
    {
        addRows(text);
        setInvalid;
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

    void text(string t, bool isTriggerListeners = true)
    {
        import std.conv : to;

        this.text(t.to!dstring, isTriggerListeners);
    }

    void text(dstring t, bool isTriggerListeners = true)
    {
        if (!isBuilt || !isCreated)
        {
            tempText = t;
            isRebuildRows = true;
            return;
        }

        tempText = t;
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
        assert(_textBuffer.length >= textBufferCount);
        return _textBuffer[0 .. textBufferCount];
    }

    dstring text()
    {
        if ((!isBuilt || !isCreated) && tempText)
        {
            return tempText;
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
}
