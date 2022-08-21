module deltotum.i18n.texts.alphabets.alphabet_ru;

import deltotum.i18n.texts.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 * TODO config?
 */
class AlphabetRu : Alphabet
{
    override dstring allLetters()
    {
        return "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя";
    }
}
