module api.dm.gui.controls.texts.editable_text;

import api.dm.gui.controls.texts.base_text : BaseText;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
import api.math.geom2.vec2 : Vec2d;

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
