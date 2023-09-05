module deltotum.gui.controls.texts.text;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;
import deltotum.kit.sprites.flip : Flip;
import deltotum.gui.fonts.glyphs.glyph : Glyph;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.math.geom.insets : Insets;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;

import std.stdio;

protected
{
    struct TextRow
    {
        Glyph[] glyphs;
    }

    struct CursorPos
    {
        Vector2d pos;
        size_t rowIndex;
        size_t glyphIndex;
    }
}

/**
 * Authors: initkfs
 * TODO optimizations oldText == text
 */
class Text : Control
{
    int spaceWidth = 5;
    int rowHeight = 0;

    RGBA color = RGBA.white;

    Sprite focusEffect;
    Sprite delegate() focusEffectFactory;

    Rectangle cursor;

    CursorPos cursorPos;

    protected
    {
        dstring oldText;
        TextRow[] rows;

        dstring _text;
    }

    this(string text)
    {
        import std.conv : to;

        this(text.to!dstring);
        isFocusable = true;
    }

    this(dstring text = "text")
    {
        //TODO validate
        this._text = text;
    }

    override void initialize()
    {
        super.initialize;

        invalidateListeners ~= () { updateRows; };

        onFocusIn = (ref e) {
            if (focusEffect !is null)
            {
                focusEffect.isVisible = true;
            }
        };

        onFocusOut = (ref e) {
            if (focusEffect !is null && focusEffect.isVisible)
            {
                focusEffect.isVisible = false;
            }
        };

        onMouseDown = (ref e) {
            const mouseX = e.x;
            const mouseY = e.y;

            cursorPos = coordsToRowPos(mouseX, mouseY);
            if (cursorPos.pos.x == 0 && cursorPos.pos.y == 0)
            {
                //TODO error
                return;
            }

            debug
            {
                import std;

                writefln("Cursor position for %s, %s: %s", mouseX, mouseY, cursorPos);
            }

            cursor.x = cursorPos.pos.x;
            cursor.y = cursorPos.pos.y;
            cursor.isVisible = true;
        };

        onKeyDown = (ref e) {
            import deltotum.com.inputs.keyboards.key_name : KeyName;

            if (!cursor.isVisible)
            {
                return;
            }

            switch (e.keyName) with (KeyName)
            {
            case LEFT:
                if (cursorPos.glyphIndex == 0)
                {
                    //TODO cursor to left border
                    return;
                }
                const glyph = rows[cursorPos.rowIndex].glyphs[cursorPos.glyphIndex];
                cursorPos.glyphIndex--;
                cursor.x = cursor.x - glyph.geometry.width;
                break;
            case RIGHT:
                const row = rows[cursorPos.rowIndex];
                if (cursorPos.glyphIndex >= row.glyphs.length - 1)
                {
                    return;
                }
                const glyph = row.glyphs[cursorPos.glyphIndex];
                cursorPos.glyphIndex++;
                cursor.x = cursor.x + glyph.geometry.width;
                break;
            case DOWN:
                if (rows.length <= 1 || cursorPos.rowIndex >= rows.length - 1)
                {
                    return;
                }
                const glyph = rows[cursorPos.rowIndex].glyphs[cursorPos.glyphIndex];
                cursorPos.rowIndex++;
                cursor.y = cursor.y + glyph.geometry.height;
                break;
            case UP:
                if (cursorPos.rowIndex == 0)
                {
                    return;
                }
                const glyph = rows[cursorPos.rowIndex].glyphs[cursorPos.glyphIndex];
                cursorPos.rowIndex--;
                cursor.y = cursor.y - glyph.geometry.height;
                break;
            case BACKSPACE:
            break;
            default:
                break;
            }
        };

        if (isFocusable)
        {
            focusEffectFactory = () {
                import deltotum.kit.graphics.shapes.rectangle : Rectangle;
                import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

                GraphicStyle style = GraphicStyle(1, graphics.theme.colorFocus);

                import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;

                auto effect = new RegularPolygon(width, height, style, graphics
                        .theme.controlCornersBevel);
                //auto effect = new Rectangle(width, height, style);
                effect.isVisible = false;
                return effect;
            };
        }
    }

    override void create()
    {
        super.create;

        import deltotum.math.geom.insets : Insets;

        padding = Insets(0);

        updateRows;

        if (focusEffectFactory !is null)
        {
            focusEffect = focusEffectFactory();
            focusEffect.isLayoutManaged = false;
            focusEffect.isVisible = false;
            addCreate(focusEffect);
        }

        import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

        cursor = new Rectangle(2, 10, GraphicStyle(1, RGBA.white, true, RGBA.white));
        addCreate(cursor);
        cursor.isLayoutManaged = false;
        cursor.isVisible = false;

    }

    //TODO buffer []
    //TODO optimizations
    // 35142       12631       12063           0     deltotum.gui.fonts.glyphs.glyph.Glyph[] deltotum.gui.controls.texts.text.Text.textToGlyphs(immutable(dchar)[])
    protected Glyph[] textToGlyphs(dstring textString)
    {
        if (textString.length == 0)
        {
            return [];
        }

        Glyph[] newGlyphs;
        newGlyphs.reserve(textString.length);

        //TODO on^2?
        foreach (grapheme; textString)
        {
            Glyph newGlyph;
            bool isFound;
            //TODO hash map
            foreach (glyph; asset.defaultBitmapFont.glyphs)
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
                newGlyph = asset.defaultBitmapFont.placeholder;
            }

            newGlyphs ~= newGlyph;
        }

