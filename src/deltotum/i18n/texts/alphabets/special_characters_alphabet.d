module deltotum.i18n.texts.alphabets.special_characters_alphabet;

import deltotum.i18n.texts.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 */
class SpecialCharactersAlphabet : Alphabet
{
    override dstring allLetters()
    {
        return "!\"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~";
    }
}
