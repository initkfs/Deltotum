module api.dm.gui.controls.texts.base_editable_text;

import api.dm.gui.controls.texts.base_mono_text : BaseMonoText;
import api.dm.gui.controls.texts.layouts.simple_text_layout : SimpleTextLayout;
import api.dm.gui.controls.texts.buffers.base_text_buffer : BaseTextBuffer;
import api.dm.gui.controls.texts.buffers.array_text_buffer : ArrayTextBuffer;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;

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

struct Selection
{
    CursorPos startPos;
    CursorPos endPos;
    bool isValid;
    bool isStart;
}

/**
 * Authors: initkfs
 */
class BaseEditableText : BaseMonoText
{
    Rectangle cursor;
    CursorPos cursorPos;

    Selection selection;

    bool isEditable;
    bool isStartTextInput;

    this(dstring text = "", typeof(_textBuffer) newBuffer = null, bool isFocusable = true)
    {
        super(text, newBuffer, isFocusable);

        //import api.math.pos2.insets : Insets;

        //_padding = Insets(5);
    }

    this(string text)
    {
        import std.conv : to;

        this(text.to!dstring);
    }

    abstract
    {
        bool insertText(size_t pos, dchar letter);
        bool removePrevText(size_t pos, size_t bufferLength);
    }

    override void initialize()
    {
        super.initialize;

        onFocusEnter ~= (ref e) {
            if (_focusEffect)
            {
                _focusEffect.isVisible = true;
            }

            window.startTextInput;
            isStartTextInput = true;
        };

        onFocusExit ~= (ref e) {
            if (_focusEffect && _focusEffect.isVisible)
            {
                _focusEffect.isVisible = false;
            }

            if (cursor)
            {
                cursor.isVisible = false;
            }

            cursorPos.isValid = false;
            selection.isValid = false;
            selection.isStart = false;

            isStartTextInput = false;

            window.endTextInput;
        };

        if (isEditable)
        {
            onPointerPress ~= (ref e) {

                // if(!isStartTextInput){
                //     return false;
                // }

                const mouseX = e.x;
                const mouseY = e.y;

                cursorPos = coordsToRowPos(mouseX, mouseY);

                if (cursorPos.isValid)
                {
                    selection.startPos = cursorPos;

                    selection.isStart = true;

                    if (selection.startPos.state == CursorState.forPrevGlyph)
                    {
                        if (selection.startPos.glyphIndexAbs < lastGlyphIndex)
                        {
                            selection.startPos.glyphIndexAbs++;
                            selection.startPos.state = CursorState.forNextGlyph;
                        }
                    }

                    selection.endPos = selection.startPos;
                }

                debug
                {
                    import std.stdio;

                    Glyph[] rows = allGlyphs;
                    if (rows.length > 0)
                    {
                        Glyph first = rows[cursorPos.glyphIndexAbs];
                        Glyph next;
                        if (cursorPos.glyphIndexAbs < rows.length - 1)
                        {
                            next = rows[cursorPos.glyphIndexAbs + 1];
                        }
                        writefln("Cursor pos for %s,%s: %s, betw %s:%s, row:%s", mouseX, mouseY, cursorPos, first.grapheme, next != next
                                .init ? next
                                .grapheme : '-', glyphsToStr(row(cursorPos.rowIndexAbs)));
                    }

                }

                updateCursor;
                cursor.isVisible = true;
            };

            onPointerRelease ~= (ref e) {
                if (selection.isStart)
                {
                    selection.isStart = false;
                }
            };

            onPointerClick ~= (ref e) {

                auto cursorPos = coordsToRowPos(e.x, e.y);

                if (cursorPos.isValid)
                {
                    size_t startIndex = cursorPos.glyphIndexAbs;
                    Glyph leftGlyph;
                    bool isFoundLeftIndex;
                    while (startIndex > 0)
                    {
                        startIndex--;

                        leftGlyph = allGlyphs[startIndex];
                        if (leftGlyph.grapheme == ' ')
                        {
                            selection.startPos = CursorPos(CursorState.forNextGlyph, leftGlyph.pos, startIndex + 1, cursorPos
                                    .rowIndexAbs, cursorPos.rowIndexInViewport, true);
                            isFoundLeftIndex = true;
                            break;
                        }
                    }

                    if (!isFoundLeftIndex)
                    {
                        selection.startPos = CursorPos(CursorState.forNextGlyph, leftGlyph.pos, startIndex, cursorPos
                                .rowIndexAbs, cursorPos.rowIndexInViewport, true);
                        isFoundLeftIndex = true;
                    }

                    size_t endGlyphIndex = allGlyphs.length - 1;
                    startIndex = cursorPos.glyphIndexAbs + 1;
                    Glyph rightGlyph;
                    bool isFoundRightSpace;
                    while (startIndex <= endGlyphIndex)
                    {
                        rightGlyph = allGlyphs[startIndex];
                        if (rightGlyph.grapheme == ' ')
                        {
                            selection.endPos = CursorPos(CursorState.forPrevGlyph, rightGlyph.pos, startIndex - 1, cursorPos
                                    .rowIndexAbs, cursorPos.rowIndexInViewport, true);
                            isFoundRightSpace = true;
                            break;
                        }
                        startIndex++;
                    }

                    if (!isFoundRightSpace)
                    {
                        selection.endPos = CursorPos(CursorState.forPrevGlyph, rightGlyph.pos, startIndex - 1, cursorPos
                                .rowIndexAbs, cursorPos.rowIndexInViewport, true);
                        isFoundLeftIndex = true;
                    }

                    selection.isStart = false;
                    selection.isValid = true;

                    if (cursor.isVisible)
                    {
                        cursor.isVisible = false;
                    }
                }

                e.isConsumed = true;
            };

            onKeyPress ~= (ref e) {

                if (!isStartTextInput)
                {
                    return;
                }

                import api.dm.com.inputs.com_keyboard : ComKeyName;

                if (e.keyName == ComKeyName.key_return && onEnter)
                {
                    if (onEnter(e))
                    {

                    }
                    return;
                }

                if (input.keyboard.keyModifier.isCtrl)
                {
                    switch (e.keyName) with (ComKeyName)
                    {
                        case key_c:
                            if (selection.isValid)
                            {
                                auto text = glyphsToStr(
                                    allGlyphs[selection.startPos.glyphIndexAbs .. selection
                                        .endPos.glyphIndexAbs + 1]);
                                if (!input.clipboard.setText(text))
                                {
                                    logger.error("Error setting text in clipboard");
                                }
                                else
                                {
                                    logger.trace("Copy text to clipboard: ", text);
                                }

                                return;
                            }
                            break;
                        case key_v:
                            if (input.clipboard.hasText)
                            {
                                import std.conv : to;

                                if (selection.isValid)
                                {
                                    if (!removeSelectionWithCursor)
                                    {
                                        logger.error("Error removing selection for insert");
                                        selection.isValid = false;
                                    }
                                }

                                if (!cursorPos.isValid)
                                {
                                    return;
                                }

                                dstring newText = input.clipboard.getText.to!dstring;
                                const insertIndex = cursorPos.state == CursorState.forPrevGlyph ? cursorPos
                                    .glyphIndexAbs + 1 : cursorPos.glyphIndexAbs;
                                if (!_textBuffer.insert(insertIndex, newText))
                                {
                                    logger.error("Error text inserting from clipboard: ", newText);
                                }
                                else
                                {
                                    updateRows;

                                    logger.trace("Paste text to clipboard: ", text);

                                    auto offset = newText.length;
                                    size_t newIndex = cursorPos.glyphIndexAbs + offset;
                                    if (newIndex >= lastGlyphIndex || !setCursorPos(newIndex, false))
                                    {
                                        logger.error("Error setting cursor index after insert: ", newIndex);

                                    }

                                    cursorPos.isValid = false;
                                    cursor.isVisible = false;
                                }

                                return;
                            }
                            break;
                        default:
                            break;
                    }
                }

                if (e.keyName == ComKeyName.key_backspace)
                {
                    if (selection.isValid)
                    {
                        if (!removeSelection)
                        {
                            logger.error("Error removing selection");
                        }
                        else
                        {
                            logger.trace("Remove selection on backspace");

                            if (!cursor.isVisible)
                            {
                                cursor.isVisible = true;
                            }

                            cursorPos = selection.startPos;

                            if (cursorPos.glyphIndexAbs == 0)
                            {
                                cursorPos.state = CursorState.forNextGlyph;
                            }
                            else
                            {
                                cursorPos.state = CursorState.forPrevGlyph;
                                cursorPos.glyphIndexAbs--;
                            }

                            if (allGlyphs.length > 0)
                            {
                                auto glyph = allGlyphs[cursorPos.glyphIndexAbs];

                                auto newPos = cursorPos.state == CursorState.forPrevGlyph ? Vec2d(
                                    glyph.pos.x + glyph.geometry.width, glyph.pos.y) : glyph.pos;
                                cursorPos.pos = startGlyphPos.add(newPos);
                                updateCursor;
                            }
                        }
                        return;
                    }

                    if (!cursorPos.isValid || cursorPos.state == CursorState.forNextGlyph)
                    {
                        return;
                    }

                    if (removePrevText(cursorPos.glyphIndexAbs, 1))
                    {
                        updateRows;

                        if (cursorPos.glyphIndexAbs > 0)
                        {
                            cursorPos.glyphIndexAbs--;
                            cursorPos.state = CursorState.forPrevGlyph;
                            if (!setCursorPos(cursorPos.glyphIndexAbs, isFromLeftGlyphCorner:
                                    false, isChangeCursorState:
                                    false))
                            {
                                logger.error("Invalid cursor pos: ", cursorPos);
                            }

                        }
                        else
                        {
                            cursorPos = CursorPos(CursorState.forNextGlyph, startGlyphPos, 0, 0, 0, true);
                            updateCursor;
                        }
                    }
                    else
                    {
                        logger.error("Error removing buffer text: ", text);
                    }

                    return;
                }

                if (selection.isStart)
                {
                    selection.isStart = false;
                    selection.isValid = false;
                }

                if (!cursor.isVisible)
                {
                    cursor.isVisible = true;
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
                    default:
                        break;
                }
            };

            onTextInput ~= (ref e) {

                // if (!isStartTextInput)
                // {
                //     return;
                // }

                if (selection.isValid)
                {
                    if (!removeSelectionWithCursor)
                    {
                        logger.error("Error removing selection on text input");
                        selection.isValid = false;
                        return;
                    }
                }

                if (!cursor.isVisible)
                {
                    return;
                }

                size_t textIndex = cursorPos.glyphIndexAbs;
                dchar letter = e.firstLetter;

                const insertIndex = cursorPos.state == CursorState.forPrevGlyph ? textIndex + 1
                    : textIndex;

                if (insertText(insertIndex, letter))
                {
                    updateRows;

                    if (cursorPos.state == CursorState.forPrevGlyph)
                    {
                        auto nextIndex = cursorPos.glyphIndexAbs + 1;
                        if (!setCursorPos(nextIndex, isFromLeftGlyphCorner:
                                false))
                        {
                            cursorPos.isValid = false;
                            cursor.isVisible = false;
                        }
                        else
                        {
                            cursorPos.glyphIndexAbs = nextIndex;
                        }
                    }
                    else
                    {
                        if (!setCursorPos(cursorPos.glyphIndexAbs, isFromLeftGlyphCorner:
                                false))
                        {
                            cursorPos.isValid = false;
                            cursor.isVisible = false;
                        }
                        else
                        {
                            cursorPos.state = CursorState.forPrevGlyph;
                        }
                    }

                }
            };

            onPointerMove ~= (ref e) {

                if (!selection.isStart)
                {
                    return;
                }

                auto newPos = coordsToRowPos(e.x, e.y);
                if (!newPos.isValid || newPos.glyphIndexAbs == cursorPos.glyphIndexAbs)
                {
                    return;
                }

                selection.isValid = true;

                if (newPos.glyphIndexAbs > selection.startPos.glyphIndexAbs)
                {
                    selection.endPos = newPos;
                }
                else
                {
                    selection.endPos = selection.startPos;
                    selection.startPos = newPos;
                }

                cursor.isVisible = false;
            };
        }
    }

