module api.dm.gui.controls.texts.text_view;

import api.dm.gui.controls.texts.base_text : BaseText, TextRow;
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
import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;

import std.stdio;
import core.stdc.stdlib;
import Math = api.math;
import std.conv : to;

enum CursorState
{
    forPrevGlyph,
    forNextGlyph
}

struct CursorPos
{
    CursorState state;
    Vec2d pos;
    size_t rowIndex;
    size_t glyphIndex;
    bool isValid;
}

/**
 * Authors: initkfs
 */
class TextView : BaseText
{
    protected
    {
        double scrollPosition = 0;
    }

    Rectangle cursor;
    CursorPos cursorPos;

    bool isEditable;

    PieceTable!dchar _textBuffer;

    BitmapFont fontTexture;

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

        _textBuffer.glyphProvider = (ch) => charToGlyph(ch);

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

    override void create()
    {
        super.create;

        _textBuffer.create(tempText);
        tempText = null;

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

    protected TextRow[] glyphsBufferToRows()
    {
        Glyph*[] glyphs = _textBuffer.allGlyphsPtr;
        scope (exit)
        {
            free(glyphs.ptr);
        }
        return glyphsToRows(glyphs);
    }

    protected TextRow[] glyphsToRows(Glyph*[] glyphs)
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

            row.glyphs ~= glyph;
            glyphCount++;
            glyphPosX += glyph.geometry.width;
        }

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

        this.rows = glyphsBufferToRows;
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

