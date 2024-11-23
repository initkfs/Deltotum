module api.dm.gui.controls.buttons.base_button;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.labeled : Labeled;
import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.graphics.colors.rgba : RGBA;

import std.traits : isSomeString;

enum ButtonType
{
    normal,
    cancel,
    close,
    next,
    no,
    ok,
    previous,
    yes
}

/**
 * Authors: initkfs
 */
class BaseButton : Labeled
{
    //The listener is used very often and the array can affect performance
    void delegate(ref ActionEvent) onAction;

    bool isCancel;
    void delegate()[] onCancel;

    bool isDefault;
    void delegate()[] onDefault;

    this(dstring text = "Button", string iconName, bool isCreateLayout = true)
    {
        this(text, 0, 0, 0, iconName, isCreateLayout);
    }

    this(
        dstring text = "Button",
        double width = 0,
        double height = 0,
        double graphicsGap = 0,
        string iconName = null,
        bool isCreateLayout = true
    )
    {
        super(width, height, iconName, graphicsGap, text, isCreateLayout);

        isCreateHoverEffectFactory = true;
        isCreateHoverAnimationFactory = true;
        isCreateActionEffectFactory = true;
        isCreateActionAnimationFactory = true;

        isCreateInteractiveListeners = true;
    }

    override void loadTheme()
    {
        loadLabeledTheme;
        loadBaseButtonTheme;
    }

    void loadBaseButtonTheme()
    {
        if (isSetNullWidthFromTheme && _width == 0)
        {
            _width = theme.buttonWidth;
        }

        if (isSetNullHeightFromTheme && _height == 0)
        {
            _height = theme.buttonHeight;
        }
    }

    override void create()
    {
        super.create;

        onPointerUp ~= (ref e) {

            if (isDisabled || _selected)
            {
                return;
            }

            if (onAction)
            {
                auto ea = ActionEvent(e.ownerId, e.x, e.y, e.button);
                onAction(ea);
            }
        };

        if (isCancel)
        {
            import api.dm.com.inputs.com_keyboard : ComKeyName;

            onKeyDown ~= (ref e) {
                if (isDisabled)
                {
                    return;
                }

                if (isFocus && e.keyName == ComKeyName.ESCAPE)
                {
                    if (onCancel)
                    {
                        foreach (dg; onCancel)
                        {
                            dg();
                        }
                    }
                }
            };
        }

        if (isDefault)
        {
            import api.dm.com.inputs.com_keyboard : ComKeyName;

            onKeyDown ~= (ref e) {
                if (isDisabled)
                {
                    return;
                }

                if (isFocus && e.keyName == ComKeyName.RETURN)
                {
                    foreach (dg; onDefault)
                    {
                        dg();
                    }
                }
            };
        }
    }

    override void addCreateIcon(string iconName)
    {
        super.addCreateIcon(iconName);
        if (_text && _text.text.length == 0)
        {
            _text.isLayoutManaged = false;
            _text.isVisible = false;
        }
        setInvalid;
    }

    override void dispose()
    {
        super.dispose;

        onAction = null;
        onCancel = null;
        onDefault = null;
    }

}
