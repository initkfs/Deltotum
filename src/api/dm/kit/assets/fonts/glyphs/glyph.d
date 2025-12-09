module api.dm.kit.assets.fonts.glyphs.glyph;

import api.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;
import api.dm.kit.i18n.langs.charsets.ascii.special_symbol : SpecialSymbol;

import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2: Vec2f;

/**
 * Authors: initkfs
 */
struct Glyph
{
    dchar grapheme;
    Rect2f geometry;
    Vec2f pos;
    Alphabet alphabet;

    bool isEmpty;
    bool isNEL;
}
