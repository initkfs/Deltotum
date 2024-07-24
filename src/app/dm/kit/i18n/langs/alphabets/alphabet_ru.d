module app.dm.kit.i18n.langs.alphabets.alphabet_ru;

import app.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;

/**
 * Authors: initkfs
 * TODO config?
 */
class AlphabetRu : Alphabet
{
    override immutable(dchar)[] allLetters()
    {
        return "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя";
    }
}
