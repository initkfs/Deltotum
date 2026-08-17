module api.dm.gui.controls.selects.color_pickers.dialogs.color_picker_dialog;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.dm.kit.sprites2d.textures.tex2d : Tex2d;
import api.dm.gui.controls.containers.tabs.tabbox : TabBox;
import api.dm.gui.controls.containers.tabs.tab : Tab;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.forms.regulates.regulate_text_field;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.dm.kit.graphics.colors.hsla : HSLA;

import api.math.geom2.rect2 : Rect2f;
import Math = api.math;

/**
 * Authors: initkfs
 */
class ColorPickerDialog : Control
{
    TabBox contentContainer;
    bool isCreateContentContainer = true;
    TabBox delegate(TabBox) onNewContentContainer;
    void delegate(TabBox) onConfiguredContentContainer;
    void delegate(TabBox) onCreatedContentContainer;

    RegulateTextField alphaField;

    RegulateTextField rField;
    RegulateTextField gField;
    RegulateTextField bField;

    RegulateTextField hslHField;
    RegulateTextField hslSField;
    RegulateTextField hslLField;

    RegulateTextField hsvHField;
    RegulateTextField hsvSField;
    RegulateTextField hsvVField;

    Text palNameText;
    Text delegate(Text) onNewPalNameText;
    void delegate(Text) onConfiguredPalNameText;
    void delegate(Text) onCreatedPalNameText;

    void delegate(RGBA, RGBA) onChangeOldNew;

    size_t paletteColorSize = 14;

    float valueStep = 0.01;

    protected
    {
        RGBA _lastColor;

        //TODO hack, SDL_RenderReadPixels in SDl3
        ColorInfo[14 * 19] colorPixels;
        struct ColorInfo
        {
            Rect2f bounds;
            RGBA color;
            string name;
        }

        Tab hslTab;
        Tab hsvTab;
        Tab rgbTab;
        Tab palTab;
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

            if (onConfiguredContentContainer)
            {
                onConfiguredContentContainer(contentContainer);
            }

            addCreate(contentContainer);

            if (onCreatedContentContainer)
            {
                onCreatedContentContainer(container);
            }

            createHSLTab;
            createHSVTab;
            createRGBTab;
            createPalTab;
        }

        alphaField = new RegulateTextField("A", RGBA.minAlpha, RGBA.maxAlpha, (v) {
            _lastColor.a = alpha;
            updateColor(_lastColor);
        });
        alphaField.scrollDt = valueStep;
        addCreate(alphaField);
        alphaField.enablePadding;

