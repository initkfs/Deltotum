module deltotum.gui.controls.texts.text;

import deltotum.gui.controls.control : Control;
import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;
import deltotum.kit.display.flip : Flip;
import deltotum.gui.fonts.glyphs.glyph : Glyph;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.display.textures.texture : Texture;

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

    Texture focusEffect;
    Texture delegate() focusEffectFactory;

    protected
    {
        dstring oldText;
        TextRow[] rows;
    }

    this(string text)
    {
        import std.conv : to;

        this(text.to!dstring);
    }

    this(dstring text = "text")
    {
        //TODO validate
        this._text = text;
    }

    override void initialize()
    {
        super.initialize;
        backgroundFactory = null;

        width = minWidth;
        height = minHeight;

        onFocusIn = (e) {
            if (focusEffect !is null)
            {
                focusEffect.isVisible = true;
            }
            return false;
        };

        onFocusOut = (e) {
            if (focusEffect !is null && focusEffect.isVisible)
            {
                focusEffect.isVisible = false;
            }
            return false;
        };

        focusEffectFactory = () {
            import deltotum.kit.graphics.shapes.rectangle : Rectangle;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            GraphicStyle style = GraphicStyle(1, graphics.theme.colorFocus);

            import deltotum.kit.graphics.shapes.regular_polygon: RegularPolygon;
            auto effect = new RegularPolygon(width, height, style, graphics.theme.controlCornersBevel);
            //auto effect = new Rectangle(width, height, style);
            effect.isVisible = false;
            return effect;
        };
    }

    override void create()
    {
        super.create;
        updateRows;
        drawContent;

        if (focusEffectFactory !is null)
        {
            focusEffect = focusEffectFactory();
            focusEffect.isLayoutManaged = false;
            focusEffect.isVisible = false;
            addCreated(focusEffect);
        }
    }

    protected Glyph[] textToGlyphs(dstring textString)
    {
        if (textString.length == 0)
        {
            return [];
        }

        import std.uni : isSpace;
        import std.conv : to;

        //import std.uni : byGrapheme;
        //import std.range.primitives : walkLength;

        dstring mustBeText = to!dstring(textString);

        //Grapheme walkLength?
        Glyph[] newGlyphs;
        newGlyphs.reserve(mustBeText.length);

        foreach (dchar letter; mustBeText)
        {
            if (letter.isSpace)
            {
                Rect2d emptyGeometry = Rect2d(0, 0, spaceWidth, 0);
                //TODO alphabet?
                newGlyphs ~= Glyph(letter, emptyGeometry, true, false, null);
                continue;
            }
            else if (letter == '\n' || letter == ' ')
            { //TODO isControl?
                Rect2d emptyGeometry = Rect2d();
                //TODO alphabet?
                newGlyphs ~= Glyph(letter, emptyGeometry, false, true, null);
                continue;
            }

            foreach (i, glyph; asset.defaultBitmapFont.glyphs)
            {
                if (glyph.grapheme == letter)
                {
                    newGlyphs ~= glyph;
                    break;
                }
            }
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

        double incWidth = padding.width;

        double glyphPosX = padding.left;
        TextRow row;
        foreach (Glyph glyph; glyphs)
        {
            //TODO move to render, bool check flags
            incWidth += glyph.geometry.width;
            if (incWidth > width && incWidth < maxWidth)
            {
                width = incWidth;
            }

            if (glyph.isCarriageReturn || glyphPosX + glyph.geometry.width > width - padding.right)
            {
                newRows ~= row;
                row = TextRow();
                glyphPosX = padding.left;
            }

            row.glyphs ~= glyph;
            glyphPosX += glyph.geometry.width;
        }

        if (row.glyphs.length > 0)
        {
            newRows ~= row;
        }

        auto newHeight = newRows.length * rowHeight + padding.height;
        if (newHeight > height && newHeight <= maxHeight)
        {
            height = newHeight;
        }

        return newRows;
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
                if (const err = graphics.renderer.drawTexture(asset.defaultBitmapFont.nativeTexture, textureBounds, destBounds, angle, Flip
                        .none))
                {
                    //TODO logging
                }

                position.x += glyph.geometry.width;
            }

            position.y += rowHeight;
            position.x = x + padding.left;
        }
    }

    override void drawContent()
    {
        if (_text.length == 0)
        {
            return;
        }

        if (oldText != _text)
        {
            updateRows;
            oldText = _text;
        }

        renderText(rows);
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

    ref dstring text(){
        return _text;
    }
}
