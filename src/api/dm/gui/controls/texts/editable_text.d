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
    size_t glyphIndex;

    bool isValid;
}

/**
 * Authors: initkfs
 */
class EditableText : BaseText
{
    Rectangle cursor;
    CursorPos cursorPos;

    bool isEditable;

    this()
    {
        isFocusable = true;
    }

    abstract
    {
        bool insert(size_t pos, dchar letter);
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
                    Glyph* first = rows[cursorPos.glyphIndex];
                    Glyph* next;
                    if (cursorPos.glyphIndex < rows.length - 1)
                    {
                        next = rows[cursorPos.glyphIndex + 1];
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

                switch (e.keyName) with (ComKeyName)
                {
                    //         case key_left:
                    //             moveCursorLeft;
                    //             break;
                    //         case key_right:
                    //             moveCursorRight;
                    //             break;
                    //         case key_down:
                    //             moveCursorDown;
                    //             break;
                    //         case key_up:
                    //             moveCursorUp;
                    //             break;
                    //         case key_backspace:

                    //             if (!cursorPos.isValid)
                    //             {
                    //                 return;
                    //             }

                    //             logger.tracef("Backspace pressed for cursor: %s", cursorPos);

                    //             if (cursorPos.glyphIndex == 0)
                    //             {
                    //                 if (cursorPos.state == CursorState.forNextGlyph)
                    //                 {
                    //                     return;
                    //                 }
                    //             }

                    //             auto row = rows[cursorPos.rowIndex];

                    //             if (row.glyphs.length == 0)
                    //             {
                    //                 return;
                    //             }

                    //             if (cursorPos.state == CursorState.forNextGlyph)
                    //             {
                    //                 cursorPos.glyphIndex--;
                    //             }
                    //             else if (cursorPos.state == CursorState.forPrevGlyph)
                    //             {
                    //                 cursorPos.state = CursorState.forNextGlyph;
                    //             }

                    //             import std.algorithm.mutation : remove;

                    //             size_t textIndex = cursorGlyphIndex;
                    //             auto glyph = row.glyphs[cursorPos.glyphIndex];

                    //             // _text = _text.remove(textIndex);
                    //             // cursorPos.pos.x -= glyph.geometry.width;

                    //             // logger.tracef("Remove index %s, new cursor pos: %s", textIndex, cursorPos);

                    //             updateCursor;
                    //             setInvalid;
                    //             break;
                    default:
                        break;
                }
            };

            onTextInput ~= (ref e) {

                if (!cursor.isVisible)
                {
                    return;
                }

                size_t textIndex = cursorPos.glyphIndex;
                dchar letter = e.firstLetter;

                if (insert(textIndex, letter))
                {
                    cursorPos.pos.x += 10;
                    cursorPos.glyphIndex++;
                    updateCursor;
                    setInvalid;
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

    abstract Glyph*[] allGlyphs();
    abstract Glyph*[] viewportRows(out size_t firstRowIndex);
    abstract size_t[] lineBreaks();
    abstract size_t glyphsCount();

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
