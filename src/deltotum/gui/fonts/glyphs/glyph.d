module deltotum.gui.fonts.glyphs.glyph;

import deltotum.kit.i18n.langs.alphabets.alphabet : Alphabet;
import deltotum.kit.i18n.langs.charactersets.ascii.special_symbol : SpecialSymbol;

import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d: Vector2d;

/**
 * Authors: initkfs
 */
struct Glyph
{
    dchar grapheme;
    Rect2d geometry;
    Vector2d pos;
    Alphabet alphabet;

    bool isEmpty;
    bool isNEL;
}
