module api.dm.gui.controls.labeled;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.layouts.layout2d : Layout2d;
import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
import api.dm.gui.controls.texts.text : Text;

import std.traits : isSomeString;

/**
 * Authors: initkfs
 */
class Labeled : Control
{
    protected
    {
        Sprite2d _icon;
        Text _label;

        dchar _iconName;
        dstring _labelText;

        float _graphicsGap = 0;
    }

    bool isSetNullGapFromTheme = true;
    bool isEnablePadding = true;

    bool isCreateLabelIcon;

    void delegate() onPreIconCreate;
    void delegate() onPostIconCreated;

    bool isCreateLabelText;
    bool isLabelMarginIsEmpty = true;

    void delegate() onPreTextCreate;
    void delegate() onPostTextCreated;

    this(dstring labelText = null, dchar iconName = dchar.init, float graphicsGap = 0, bool isCreateLayout = true)
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
    }

    override void initialize()
    {
        super.initialize;

        if (isEnablePadding && canEnablePadding)
        {
            enablePadding;
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

        if (isCreateLabelIcon && (iconName != dchar.init) && platform.cap.isIconPack)
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
        if (_iconName && platform.cap.isIconPack)
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

        if (isLabelMarginIsEmpty && _label.margin.isEmpty)
        {
            _label.margin = theme.controlGraphicsGap;
        }
    }

    Sprite2d newLabelIcon()
    {
        auto newIcon = createIcon(_iconName);
        _iconName = dchar.init;
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

    inout(Sprite2d) icon() inout
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

    bool hasIcon() => _icon !is null;

    Sprite2d icon()
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

    dchar iconName() => _iconName;

    bool iconName(dchar name)
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

    float graphicsGap() => _graphicsGap;

    bool graphicsGap(float value)
    {
        _graphicsGap = value;
        if (layout)
        {
            import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;

            if (auto sl = cast(SpaceableLayout) layout)
            {
                sl.spacing = graphicsGap;
            }
        }
        return true;
    }

    override void addCreateIcon(dchar iconName, long index = -1)
    {
        super.addCreateIcon(iconName, index);
        if (_label && _label.text.length == 0)
        {
            _label.isLayoutManaged = false;
            _label.isVisible = false;
            setInvalid;
        }
    }

    bool setLargeSize()
    {
        if (!_label)
        {
            return false;
        }
        _label.setLargeSize;
        return true;
    }

    bool setMediumSize()
    {
        if (!_label)
        {
            return false;
        }
        _label.setMediumSize;
        return true;
    }

    bool setSmallSize()
    {
        if (!_label)
        {
            return false;
        }
        _label.setSmallSize;
        return true;
    }

    override void dispose()
    {
        super.dispose;
        _iconName = dchar.init;
        _labelText = null;
    }

}
