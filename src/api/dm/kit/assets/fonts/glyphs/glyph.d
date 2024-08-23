module api.dm.kit.assets.fonts.glyphs.glyph;

import api.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;
import api.dm.kit.i18n.langs.charsets.ascii.special_symbol : SpecialSymbol;

import api.dm.math.rect2d : Rect2d;
import api.dm.math.vector2: Vector2;

/**
 * Authors: initkfs
 */
struct Glyph
{
    dchar grapheme;
    Rect2d geometry;
    Vector2 pos;
    Alphabet alphabet;

    bool isEmpty;
    bool isNEL;
}
