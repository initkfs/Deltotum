module dm.kit.i18n.langs.alphabets.alphabet_en;

import dm.kit.i18n.langs.alphabets.alphabet : Alphabet;

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
