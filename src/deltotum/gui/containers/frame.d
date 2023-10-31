module deltotum.gui.containers.frame;

import deltotum.gui.containers.container : Container;
import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.layouts.vlayout : VLayout;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class Frame : Container
{
    Text label;
    Container container;

    double vspacing = 0;

    private {
        dstring initText;
    }

    this(dstring labelText = "Frame", double spacing = 5) pure
    {
        import std.exception : enforce;
        import std.conv : text;

        initText = labelText;
        vspacing = spacing;

        isBorder = true;
    }

    override void create()
    {
        super.create;

        import deltotum.gui.controls.texts.text : Text;

        label = new Text(initText);
        label.isLayoutManaged = false;
        label.isFocusable = false;
        label.isBorder = true;
        addCreate(label);

        label.x = x + 20;
        label.y = y - label.height / 2;
        
        setFrameClipping;
        // label.invalidateListeners ~= (){
        //     setFrameClipping;
        // };

        auto mainContainer = new Container;
        mainContainer.y = label.bounds.bottom + vspacing;
        mainContainer.isLayoutManaged = false;
        mainContainer.resize(width, height - label.height / 2 - vspacing);
        addCreate(mainContainer);

        container = mainContainer;
    }

    protected void setFrameClipping()
    {
        if (background && label)
        {
            import deltotum.kit.sprites.shapes.regular_polygon : RegularPolygon;

            if (auto rp = cast(RegularPolygon) background)
            {
                rp.topClip.start.x = label.x;
                rp.topClip.end.x = label.bounds.right;
            }
        }
    }

    override void addCreate(Sprite[] sprites)
    {
        if (!container)
        {
            super.addCreate(sprites);
            return;
        }

        container.addCreate(sprites);
    }

    override void addCreate(Sprite sprite, long index = -1)
    {
        if (!container)
        {
            super.addCreate(sprite, index);
            return;
        }

        container.addCreate(sprite, index);
    }
}
