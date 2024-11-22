module api.dm.gui.containers.frame;

import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.layouts.vlayout : VLayout;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class Frame : Container
{
    Text label;
    Container container;

    double vspacing = 0;

    private
    {
        dstring initText;
    }

    this(dstring labelText = "Frame", double spacing = 5)
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

        import api.dm.gui.controls.texts.text : Text;

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
        if (hasBackground && label)
        {
            import api.dm.kit.sprites.shapes.convex_polygon : ConvexPolygon;
            import api.core.utils.types : castSafe;

            if (auto rp = background.get.castSafe!ConvexPolygon)
            {
                rp.topClip.start.x = label.x;
                rp.topClip.end.x = label.bounds.right;
            }
        }
    }

    void addCreate(Control[] controls)
    {
        foreach (Control c; controls)
        {
            addCreate(c);
        }
    }

    override void addCreate(Control control, long index = -1)
    {
        if (!container)
        {
            super.addCreate(control, index);
            return;
        }

        container.addCreate(control, index);
    }

    override void addCreate(Sprite[] sprites)
    {
        foreach (s; sprites)
        {
            addCreate(s);
        }
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
