module api.dm.gui.controls.texts.editable_text;

import api.dm.gui.controls.texts.base_mono_text : BaseMonoText, TextStruct;
import api.dm.gui.controls.texts.buffers.base_text_buffer : BaseTextBuffer;
import api.dm.gui.controls.texts.buffers.array_text_buffer : ArrayTextBuffer;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
import api.math.geom2.vec2 : Vec2d;

import std.stdio : writeln, writefln;
import Math = api.math;

enum CursorState
{
    forPrevGlyph,
    forNextGlyph
}

struct CursorPos
{
    CursorState state;
    Vec2d pos;
    size_t glyphIndexAbs;
    size_t rowIndexAbs;
    size_t rowIndexInViewport;

    bool isValid;
}

/**
 * Authors: initkfs
 */
class EditableText : BaseMonoText
{
    Rectangle cursor;
    CursorPos cursorPos;

    bool isEditable;

    this(typeof(_textBuffer) newBuffer = null)
    {
        super(newBuffer);
        isFocusable = true;
    }

    abstract
    {
        bool insertText(size_t pos, dchar letter);
        bool removePrevText(size_t pos, size_t bufferLength);
    }

    override void initialize()
    {
        super.initialize;

        if (isFocusable)
        {
            focusEffectFactory = () {
                import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
                import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

                GraphicStyle style = GraphicStyle(1, theme.colorFocus);

                import api.dm.kit.sprites2d.shapes.convex_polygon : ConvexPolygon;

                auto effect = new ConvexPolygon(width, height, style, theme.controlCornersBevel);
                //auto effect = new Rectangle(width, height, style);
                effect.isVisible = false;
                return effect;
            };

            onFocusEnter ~= (ref e) {
                if (focusEffect)
                {
                    focusEffect.isVisible = true;
                }

                window.startTextInput;
            };

            onFocusExit ~= (ref e) {
                if (focusEffect && focusEffect.isVisible)
                {
                    focusEffect.isVisible = false;
                    if (cursor)
                    {
                        cursor.isVisible = false;
                    }
                }

                window.endTextInput;
            };
        }

        if (isEditable)
        {
            onPointerPress ~= (ref e) {

                const mouseX = e.x;
                const mouseY = e.y;

                cursorPos = coordsToRowPos(mouseX, mouseY);

                debug
                {
                    import std.stdio;

                    Glyph[] rows = allGlyphs;
                    Glyph first = rows[cursorPos.glyphIndexAbs];
                    Glyph next;
                    if (cursorPos.glyphIndexAbs < rows.length - 1)
                    {
                        next = rows[cursorPos.glyphIndexAbs + 1];
                    }
                    writefln("Cursor pos for %s,%s: %s, betw %s:%s", mouseX, mouseY, cursorPos, first.grapheme, next != next
                            .init ? next
                            .grapheme : '-');
                }

                updateCursor;
                cursor.isVisible = true;
            };

            onKeyPress ~= (ref e) {
                import api.dm.com.inputs.com_keyboard : ComKeyName;

                if (!cursor.isVisible)
                {
                    return;
                }

                if (e.keyName == ComKeyName.key_return && onEnter)
                {
                    onEnter(e);
                    return;
                }

                if (input.keyboard.keyModifier.isCtrl)
                {
                    switch (e.keyName) with (ComKeyName)
                    {
                        case key_j:
                            moveCursorLeft;
                            break;
                        case key_l:
                            moveCursorRight;
                            break;
                        case key_u:
                            moveCursorUp;
                            break;
                        case key_m:
                            moveCursorDown;
                            break;
                        default:
                            break;
                    }
                }

                switch (e.keyName) with (ComKeyName)
                {
                    case key_left:
                        moveCursorLeft;
                        break;
                    case key_right:
                        moveCursorRight;
                        break;
                    case key_down:
                        moveCursorDown;
                        break;
                    case key_up:
                        moveCursorUp;
                        break;
                    case key_backspace:

                        if (!cursorPos.isValid || cursorPos.state == CursorState.forNextGlyph)
                        {
                            return;
                        }

                        if (removePrevText(cursorPos.glyphIndexAbs, 1))
                        {
                            updateRows;

                            auto nextIndex = cursorPos.glyphIndexAbs;

                            const bounds = boundsRect;
                            auto nextGlyph = allGlyphs[nextIndex];
                            cursorPos.pos.x = bounds.x + padding.left + nextGlyph.pos.x;
                            cursorPos.pos.y = bounds.y + padding.top + nextGlyph.pos.y;

                            if (cursorPos.glyphIndexAbs > 0)
                            {
                                cursorPos.glyphIndexAbs--;
                            }
                            else
                            {
                                cursorPos.state = CursorState.forNextGlyph;
                            }

                            updateCursor;
                            setInvalid;
                        }
                        break;
                    default:
                        break;
                }
            };

            onTextInput ~= (ref e) {

                if (!cursor.isVisible)
                {
                    return;
                }

                size_t textIndex = cursorPos.glyphIndexAbs;
                dchar letter = e.firstLetter;

                if (insertText(textIndex, letter))
                {
                    updateRows;

                    auto nextIndex = cursorPos.glyphIndexAbs + 2;
                    if (bufferLength > 0 && nextIndex < bufferLength)
                    {
                        const bounds = boundsRect;
                        auto nextGlyph = allGlyphs[nextIndex];
                        cursorPos.pos.x = bounds.x + padding.left + nextGlyph.pos.x;
                        cursorPos.pos.y = bounds.y + padding.top + nextGlyph.pos.y;

                        cursorPos.glyphIndexAbs++;
                        updateCursor;
                        setInvalid;
                    }

                }
            };
        }
    }