        if (contentContainer)
        {
            contentContainer.selectFirstTab(isTrigger : false);
        }
    }

    protected void updateColor(RGBA newColor, bool isTrigger = true)
    {
        if (onChangeOldNew && isTrigger)
        {
            onChangeOldNew(_lastColor, newColor);
        }

        _lastColor = newColor;
    }

    Control rootContainer() => contentContainer ? contentContainer : this;

    protected void createRGBTab()
    {
        rgbTab = newRGBTab("RGB");
        rgbTab.id = "color_picker_rgb_tab";
        rgbTab.onActivate = () { setColorRGBA(_lastColor); };
        rgbTab.content = createRGBTabContent;
        rootContainer.addCreate(rgbTab);
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
        auto field = new RegulateTextField(text, RGBA.minColor, RGBA.maxColor, (v) {
            updateColorRGBA;
        });
        field.scrollDt = valueStep;
        field.valueFormatPrec = 0;
        return field;
    }

    void updateColorRGBA(bool isTrigger = true)
    {
        updateColor(colorRGBA, isTrigger);
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
        hslTab = newHSLTab("HSL");
        hslTab.id = "color_picker_hsl_tab";
        hslTab.onActivate = () { setColorHSL(_lastColor.toHSLA); };
        hslTab.content = createHSLTabContent;
        rootContainer.addCreate(hslTab);
    }

    void createThumbPointer(Sprite2d thumb)
    {
        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        thumb.layout = new CenterLayout;

        import api.dm.gui.controls.separators.vsep : VSep;

        //TOCO calc padding
        float linePadding = 5;
        // if(auto thumbControl = cast(Control) thumb){
        //     auto thumbStyle = createStyle;
        //     linePadding += thumbStyle.lineWidth * 2;
        // }

        auto pointer = new VSep;
        pointer.width = 2;
        pointer.height = thumb.height - linePadding;
        pointer.isVGrow = true;
        buildInitCreate(pointer);
        thumb.add(pointer);
    }

    import api.dm.gui.controls.meters.scrolls.base_regular_mono_scroll : BaseRegularMonoScroll;

    void createHueColorBar(BaseRegularMonoScroll scroll, RGBA delegate(float) onHueStep)
    {
        auto colorBarW = scroll.width;
        if (scroll.thumb && colorBarW > scroll.thumb.width)
        {
            colorBarW -= scroll.thumb.width;
        }
        auto colorBarH = scroll.height > 0 ? scroll.height / 2 : 10;

        if (platform.cap.isVector)
        {
            import api.dm.kit.sprites2d.textures.vectors.vec_tex : VecTex;

            auto colorBar = new class VecTex
            {
                this()
                {
                    super(colorBarW, colorBarH);
                }

                override void createContent()
                {
                    auto ctx = canvas;

                    import api.dm.kit.graphics.canvases.graphic_canvas : GrStop;
                    import api.math.geom2.vec2 : Vec2f;

                    enum pointsCount = 10;
                    float offsetDelta = 1.0 / pointsCount;

                    GrStop[pointsCount] points;

                    RGBA currentColor = onHueStep(0);
                    float currentOffset = 0;
                    float hueDelta = 360 / pointsCount;

                    ctx.color = currentColor;

                    foreach (pi, ref p; points)
                    {
                        p = GrStop(currentOffset, currentColor);
                        currentOffset += offsetDelta;
                        currentColor = onHueStep(hueDelta);
                    }

                    points[$ - 1].offset = 1;

                    ctx.linearGradient(Vec2f(0, 0), Vec2f(colorBarW, 0), points, () {
                        ctx.fillRect(0, 0, colorBarW, colorBarH);
                    });

                    ctx.stroke;
                }
            };
            colorBar.isResizedByParent = false;
            scroll.addCreate(colorBar, 0);
        }

    }

    Sprite2d createHSLTabContent()
    {
        import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;

        auto form = new RegulateTextPanel;
        buildInitCreate(form);

        hslHField = new RegulateTextField("H", HSLA.minHue, HSLA.maxHue, (v) {
            updateColorHSL;
        });
        hslHField.scrollDt = valueStep;
        hslHField.onNewScrollField = (scroll) {
            auto thumbStyle = createStyle;
            thumbStyle.isFill = false;
            scroll.thumbStyle = thumbStyle;
            return scroll;
        };

        hslHField.onCreatedScrollField = (scroll) {
            if (scroll.thumb)
            {
                createThumbPointer(scroll.thumb);
            }
        };

        form.addCreate(hslHField);

        if (hslHField.scrollField)
        {
            auto currentColor = HSLA(0, 1, 0.5, 1);

            createHueColorBar(hslHField.scrollField, (hueDelta) {
                currentColor.h += hueDelta;
                return currentColor.toRGBA;
            });

            hslHField.scrollField.valueStep = 0.25;
        }

        hslSField = new RegulateTextField("S", HSLA.minSaturation, HSLA.maxSaturation, (v) {
            updateColorHSL;
        });
        hslSField.scrollDt = valueStep;
        form.addCreate(hslSField);
        hslHField.value(HSLA.maxSaturation, false);

        hslLField = new RegulateTextField("L", HSLA.minLightness, HSLA.maxLightness, (v) {
            updateColorHSL;
        });
        hslLField.scrollDt = valueStep;
        form.addCreate(hslLField);
        hslLField.value(HSLA.maxLightness, false);

        form.alignFields;

        return form;
    }

    void updateColorHSL(bool isTrigger = true)
    {
        //Warn! if L == 1 => RGBA.white!
        updateColor(colorHSL.toRGBA, isTrigger);
    }

    HSLA colorHSL()
    {
        auto h = Math.clamp(HSLA.minHue, hslHField.value, HSLA.maxHue);
        auto s = Math.clamp(HSLA.minSaturation, hslSField.value, HSLA.maxSaturation);
        auto l = Math.clamp(HSLA.minLightness, hslLField.value, HSLA.maxLightness);
        return HSLA(h, s, l, alpha);
    }

    protected void createHSVTab()
    {
        hsvTab = newHSVTab("HSV");
        hsvTab.id = "color_picker_hsv_tab";

        hsvTab.onActivate = () { setColorHSV(_lastColor.toHSVA); };

        hsvTab.content = createHSVTabContent;

        rootContainer.addCreate(hsvTab);
    }

    Sprite2d createHSVTabContent()
    {
        import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;

        auto form = new RegulateTextPanel;
        buildInitCreate(form);

        hsvHField = new RegulateTextField("H", HSVA.minHue, HSVA.maxHue, (v) {
            updateColorHSV;
        });
        hsvHField.scrollDt = valueStep;
        hsvHField.onNewScrollField = (scroll) {
            auto thumbStyle = createStyle;
            thumbStyle.isFill = false;
            scroll.thumbStyle = thumbStyle;
            return scroll;
        };

        hsvHField.onCreatedScrollField = (scroll) {
            if (scroll.thumb)
            {
                createThumbPointer(scroll.thumb);
            }
        };

        form.addCreate(hsvHField);

        if (hsvHField.scrollField)
        {
            auto currentColor = HSVA(0, 1, 1, 1);
            createHueColorBar(hsvHField.scrollField, (hueDelta) {
                currentColor.h += hueDelta;
                return currentColor.toRGBA;
            });

            hsvHField.scrollField.valueStep = 0.25;
        }

        hsvSField = new RegulateTextField("S", HSVA.minSaturation, HSVA.maxSaturation, (v) {
            updateColorHSV;
        });
        hsvSField.scrollDt = valueStep;
        form.addCreate(hsvSField);
        hslHField.value(HSVA.maxSaturation, false);

        hsvVField = new RegulateTextField("V", HSVA.minValue, HSVA.maxValue, (v) {
            updateColorHSV;
        });
        hsvVField.scrollDt = valueStep;
        form.addCreate(hsvVField);
        hsvVField.value(HSVA.maxValue, false);

        form.alignFields;

        return form;
    }

    void updateColorHSV(bool isTrigger = true)
    {
        //Warn! if L == 1 => RGBA.white!
        updateColor(colorHSV.toRGBA, isTrigger);
    }

    HSVA colorHSV()
    {
        auto h = Math.clamp(HSVA.minHue, hsvHField.value, HSVA.maxHue);
        auto s = Math.clamp(HSVA.minSaturation, hsvSField.value, HSVA.maxSaturation);
        auto v = Math.clamp(HSVA.minValue, hsvVField.value, HSVA.maxValue);
        return HSVA(h, s, v, alpha);
    }

    protected void createPalTab()
    {
        palTab = newPalTab("Pal");
        palTab.id = "color_picker_pal_tab";
        palTab.content = createPalTabContent;
        rootContainer.addCreate(palTab);
    }

    Sprite2d createPalTabContent()
    {
        import api.dm.gui.controls.containers.scroll_box : ScrollBox, ScrollBarPolicy;
        import api.dm.gui.controls.containers.hbox : HBox;

        auto container = new ScrollBox;
        container.isBorder = false;
        buildInitCreate(container);
        import api.dm.kit.sprites2d.textures.rgba_tex2d : RgbaTex2d;

        import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;

        size_t colorInRow = MaterialPalette.maxToneCount;

        if (paletteColorSize == 0)
        {
            return container;
        }

        auto colorTextureW = colorInRow * paletteColorSize;
        auto colorTextureH = MaterialPalette.colorCount * paletteColorSize;

        container.width = colorTextureW;
        container.height = colorTextureH;

        auto colorTexture = new class RgbaTex2d
        {
            this()
            {
                super(colorTextureW, colorTextureH);
            }

            override void createContent()
            {
                float nextX = 0;
                float nextY = 0;
                size_t colIndex;
                auto oldColor = graphic.color;

                MaterialPalette.onColor((color, i) {
                    graphic.color(RGBA.hex(color));
                    graphic.fillRect(nextX, nextY, paletteColorSize, paletteColorSize);

                    colorPixels[i] = ColorInfo(Rect2f(nextX, nextY, paletteColorSize, paletteColorSize), graphic
                        .color, color);

                    nextX += paletteColorSize;
                    colIndex++;

                    if (colIndex >= colorInRow)
                    {
                        colIndex = 0;
                        nextX = 0;
                        nextY += paletteColorSize;
                    }

                    return true;
                });

                // static foreach (color; __traits(allMembers, MaterialPalette))
                // {
                //     static if (is(typeof(__traits(getMember, MaterialPalette, color)) : string))
                //     {
                //         graphic.color(RGBA.hex(__traits(getMember, MaterialPalette, color)));
                //         graphic.fillRect(nextX, nextY, paletteColorSize, paletteColorSize);

                //         colorPixels[pixelCounter] = ColorInfo(Rect2f(nextX, nextY, paletteColorSize, paletteColorSize), graphic
                //                 .color, color);
                //         pixelCounter++;

                //         nextX += paletteColorSize;
                //         colIndex++;

                //         if (colIndex >= colorInRow)
                //         {
                //             colIndex = 0;
                //             nextX = 0;
                //             nextY += paletteColorSize;
                //         }
                //     }
                // }

                //assert(pixelCounter == colorPixels.length);
                graphic.changeColor(oldColor);
            }
        };

        container.setContent(colorTexture, colorTextureW, height);

        colorTexture.onPointerPress ~= (ref e) {
            import api.math.geom2.vec2 : Vec2f;

            //binary search
            auto rawPoint = Vec2f(e.x, e.y).sub(colorTexture.pos);
            foreach (ref colorInfo; colorPixels)
            {
                if (colorInfo.bounds.contains(rawPoint))
                {
                    auto color = colorInfo.color;
                    color.a = alpha;
                    updateColor(color);
                    if (palNameText)
                    {
                        palNameText.text = colorInfo.name;
                    }
                }
            }
        };

        if (!palNameText)
        {
            auto t = newPalNameText("color");
            palNameText = !onNewPalNameText ? t : onNewPalNameText(t);

            if (onConfiguredPalNameText)
            {
                onConfiguredPalNameText(palNameText);
            }

            container.addCreate(palNameText);

            palNameText.enablePadding;

            if (onCreatedPalNameText)
            {
                onCreatedPalNameText(palNameText);
            }
        }

        return container;
    }

    float alpha()
    {
        if (!alphaField)
        {
            throw new Exception("Alpha field is null");
        }
        //TODO HSVA min\max value?
        return Math.clamp(RGBA.minAlpha, alphaField.value, RGBA.maxAlpha);
    }

    bool color(RGBA newColor)
    {
        updateColor(newColor, isTrigger:
            false);

        //TODO is tab active + alpha
        setColorHSL(newColor.toHSLA);
        setColorRGBA(newColor);
        setColorHSV(newColor.toHSVA);

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
        alphaField.value(newColor.a, isTrigger:
            false);
    }

    protected void setColorHSL(HSLA newColor)
    {
        assert(hslHField);
        hslHField.value(newColor.h, false, true);

        assert(hslSField);
        hslSField.value(newColor.s, false, true);

        assert(hslLField);
        hslLField.value(newColor.l, false, true);

        assert(alphaField);
        alphaField.value(newColor.a, isTrigger:
            false, true);
    }

    protected void setColorHSV(HSVA newColor)
    {
        assert(hsvHField);
        hsvHField.value(newColor.h, false, true);

        assert(hsvSField);
        hsvSField.value(newColor.s, false, true);

        assert(hsvVField);
        hsvVField.value(newColor.v, false, true);

        assert(alphaField);
        alphaField.value(newColor.a, isTrigger:
            false, true);
    }

    Tab newTab(dstring text) => new Tab(text);

    Tab newRGBTab(dstring text) => newTab(text);
    Tab newHSLTab(dstring text) => newTab(text);
    Tab newHSVTab(dstring text) => newTab(text);

    Text newPalNameText(dstring text) => new Text(text);

    Tab newPalTab(dstring text)
    {
        auto tab = newTab(null);
        buildInitCreate(tab);

        assert(tab.labelButton);
        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        tab.labelButton.layout = new CenterLayout;
        tab.labelButton.layout.isAutoResize = true;

        import api.dm.kit.sprites2d.textures.tex2d : Tex2d;

        auto colorSize = theme.iconSize / 2;

        auto palTabColor = new Tex2d(colorSize, colorSize);
        buildInitCreate(palTabColor);
        palTabColor.createTargetRGBA32;
        palTabColor.setRenderTarget;
        scope (exit)
        {
            palTabColor.restoreRenderTarget;
        }

        graphic.clearTransparent;

        graphic.fillRect(0, 0, colorSize, colorSize, RGBA.hex("#CC00FF"));
        tab.addCreate(palTabColor);
        return tab;
    }

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
