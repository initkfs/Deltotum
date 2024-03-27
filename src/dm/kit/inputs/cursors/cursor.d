module dm.kit.inputs.cursors.cursor;

import dm.com.inputs.cursors.com_cursor : ComCursor, ComSystemCursorType;

import dm.math.vector2 : Vector2;

//TODO move cursor and mouse
import dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
abstract class Cursor
{
    ComCursor delegate(ComSystemCursorType) cursorFactory;

    protected
    {
        ComCursor[ComSystemCursorType] cursors;
        ComCursor defaultCursor;
        ComCursor lastCursor;
        bool _locked;
        Sprite _cursorOwner;
    }

    void change(ComSystemCursorType type)
    {
        if (!defaultCursor || _locked)
        {
            return;
        }

        if (lastCursor)
        {
            //TODO dispose?
            lastCursor = null;
        }

        if (auto typePtr = type in cursors)
        {
            lastCursor = *typePtr;
            if (const err = lastCursor.set)
            {
                throw new Exception(err.toString);
            }
            return;
        }

        if (cursorFactory)
        {
            auto newCursor = cursorFactory(type);
            cursors[type] = newCursor;
        }
    }

    bool restore()
    {
        if (!defaultCursor)
        {
            return false;
        }

        if (const err = defaultCursor.set)
        {
            throw new Exception(err.toString);
        }

        return true;
    }

    bool unlock(Sprite owner)
    {
        if (_locked && (owner !is null && _cursorOwner is owner))
        {
            _locked = false;
            _cursorOwner = null;
            return true;
        }
        return false;
    }

    bool lock(Sprite owner)
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

    Vector2 getPos()
    {
        auto cursor = lastCursor;
        if (!cursor)
        {
            cursor = defaultCursor;
        }
        int x, y;
        if (const err = cursor.getPos(x, y))
        {
            //TODO log
            throw new Exception(err.toString);
        }
        return Vector2(x, y);
    }

    void show()
    {
        assert(defaultCursor);
        if (const err = defaultCursor.show)
        {
            throw new Exception(err.toString);
        }
    }

    void hide()
    {
        assert(defaultCursor);
        if (const err = defaultCursor.hide)
        {
            throw new Exception(err.toString);
        }
    }

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
