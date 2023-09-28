module deltotum.kit.inputs.cursors.system_cursor;

import deltotum.com.inputs.cursors.com_system_cursor_type : ComSystemCursorType;

//TODO move cursor and mouse
import deltotum.sys.sdl.sdl_cursor : SDLCursor;
import deltotum.kit.sprites.sprite : Sprite;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SystemCursor
{
    SDLCursor delegate(ComSystemCursorType) cursorFactory;

    protected
    {
        SDLCursor[ComSystemCursorType] cursors;
    }
    private
    {
        SDLCursor defaultCursor;

        SDLCursor lastCursor;
        bool _locked;
        Sprite _cursorOwner;
    }

    this()
    {
        if (const err = SDLCursor.defaultCursor(this.defaultCursor))
        {
            throw new Exception(err.toString);
        }
        assert(this.defaultCursor);
    }

    this(SDLCursor defaultCursor)
    {
        this.defaultCursor = defaultCursor;
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

    void destroy()
    {
        foreach (type, cursor; cursors)
        {
            cursors.destroy;
        }
        _cursorOwner = null;

        if (defaultCursor)
        {
            defaultCursor.destroy;
        }

        if (lastCursor)
        {
            lastCursor.destroy;
        }

        cursors.clear;
    }

}
