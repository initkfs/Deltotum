module api.dm.kit.i18n.langs.alphabets.special_alphabet;

import api.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 */
class SpecialAlphabet : Alphabet
{
    //TODO cache
    override immutable(dchar)[] allLetters() pure
    {
        dchar[] letters = "∙𑑛!×\"—«»#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ \n\r\t\b"d.dup;
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

        //Geometric Shapes Extended
        // foreach (dchar ch; '\U0001F780' .. '\U0001F7FF')
        // {
        //     letters ~= ch;
        // }

        //Miscellaneous Symbols and Pictographs
        // foreach (dchar ch; '\U0001F300' .. '\U0001F5FF')
        // {
        //     letters ~= ch;
        // }

        return letters;
    }
}
