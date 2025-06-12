module api.dm.gui.controls.texts.editable_text;

import api.dm.gui.controls.texts.base_text : BaseText;
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
    size_t rowIndex;
    size_t glyphIndexAbs;

    bool isValid;
}

struct DocStruct
{
    size_t[] rowsGlyphCount;
    size_t[] lineBreaks;
}

/**
 * Authors: initkfs
 */
class EditableText : BaseText
{
    Rectangle cursor;
    CursorPos cursorPos;

    bool isEditable;

    DocStruct docStruct;

    this()
    {
        isFocusable = true;
    }

    abstract
    {
        bool insertText(size_t pos, dchar letter);
        bool removePrevText(size_t pos, size_t count);

        Glyph*[] allGlyphs();
        Glyph*[] viewportRows(out size_t firstRowIndex);
        size_t[] lineBreaks();
        size_t glyphsCount();
        void updateRows(bool isForce = false);
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

                // if (!cursorPos.isValid)
                // {
                //     Vec2d pos;
                //     CursorState state;
                //     size_t glyphIndex;
                // if (rows.length == 0)
                // {
                //     pos = Vec2d(x + padding.left, y + padding.top);
                //     state = CursorState.forNextGlyph;
                // }
                // else
                // {
                //TODO empty rows
                // auto lastRow = rows[$ - 1];
                // glyphIndex = lastRow.glyphs.length - 1;
                // auto lastRowGlyph = lastRow.glyphs[$ - 1];
                // pos = Vec2d(x + lastRowGlyph.pos.x + lastRowGlyph.geometry.width, y + lastRowGlyph
                //         .pos.y);
                // state = CursorState.forPrevGlyph;
                // cursorPos = CursorPos(state, pos, 0, glyphIndex, true);
                //}

                debug
                {
                    import std.stdio;

                    Glyph*[] rows = allGlyphs;
                    Glyph* first = rows[cursorPos.glyphIndexAbs];
                    Glyph* next;
                    if (cursorPos.glyphIndexAbs < rows.length - 1)
                    {
                        next = rows[cursorPos.glyphIndexAbs + 1];
                    }
                    writefln("Cursor pos for %s,%s: %s, betw %s:%s", mouseX, mouseY, cursorPos, first.grapheme, next ? next
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
                    if (glyphsCount > 0 && nextIndex < glyphsCount)
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

        size_t firstIndex;
        Glyph*[] rows = viewportRows(firstIndex);

        size_t rowIndex;
        foreach (ri, lineBreak; lineBreaks)
        {
            auto currentH = startY + (1 + ri) * rowHeight;
            if (currentH < y)
            {
                continue;
            }

            rowIndex = ri;

            auto prevBreakIndex = ri == 0 ? 0 : ri - 1;
            auto prevBreakLine = lineBreaks[prevBreakIndex];

            const maxCount = glyphsCount;
            size_t glyphMaxIndex = maxCount > 0 ? maxCount - 1 : 0;
            if (prevBreakLine < glyphMaxIndex)
            {
                prevBreakLine++;
            }

            Glyph*[] needRow = rows[prevBreakLine .. lineBreak + 1];

            size_t glyphIndex;
            Vec2d pos;

            foreach (gi, Glyph* glyph; needRow)
            {
                if (startX + glyph.pos.x > x)
                {
                    glyphIndex = gi;
                    if (gi > 0)
                    {
                        glyphIndex--;
                        auto prevGlyph = needRow[glyphIndex];
                        pos = Vec2d(startX + prevGlyph.pos.x + prevGlyph.geometry.width, startY + ri * rowHeight);
                    }
                    else
                    {
                        pos = Vec2d(startX, startY + ri * rowHeight);
                    }

                    break;
                }
            }

            auto absGlyphIndex = prevBreakLine + glyphIndex;

            return CursorPos(CursorState.forPrevGlyph, pos, ri, absGlyphIndex, true);
        }

        return CursorPos.init;
    }

    bool setCursorPos(size_t index)
    {
        if (index >= glyphsCount)
        {
            return false;
        }
        const bounds = boundsRect;
        auto nextGlyph = allGlyphs[index];
        cursorPos.pos.x = bounds.x + padding.left + nextGlyph.pos.x;
        cursorPos.pos.y = bounds.y + padding.top + nextGlyph.pos.y;

        updateCursor;

        return true;
    }

    bool setCursorPos() => setCursorPos(cursorPos.glyphIndexAbs);

    bool moveCursorLeft()
    {
        if (!cursorPos.isValid)
        {
            return false;
        }

        if (cursorPos.glyphIndexAbs == 0)
        {
            return false;
        }

        cursorPos.glyphIndexAbs--;
        setCursorPos;
        return true;
    }

    bool moveCursorRight()
    {
        if (!cursorPos.isValid)
        {
            return false;
        }

        if (cursorPos.glyphIndexAbs >= glyphsCount)
        {
            return false;
        }

        cursorPos.glyphIndexAbs++;
        setCursorPos;
        return true;
    }

    Glyph*[] currentRow()
    {
        auto currentBreak = docStruct.lineBreaks[cursorPos.rowIndex];
        if (cursorPos.rowIndex == 0)
        {
            return allGlyphs[0 .. currentBreak + 1];
        }

        auto prevBreak = docStruct.lineBreaks[cursorPos.rowIndex - 1];

        return allGlyphs[prevBreak + 1 .. currentBreak + 1];
    }

    bool moveCursorUp()
    {
        if (cursorPos.rowIndex == 0)
        {
            return false;
        }

        auto row = docStruct.lineBreaks[cursorPos.rowIndex];

        cursorPos.rowIndex--;

        auto nextRow = docStruct.lineBreaks[cursorPos.rowIndex];

        ptrdiff_t currentPosRel = row - cursorPos.glyphIndexAbs;
        if (currentPosRel < 0)
        {
            return false;
        }

        auto nextRowIndex = nextRow - currentPosRel;
        if (nextRowIndex < glyphsCount)
        {
            cursorPos.glyphIndexAbs = nextRowIndex;
            setCursorPos;
            return true;
        }

        return false;
    }

    bool moveCursorDown()
    {
        auto maxRowIndex = docStruct.lineBreaks.length == 0 ? 0 : docStruct.lineBreaks.length - 1;
        if (cursorPos.rowIndex == maxRowIndex)
        {
            return false;
        }

        auto row = docStruct.lineBreaks[cursorPos.rowIndex];

        cursorPos.rowIndex++;

        auto nextRow = docStruct.lineBreaks[cursorPos.rowIndex];

        ptrdiff_t currentPosRel = row - cursorPos.glyphIndexAbs;
        if (currentPosRel < 0)
        {
            return false;
        }

        auto nextRowIndex = nextRow - currentPosRel;
        if (nextRowIndex < glyphsCount)
        {
            cursorPos.glyphIndexAbs = nextRowIndex;
            setCursorPos;
            return true;
        }

        return false;
    }

}
