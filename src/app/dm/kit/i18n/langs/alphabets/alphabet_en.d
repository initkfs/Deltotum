module app.dm.kit.i18n.langs.alphabets.en;

import app.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 * TODO config?
 */
class AlphabetEn : Alphabet
{
    override immutable(dchar)[] allLetters()
    {
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    }
}
