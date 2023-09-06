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
        Glyph*[] glyphs;
    }

    struct CursorPos
    {
        Vector2d pos;
        size_t rowIndex;
        size_t glyphIndex;
        bool isValid;
    }
}

/**
 * Authors: initkfs
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
        TextRow[] rows;

        dstring tempText;

        Glyph[] _text;
        bool isRebuildRows;
    }

    this(string text)
    {
        import std.conv : to;

        this(text.to!dstring);
    }

    this(dstring text = "text")
    {
        this.tempText = text;
        isFocusable = true;

        import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;

        this.layout = new ManagedLayout;
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
                cursor.isVisible = false;
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
                import std.stdio;

                writefln("Cursor pos for %s,%s: %s", mouseX, mouseY, cursorPos);
            }

            updateCursor;
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
                moveCursorLeft;
                break;
            case RIGHT:
                moveCursorRight;
                break;
            case DOWN:
                moveCursorDown;
                break;
            case UP:
                moveCursorUp;
                break;
            case BACKSPACE:
                if (!cursorPos.isValid || cursorPos.glyphIndex == 0)
                {
                    return;
                }

                cursorPos.glyphIndex--;

                import std.algorithm.mutation : remove;

                size_t textIndex = cursorGlyphIndex;
                auto glyph = rows[cursorPos.rowIndex].glyphs[cursorPos.glyphIndex];

                _text = _text.remove(textIndex);
                cursorPos.pos.x -= glyph.geometry.width;

                updateCursor;
                setInvalid;
                break;
            default:
                break;
            }
        };

        onTextInput = (ref e) {
            if (!cursor.isVisible)
            {
                return;
            }
            size_t textIndex = cursorGlyphIndex();
            import std.array : insertInPlace;

            //TODO one glyph
            import std.conv : to;

            auto glyphsArr = textToGlyphs(e.firstLetter.to!dstring);

            double glyphOffset;
            foreach (ref glyph; glyphsArr)
            {
                glyphOffset += glyph.geometry.width;
            }

            if (textIndex == 0)
            {
                _text ~= glyphsArr;
            }
            else
            {
                _text.insertInPlace(textIndex, glyphsArr);
            }

            cursorPos.pos.x += glyphOffset;
            updateCursor;
            setInvalid;
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
            focusEffect.isResizedByParent = true;
            focusEffect.isVisible = false;
            addCreate(focusEffect);
        }

        import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

        const cursorColor = graphics.theme.colorAccent;

        cursor = new Rectangle(2, 20, GraphicStyle(1, cursorColor, true, cursorColor));
        addCreate(cursor);
        cursor.isLayoutManaged = false;
        cursor.isVisible = false;

    }

    override void update(double delta)
    {
        super.update(delta);
        if (tempText !is null)
        {
            updateRows;
            tempText = null;
        }

        if (isRebuildRows)
        {
            updateRows;
            isRebuildRows = false;
        }
    }

    bool updateCursor()
    {
        if (!cursorPos.isValid)
        {
            return false;
        }
        cursor.xy(cursorPos.pos.x, cursorPos.pos.y);
        return true;
    }

    size_t cursorGlyphIndex()
    {
        return cursorGlyphIndex(cursorPos.rowIndex, cursorPos.glyphIndex);
    }

    size_t cursorGlyphIndex(size_t rowIndex, size_t glyphIndex)
    {
        size_t rowOffset;
        if (rowIndex > 0)
        {
            enum hyphenCorrection = 1;
            foreach (ri; 0 .. rowIndex)
            {
                rowOffset += rows[ri].glyphs.length + hyphenCorrection;
            }
        }

        size_t index = rowOffset + glyphIndex;
        return index;
    }

    //TODO optimizations
    protected Glyph[] textToGlyphs(dstring textString)
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

        TextRow row;
        size_t glyphCount;
        foreach (ref glyph; glyphs)
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
            }

            glyph.pos.x = glyphPosX;
            glyph.pos.y = glyphPosY;

            row.glyphs ~= &glyph;
            glyphCount++;
            glyphPosX += glyph.geometry.width;
        }

        debug
        {
            if (glyphCount != glyphs.length)
            {
                import std.format : format;

                throw new Exception(format("Glyph count %s, but text count is %s", glyphCount, glyphs
                        .length));
            }
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
            Glyph* firstGlyph = row.glyphs[0];

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
                    double posX = glyphMinX;
                    size_t glyphIndex = gi;
                    if (x > (minMaxRange / 2) && glyphIndex < row.glyphs.length - 1)
                    {
                        glyphIndex++;
                        posX = thisBounds.x + row.glyphs[glyphIndex].pos.x;
                    }
                    const pos = Vector2d(posX, rowMinY);
                    return CursorPos(pos, ri, glyphIndex, true);
                }
            }
        }
        return CursorPos.init;
    }

    bool moveCursorLeft()
    {
        if (!cursorPos.isValid || cursorPos.glyphIndex == 0)
        {
            return false;
        }
        auto row = rows[cursorPos.rowIndex];
        if (row.glyphs.length == 0)
        {
            return false;
        }

        double cursorOffset = 0;
        if (cursorPos.glyphIndex == row.glyphs.length)
        {
            cursorPos.glyphIndex--;
            const glyph = row.glyphs[cursorPos.glyphIndex];
            cursorOffset = glyph.geometry.width;
        }
        else
        {
            const glyph = row.glyphs[cursorPos.glyphIndex];
            cursorPos.glyphIndex--;
            cursorOffset = glyph.geometry.width;
        }

        cursor.x = cursor.x - cursorOffset;

        return true;
    }

    bool moveCursorRight()
    {
        if (!cursorPos.isValid)
        {
            return false;
        }
        const row = rows[cursorPos.rowIndex];
        if (row.glyphs.length == 0)
        {
            return false;
        }

        if (cursorPos.glyphIndex >= row.glyphs.length)
        {
            return false;
        }

        const glyph = row.glyphs[cursorPos.glyphIndex];
        cursorPos.glyphIndex++;
        cursor.x = cursor.x + glyph.geometry.width;
        return true;
    }

    bool moveCursorUp()
    {
        if (cursorPos.rowIndex == 0)
        {
            return false;
        }

        const row = rows[cursorPos.rowIndex];
        if (row.glyphs.length == 0)
        {
            return false;
        }

        //TODO strings may not match in number of characters

        const glyph = rows[cursorPos.rowIndex].glyphs[cursorPos.glyphIndex];
        cursorPos.rowIndex--;
        cursor.y = cursor.y - glyph.geometry.height;
        return true;
    }

    bool moveCursorDown()
    {
        if (rows.length <= 1 || cursorPos.rowIndex >= rows.length - 1)
        {
            return false;
        }

        //TODO strings may not match in number of characters

        const glyph = rows[cursorPos.rowIndex].glyphs[cursorPos.glyphIndex];
        cursorPos.rowIndex++;
        cursor.y = cursor.y + glyph.geometry.height;
        return true;
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
        if (!isBuilt)
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

    void addRows(dstring text)
    {
        auto glyphs = textToGlyphs(text);
        _text ~= glyphs;
        this.rows ~= glyphsToRows(glyphs);
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
            foreach (Glyph* glyph; row.glyphs)
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

    void appendText(dstring text)
    {
        addRows(text);
        setInvalid;
    }

    void text(string t)
    {
        import std.conv : to;

        this.text(t.to!dstring);
    }

    void text(dstring t)
    {
        if (!isBuilt)
        {
            tempText = t;
            isRebuildRows = true;
            return;
        }

        _text = textToGlyphs(t);
        tempText = null;
        setInvalid;
    }

    dstring text()
    {
        import std.array : appender;

        auto builder = appender!dstring;
        foreach (ref glyph; _text)
        {
            builder ~= glyph.grapheme;
        }
        return builder.data;
    }
}
