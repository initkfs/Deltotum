module api.dm.kit.inputs.cursors.cursor;

import api.dm.com.inputs.com_cursor : ComCursor, ComPlatformCursorType;

import api.math.geom2.vec2 : Vec2d;

//TODO move cursor and mouse
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
abstract class Cursor
{
    ComCursor delegate() cursorFactory;

    protected
    {
        ComCursor[ComPlatformCursorType] cursors;
        ComCursor defaultCursor;
        ComCursor lastCursor;
        bool _locked;
        Sprite2d _cursorOwner;
    }

    bool isDisposeOnChangeNotCached = true;

    bool change(ComPlatformCursorType type)
    {
        if (!defaultCursor || _locked)
        {
            return false;
        }

        if (lastCursor)
        {
            if ((type !in cursors) && isDisposeOnChangeNotCached)
            {
                lastCursor.dispose;
            }
            lastCursor = null;
        }

        if (auto typePtr = type in cursors)
        {
            lastCursor = *typePtr;
            return lastCursor.set;
        }

        if (cursorFactory)
        {
            auto newCursor = cursorFactory();
            if (const err = newCursor.createFromType(type))
            {
                throw new Exception(err.toString);
            }
            cursors[type] = newCursor;
            return newCursor.set;
        }

        return false;
    }

    bool restore()
    {
        if (!defaultCursor)
        {
            return false;
        }

        return defaultCursor.set;
    }

    bool unlock(Sprite2d owner)
    {
        if (_locked && (owner !is null && _cursorOwner is owner))
        {
            _locked = false;
            _cursorOwner = null;
            return true;
        }
        return false;
    }

    bool lock(Sprite2d owner)
    {
        if (!defaultCursor)
        {
            return false;
        }

        if (!_locked && _cursorOwner is null && owner !is null)
        {
            _locked = true;
            _cursorOwner = owner;
            return _locked;
        }
        return false;
    }

    bool isLocked()
    {
        return _locked;
    }

    bool getPos(out Vec2d pos)
    {
        auto cursor = lastCursor;
        if (!cursor)
        {
            cursor = defaultCursor;
            assert(cursor);
        }
        float x, y;
        if (!cursor.getPos(x, y))
        {
            return false;
        }
        pos = Vec2d(x, y);
        return true;
    }

    bool show()
    {
        assert(defaultCursor);
        return defaultCursor.show;
    }

    bool hide()
    {
        assert(defaultCursor);
        return defaultCursor.hide;
    }

    string getLastErrorStr() => defaultCursor.getLastErrorStr;

    void dispose()
    {
        if (defaultCursor)
        {
            defaultCursor.dispose;
        }

        if (lastCursor)
        {
            lastCursor.dispose;
        }

        foreach (type, cursor; cursors)
        {
            if (!cursor.isDisposed)
            {
                cursor.dispose;
            }
        }
        _cursorOwner = null;

        cursors.clear;
    }

}
