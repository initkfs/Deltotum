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

import std.stdio;

protected
{
    struct TextRow
    {
        Glyph[] glyphs;
    }
}

/**
 * Authors: initkfs
 * TODO optimizations oldText == text
 */
class Text : Control
{
    dstring _text;
    int spaceWidth = 5;
    int rowHeight = 0;

    RGBA color = RGBA.white;

    Sprite focusEffect;
    Sprite delegate() focusEffectFactory;

    protected
    {
        dstring oldText;
        TextRow[] rows;
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

        invalidateListeners ~= () {
            updateRows;
        };

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

        updateRows;

        if (focusEffectFactory !is null)
        {
            focusEffect = focusEffectFactory();
            focusEffect.isLayoutManaged = false;
            focusEffect.isVisible = false;
            addCreate(focusEffect);
        }
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

        double glyphPosX = startRowTextX;
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
                isStartNewLine = true;
            }
            else if (nextGlyphPosX >= endRowTextX)
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

                if (slicePos != -1)
                {
                    foreach (i; slicePos + 1 .. row.glyphs.length)
                    {
                        auto oldGlyph = row.glyphs[i];
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
                if (glyph.isEmpty)
                {
                    continue;
                }
            }

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

        Vector2d position = Vector2d(x, y);
        position.x += padding.left;
        position.y += padding.top;

        foreach (TextRow row; rows)
        {
            foreach (Glyph glyph; row.glyphs)
            {
                if (glyph.isEmpty)
                {
                    position.x += glyph.geometry.width;
                    continue;
                }

                Rect2d textureBounds = glyph.geometry;
                Rect2d destBounds = Rect2d(position.x, position.y, glyph.geometry.width, glyph
                        .geometry.height);
                asset.defaultBitmapFont.drawTexture(textureBounds, destBounds, angle, Flip
                        .none);

                position.x += glyph.geometry.width;
            }

            position.y += rowHeight;
            position.x = x + padding.left;
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
