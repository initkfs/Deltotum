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

    void change(ComPlatformCursorType type)
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
            auto newCursor = cursorFactory();
            if (const err = newCursor.createFromType(type))
            {
                throw new Exception(err.toString);
            }
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

    Vec2d getPos()
    {
        auto cursor = lastCursor;
        if (!cursor)
        {
            cursor = defaultCursor;
        }
        float x, y;
        if (const err = cursor.getPos(x, y))
        {
            //TODO log
            throw new Exception(err.toString);
        }
        return Vec2d(x, y);
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