    override void create()
    {
        super.create;

        if (focusEffectFactory)
        {
            focusEffect = focusEffectFactory();
            focusEffect.isLayoutManaged = false;
            focusEffect.isResizedByParent = true;
            focusEffect.isVisible = false;
            addCreate(focusEffect);
        }

        if (isEditable)
        {
            const cursorColor = theme.colorAccent;

            import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
            import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

            cursor = new Rectangle(2, 20, GraphicStyle(1, cursorColor, true, cursorColor));
            addCreate(cursor);
            cursor.isLayoutManaged = false;
            cursor.isVisible = false;
        }

    }

    bool updateCursor()
    {
        if (!cursor || !cursorPos.isValid)
        {
            return false;
        }
        cursor.xy(cursorPos.pos.x, cursorPos.pos.y);
        return true;
    }

    // size_t cursorGlyphIndex()
    // {
    //     return cursorGlyphIndex(cursorPos.rowIndex, cursorPos.glyphIndexAbs);
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

    protected CursorPos coordsToRowPos(double x, double y)
    {
        const thisBounds = boundsRect;
        double startX = thisBounds.x + padding.left;
        double startY = thisBounds.y + padding.top;

        Vec2d breakIdx = viewportRowIndex;
        size_t rowStartIndex = cast(size_t) breakIdx.x;
        size_t rowEndIndex = cast(size_t) breakIdx.y;

        size_t rowIndex;
        foreach (ri, lineBreak; lineBreaks[rowStartIndex .. rowEndIndex + 1])
        {
            auto rowStartY = startY + ri * rowHeight;
            auto endRowY = rowStartY + rowHeight;
            if (!(y >= rowStartY && y <= endRowY))
            {
                continue;
            }

            rowIndex = ri;

            size_t prevBreakLine = 0;

            if (ri > 0 || rowStartIndex > 0)
            {
                prevBreakLine = lineBreaks[rowStartIndex + ri - 1];

                const maxCount = bufferLength;
                size_t glyphMaxIndex = maxCount > 0 ? maxCount - 1 : 0;
                if (prevBreakLine < glyphMaxIndex)
                {
                    prevBreakLine++;
                }
            }

            Glyph[] needRow = allGlyphs[prevBreakLine .. lineBreak + 1];

            if (needRow.length == 0)
            {
                logger.error("Empty row for cursor: ", prevBreakLine, " ", lineBreak + 1);
                return CursorPos.init;
            }

            const rowIndexAbs = rowStartIndex + ri;
            const rowY = startY + ri * rowHeight;
            size_t lastRowIndex = needRow.length - 1;

            foreach (gi, ref Glyph glyph; needRow)
            {

                if (gi == 0)
                {
                    const glyphMiddleX = startX + glyph.pos.x + glyph.geometry.halfWidth;
                    if (x < glyphMiddleX)
                    {
                        return CursorPos(CursorState.forNextGlyph, Vec2d(startX, rowY), prevBreakLine, rowIndexAbs, ri, true);
                    }
                }

                if (gi == lastRowIndex)
                {
                    const glyphMiddleX = startX + glyph.pos.x + glyph.geometry.halfWidth;
                    if (x > glyphMiddleX)
                    {
                        return CursorPos(CursorState.forPrevGlyph, Vec2d(startX + glyph.pos.x + glyph.geometry.width, rowY), prevBreakLine + gi, rowIndexAbs, ri, true);
                    }
                }

                if (startX + glyph.pos.x > x)
                {
                    auto glyphIndex = gi;
                    Vec2d pos;
                    if (gi > 0)
                    {
                        glyphIndex--;
                        auto prevGlyph = needRow[glyphIndex];
                        pos = Vec2d(startX + prevGlyph.pos.x + prevGlyph.geometry.width, rowY);
                    }
                    else
                    {
                        pos = Vec2d(startX, rowY);
                    }

                    auto absGlyphIndex = prevBreakLine + glyphIndex;

                    return CursorPos(CursorState.forPrevGlyph, pos, absGlyphIndex, rowIndexAbs, ri, true);
                }
            }
        }

        logger.error("Not found cursor position");
        return CursorPos.init;
    }

