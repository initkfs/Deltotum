module api.dm.kit.assets.fonts.glyphs.glyph;

import api.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;
import api.dm.kit.i18n.langs.charsets.ascii.special_symbol : SpecialSymbol;

import api.math.rect2d : Rect2d;
import api.math.vec2: Vec2d;

/**
 * Authors: initkfs
 */
struct Glyph
{
    dchar grapheme;
    Rect2d geometry;
    Vec2d pos;
    Alphabet alphabet;

    bool isEmpty;
    bool isNEL;
}
