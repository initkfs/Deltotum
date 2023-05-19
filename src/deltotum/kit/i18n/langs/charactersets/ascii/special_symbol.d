module deltotum.kit.i18n.langs.charactersets.ascii.special_symbol;

import std.ascii : ControlChar;

/**
 * Authors: initkfs
 */
enum SpecialSymbol : char
{
    none = char.init,
    nul = ControlChar.nul,
    lf = ControlChar.lf,
    cr = ControlChar.cr,
    tab = ControlChar.tab
}
