module api.dm.gui.controls.selects.color_pickers.dialogs.color_picker_dialog;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.gui.controls.containers.tabs.tabbox : TabBox;
import api.dm.gui.controls.containers.tabs.tab : Tab;
import api.dm.gui.controls.forms.regulates.regulate_text_field;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsv : HSV;
import api.dm.kit.graphics.colors.hsl : HSL;

import api.math.geom2.rect2: Rect2d;
import Math = api.math;

/**
 * Authors: initkfs
 */
class ColorPickerDialog : Control
{
    TabBox contentContainer;
    bool isCreateContentContainer = true;
    TabBox delegate(TabBox) onNewContentContainer;
    void delegate(TabBox) onCreatedContentContainer;

    RegulateTextField alphaField;

    RegulateTextField rField;
    RegulateTextField gField;
    RegulateTextField bField;

    RegulateTextField hslHField;
    RegulateTextField hslSField;
    RegulateTextField hslLField;

    void delegate(RGBA, RGBA) onChangeOldNew;

    protected
    {
        RGBA _lastColor;

        //TODO hack, SDL_RenderReadPixels in SDl3
        ColorInfo[14 * 19] colorPixels; 
        struct ColorInfo {
            Rect2d bounds;
            RGBA color;
        }
    }

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        layout.isDecreaseRootSize = true;

