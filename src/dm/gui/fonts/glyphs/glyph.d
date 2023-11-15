module dm.gui.fonts.glyphs.glyph;

import dm.kit.i18n.langs.alphabets.alphabet : Alphabet;
import dm.kit.i18n.langs.charactersets.ascii.special_symbol : SpecialSymbol;

import dm.math.shapes.rect2d : Rect2d;
import dm.math.vector2d: Vector2d;

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
