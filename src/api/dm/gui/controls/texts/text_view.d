module api.dm.gui.controls.texts.text_view;

import api.dm.gui.controls.texts.editable_text : EditableText;
import api.dm.gui.controls.texts.adt.piece_table : PieceTable;
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

struct DocStruct
{
    size_t[] rowsGlyphCount;
    size_t[] lineBreaks;
}

/**
 * Authors: initkfs
 */
class TextView : EditableText
{
    protected
    {
        double scrollPosition = 0;
    }

    bool isEditable;

    PieceTable!dchar _textBuffer;

    DocStruct docStruct;

    BitmapFont fontTexture;

    bool isRebuildRows;

    protected
    {
        double lastRowWidth = 0;
        size_t textBufferCount;
        dstring tempText;
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

        if (!_textBuffer.glyphProvider)
        {
            _textBuffer.glyphProvider = (ch) => charToGlyph(ch);
        }

        //     if (isFocusable)
        //     {
        //         onFocusEnter ~= (ref e) {
        //             if (focusEffect)
        //             {
        //                 focusEffect.isVisible = true;
        //             }

        //             window.startTextInput;
        //         };

        //         onFocusExit ~= (ref e) {
        //             if (focusEffect && focusEffect.isVisible)
        //             {
        //                 focusEffect.isVisible = false;
        //                 if (cursor)
        //                 {
        //                     cursor.isVisible = false;
        //                 }
        //             }

        //             window.endTextInput;
        //         };
        //     }

        //     if (isEditable)
        //     {
        //         onPointerPress ~= (ref e) {

        //             const mouseX = e.x;
        //             const mouseY = e.y;

        //             cursorPos = coordsToRowPos(mouseX, mouseY);
        //             if (!cursorPos.isValid)
        //             {
        //                 Vec2d pos;
        //                 CursorState state;
        //                 size_t glyphIndex;
        //                 if (rows.length == 0)
        //                 {
        //                     pos = Vec2d(x + padding.left, y + padding.top);
        //                     state = CursorState.forNextGlyph;
        //                 }
        //                 else
        //                 {
        //                     //TODO empty rows
        //                     auto lastRow = rows[$ - 1];
        //                     glyphIndex = lastRow.glyphs.length - 1;
        //                     auto lastRowGlyph = lastRow.glyphs[$ - 1];
        //                     pos = Vec2d(x + lastRowGlyph.pos.x + lastRowGlyph.geometry.width, y + lastRowGlyph
        //                             .pos.y);
        //                     state = CursorState.forPrevGlyph;
        //                     cursorPos = CursorPos(state, pos, 0, glyphIndex, true);
        //                 }

        //                 updateCursor;
        //                 cursor.isVisible = true;

        //                 logger.tracef("Mouse position is invalid, new cursor pos: %s", cursorPos);
        //                 return;
        //             }

        //             debug
        //             {
        //                 import std.stdio;

        //                 writefln("Cursor pos for %s,%s: %s", mouseX, mouseY, cursorPos);
        //             }

        //             updateCursor;
        //             cursor.isVisible = true;
        //         };

        //         onKeyPress ~= (ref e) {
        //             import api.dm.com.inputs.com_keyboard : ComKeyName;

        //             if (!cursor.isVisible)
        //             {
        //                 return;
        //             }

        //             if (e.keyName == ComKeyName.key_return && onEnter)
        //             {
        //                 onEnter(e);
        //                 return;
        //             }

        //             switch (e.keyName) with (ComKeyName)
        //             {
        //                 case key_left:
        //                     moveCursorLeft;
        //                     break;
        //                 case key_right:
        //                     moveCursorRight;
        //                     break;
        //                 case key_down:
        //                     moveCursorDown;
        //                     break;
        //                 case key_up:
        //                     moveCursorUp;
        //                     break;
        //                 case key_backspace:

        //                     if (!cursorPos.isValid)
        //                     {
        //                         return;
        //                     }

        //                     logger.tracef("Backspace pressed for cursor: %s", cursorPos);

        //                     if (cursorPos.glyphIndex == 0)
        //                     {
        //                         if (cursorPos.state == CursorState.forNextGlyph)
        //                         {
        //                             return;
        //                         }
        //                     }

        //                     auto row = rows[cursorPos.rowIndex];

        //                     if (row.glyphs.length == 0)
        //                     {
        //                         return;
        //                     }

        //                     if (cursorPos.state == CursorState.forNextGlyph)
        //                     {
        //                         cursorPos.glyphIndex--;
        //                     }
        //                     else if (cursorPos.state == CursorState.forPrevGlyph)
        //                     {
        //                         cursorPos.state = CursorState.forNextGlyph;
        //                     }

        //                     import std.algorithm.mutation : remove;

        //                     size_t textIndex = cursorGlyphIndex;
        //                     auto glyph = row.glyphs[cursorPos.glyphIndex];

        //                     // _text = _text.remove(textIndex);
        //                     // cursorPos.pos.x -= glyph.geometry.width;

        //                     // logger.tracef("Remove index %s, new cursor pos: %s", textIndex, cursorPos);

        //                     updateCursor;
        //                     setInvalid;
        //                     break;
        //                 default:
        //                     break;
        //             }
        //         };

        //         onTextInput ~= (ref e) {
        //             if (!cursor.isVisible)
        //             {
        //                 return;
        //             }

        //             size_t textIndex = cursorGlyphIndex();
        //             import std.array : insertInPlace;

        //             //TODO one glyph
        //             import std.conv : to;

        //             // auto glyphsArr = textToGlyphs(e.firstLetter.to!dstring);

        //             // double glyphOffset;
        //             // foreach (ref glyph; glyphsArr)
        //             // {
        //             //     glyphOffset += glyph.geometry.width;
        //             // }

        //             // _text.insertInPlace(textIndex, glyphsArr);
        //             // logger.tracef("Insert text %s with index %s", glyphsArr, textIndex);

        //             // cursorPos.pos.x += glyphOffset;
        //             // cursorPos.glyphIndex++;
        //             // updateCursor;
        //             // setInvalid;
        //         };
        //     }

        //     if (isFocusable)
        //     {
        //         focusEffectFactory = () {
        //             import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
        //             import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        //             GraphicStyle style = GraphicStyle(1, theme.colorFocus);

        //             import api.dm.kit.sprites2d.shapes.convex_polygon : ConvexPolygon;

        //             auto effect = new ConvexPolygon(width, height, style, theme.controlCornersBevel);
        //             //auto effect = new Rectangle(width, height, style);
        //             effect.isVisible = false;
        //             return effect;
        //         };
        //     }
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

        // if (glyphs.length == 0)
        // {
        //     return docStruct;
        // }

        //rowHeight = cast(int) glyphs[0].geometry.height;

        const double startRowTextX = padding.left;
        const double endRowTextX = maxWidth - padding.right;

        const double startRowTextY = padding.top;

        double glyphPosX = startRowTextX;
        double glyphPosY = startRowTextY;

        double maxRowWidth = 0;
        lastRowWidth = 0;

        size_t glyphCount;

        _textBuffer.onGlyphs((Glyph* glyph, i) {
            auto newRowHeight = cast(int) glyph.geometry.height;
            if (newRowHeight > rowHeight)
            {
                rowHeight = newRowHeight;
            }

            auto nextGlyphPosX = glyphPosX + glyph.geometry.width;
            lastRowWidth += glyph.geometry.width;

            if (lastRowWidth > maxRowWidth)
            {
                maxRowWidth = lastRowWidth;
            }

            if (glyph.isNEL)
            {
                docStruct.lineBreaks ~= i;

                glyphPosX = startRowTextX;
                glyphPosY += rowHeight;
                lastRowWidth = 0;
            }
            else if (nextGlyphPosX > endRowTextX)
            {
                long slicePos = -1;
                // foreach_reverse (j, oldGlyph; row.glyphs)
                // {
                //     if (oldGlyph.grapheme == ' ')
                //     {
                //         ptrdiff_t idt = row.glyphs.length - 1;
                //         if (idt < 0)
                //         {
                //             continue;
                //         }

                //         if (j == idt)
                //         {
                //             continue;
                //         }
                //         slicePos = j;
                //         break;
                //     }
                // }

                glyphPosX = startRowTextX;
                glyphPosY += rowHeight;
                lastRowWidth = 0;
                docStruct.lineBreaks ~= i;
                // if (slicePos != -1)
                // {
                //     foreach (i; slicePos + 1 .. row.glyphs.length)
                //     {
                //         auto oldGlyph = row.glyphs[i];
                //         oldGlyph.pos.x = glyphPosX;
                //         oldGlyph.pos.y = glyphPosY;

                //         newRow.glyphs ~= oldGlyph;
                //         glyphPosX += oldGlyph.geometry.width;
                //     }

                //     row.glyphs = row.glyphs[0 .. slicePos];
                // }

            }

            glyph.pos.x = glyphPosX;
            glyph.pos.y = glyphPosY;
            glyphPosX += glyph.geometry.width;

            glyphCount++;

            return true;
        });

        docStruct.lineBreaks ~= (glyphCount - 1);

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

    dstring glyphsToStr(Glyph*[] glyphs)
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

    protected void renderText(Glyph*[] glyphs, size_t startIndex)
    {
        if (width == 0 || height == 0)
        {
            return;
        }

        const thisBounds = boundsRect;

        auto rowHeight = cast(int) glyphs[0].geometry.height;

        const double startRowTextY = padding.top;
        double glyphPosY = startRowTextY;

        foreach (ri, Glyph* glyph; glyphs)
        {
            foreach (bi; docStruct.lineBreaks)
            {
                if (startIndex + ri == bi)
                {
                    glyphPosY += rowHeight;
                    glyph.pos.y = glyphPosY;
                    continue;
                }
            }

            glyph.pos.y = glyphPosY;

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

    Glyph*[] bufferText()
    {
        // assert(_textBuffer.length >= textBufferCount);
        // return _textBuffer[0 .. textBufferCount];
        return _textBuffer.newGlyphsPtr;
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

    // override void create()
    // {
    //     super.create;

    //     if (focusEffectFactory !is null)
    //     {
    //         focusEffect = focusEffectFactory();
    //         focusEffect.isLayoutManaged = false;
    //         focusEffect.isResizedByParent = true;
    //         focusEffect.isVisible = false;
    //         addCreate(focusEffect);
    //     }

    //     if (isEditable)
    //     {
    //         const cursorColor = theme.colorAccent;

    //         import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
    //         import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

    //         cursor = new Rectangle(2, 20, GraphicStyle(1, cursorColor, true, cursorColor));
    //         addCreate(cursor);
    //         cursor.isLayoutManaged = false;
    //         cursor.isVisible = false;
    //     }

    // }

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

    Glyph*[] viewportRows(out size_t firstRowIndex) => viewportRows(firstRowIndex, scrollPosition);

    Glyph*[] viewportRows(out size_t firstRowIndex, double scrollPosition)
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

        size_t startGlyphIndex;
        size_t endGlyphIndex = endBreakIndex;

        if (startBreakIndex != 0 && startRowIndex > 0)
        {
            auto prevLineBreaks = docStruct.lineBreaks[startRowIndex - 1];
            startGlyphIndex = prevLineBreaks;
        }

        if (endRowIndex == maxEndIndex)
        {
            endGlyphIndex++;
        }

        Glyph*[] glyphs = _textBuffer.newGlyphsPtr[startGlyphIndex .. endGlyphIndex];

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
        Glyph*[] glyphs = viewportRows(rowStartIndex);
        renderText(glyphs, rowStartIndex);
    }

    void scrollTo(double value)
    {
        scrollPosition = value;
    }

    size_t rowCount() => docStruct.lineBreaks.length;

    ref inout(PieceTable!dchar) textBuffer() inout => _textBuffer;

}

unittest
{
    import api.math.geom2.rect2 : Rect2d;
    import api.math.geom2.vec2 : Vec2d;

    auto textView = new TextView("Hello world\nThis is a very short text for the experiment");
    textView.textBuffer.glyphProvider = (ch) {
        return Glyph(ch, Rect2d(0, 0, 10, 10), Vec2d(0, 0), null, false, ch == '\n');
    };
    textView.width = 120;
    textView.maxWidth = textView.width;
    textView.height = 40;
    textView.maxHeight = textView.height;

    textView.bufferCreate;

    textView.glyphsToDocStruct;
    assert(textView.rowCount == 5);
    assert(textView.docStruct == DocStruct([], [11, 23, 35, 47, 55]));

    assert(textView.rowsInViewport == 4);
    assert(textView.viewportRowIndex == Vec2d(0, 3));
    assert(textView.viewportRowIndex(1) == Vec2d(4, 4));

    size_t firstRowIndex;
    Glyph*[] rows = textView.viewportRows(firstRowIndex);
    assert(rows.length == 47);

    dstring rowsStr = textView.glyphsToStr(rows);
    assert(rowsStr == "Hello world\nThis is a very short text for the e");

    Glyph*[] endRows = textView.viewportRows(firstRowIndex, 1);
    dstring rowsStr1 = textView.glyphsToStr(endRows);
    assert(rowsStr1 == "xperiment");
}
