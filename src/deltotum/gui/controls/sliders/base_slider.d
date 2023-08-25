module deltotum.gui.controls.sliders.base_slider;

import deltotum.kit.sprites.sprite: Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.textures.texture : Texture;

import deltotum.kit.graphics.shapes.shape : Shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.kit.sprites.alignment : Alignment;

/**
 * Authors: initkfs
 * TODO remove duplication with slider after testing 
 */
abstract class BaseSlider : Control
{
    double minValue;
    double maxValue;

    double value = 0;
    double valueDelta = 0;

    void delegate(double) onValue;

    Sprite delegate() thumbFactory;

    protected
    {
        Sprite thumb;
    }

    this(double minValue = 0, double maxValue = 1.0)
    {
        this.minValue = minValue;
        this.maxValue = maxValue;

        this.layout = new ManagedLayout;

        isBorder = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;
    }
}
