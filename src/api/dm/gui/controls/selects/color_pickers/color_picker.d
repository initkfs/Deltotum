module api.dm.gui.controls.selects.color_pickers.color_picker;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.selects.base_dropdown_selector: BaseDropDownSelector;
import api.dm.gui.controls.selects.color_pickers.dialogs.color_picker_dialog : ColorPickerDialog;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class ColorPicker : BaseDropDownSelector!RGBA
{
    Container colorValueContainer;

    double colorCanvasSize = 0;
    Sprite2d colorCanvas;

    Text colorHexField;

    ColorPickerDialog dialog;
    bool isCreateDialog = true;
    ColorPickerDialog delegate(ColorPickerDialog) onNewDialog;
    void delegate(ColorPickerDialog) onCreatedDialog;

    this()
    {
        isBorder = true;

        isDropDownDialog = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadColorPickerTheme;
    }

    void loadColorPickerTheme()
    {
        if (colorCanvasSize == 0)
        {
            colorCanvasSize = theme.iconSize;
        }
    }

    override void create()
    {
        super.create;

        colorValueContainer = newColorValueContainer;
        addCreate(colorValueContainer);

        colorValueContainer.enableInsets;

        colorCanvas = newColorCanvas;

        colorCanvas.width = colorCanvasSize * 2;
        colorCanvas.height = colorCanvasSize;

        colorValueContainer.addCreate(colorCanvas);

        colorHexField = newColorHexField;

        colorHexField.isReduceWidthHeight = false;

        colorValueContainer.addCreate(colorHexField);

        auto colorHexWidth = colorHexField.calcTextWidth("#") * 7;
        if (colorHexWidth > colorHexField.width)
        {
            colorHexField.width = colorHexWidth;
        }

        if (!dialog && isCreateDialog)
        {
            auto d = newDialog;
            dialog = !onNewDialog ? d : onNewDialog(d);

            dialog.onChangeOldNew = (oldColor, newColor) {
                updateColor(newColor);
            };

            if (!isDropDownDialog)
            {
                addCreate(dialog);
            }
            else
            {
                createPopup;
                assert(popup);
                popup.addCreate(dialog);
            }

            if (onCreatedDialog)
            {
                onCreatedDialog(dialog);
            }
        }

        color(RGBA.red, isTriggerListeners:
            false);
    }

    override void drawContent()
    {
        super.drawContent;
        if (colorCanvas && colorCanvas.isVisible)
        {
            graphics.changeColor(current);
            scope (exit)
            {
                graphics.restoreColor;
            }
            graphics.fillRect(colorCanvas.boundsRect);
        }
    }

    protected bool updateColor(RGBA newColor, bool isTriggerListeners = true, bool isReplaceForce = false)
    {
        if (!current(newColor, isTriggerListeners, isReplaceForce))
        {
            return false;
        }

        if (colorHexField)
        {
            import std.conv : to;

            colorHexField.text = newColor.toWebHex.to!dstring;
        }

        return true;
    }

    bool color(RGBA newColor, bool isTriggerListeners = true, bool isReplaceForce = false)
    {
        if (!updateColor(newColor, isTriggerListeners, isReplaceForce))
        {
            return false;
        }

        if (dialog)
        {
            dialog.color(newColor);
        }

        return true;
    }

    ColorPickerDialog newDialog() => new ColorPickerDialog;

    Container newColorValueContainer()
    {
        import api.dm.gui.controls.containers.hbox : HBox;

        return new HBox;
    }

    Sprite2d newColorCanvas()
    {
        return new Sprite2d;
    }

    Text newColorHexField()
    {
        return new Text;
    }

}
