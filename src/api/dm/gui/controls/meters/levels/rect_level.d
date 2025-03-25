module api.dm.gui.controls.meters.levels.rect_level;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.meters.scales.dynamics.vscale_dynamic : VScaleDynamic;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsla : HSLA;

import Math = api.math;

/**
 * Authors: initkfs
 */
class RectLevel : Control
{
    Container labelContainer;
    Text[] labels;

    Container levelContainer;

    size_t levels = 10;

    RGBA[] levelColors;

    RGBA startLevelColor;
    double levelColorPaletteDeltaDeg = 0;

    double levelShapeWidth = 0;
    double levelShapeHeight = 0;

    dstring delegate(size_t) levelNameProvider;

    double delegate(size_t) levelNumValueProvider;
    double delegate() levelMaxValueProvider;

    this(double delegate(size_t) levelNumValueProvider, double delegate() levelMaxValueProvider)
    {
        assert(levelNumValueProvider);
        assert(levelMaxValueProvider);

        this.levelNumValueProvider = levelNumValueProvider;
        this.levelMaxValueProvider = levelMaxValueProvider;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadRectLevelTheme;
    }

    void loadRectLevelTheme()
    {
        if (levelColors.length == 0)
        {
            levelColors = new RGBA[](levels);
        }

        if (startLevelColor == RGBA.init)
        {
            startLevelColor = RGBA.random;
        }

        if (levelColorPaletteDeltaDeg == 0)
        {
            levelColorPaletteDeltaDeg = 20;
        }

        HSLA startColor = startLevelColor.toHSLA;
        startColor.l = 0.8;
        startColor.s = 0.6;

        foreach (ref levelColor; levelColors)
        {
            startColor.h = (startColor.h + levelColorPaletteDeltaDeg) % HSLA.maxHue;
            levelColor = startColor.toRGBA;
        }

        if (levelShapeWidth == 0)
        {
            levelShapeWidth = theme.meterThumbWidth;
        }

        if (levelShapeHeight == 0)
        {
            levelShapeHeight = theme.controlDefaultHeight;
        }
    }

    override void create()
    {
        super.create;

        levelContainer = new HBox;
        addCreate(levelContainer);

        auto levelsWidth = levels * levelShapeWidth;
        levelContainer.resize(levelsWidth, levelShapeHeight);

        labelContainer = new HBox;
        addCreate(labelContainer);

        foreach (i; 0 .. levels)
        {
            dstring levelName = levelNameProvider ? levelNameProvider(i) : "0";
            auto text = new Text(levelName);
            text.setSmallSize;
            labels ~= text;
            labelContainer.addCreate(text);
        }

    }

    override void drawContent()
    {
        super.drawContent;

        auto currentY = levelContainer.y + levelContainer.height;

        assert(levelNumValueProvider);
        assert(levelMaxValueProvider);

        auto maxValue = levelMaxValueProvider();
        auto halfLevelW = levelShapeWidth / 2;
        foreach (i; 0 .. levels)
        {
            auto label = labels[i];
            auto currentX = label.boundsRect.middleX - halfLevelW;

            auto levelValue = levelNumValueProvider(i);
            auto levelHeight = levelValue * levelShapeHeight / maxValue;

            graphics.changeColor(levelColors[i]);
            scope (exit)
            {
                graphics.restoreColor;
            }

            graphics.fillRect(currentX, currentY - levelHeight, levelShapeWidth, levelHeight);
            currentX += levelShapeWidth;
        }
    }
}