        isBorder = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadColorPickerTheme;
    }

    void loadColorPickerTheme()
    {
        if (width == 0)
        {
            initWidth = theme.controlDefaultWidth * 2;
        }

        if (height == 0)
        {
            initHeight = theme.controlDefaultHeight * 2;
        }
    }

    override void create()
    {
        super.create;

        if (!contentContainer && isCreateContentContainer)
        {
            auto container = newContentContainer;
            contentContainer = !onNewContentContainer ? container : onNewContentContainer(container);

            contentContainer.isGrow = true;

            addCreate(contentContainer);
            if (onCreatedContentContainer)
            {
                onCreatedContentContainer(container);
            }

            createHSLTab;
            createRGBTab;
            createPalTab;

            // auto hsvTab = new Tab("HSV");
            // contentContainer.addCreate(hsvTab);

            // auto hslTab = new Tab("HSL");
            // contentContainer.addCreate(hslTab);

            // auto paletteTab = new Tab("Pal");
            // contentContainer.addCreate(paletteTab);
        }

        alphaField = new RegulateTextField("A", RGBA.minAlpha, RGBA.maxAlpha, (v) {
            //TODO multiple sets
            setColorRGBA(colorRGBA);
            setColorHSL(colorHSL);

            updateColor(colorRGBA);
        });
        addCreate(alphaField);
        alphaField.enableInsets;

        if (contentContainer)
        {
            contentContainer.selectFirstTab(isTriggerListeners : false);
        }
    }

    protected void updateColor(RGBA newColor, bool isTriggerListeners = true)
    {

        if (onChangeOldNew && isTriggerListeners)
        {
            onChangeOldNew(_lastColor, newColor);
        }

        _lastColor = newColor;
    }

    protected void createRGBTab()
    {
        assert(contentContainer);

        auto rgbTab = newTab("RGB");
        rgbTab.id = "color_picker_rgb_tab";

        rgbTab.onActivate = () { setColorRGBA(_lastColor); };

        rgbTab.content = createRGBTabContent;

        contentContainer.addCreate(rgbTab);
    }

    Sprite2d createRGBTabContent()
    {
        import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
        import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;

        auto form = new RegulateTextPanel;
        buildInitCreate(form);

        rField = createRGBField("R");
        form.addCreate(rField);
        gField = createRGBField("G");
        form.addCreate(gField);
        bField = createRGBField("B");
        form.addCreate(bField);

        form.alignFields;

        return form;
    }

    protected RegulateTextField createRGBField(dstring text)
    {
        auto minValue = RGBA.minColor;
        auto maxValue = RGBA.maxColor;

        auto field = new RegulateTextField(text, minValue, maxValue, (v) {
            updateColorRGBA;
        });
        return field;
    }

    void updateColorRGBA(bool isTriggerListeners = true)
    {
        updateColor(colorRGBA, isTriggerListeners);
    }

    RGBA colorRGBA()
    {
        import std.conv : to;

        auto r = Math.clamp(RGBA.minColor, Math.round(rField.value), RGBA.maxColor);
        auto g = Math.clamp(RGBA.minColor, Math.round(gField.value), RGBA.maxColor);
        auto b = Math.clamp(RGBA.minColor, Math.round(bField.value), RGBA.maxColor);
        return RGBA(r.to!ubyte, g.to!ubyte, b.to!ubyte, alpha);
    }

    protected void createHSLTab()
    {
        assert(contentContainer);

        auto hslTab = newTab("HSL");
        hslTab.id = "color_picker_hsl_tab";

        hslTab.onActivate = () { setColorHSL(_lastColor.toHSL); };

        hslTab.content = createHSLTabContent;

        contentContainer.addCreate(hslTab);
    }

    Sprite2d createHSLTabContent()
    {
        import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
        import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;

        auto form = new RegulateTextPanel;
        buildInitCreate(form);

        hslHField = new RegulateTextField("H", HSL.minHue, HSL.maxHue, (v) {
            updateColorHSL;
        });
        form.addCreate(hslHField);

        hslSField = new RegulateTextField("S", HSL.minSaturation, HSL.maxSaturation, (v) {
            updateColorHSL;
        });
        form.addCreate(hslSField);

        hslLField = new RegulateTextField("L", HSL.minLightness, HSL.maxLightness, (v) {
            updateColorHSL;
        });
        form.addCreate(hslLField);

        form.alignFields;

        return form;
    }

    void updateColorHSL(bool isTriggerListeners = true)
    {
        updateColor(colorHSL.toRGBA, isTriggerListeners);
    }

    HSL colorHSL()
    {
        auto h = Math.clamp(HSL.minHue, hslHField.value, HSL.maxHue);
        auto s = Math.clamp(HSL.minSaturation, hslSField.value, HSL.maxSaturation);
        auto l = Math.clamp(HSL.minLightness, hslLField.value, HSL.maxLightness);
        return HSL(h, s, l, alpha);
    }

    protected void createPalTab()
    {
        assert(contentContainer);

        auto palTab = newTab("Pal");
        palTab.id = "color_picker_pal_tab";
        palTab.content = createPalTabContent;
        contentContainer.addCreate(palTab);
    }

    Sprite2d createPalTabContent()
    {
        import api.dm.gui.controls.containers.scroll_box : ScrollBox, ScrollBarPolicy;

        auto container = new ScrollBox;
        buildInitCreate(container);

        import api.dm.kit.sprites2d.textures.rgba_texture : RgbaTexture;

        import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;

        size_t colorInRow = MaterialPalette.maxToneCount;
        double colorProbeSize = 10;

        auto colorTextureW = colorInRow * colorProbeSize;
        auto colorTextureH = MaterialPalette.colorCount * colorProbeSize;

        container.width = colorTextureW;
        container.height = colorTextureH;

        auto colorTexture = new class RgbaTexture
        { 
            this()
            {
                super(colorTextureW, colorTextureH);
            }

            override void createTextureContent()
            {
                double nextX = 0;
                double nextY = 0;
                size_t colIndex;
                auto oldColor = graphics.getColor;

                size_t pixelCounter;

                static foreach (color; __traits(allMembers, MaterialPalette))
                {
                    static if (is(typeof(__traits(getMember, MaterialPalette, color)) : string))
                    {
                        graphics.changeColor(RGBA.web(__traits(getMember, MaterialPalette, color)));
                        graphics.fillRect(nextX, nextY, colorProbeSize, colorProbeSize);

                        colorPixels[pixelCounter] = ColorInfo(Rect2d(nextX, nextY, colorProbeSize, colorProbeSize),graphics.getColor);
                        pixelCounter++;

                        nextX += colorProbeSize;
                        colIndex++;
                        
                        if (colIndex >= colorInRow)
                        {
                            colIndex = 0;
                            nextX = 0;
                            nextY += colorProbeSize;
                        }
                    }
                }

                //assert(pixelCounter == colorPixels.length);
                graphics.setColor(oldColor);
            }
        };

        container.setContent(colorTexture, colorTextureW, height);

        colorTexture.onPointerPress ~= (ref e){
            import api.math.geom2.vec2: Vec2d;
            //binary search
            auto rawPoint = Vec2d(e.x, e.y).subtract(colorTexture.pos);
            foreach(ref colorInfo; colorPixels){
                if(colorInfo.bounds.contains(rawPoint)){
                    updateColor(colorInfo.color);
                }
            }
        };

        return container;
    }

    double alpha()
    {
        assert(alphaField);
        //TODO HSV min\max value?
        return Math.clamp(RGBA.minAlpha, alphaField.value, RGBA.maxAlpha);
    }

    bool color(RGBA newColor)
    {
        updateColor(newColor, isTriggerListeners:
            false);

        //TODO is tab active
        setColorRGBA(newColor);
        setColorHSL(newColor.toHSL);

        return true;
    }

    protected void setColorRGBA(RGBA newColor)
    {
        assert(rField);
        rField.value = newColor.r;
        assert(gField);
        gField.value = newColor.g;
        assert(bField);
        bField.value = newColor.b;

        assert(alphaField);
        alphaField.value(newColor.a, isTriggerListeners:
            false);
    }

    protected void setColorHSL(HSL newColor)
    {
        assert(hslHField);
        hslHField.value = newColor.hue;

        assert(hslSField);
        hslSField.value = newColor.saturation;

        assert(hslLField);
        hslLField.value = newColor.lightness;

        assert(alphaField);
        alphaField.value(newColor.alpha, isTriggerListeners:
            false);
    }

    Tab newTab(dstring text) => new Tab(text);

    TabBox newContentContainer()
    {
        auto container = new TabBox;
        return container;
    }

    void toggleChooser()
    {
        // const b = boundsRect;
        // colorChooser.x = b.x;
        // colorChooser.y = b.bottom;

        // colorChooser.isVisible = !colorChooser.isVisible;
    }

}
