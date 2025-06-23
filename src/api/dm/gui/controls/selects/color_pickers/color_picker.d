module api.dm.gui.controls.selects.color_pickers.color_picker;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.selects.base_dropdown_selector : BaseDropDownSelector;
import api.dm.gui.controls.selects.color_pickers.dialogs.color_picker_dialog : ColorPickerDialog;
import api.dm.gui.controls.texts.text : Text;

import Math = api.math;

/**
 * Authors: initkfs
 */
class ColorPicker : BaseDropDownSelector!(ColorPickerDialog, RGBA)
{
    Container colorValueContainer;
    Sprite2d colorCanvasSample;

    double colorCanvasSize = 0;
    Sprite2d colorCanvas;

    Text colorHexField;

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
        colorValueContainer.isDrawAfterParent = false;
        addCreate(colorValueContainer);

        colorValueContainer.enablePadding;

        colorCanvas = newColorCanvas;

        colorCanvas.width = colorCanvasSize * 2;
        colorCanvas.height = colorCanvasSize;
        colorCanvas.isResizedByParent = false;
        colorCanvas.isRoundEvenXY = true;
        colorCanvas.isRoundEvenChildXY = true;

        colorValueContainer.addCreate(colorCanvas);

        colorCanvasSample = newColorValueSample(colorCanvas.width, colorCanvas.height);
        colorCanvas.addCreate(colorCanvasSample);
        colorCanvasSample.isRoundEvenXY = true;

        colorHexField = newColorHexField;

        colorHexField.isReduceWidthHeight = false;

        colorValueContainer.addCreate(colorHexField);

        auto colorHexWidth = colorHexField.calcTextWidth("#") * 7;
        if (colorHexWidth > colorHexField.width)
        {
            colorHexField.width = colorHexWidth;
        }

        createDialog((dialog) {
            dialog.onChangeOldNew = (oldColor, newColor) {
                updateColor(newColor);
            };
        });

        color(RGBA.red, isTriggerListeners:
            false);
    }

    override void drawContent()
    {
        super.drawContent;
        if (colorCanvas && colorCanvas.isVisible)
        {
            graphic.changeColor(current);
            scope (exit)
            {
                graphic.restoreColor;
            }
            graphic.fillRect(colorCanvas.boundsRect);
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

    override ColorPickerDialog newDialog() => new ColorPickerDialog;

    Container newColorValueContainer()
    {
        import api.dm.gui.controls.containers.hbox : HBox;

        return new HBox;
    }

    Sprite2d newColorValueSample(double newWidth, double newHeight)
    {
        import Math = api.math;

        size_t probeCount = 6;
        double probeWSize = Math.round(newWidth / probeCount);
        double probeHSize = Math.round(newHeight / probeCount);

        import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

        auto texture = new Texture2d(newWidth, newHeight);
        buildInitCreate(texture);
        texture.isResizedByParent = false;
        texture.createTargetRGBA32;

        texture.setRendererTarget;
        scope (exit)
        {
            texture.restoreRendererTarget;
        }

        graphic.clearTransparent;

        RGBA color1 = RGBA(200, 200, 200);
        RGBA color2 = RGBA.white;

        double nextX = 0;
        double nextY = 0;
        foreach (ri; 0 .. probeCount)
        {
            foreach (ci; 0 .. probeCount)
            {
                auto color = (ci + ri) % 2 == 0 ? color1 : color2;
                graphic.fillRect(nextX, nextY, probeWSize, probeHSize, color);
                nextX += probeWSize;
            }
            nextY += probeHSize;
            nextX = 0;
        }
        return texture;
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
