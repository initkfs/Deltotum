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
        Text _label;

        string _iconName;
        dstring _labelText;

        double _graphicsGap = 0;
    }

    bool isSetNullGapFromTheme = true;

    bool isCreateLabelIcon;

    void delegate() onPreIconCreate;
    void delegate() onPostIconCreated;

    bool isCreateLabelText;

    void delegate() onPreTextCreate;
    void delegate() onPostTextCreated;

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

        isCreateLabelText = true;
        isCreateLabelIcon = true;

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

        if (isCreateLabelIcon && _iconName && capGraphics.isIconPack)
        {
            if (onPreIconCreate)
            {
                onPreIconCreate();
            }

            createLabelIcon;

            if (onPostIconCreated)
            {
                onPostIconCreated();
            }
        }

        if (isCreateLabelText)
        {
            if (onPreTextCreate)
            {
                onPreTextCreate();
            }

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
    }

    protected void createLabelIcon()
    {
        if (_iconName && capGraphics.isIconPack)
        {
            if (_icon)
            {
                bool isRemoved = remove(icon, isDestroy:
                    true);
                assert(isRemoved);
            }

            _icon = newLabelIcon;
            assert(_icon);
            addCreate(_icon);
        }
    }

    protected void createLabelText()
    {
        if (_label)
        {
            bool isRemoved = remove(_label, isDestroy:
                true);
            assert(isRemoved);
        }

        if (_labelText.length == 0)
        {
            return;
        }

        _label = newLabelText();
        assert(_label);
        addCreate(_label);
    }

    Sprite newLabelIcon()
    {
        assert(_iconName.length > 0);
        auto newIcon = createIcon(_iconName);
        _iconName = null;
        return newIcon;
    }

    Text newLabelText()
    {
        auto text = new Text();
        buildInit(text);

        auto style = createStyle;
        if (style.isDefault)
        {
            text.color = style.lineColor;
            text.setInvalid;
        }
        //String can be forced to be empty
        //if (_labelText.length > 0)
        //{
        text.text = _labelText;
        //}

        return text;
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

        if (!_label)
        {
            _labelText = newText;
            setInvalid;
            return true;
        }

        _label.text = newText;
        if (!_label.isLayoutManaged)
        {
            _label.isLayoutManaged = true;
        }

        setInvalid;
        return true;
    }

    Text label()
    {
        assert(_label);
        return _label;
    }

    Sprite icon()
    {
        assert(_icon);
        return _icon;
    }

    dstring text()
    {
        if (_label)
        {
            return _label.text;
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
