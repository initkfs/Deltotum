module api.dm.gui.controls.texts.text_view;

import api.dm.gui.controls.texts.base_mono_text : BaseMonoText, TextStruct;
import api.dm.gui.controls.texts.editable_text : EditableText;
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
    BitmapFont fontTexture;

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

    override void drawContent()
    {
        if (textStruct.lineBreaks.length == 0)
        {
            return;
        }

        size_t rowStartIndex;
        Glyph[] glyphs = viewportRows(rowStartIndex);
        renderText(glyphs, rowStartIndex);
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

        auto sortedLineBreaks = textStruct.lineBreaks.assumeSorted;
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

    textView.updateTextStruct;

    assert(textView.rowCount == 5);
    assert(textView.textStruct.lineBreaks == [11u, 21, 32, 45, 55]);

    assert(textView.rowsInViewport == 4);
    assert(textView.viewportRowIndex == Vec2d(0, 3));
    assert(textView.viewportRowIndex(1) == Vec2d(4, 4));

    size_t firstRowIndex;
    Glyph[] rows = textView.viewportRows(firstRowIndex);
    assert(rows.length == 46);

    dstring rowsStr = textView.glyphsToStr(rows);
    assert(rowsStr == "Hello world\nThis is a very short text for the ");

    Glyph[] endRows = textView.viewportRows(firstRowIndex, 1);
    dstring rowsStr1 = textView.glyphsToStr(endRows);
    assert(rowsStr1 == "experiment");
}
