module api.sims.ele.components.elements.base_element;

import api.sims.ele.components.base_component: BaseComponent;
import api.dm.kit.sprites2d.sprite2d: Sprite2d;
import api.math.pos2.orientation : Orientation;
import api.math.graphs.vertex : Vertex;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */

abstract class BaseElement : BaseComponent
{
    Text label;
    Vertex vertex;

    Orientation orientation;

    Sprite2d content;

    this(string id, Orientation orientation = Orientation.vertical)
    {
        this.id = id;

        label = new Text(id);
        vertex = new Vertex;
        isDraggable = true;

        this.orientation = orientation;

        if (orientation == Orientation.vertical)
        {
            import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

            layout = new VLayout;
            layout.isAlignX = true;
        }
        else
        {
            //TODO other
            import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

            layout = new HLayout;
            layout.isAlignY = true;
        }

        layout.isAutoResize = true;
    }

    override void loadTheme()
    {
        super.loadTheme;

        //TODO from theme\config
        const size = 50;
        initSizeIfZero(size);
    }

    override void create()
    {
        super.create;

        assert(label);
        label.isLayoutManaged = false;
        addCreate(label);
    }

    override GraphicStyle createDefaultStyle()
    {
        auto style = super.createDefaultStyle;
        
        style.isFill = false;
        style.lineWidth = theme.lineThickness * 2;
        
        return style;
    }

    override void applyLayout()
    {
        super.applyLayout;

        if (label)
        {
            const labelPosX = boundsRect.right;
            const labelPosY = boundsRect.center.y - label
                .halfHeight;
            label.pos(labelPosX, labelPosY);
        }
    }

    string createSVG()
    {
        import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;

        if (auto vtexture = cast(VectorTexture) content)
        {
            auto svg = vtexture.createSVG;
            return svg;
        }

        return null;
    }
}
