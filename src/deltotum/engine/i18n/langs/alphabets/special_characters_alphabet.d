module deltotum.engine.i18n.langs.alphabets.special_characters_alphabet;

import deltotum.engine.i18n.langs.alphabets.alphabet : Alphabet;

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
