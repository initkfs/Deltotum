module dm.kit.i18n.langs.alphabets.special_alphabet;

import dm.kit.i18n.langs.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 */
class SpecialAlphabet : Alphabet
{
    override immutable(dchar)[] allLetters() pure
    {
        dchar[] letters = "𑑛!×\"—«»#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ \n\r\t\b"d.dup;
        //Box-drawing characters
        foreach (dchar ch; '\u2500' .. '\u257F')
        {
            letters ~= ch;
        }
        
        //Geometric Shapes block
        foreach (dchar ch; '\u25A0' .. '\u25FF')
        {
            letters ~= ch;
        }

        return letters;
    }
}
