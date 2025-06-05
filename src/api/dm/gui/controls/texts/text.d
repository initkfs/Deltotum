module api.dm.gui.controls.texts.text;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d;
import api.math.flip : Flip;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.math.insets : Insets;
import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
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
class Text : Control
{
    int spaceWidth = 5;
    int rowHeight = 0;

    RGBA _color;
    FontSize fontSize = FontSize.medium;

    Sprite2d focusEffect;
    Sprite2d delegate() focusEffectFactory;

    void delegate(ref KeyEvent) onEnter;
    void delegate() onTextChange;

    bool isReduceWidthHeight = true;

    Rectangle cursor;

    BitmapFont fontTexture;

    bool isShowNewLineGlyph;

    TextRow[] rows;

    protected
    {
        double rowWidth = 0;
        dstring tempText;
    }

    Glyph[] _text;
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
    }

    override void initialize()
    {
        super.initialize;

        loadTheme;

        invalidateListeners ~= () { updateRows; };
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadTextTheme;
    }

    void loadTextTheme()
    {
        if (_color == RGBA.init)
        {
            _color = theme.colorText;
        }
    }

    override void create()
    {
        super.create;

        import api.math.insets : Insets;

        //padding = Insets(0);

        setColorTexture;

        updateRows;

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

    //TODO optimizations
    protected Glyph[] textToGlyphs(const(dchar)[] textString)
    {
        if (textString.length == 0)
        {
            return [];
        }

        Glyph[] newGlyphs;
        newGlyphs.reserve(textString.length);

        foreach (ref grapheme; textString)
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

            newGlyphs ~= newGlyph;
        }

        return newGlyphs;
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

        rowWidth = 0;

        TextRow row;
        size_t glyphCount;
        foreach (ref glyph; glyphs)
        {
            auto nextGlyphPosX = glyphPosX + glyph.geometry.width;
            if (nextGlyphPosX <= endRowTextX && nextGlyphPosX > rowWidth)
            {
                auto newRowWidth = rowWidth + (nextGlyphPosX - rowWidth + padding.right);
                if (newRowWidth > rowWidth)
                {
                    rowWidth = newRowWidth;
                }
            }

            if (glyph.isNEL)
            {
                newRows ~= row;
                row = TextRow();
                glyphPosX = startRowTextX;
                glyphPosY += rowHeight;

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
                            return [];
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

        if (rowWidth > width)
        {
            width = Math.min(maxWidth, rowWidth);
        }
        else
        {
            if (isReduceWidthHeight)
            {
                //TODO check minHeight;
                width = rowWidth;
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

    void updateRows(bool isForce = false)
    {
        if (!isBuilt && !isForce)
        {
            isRebuildRows = true;
            return;
        }

        if (tempText.length > 0)
        {
            _text = textToGlyphs(tempText);
            tempText = null;
        }

        this.rows = glyphsToRows(_text);
    }

    void addRows(const(dchar)[] text)
    {
        auto glyphs = textToGlyphs(text);
        _text ~= glyphs;
        this.rows ~= glyphsToRows(glyphs);
    }

    override bool canChangeWidth(double value)
    {
        if (rowWidth > 0 && value < (rowWidth + padding.width))
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

        _text = textToGlyphs(t);
        rows = glyphsToRows(_text);
        tempText = null;
        setInvalid;

        if (onTextChange && isTriggerListeners)
        {
            onTextChange();
        }
    }

    auto textTo(T)() => text.to!T;
    string textString() => textTo!string;

    dstring text()
    {
        if ((!isBuilt || !isCreated) && tempText)
        {
            return tempText;
        }

        import std.array : appender;

        auto builder = appender!dstring;
        foreach (ref glyph; _text)
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
}
