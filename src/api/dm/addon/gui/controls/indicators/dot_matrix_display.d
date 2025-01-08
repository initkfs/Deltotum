module api.dm.addon.gui.controls.indicators.dot_matrix_display;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.hbox : HBox;

/**
 * Authors: initkfs
 */
class Led : Control
{
    double cornerBevel = 0;

    this(double width, double height)
    {
        this.width = width;
        this.height = height;

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
    }

    override void create()
    {
        super.create;
        auto style = createStyle;
        if (!style.isNested)
        {
            style.isFill = true;
            style.fillColor = theme.colorAccent;
        }
        Sprite2d led;
        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            led = new VConvexPolygon(width, height, style, cornerBevel);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.convex_polygon : ConvexPolygon;

            led = new ConvexPolygon(width, height, style, cornerBevel);
        }
        addCreate(led);
    }
}

/**
 * Authors: initkfs
 */
class DotMatrixDisplay(size_t Row = 7, size_t Col = 5) : VBox
{
    Led[Col][Row] ledMatrix;
    double colSpacing = 1;

    this(double width = 80, double height = 80, double rowSpacing = 1)
    {
        super(rowSpacing);
        this.width = width;
        this.height = height;
        isBorder = true;
        layout.isAlign = true;
        import api.math.insets : Insets;

        padding = Insets(5);
    }

    override void create()
    {
        super.create;

        import Math = api.dm.math;

        const fullWidth = width - (colSpacing * Col - 1) - padding.width;
        const fullHeight = height - (spacing * Row - 1) - padding.height;
        const ledWidth = Math.trunc(fullWidth / Col);
        const ledHeight = Math.trunc(fullHeight / Row);

        foreach (ref row; ledMatrix)
        {
            auto colContainer = new HBox(colSpacing);
            addCreate(colContainer);
            foreach (ref col; row)
            {
                col = new Led(ledWidth, ledHeight);
                colContainer.addCreate(col);
            }
        }

        reset;
    }

    void onLed(scope void delegate(size_t row, size_t col, Led led) onLed)
    {
        foreach (r, ref row; ledMatrix)
        {
            foreach (c, ref led; row)
            {
                onLed(r, c, led);
            }
        }
    }

    void reset()
    {
        onLed((ri, ci, led) { led.isVisible = false; });
    }

    void showAll()
    {
        onLed((ri, ci, led) { led.isVisible = true; });
    }

    void draw(ref int[Col][Row] matrix)
    {
        foreach (ri, ref row; matrix)
        {
            foreach (ci, ref isDrawValue; row)
            {
                (ledMatrix[ri][ci]).isVisible = isDrawValue == 1;
            }
        }
    }

}
