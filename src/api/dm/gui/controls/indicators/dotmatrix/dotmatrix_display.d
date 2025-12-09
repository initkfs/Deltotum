module api.dm.gui.controls.indicators.dotmatrix.dotmatrix_display;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class DotMatrixDisplay(size_t Row = 7, size_t Col = 5) : VBox
{
    Texture2d[Col][Row] matrix;

    Texture2d delegate(Texture2d) onNewLed;
    void delegate(Texture2d) onConfiguredLed;
    void delegate(Texture2d) onCreatedLed;

    float colSpacing = 0;
    float rowSpacing = 0;

    float ledWidth = 0;
    float ledHeight = 0;

    this(float ledWidth = 0, float ledHeight = 0)
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAutoResize = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadDotMatrixDisplayTheme;
    }

    void loadDotMatrixDisplayTheme()
    {
        auto ledSize = theme.iconSize / 2;
        if (ledWidth == 0)
        {
            ledWidth = ledSize;
        }

        if (ledHeight == 0)
        {
            ledHeight = ledSize;
        }

        ledWidth = Math.roundEven(ledWidth);
        ledHeight = Math.roundEven(ledHeight);
    }

    override void create()
    {
        super.create;

        import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;

        if (auto sl = cast(SpaceableLayout) layout)
        {
            sl.spacing = rowSpacing;
        }

        createLedMatrix;

        //hideAll;
    }

    void createLedMatrix()
    {
        // auto fullWidth = ledWidth * Col;
        // auto fullHeight = ledHeight * Row;
        // if (fullWidth > width)
        // {
        //     width = fullWidth;
        // }
        // if (fullHeight > height)
        // {
        //     height = fullHeight;
        // }

        foreach (ref row; matrix)
        {
            auto rowContainer = new HBox(colSpacing);
            addCreate(rowContainer);
            foreach (ref col; row)
            {
                col = newLed(ledWidth, ledHeight);

                if (onConfiguredLed)
                {
                    onConfiguredLed(col);
                }

                rowContainer.addCreate(col);

                if (onCreatedLed)
                {
                    onCreatedLed(col);
                }
            }
        }
    }

    Texture2d newLed(float w, float h)
    {
        auto ledStyle = createFillStyle;
        ledStyle.fillColor = RGBA.white;

        auto led = theme.rectShape(w, h, angle, ledStyle);
        if (auto texture = cast(Texture2d) led)
        {
            if (!texture.isCreated)
            {
                buildInitCreate(texture);
            }
            texture.blendModeBlend;
            return texture;
        }
        auto newTexture = new Texture2d(led.width, led.height);
        buildInitCreate(newTexture);
        newTexture.createTargetRGBA32;
        newTexture.blendModeBlend;
        newTexture.setRendererTarget;
        scope (exit)
        {
            newTexture.restoreRendererTarget;
        }
        graphic.clearTransparent;

        led.draw;

        return newTexture;
    }

    void onLed(scope void delegate(size_t row, size_t col, Texture2d led) onLed)
    {
        foreach (r, ref row; matrix)
        {
            foreach (c, ref led; row)
            {
                assert(led);
                onLed(r, c, led);
            }
        }
    }

    void hideAll()
    {
        onLed((ri, ci, led) { led.isVisible = false; });
    }

    void showAll()
    {
        onLed((ri, ci, led) { led.isVisible = true; });
    }

    void fillScreen(RGBA color)
    {
        onLed((ri, ci, led) { led.color = color; });
    }

    void clearColor(RGBA defaultColor = RGBA.black)
    {
        onLed((ri, ci, led) { led.color = defaultColor; });
    }

    void drawPixel(size_t x, size_t y)
    {
        drawPixel(x, y, defaultColor);
    }

    void drawPixel(size_t x, size_t y, RGBA color)
    {
        assert(x < Col);
        assert(y < Row);

        auto led = matrix[y][x];
        led.color = color;
        if (!led.isVisible)
        {
            led.isVisible = true;
        }
    }

    RGBA defaultColor()
    {
        return theme.colorAccent;
    }

    void fromIntMatrix(ref int[Col][Row] intMatrix)
    {
        fromIntMatrix(intMatrix, defaultColor);
    }

    void fromIntMatrix(ref int[Col][Row] intMatrix, RGBA color)
    {
        foreach (ri, ref row; intMatrix)
        {
            foreach (ci, ref isDrawValue; row)
            {
                auto item = matrix[ri][ci];
                item.isVisible = isDrawValue == 1;
                item.color = color;
            }
        }
    }

}
