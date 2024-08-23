module api.dm.kit.i18n.langs.alphabets.arabic_num_alphabet;

import api.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 */
class ArabicNumAlpabet : Alphabet
{
    override immutable(dchar)[] allLetters()
    {
        return "0123456789";
    }
}
