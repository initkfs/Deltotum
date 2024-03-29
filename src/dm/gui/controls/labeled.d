module dm.gui.controls.labeled;

import dm.gui.controls.control : Control;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.layouts.layout : Layout;
import dm.kit.sprites.layouts.hlayout : HLayout;
import dm.gui.controls.texts.text : Text;

import std.traits : isSomeString;

/**
 * Authors: initkfs
 */
class Labeled : Control
{
    //protected
    //{
        string _iconName;
        dstring _labelText;
        Sprite _icon;
        Text _text;
   // }

    void delegate() onPreIconCreate;
    void delegate() onPreIconCreated;
    void delegate() onPostIconCreated;
    void delegate() onPostIconCreate;

    void delegate() onPreTextCreate;
    void delegate() onPreTextCreated;
    void delegate() onPostTextCreated;
    void delegate() onPostTextCreate;

    bool isCreateTextFactory;
    Text delegate() textFactory;

    this(string iconName = null, double graphicsGap, bool isCreateLayout = true)
    {
        this._iconName = iconName;

        if (isCreateLayout)
        {
            this.layout = new HLayout(graphicsGap);
            this.layout.isAutoResizeAndAlignOne = true;
            this.layout.isAlignY = true;
        }

        isCreateHoverFactory = true;
        isCreatePointerEffectFactory = true;
        isCreatePointerEffectAnimationFactory = true;
        isCreateTextFactory = true;

        isBorder = true;
    }

    override void initialize()
    {
        super.initialize;

        if (isCreateTextFactory)
        {
            textFactory = createTextFactory;
        }
    }

    override void create()
    {
        super.create;
        if (onPreIconCreate)
        {
            onPreIconCreate();
        }
        if (_iconName && capGraphics.isIconPack)
        {
            if (onPreIconCreated)
            {
                onPreIconCreated();
            }
            _icon = createIcon(_iconName);
            add(icon);
            _iconName = null;
            if (onPostIconCreated)
            {
                onPostIconCreated();
            }
        }

        if (onPostIconCreate)
        {
            onPostIconCreate();
        }

        if (onPreTextCreate)
        {
            onPreTextCreate();
        }

        if (textFactory)
        {
            if (onPreTextCreated)
            {
                onPreTextCreated();
            }
            _text = textFactory();
            if (_text)
            {
                addCreate(_text);
            }
            else
            {
                logger.error("Text factory did not return the object");
            }

            if (onPostTextCreated)
            {
                onPostTextCreated();
            }
        }

        if (onPostTextCreate)
        {
            onPostTextCreate();
        }
    }

    Text delegate() createTextFactory()
    {
        return () {
            auto text = new Text();
            build(text);
            //String can be forced to be empty
            //if (_labelText.length > 0)
            //{
            text.text = _labelText;
            //}

            return text;
        };
    }

    inout(Sprite) icon() inout
    out (_icon; _icon !is null)
    {
        return _icon;
    }

    void text(T)(T s) if (isSomeString!T)
    {
        dstring newText;

        static if (!is(T : immutable(dchar[])))
        {
            import std.conv : to;

            newText = s.to!dstring;
        }
        else
        {
            newText = s;
        }

        if (!_text)
        {
            _labelText = newText;
            setInvalid;
            return;
        }

        _text.text = newText;
        if (!_text.isLayoutManaged)
        {
            _text.isLayoutManaged = true;
        }

        setInvalid;
    }

    dstring text()
    {
        if (_text)
        {
            return _text.text;
        }
        return _labelText;
    }

    string iconName()
    {
        return _iconName;
    }

    void iconName(string name)
    {
        //TODO check names
        _iconName = name;
    }

    override void dispose()
    {
        super.dispose;
        if (_icon && !_icon.isDisposed)
        {
            _icon.dispose;
        }
        _icon = null;
        _iconName = null;
        _labelText = null;
    }

}
