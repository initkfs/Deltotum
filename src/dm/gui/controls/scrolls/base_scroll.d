module dm.gui.controls.scrolls.base_scroll;

import dm.kit.sprites.sprite: Sprite;
import dm.gui.controls.control : Control;
import dm.kit.sprites.textures.texture : Texture;

import dm.kit.sprites.shapes.shape : Shape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.sprites.layouts.managed_layout : ManagedLayout;
import dm.kit.sprites.shapes.rectangle : Rectangle;
import dm.math.alignment : Alignment;

/**
 * Authors: initkfs
 * TODO remove duplication with slider after testing 
 */
abstract class BaseScroll : Control
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