    bool setCursorPos(size_t index, bool isFromLeftGlyphCorner = true)
    {
        if (index >= bufferLength)
        {
            return false;
        }
        const bounds = boundsRect;

        auto nextGlyph = allGlyphs[index];

        const startX = bounds.x + padding.left;

        if (isFromLeftGlyphCorner)
        {
            cursorPos.pos.x = startX + nextGlyph.pos.x;
        }
        else
        {
            cursorPos.pos.x = startX + nextGlyph.pos.x + nextGlyph.geometry.width;
        }

        cursorPos.pos.y = bounds.y + padding.top + nextGlyph.pos.y;

        if (index == 0)
        {
            cursorPos.state = CursorState.forNextGlyph;
        }

        updateCursor;

        return true;
    }

    bool setCursorPos(bool isFromLeftGlyphCorner = true) => setCursorPos(
        cursorPos.glyphIndexAbs, isFromLeftGlyphCorner);

    bool moveCursorLeft()
    {
        if (!cursorPos.isValid)
        {
            return false;
        }

        setCursorPos;

        if (cursorPos.glyphIndexAbs == 0)
        {
            return false;
        }

        cursorPos.glyphIndexAbs--;

        return true;
    }

    bool moveCursorRight()
    {
        if (!cursorPos.isValid)
        {
            return false;
        }

        if (cursorPos.glyphIndexAbs >= bufferLength)
        {
            return false;
        }

        cursorPos.glyphIndexAbs++;
        setCursorPos(isFromLeftGlyphCorner : false);
        return true;
    }

    Glyph[] currentRow() => row(cursorPos.rowIndexAbs);

    Glyph[] row(size_t rowIndex)
    {
        auto currentBreak = textStruct.lineBreaks[rowIndex];
        if (rowIndex == 0)
        {
            return allGlyphs[0 .. currentBreak + 1];
        }

        auto prevBreak = textStruct.lineBreaks[rowIndex - 1];

        return allGlyphs[prevBreak + 1 .. currentBreak + 1];
    }

    bool moveCursorUp()
    {
        if (cursorPos.rowIndexInViewport == 0 || cursorPos.rowIndexAbs == 0)
        {
            return false;
        }

        cursorPos.rowIndexAbs--;
        cursorPos.rowIndexInViewport = cursorPos.rowIndexInViewport == 0 ? 0
            : cursorPos.rowIndexInViewport - 1;

        size_t prevLineBreak = lineBreaks[cursorPos.rowIndexAbs];

        ptrdiff_t posFromStartRow = cursorPos.glyphIndexAbs - prevLineBreak;
        if (posFromStartRow < 0)
        {
            return false;
        }

        size_t prevPrevLineBreak = cursorPos.rowIndexAbs == 0 ? 0
            : lineBreaks[cursorPos.rowIndexAbs - 1];
        if (prevPrevLineBreak == 0 && posFromStartRow > 0)
        {
            posFromStartRow--;
        }

        ptrdiff_t nextRowIndex = prevPrevLineBreak + posFromStartRow;
        if (nextRowIndex >= 0 && nextRowIndex < bufferLength)
        {
            cursorPos.glyphIndexAbs = nextRowIndex;
            setCursorPos(isFromLeftGlyphCorner : false);
            return true;
        }

        return false;
    }

    bool moveCursorDown()
    {
        size_t lastRowIndex = lineBreaks.length > 0 ? lineBreaks.length - 1 : 0;
        //TODO viewport?
        if (cursorPos.rowIndexAbs == lastRowIndex)
        {
            return false;
        }

        const viewportRows = rowsInViewport;
        if(viewportRows > 0 && cursorPos.rowIndexInViewport == viewportRows - 1){
            return false;
        }

        size_t prevLineBreak = cursorPos.rowIndexAbs == 0 ? 0 : lineBreaks[cursorPos.rowIndexAbs - 1];
        ptrdiff_t posFromStartRow = cursorPos.glyphIndexAbs - prevLineBreak;
        if (posFromStartRow < 0)
        {
            return false;
        }

        size_t currLineBreak = lineBreaks[cursorPos.rowIndexAbs];

        cursorPos.rowIndexAbs++;
        
        if (viewportRows > 0 && cursorPos.rowIndexInViewport < viewportRows - 1)
        {
            cursorPos.rowIndexInViewport++;
        }

        size_t nextRowIndex = currLineBreak + posFromStartRow;
        if (nextRowIndex < bufferLength)
        {
            cursorPos.glyphIndexAbs = nextRowIndex;
        }else {
            cursorPos.glyphIndexAbs = bufferLength - 1;
        }

        setCursorPos(isFromLeftGlyphCorner : false);

        return true;
    }

}
