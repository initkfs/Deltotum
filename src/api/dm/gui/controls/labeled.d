module api.dm.gui.controls.labeled;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.layouts.layout : Layout;
import api.dm.kit.sprites.layouts.hlayout : HLayout;
import api.dm.gui.controls.texts.text : Text;

import std.traits : isSomeString;

/**
 * Authors: initkfs
 */
class Labeled : Control
{
    protected
    {
        Sprite _icon;
        Text _text;

        string _iconName;
        dstring _labelText;

        double _graphicsGap = 0;
    }

    bool isSetNullGapFromTheme = true;

    void delegate() onPreIconTryCreate;
    void delegate() onPreIconCreate;
    void delegate() onPostIconCreated;
    void delegate() onPostIconTryCreate;

    Sprite delegate() iconFactory;
    bool isCreateIconFactory;

    void delegate() onPreTextTryCreate;
    void delegate() onPreTextCreate;
    void delegate() onPostTextCreated;
    void delegate() onPostTextTryCreate;

    bool isCreateTextFactory;
    Text delegate() textFactory;

    this(double width = 0, double height = 0, string iconName = null, double graphicsGap = 0, dstring labelText = null, bool isCreateLayout = true)
    {
        this._iconName = iconName;
        this._labelText = labelText;

        this._graphicsGap = graphicsGap;

        if (isCreateLayout)
        {
            this.layout = new HLayout(graphicsGap);
            this.layout.isAutoResizeAndAlignOne = true;
            this.layout.isAlignY = true;
        }

        isCreateTextFactory = true;
        isCreateIconFactory = true;

        isBorder = true;

        this._width = width;
        this._height = height;
    }

    override void initialize()
    {
        super.initialize;

        if (isCanEnableInsets)
        {
            enableInsets;
        }

        if (!textFactory && isCreateTextFactory)
        {
            textFactory = createTextFactory;
        }

        if (!iconFactory && isCreateIconFactory)
        {
            iconFactory = createIconFactory;
        }
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadLabeledTheme;
    }

    void loadLabeledTheme()
    {
        if (isSetNullGapFromTheme && _graphicsGap == 0)
        {
            graphicsGap = theme.controlGraphicsGap;
        }
    }

    override void create()
    {
        super.create;

        if (onPreIconTryCreate)
        {
            onPreIconTryCreate();
        }

        if (_iconName && capGraphics.isIconPack)
        {
            createLabelIcon;
        }

        if (onPostIconTryCreate)
        {
            onPostIconTryCreate();
        }

        if (onPreTextTryCreate)
        {
            onPreTextTryCreate();
        }

        if (textFactory)
        {
            if (onPreTextCreate)
            {
                onPreTextCreate();
            }

            createLabelText;

            if (onPostTextCreated)
            {
                onPostTextCreated();
            }
        }

        if (onPostTextTryCreate)
        {
            onPostTextTryCreate();
        }
    }

    protected void createLabelIcon()
    {
        if (_iconName && capGraphics.isIconPack)
        {
            assert(iconFactory);

            if (_icon)
            {
                bool isRemoved = remove(icon, isDestroy:
                    true);
                assert(isRemoved);
            }

            _icon = iconFactory();
            assert(_icon);
            addCreate(_icon);
        }
    }

    protected void createLabelText()
    {
        if (_text)
        {
            bool isRemoved = remove(_text, isDestroy:
                true);
            assert(isRemoved);
        }

        if(_labelText.length == 0){
            return;
        }

        _text = textFactory();
        assert(_text);
        addCreate(_text);
    }

    Sprite delegate() createIconFactory()
    {
        return () {
            assert(_iconName.length > 0);
            auto newIcon = createIcon(_iconName);
            _iconName = null;
            return newIcon;
        };
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

    bool text(T)(T s) if (isSomeString!T)
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
            return true;
        }

        _text.text = newText;
        if (!_text.isLayoutManaged)
        {
            _text.isLayoutManaged = true;
        }

        setInvalid;
        return true;
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

    bool iconName(string name)
    {
        if (_icon)
        {
            //TODO recreate?
            return false;
        }

        //TODO check names
        _iconName = name;
        return true;
    }

    double graphicsGap() => _graphicsGap;

    bool graphicsGap(double value)
    {
        _graphicsGap = value;
        if (layout)
        {
            import api.dm.kit.sprites.layouts.spaceable_layout : SpaceableLayout;

            if (auto sl = cast(SpaceableLayout) layout)
            {
                sl.spacing = graphicsGap;
            }
        }
        return true;
    }

    override void dispose()
    {
        super.dispose;
        _iconName = null;
        _labelText = null;
    }

}
