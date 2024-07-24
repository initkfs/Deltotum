module app.dm.kit.i18n.langs.alphabets.light_special_alphabet;

import app.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 */
class LightSpecialAlphabet : Alphabet
{
    override immutable(dchar)[] allLetters() pure
    {
        dchar[] letters = "+,-.:;"d.dup;
        return letters;
    }
}
