module deltotum.kit.i18n.langs.alphabets.arabic_numerals_alphabet;

import deltotum.kit.i18n.langs.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 */
class ArabicNumeralsAlpabet : Alphabet
{
    override immutable(dchar)[] allLetters()
    {
        return "0123456789";
    }
}
