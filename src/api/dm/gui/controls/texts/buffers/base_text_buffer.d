module api.dm.gui.controls.texts.buffers.base_text_buffer;

import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;

/**
 * Authors: initkfs
 */

class BaseTextBuffer(T)
{
    size_t length;

    T delegate(dchar) itemProvider;

    abstract
    {
        bool destroy();
        inout(T[]) buffer() inout;
        bool insert(size_t pos, const(dchar)[] text);
        bool insert(size_t pos, T[] text);
        size_t removePrev(size_t pos, size_t removeCount);
        dstring text();
    }

    void onItem(scope bool delegate(T*, size_t) onItemIndexDg)
    {
        foreach (i, ref item; buffer)
        {
            if (!onItemIndexDg(&item, i))
            {
                break;
            }
        }
    }

    bool create(const(dchar)[] text)
    {
        if (!itemProvider)
        {
            itemProvider = (ch) => Glyph(ch);
        }

        return true;
    }

}