    override void create()
    {
        super.create;

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

    void drawSelection()
    {
        if (!selection.isValid)
        {
            return;
        }

        const startCursorPos = selection.startPos;
        const endCursorPos = selection.endPos;

        if (startCursorPos.glyphIndexAbs >= endCursorPos.glyphIndexAbs)
        {
            selection.isValid = false;
            return;
        }

        RGBA color = theme.colorAccent;
        color.a = 0.5;

        graphic.color(color);
        scope (exit)
        {
            graphic.restoreColor;
        }

        const startRow = startCursorPos.rowIndexAbs;
        const endRow = endCursorPos.rowIndexAbs;

        float shapeWidth = 0;

        if (startRow == endRow)
        {
            auto startX = startGlyphX + allGlyphs[startCursorPos.glyphIndexAbs].pos.x;
            auto startY = startGlyphY + allGlyphs[startCursorPos.glyphIndexAbs].pos.y;

            auto endGlyph = allGlyphs[endCursorPos.glyphIndexAbs];

            shapeWidth = (endGlyph.pos.x + endGlyph.geometry.width) - allGlyphs[startCursorPos
                    .glyphIndexAbs].pos.x;

            graphic.fillRect(Rect2d(startX, startY, shapeWidth, rowHeight));
            return;
        }

        const fullRows = endRow - startRow;
        if (fullRows > 1)
        {
            size_t currRow = startRow + 1;
            while (currRow < endRow)
            {
                auto glyphs = row(currRow);
                if (glyphs.length > 0)
                {
                    auto firstGlyph = glyphs[0];
                    if (glyphs.length == 1)
                    {
                        shapeWidth = firstGlyph.geometry.width;
                    }
                    else
                    {
                        auto lastGlyph = glyphs[$ - 1];
                        shapeWidth = lastGlyph.pos.x + lastGlyph.geometry.width - firstGlyph.pos.x;
                    }

                    graphic.fillRect(Rect2d(startGlyphX + firstGlyph.pos.x, startGlyphY + firstGlyph.pos.y, shapeWidth, rowHeight));
                }

                currRow++;
            }
        }

        auto fullStartRow = row(startRow);
        auto fullStartFirst = allGlyphs[startCursorPos.glyphIndexAbs];
        auto fullStartEnd = fullStartRow[$ - 1];
        shapeWidth = fullStartEnd.pos.x + fullStartEnd.geometry.width - fullStartFirst.pos.x;
        graphic.fillRect(Rect2d(startGlyphX + fullStartFirst.pos.x, startGlyphY + fullStartFirst.pos.y, shapeWidth, rowHeight));

        auto fullEndRow = row(endRow);
        auto fullEndFirst = fullEndRow[0];
        auto fullEndEnd = allGlyphs[endCursorPos.glyphIndexAbs];
        shapeWidth = fullEndEnd.pos.x + fullStartEnd.geometry.width - fullEndFirst.pos.x;
        graphic.fillRect(Rect2d(startGlyphX + fullEndFirst.pos.x, startGlyphY + fullEndFirst.pos.y, shapeWidth, rowHeight));

    }

    override void drawContent()
    {
        super.drawContent;

        drawSelection;
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

    protected CursorPos coordsToRowPos(float x, float y)
    {
        const thisBounds = boundsRect;
        float startX = thisBounds.x + padding.left;
        float startY = thisBounds.y + padding.top;

        CursorPos result;

        if (lineBreaks.length == 0)
        {
            Glyph[] fullRow = allGlyphs;
            if (fullRow.length == 0 || !findFromRowX(fullRow, x, 0, 0, 0, result))
            {
                return CursorPos.init;
            }

            return result;
        }

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

            if (findFromRowX(needRow, x, prevBreakLine, rowIndexAbs, ri, result))
            {
                return result;
            }
        }

        //logger.error("Not found cursor position");
        return CursorPos.init;
    }

    bool findFromRowX(Glyph[] needRow, float x, size_t prevBreakLine, size_t rowIndexAbs, size_t ri, out CursorPos result)
    {
        if (needRow.length == 0)
        {
            return false;
        }

        const startX = startGlyphX;
        const startY = startGlyphY;

        const rowY = startY + ri * rowHeight;

        const lastRowIndex = needRow.length - 1;

        foreach (gi, ref Glyph glyph; needRow)
        {
            if (gi == 0)
            {
                const glyphMiddleX = startX + glyph.pos.x + glyph.geometry.halfWidth;
                if (x < glyphMiddleX)
                {
                    result = CursorPos(CursorState.forNextGlyph, Vec2d(startX, rowY), prevBreakLine, rowIndexAbs, ri, true);
                    return true;
                }
            }

            if (gi == lastRowIndex)
            {
                const glyphMiddleX = startX + glyph.pos.x + glyph.geometry.halfWidth;
                if (x > glyphMiddleX)
                {
                    result = CursorPos(CursorState.forPrevGlyph, Vec2d(startX + glyph.pos.x + glyph.geometry.width, rowY), prevBreakLine + gi, rowIndexAbs, ri, true);
                    return true;
                }
            }

            const glyphEndX = startX + glyph.pos.x + glyph.geometry.width;
            if (glyphEndX > x)
            {
                size_t glyphIndex = gi;

                const glyphMiddleX = glyphEndX - glyph.geometry.width / 2;
                Vec2d pos;
                if (x <= glyphMiddleX)
                {
                    glyphIndex = (glyphIndex > 0) ? (glyphIndex - 1) : 0;
                    auto prevGlyph = needRow[glyphIndex];
                    pos = Vec2d(startX + prevGlyph.pos.x + prevGlyph.geometry.width, rowY);
                }
                else
                {
                    auto currGlyph = needRow[glyphIndex];
                    pos = Vec2d(glyphEndX, rowY);
                }

                auto absGlyphIndex = prevBreakLine + glyphIndex;

                result = CursorPos(CursorState.forPrevGlyph, pos, absGlyphIndex, rowIndexAbs, ri, true);
                return true;
            }
        }

        return false;
    }

    bool setCursorPos(size_t index, bool isFromLeftGlyphCorner = true, bool isChangeCursorState = true)
    {
        if (index >= bufferLength)
        {
            return false;
        }

        auto nextGlyph = allGlyphs[index];

        const startX = startGlyphX;
        const startY = startGlyphY;

        if (isFromLeftGlyphCorner)
        {
            cursorPos.pos.x = startX + nextGlyph.pos.x;
        }
        else
        {
            cursorPos.pos.x = startX + nextGlyph.pos.x + nextGlyph.geometry.width;
        }

        if (scrollPosition > 0)
        {
            updateViewport;
            cursorPos.pos.y = startY + allGlyphs[index].pos.y;
        }
        else
        {
            cursorPos.pos.y = startY + nextGlyph.pos.y;
        }

        if (index == 0 && isChangeCursorState)
        {
            cursorPos.state = CursorState.forNextGlyph;
        }

        updateCursor;

        return true;
    }

    bool removeSelection()
    {
        if (!selection.isValid)
        {
            return false;
        }

        ptrdiff_t count = selection.endPos.glyphIndexAbs - selection.startPos.glyphIndexAbs + 1;
        if (count <= 0)
        {
            return false;
        }

        bool isRemove = _textBuffer.removePrev(selection.endPos.glyphIndexAbs, count) != 0;
        if (isRemove)
        {
            selection.isValid = false;
            selection.isStart = false;
            updateRows(isForce : true);
        }

        return isRemove;
    }

    bool removeSelectionWithCursor()
    {
        if (!selection.isValid)
        {
            return false;
        }

        if (!removeSelection)
        {
            return false;
        }

        logger.trace("Remove selection on text input");
        cursor.isVisible = true;
        cursorPos = selection.startPos;
        if (cursorPos.glyphIndexAbs == 0)
        {
            cursorPos.state = CursorState.forNextGlyph;
        }
        else
        {
            cursorPos.state = CursorState.forPrevGlyph;
            cursorPos.glyphIndexAbs--;
        }

        auto glyph = allGlyphs[cursorPos.glyphIndexAbs];
        auto newPos = cursorPos.state == CursorState.forPrevGlyph ? Vec2d(
            glyph.pos.x + glyph.geometry.width, glyph.pos.y) : glyph.pos;
        cursorPos.pos = startGlyphPos.add(newPos);
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
        if (lineBreaks.length == 0)
        {
            return allGlyphs;
        }

        auto currentBreak = textLayout.lineBreaks[rowIndex];
        if (rowIndex == 0)
        {
            return allGlyphs[0 .. currentBreak + 1];
        }

        auto prevBreak = textLayout.lineBreaks[rowIndex - 1];

        return allGlyphs[prevBreak + 1 .. currentBreak + 1];
    }

    float rowWidth(size_t rowIndex)
    {
        auto glyphs = row(rowIndex);

        if (glyphs.length == 0)
        {
            return 0;
        }

        if (glyphs.length == 1)
        {
            return glyphs[0].geometry.width;
        }

        float dt = glyphs[$ - 1].pos.x - glyphs[0].pos.x;
        return dt < 0 ? 0 : dt;
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
        if (viewportRows > 0 && cursorPos.rowIndexInViewport == viewportRows - 1)
        {
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
        }
        else
        {
            cursorPos.glyphIndexAbs = bufferLength - 1;
        }

        setCursorPos(isFromLeftGlyphCorner : false);

        return true;
    }

    bool clear(dstring defaultValue = null, bool isShowCursor = false)
    {
        if (_textBuffer.length == 0)
        {
            return false;
        }

        dstring newStr = defaultValue.length > 0 ? defaultValue : "";

        if (_textBuffer.create(newStr))
        {
            updateRows;
            cursorPos = CursorPos(CursorState.forNextGlyph, startGlyphPos, 0, 0, 0, true);
            updateCursor;

            if (isShowCursor)
            {
                cursor.isVisible = true;
            }

            return true;
        }

        return false;
    }

    override bool scrollTo(float value0to1)
    {
        if (!super.scrollTo(value0to1))
        {
            return false;
        }

        const value = false;

        cursor.isVisible = value;
        cursor.isValid = value;
        selection.isValid = value;
        selection.isStart = value;
        return true;
    }

}