    protected void renderText(TextRow[] rows)
    {
        if (width == 0 || height == 0)
        {
            return;
        }

        const thisBounds = boundsRect;

        rowHeight = cast(int) rows[0].glyphs[0].geometry.height;
        const double startRowTextY = padding.top;
        double glyphPosY = startRowTextY;

        foreach (TextRow row; rows)
        {
            foreach (Glyph* glyph; row.glyphs)
            {
                if (glyph.isNEL)
                {
                    glyphPosY += rowHeight;

                    if (!isShowNewLineGlyph)
                    {
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
            glyphPosY += rowHeight;
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
        return _textBuffer.allGlyphs;
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
            //renderText(rows);
        }
        else
        {
            import std.math.rounding : round;

            //TODO only one hanging line in text
            size_t mustBeLastRowIndex = lastRowIndex;
            if (mustBeLastRowIndex > rowsInViewport)
            {
                mustBeLastRowIndex -= rowsInViewport - 1;
            }

            size_t mustBeStartRowIndex = to!size_t(round(scrollPosition * mustBeLastRowIndex));
            size_t mustBeEndRowIndex = mustBeStartRowIndex + rowsInViewport - 1;
            if (mustBeEndRowIndex > lastRowIndex)
            {
                mustBeEndRowIndex = lastRowIndex;
            }

            auto rowsForView = rows[mustBeStartRowIndex .. mustBeEndRowIndex + 1];
            renderText(rowsForView);
        }
    }

    void scrollTo(double value)
    {
        scrollPosition = value;
    }

    // bool updateCursor()
    // {
    //     if (!cursor || !cursorPos.isValid)
    //     {
    //         return false;
    //     }
    //     cursor.xy(cursorPos.pos.x, cursorPos.pos.y);
    //     return true;
    // }

    // size_t cursorGlyphIndex()
    // {
    //     return cursorGlyphIndex(cursorPos.rowIndex, cursorPos.glyphIndex);
    // }

    // size_t cursorGlyphIndex(size_t rowIndex, size_t glyphIndex)
    // {
    //     size_t rowOffset;
    //     if (rowIndex > 0)
    //     {
    //         enum hyphenCorrection = 1;
    //         foreach (ri; 0 .. rowIndex)
    //         {
    //             rowOffset += rows[ri].glyphs.length + hyphenCorrection;
    //         }
    //     }

    //     size_t index = rowOffset + glyphIndex;
    //     return index;
    // }

    // protected CursorPos coordsToRowPos(double x, double y)
    // {
    //     const thisBounds = boundsRect;
    //     //TODO row height
    //     foreach (ri, row; rows)
    //     {
    //         if (row.glyphs.length == 0)
    //         {
    //             continue;
    //         }

    //         //TODO row height
    //         Glyph* firstGlyph = row.glyphs[0];

    //         const rowMinY = thisBounds.y + firstGlyph.pos.y;
    //         const rowMaxY = rowMinY + firstGlyph.geometry.height;

    //         if (y < rowMinY || y > rowMaxY)
    //         {
    //             continue;
    //         }

    //         foreach (gi, glyph; row.glyphs)
    //         {
    //             const glyphMinX = thisBounds.x + glyph.pos.x;
    //             const glyphMaxX = glyphMinX + glyph.geometry.width;

    //             if (x > glyphMinX && x < glyphMaxX)
    //             {
    //                 CursorState state = CursorState.forNextGlyph;
    //                 const minMaxRangeMiddle = glyphMinX + (glyph.geometry.width / 2);
    //                 double posX = glyphMinX;
    //                 size_t glyphIndex = gi;

    //                 if (x > minMaxRangeMiddle)
    //                 {
    //                     if (glyphIndex < row.glyphs.length - 1)
    //                     {
    //                         glyphIndex++;
    //                     }
    //                     else
    //                     {
    //                         posX += glyph.geometry.width;
    //                         state = CursorState.forPrevGlyph;
    //                     }
    //                     posX = glyphMaxX;
    //                 }
    //                 const pos = Vec2d(posX, rowMinY);
    //                 return CursorPos(state, pos, ri, glyphIndex, true);
    //             }
    //         }
    //     }
    //     return CursorPos.init;
    // }

    // bool moveCursorLeft()
    // {
    //     if (!cursorPos.isValid)
    //     {
    //         return false;
    //     }

    //     if (cursorPos.glyphIndex == 0)
    //     {
    //         if (cursorPos.rowIndex == 0)
    //         {
    //             return false;
    //         }
    //         else
    //         {
    //             cursorPos.rowIndex--;
    //             //TODO empty rows
    //             auto row = rows[cursorPos.rowIndex];
    //             auto lastGlyph = row.glyphs[$ - 1];
    //             cursorPos.pos.x = lastGlyph.pos.x + lastGlyph.geometry.width;
    //             updateCursor;
    //             cursorPos.glyphIndex = row.glyphs.length - 1;
    //             cursorPos.state = CursorState.forPrevGlyph;
    //             return true;
    //         }
    //     }

    //     auto row = rows[cursorPos.rowIndex];

    //     double cursorOffset = 0;
    //     if (cursorPos.glyphIndex == row.glyphs.length)
    //     {
    //         cursorPos.glyphIndex--;
    //         const glyph = row.glyphs[cursorPos.glyphIndex];
    //         cursorOffset = glyph.geometry.width;
    //     }
    //     else
    //     {
    //         const glyph = row.glyphs[cursorPos.glyphIndex];
    //         cursorPos.glyphIndex--;
    //         cursorOffset = glyph.geometry.width;
    //     }

    //     cursor.x = cursor.x - cursorOffset;

    //     return true;
    // }

    // bool moveCursorRight()
    // {
    //     if (!cursorPos.isValid)
    //     {
    //         return false;
    //     }
    //     const row = rows[cursorPos.rowIndex];
    //     if (row.glyphs.length == 0)
    //     {
    //         return false;
    //     }

    //     if (cursorPos.glyphIndex >= row.glyphs.length)
    //     {
    //         return false;
    //     }

    //     const glyph = row.glyphs[cursorPos.glyphIndex];
    //     cursorPos.glyphIndex++;
    //     cursor.x = cursor.x + glyph.geometry.width;
    //     return true;
    // }

    // bool moveCursorUp()
    // {
    //     if (cursorPos.rowIndex == 0)
    //     {
    //         return false;
    //     }

    //     const row = rows[cursorPos.rowIndex];
    //     if (row.glyphs.length == 0)
    //     {
    //         return false;
    //     }

    //     //TODO strings may not match in number of characters

    //     const glyph = rows[cursorPos.rowIndex].glyphs[cursorPos.glyphIndex];
    //     cursorPos.rowIndex--;
    //     cursor.y = cursor.y - glyph.geometry.height;
    //     return true;
    // }

    // bool moveCursorDown()
    // {
    //     if (rows.length <= 1 || cursorPos.rowIndex >= rows.length - 1)
    //     {
    //         return false;
    //     }

    //     //TODO strings may not match in number of characters

    //     const glyph = rows[cursorPos.rowIndex].glyphs[cursorPos.glyphIndex];
    //     cursorPos.rowIndex++;
    //     cursor.y = cursor.y + glyph.geometry.height;
    //     return true;
    // }
}
