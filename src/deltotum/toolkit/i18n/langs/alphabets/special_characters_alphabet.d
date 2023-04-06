module deltotum.toolkit.i18n.langs.alphabets.special_characters_alphabet;

import deltotum.toolkit.i18n.langs.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 */
class SpecialCharactersAlphabet : Alphabet
{
    override dstring allLetters()
    {
        return "!\"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~\n\r";
    }
}
