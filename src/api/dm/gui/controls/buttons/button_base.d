module api.dm.gui.controls.buttons.button_base;

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
class ButtonBase : Labeled
{

    void delegate(ref ActionEvent) onAction;

    bool isCancel;
    void delegate() onCancel;

    bool isDefault;
    void delegate() onDefault;

    string idBackground = "btn_background";

    enum double defaultWidth = 80;
    enum double defaultHeight = 30;
    enum double defaultGraphicsGap = 5;

    //TODO mixins for children
    this(dstring text = "Button", string iconName)
    {
        this(text, defaultWidth, defaultHeight, defaultGraphicsGap, iconName);
    }

    this(
        dstring text = "Button",
        double width = defaultWidth,
        double height = defaultHeight,
        double graphicsGap = defaultGraphicsGap,
        string iconName = null
    )
    {
        super(iconName, graphicsGap);
        this.width = width;
        this.height = height;
        //TODO private
        this._labelText = text;
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
    }

    override Sprite delegate(double, double) createBackgroundFactory()
    {
        return (width, height) {
            assert(graphics.theme);

            auto style = createStyle;
            auto newBackground = graphics.theme.background(width, height, &style);
            newBackground.isLayoutManaged = false;
            newBackground.id = idBackground;
            return newBackground;
        };
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
                        onCancel();
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
                    if (onDefault)
                    {
                        onDefault();
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
        }
        setInvalid;
    }

    override void dispose()
    {
        super.dispose;
    }

}
