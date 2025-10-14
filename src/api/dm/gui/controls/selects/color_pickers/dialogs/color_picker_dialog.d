module api.dm.gui.controls.selects.color_pickers.dialogs.color_picker_dialog;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.gui.controls.containers.tabs.tabbox : TabBox;
import api.dm.gui.controls.containers.tabs.tab : Tab;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.forms.regulates.regulate_text_field;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.dm.kit.graphics.colors.hsla : HSLA;

import api.math.geom2.rect2 : Rect2d;
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

    RegulateTextField lchHField;
    RegulateTextField lchCField;
    RegulateTextField lchLField;

    Text palNameText;
    Text delegate(Text) onNewPalNameText;
    void delegate(Text) onConfiguredPalNameText;
    void delegate(Text) onCreatedPalNameText;

    void delegate(RGBA, RGBA) onChangeOldNew;

    size_t paletteColorSize = 14;

    protected
    {
        RGBA _lastColor;

        //TODO hack, SDL_RenderReadPixels in SDl3
        ColorInfo[14 * 19] colorPixels;
        struct ColorInfo
        {
            Rect2d bounds;
            RGBA color;
            string name;
        }

        Tab rgbTab;
        Tab hslTab;
        Tab palTab;
    }

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        layout.isDecreaseRootSize = true;

        //isBorder = true;
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
            createRGBTab;
            createPalTab;
        }

        alphaField = new RegulateTextField("A", RGBA.minAlpha, RGBA.maxAlpha, (v) {
            _lastColor.a = alpha;
            updateColor(_lastColor);
        });
        addCreate(alphaField);
        alphaField.enablePadding;

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

        rgbTab = newRGBTab("RGB");
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

        hslTab = newHSLTab("HSL");
        hslTab.id = "color_picker_hsl_tab";

        hslTab.onActivate = () { setColorHSL(_lastColor.toHSLA); };

        hslTab.content = createHSLTabContent;

        contentContainer.addCreate(hslTab);
    }

    Sprite2d createHSLTabContent()
    {
        import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
        import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;

        auto form = new RegulateTextPanel;
        buildInitCreate(form);

        hslHField = new RegulateTextField("H", HSLA.minHue, HSLA.maxHue, (v) {
            updateColorHSL;
        });
        hslHField.onNewScrollField = (scroll) {
            auto thumbStyle = createStyle;
            thumbStyle.isFill = false;
            scroll.thumbStyle = thumbStyle;
            return scroll;
        };

        hslHField.onCreatedScrollField = (scroll) {
            if (scroll.thumb)
            {
                import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

                scroll.thumb.layout = new CenterLayout;

                import api.dm.gui.controls.separators.vseparator : VSeparator;

                auto pointer = new VSeparator;
                pointer.width = 2;
                pointer.height = scroll.thumb.height;
                pointer.isVGrow = true;
                buildInitCreate(pointer);
                scroll.thumb.add(pointer);
            }
        };

        form.addCreate(hslHField);

        assert(hslHField.scrollField);
        auto scroll = hslHField.scrollField;
        import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;

        auto colorBarW = scroll.width;
        if (scroll.thumb && colorBarW > scroll.thumb.width)
        {
            colorBarW -= scroll.thumb.width;
        }
        auto colorBarH = scroll.height > 0 ? scroll.height / 2 : 10;

        auto colorBar = new class VectorTexture
        {
            this()
            {
                super(colorBarW, colorBarH);
            }

            override void createTextureContent()
            {
                auto ctx = canvas;

                import api.dm.kit.graphics.canvases.graphic_canvas : GradientStopPoint;
                import api.math.geom2.vec2 : Vec2d;

                enum pointsCount = 10;
                double offsetDelta = 1.0 / pointsCount;

                GradientStopPoint[pointsCount] points;

                HSLA currentColor = HSLA(0, 1, 0.5, 1);
                double currentOffset = 0;
                double hueDelta = 360 / pointsCount;

                ctx.color = currentColor.toRGBA;

                foreach (pi, ref p; points)
                {
                    p = GradientStopPoint(currentOffset, currentColor.toRGBA);
                    currentOffset += offsetDelta;
                    currentColor.h += hueDelta;
                }

                points[$ - 1].offset = 1;

                ctx.linearGradient(Vec2d(0, 0), Vec2d(colorBarW, 0), points, () {
                    ctx.fillRect(0, 0, colorBarW, colorBarH);
                });

                ctx.stroke;
            }
        };
        colorBar.isResizedByParent = false;
        scroll.addCreate(colorBar, 0);

        assert(hslHField.scrollField);
        hslHField.scrollField.valueStep = 5;

        hslSField = new RegulateTextField("S", HSLA.minSaturation, HSLA.maxSaturation, (v) {
            updateColorHSL;
        });
        form.addCreate(hslSField);

        hslLField = new RegulateTextField("L", HSLA.minLightness, HSLA.maxLightness, (v) {
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

    HSLA colorHSL()
    {
        auto h = Math.clamp(HSLA.minHue, hslHField.value, HSLA.maxHue);
        auto s = Math.clamp(HSLA.minSaturation, hslSField.value, HSLA.maxSaturation);
        auto l = Math.clamp(HSLA.minLightness, hslLField.value, HSLA.maxLightness);
        return HSLA(h, s, l, alpha);
    }

    protected void createPalTab()
    {
        assert(contentContainer);

        palTab = newPalTab("Pal");
        palTab.id = "color_picker_pal_tab";
        palTab.content = createPalTabContent;
        contentContainer.addCreate(palTab);
    }

    Sprite2d createPalTabContent()
    {
        import api.dm.gui.controls.containers.scroll_box : ScrollBox, ScrollBarPolicy;
        import api.dm.gui.controls.containers.hbox : HBox;

        HBox contentRoot = new HBox;
        buildInitCreate(contentRoot);

        auto container = new ScrollBox;
        container.isBorder = false;
        contentRoot.addCreate(container);

        import api.dm.kit.sprites2d.textures.rgba_texture : RgbaTexture;

        import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;

        size_t colorInRow = MaterialPalette.maxToneCount;

        assert(paletteColorSize > 0);

        auto colorTextureW = colorInRow * paletteColorSize;
        auto colorTextureH = MaterialPalette.colorCount * paletteColorSize;

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
                auto oldColor = graphic.color;

                MaterialPalette.onColor((color, i) {
                    graphic.color(RGBA.web(color));
                    graphic.fillRect(nextX, nextY, paletteColorSize, paletteColorSize);

                    colorPixels[i] = ColorInfo(Rect2d(nextX, nextY, paletteColorSize, paletteColorSize), graphic
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
                //         graphic.color(RGBA.web(__traits(getMember, MaterialPalette, color)));
                //         graphic.fillRect(nextX, nextY, paletteColorSize, paletteColorSize);

                //         colorPixels[pixelCounter] = ColorInfo(Rect2d(nextX, nextY, paletteColorSize, paletteColorSize), graphic
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
            import api.math.geom2.vec2 : Vec2d;

            //binary search
            auto rawPoint = Vec2d(e.x, e.y).sub(colorTexture.pos);
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

    double alpha()
    {
        assert(alphaField);
        //TODO HSVA min\max value?
        return Math.clamp(RGBA.minAlpha, alphaField.value, RGBA.maxAlpha);
    }

    bool color(RGBA newColor)
    {
        updateColor(newColor, isTriggerListeners:
            false);

        //TODO is tab active + alpha
        setColorHSL(newColor.toHSLA);
        setColorRGBA(newColor);

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

    protected void setColorHSL(HSLA newColor)
    {
        assert(hslHField);
        hslHField.value = newColor.h;

        assert(hslSField);
        hslSField.value = newColor.s;

        assert(hslLField);
        hslLField.value = newColor.l;

        assert(alphaField);
        alphaField.value(newColor.a, isTriggerListeners:
            false);
    }

    Tab newTab(dstring text) => new Tab(text);

    Tab newRGBTab(dstring text) => newTab(text);
    Tab newHSLTab(dstring text) => newTab(text);

    Text newPalNameText(dstring text) => new Text(text);

    Tab newPalTab(dstring text)
    {
        auto tab = newTab(null);
        buildInitCreate(tab);

        assert(tab.labelButton);
        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        tab.labelButton.layout = new CenterLayout;
        tab.labelButton.layout.isAutoResize = true;

        import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

        auto colorSize = theme.iconSize / 2;

        auto palTabColor = new Texture2d(colorSize, colorSize);
        buildInitCreate(palTabColor);
        palTabColor.createTargetRGBA32;
        palTabColor.setRendererTarget;
        scope (exit)
        {
            palTabColor.restoreRendererTarget;
        }

        graphic.clearTransparent;

        graphic.fillRect(0, 0, colorSize, colorSize, RGBA.web("#CC00FF"));
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