        return newGlyphs;
    }

    protected TextRow[] textToRows(dstring text)
    {
        TextRow[] newRows;

        auto glyphs = textToGlyphs(text);
        if (glyphs.length == 0)
        {
            return newRows;
        }

        rowHeight = cast(int) glyphs[0].geometry.height;

        const double startRowTextX = padding.left;
        double endRowTextX = maxWidth - padding.right;

        const double startRowTextY = padding.top;

        double glyphPosX = startRowTextX;
        double glyphPosY = startRowTextY;

        TextRow row;
        bool isStartNewLine;
        foreach (Glyph glyph; glyphs)
        {
            auto nextGlyphPosX = glyphPosX + glyph.geometry.width;
            if (nextGlyphPosX <= endRowTextX && nextGlyphPosX > width)
            {
                width = width + (nextGlyphPosX - width + padding.right);
            }

            if (glyph.isNEL)
            {
                newRows ~= row;
                row = TextRow();
                glyphPosX = startRowTextX;
                glyphPosY += rowHeight;
                isStartNewLine = true;
            }
            else if (nextGlyphPosX > endRowTextX)
            {
                long slicePos = -1;
                foreach_reverse (j, oldGlyph; row.glyphs)
                {
                    if (oldGlyph.grapheme == ' ')
                    {
                        if (j == row.glyphs.length - 1)
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
                isStartNewLine = true;
            }

            if (isStartNewLine)
            {
                isStartNewLine = false;
                // if (glyph.isEmpty)
                // {
                //     continue;
                // }
            }

            glyph.pos.x = glyphPosX;
            glyph.pos.y = glyphPosY;

            row.glyphs ~= glyph;
            glyphPosX += glyph.geometry.width;
        }

        if (row.glyphs.length > 0)
        {
            newRows ~= row;
        }

        auto newHeight = newRows.length * rowHeight + padding.height;
        if (newHeight > height)
        {
            import std.algorithm.comparison : min;

            height = min(maxHeight, newHeight);
        }

        return newRows;
    }

    protected CursorPos coordsToRowPos(double x, double y)
    {
        const thisBounds = bounds;
        //TODO row height
        foreach (ri, row; rows)
        {
            if (row.glyphs.length == 0)
            {
                continue;
            }

            //TODO row height
            Glyph* firstGlyph = &(row.glyphs[0]);

            const rowMinY = thisBounds.y + firstGlyph.pos.y;
            const rowMaxY = rowMinY + firstGlyph.geometry.height;

            if (y < rowMinY || y > rowMaxY)
            {
                continue;
            }

            foreach (gi, glyph; row.glyphs)
            {
                const glyphMinX = thisBounds.x + glyph.pos.x;
                const glyphMaxX = glyphMinX + glyph.geometry.width;

                if (x > glyphMinX && x < glyphMaxX)
                {
                    const minMaxRange = glyphMaxX - glyphMinX;
                    const posX = x < (minMaxRange / 2) ? glyphMinX : glyphMaxX;
                    const pos = Vector2d(posX, rowMinY);
                    return CursorPos(pos, ri, gi);
                }
            }
        }
        return CursorPos.init;
    }

    dstring glyphsToStr(Glyph[] glyphs)
    {
        import std.algorithm.iteration : map;
        import std.conv : to;

        return glyphs.map!(g => g.grapheme)
            .to!dstring;
    }

    void updateRows()
    {
        this.rows = textToRows(_text);
    }

    void addRows(dstring text)
    {
        this.rows ~= textToRows(text);
    }

    protected void renderText(TextRow[] rows)
    {
        if (width == 0 || height == 0)
        {
            return;
        }

        const thisBounds = bounds;

        foreach (TextRow row; rows)
        {
            foreach (Glyph glyph; row.glyphs)
            {
                Rect2d textureBounds = glyph.geometry;
                Rect2d destBounds = Rect2d(thisBounds.x + glyph.pos.x, thisBounds.y + glyph.pos.y, glyph
                        .geometry.width, glyph
                        .geometry.height);
                asset.defaultBitmapFont.drawTexture(textureBounds, destBounds, angle, Flip
                        .none);
            }
        }
    }

    override void drawContent()
    {
        renderText(rows);
    }

    override void update(double delta)
    {
        super.update(delta);
        if (_text.length == 0)
        {
            return;
        }

        if (oldText != _text)
        {
            updateRows;
            oldText = _text;
        }
    }

    void appendText(dstring text)
    {
        if (rows.length == 0)
        {
            this._text = text;
        }
        else
        {
            addRows(text);
            this._text ~= text;
            this.oldText = text;
        }
    }

    void text(string t)
    {
        import std.conv : to;

        _text = t.to!dstring;
    }

    void text(dstring t)
    {
        _text = t;
    }

    ref dstring text()
    {
        return _text;
    }
}
