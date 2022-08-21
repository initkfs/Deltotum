module deltotum.i18n.texts.alphabets.alphabet_en;

import deltotum.i18n.texts.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 * TODO config?
 */
class AlphabetEn : Alphabet
{
    override dstring allLetters()
    {
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    }
}
