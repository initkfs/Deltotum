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
    Container[] labelContainers;
    Text[] labels;

    Container[] levelContainers;

    size_t levels = 10;
    size_t rows = 1;

    RGBA[] levelColors;

    RGBA startLevelColor;
    float levelColorPaletteDeltaDeg = 0;

    float levelShapeWidth = 0;
    float levelShapeHeight = 0;

    dstring delegate(size_t) levelNameProvider;

    float delegate(size_t) levelNumValueProvider;
    float delegate() levelMaxValueProvider;

    this(float delegate(size_t) levelNumValueProvider, float delegate() levelMaxValueProvider)
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
            levelShapeWidth = theme.meterThumbWidth * 0.8;
        }

        if (levelShapeHeight == 0)
        {
            levelShapeHeight = theme.controlDefaultHeight;
        }
    }

    override void create()
    {
        super.create;

        auto levelsInRow = levels / rows;

        foreach (ri; 0 .. rows)
        {
            auto levelContainer = new HBox;
            levelContainers ~= levelContainer;
            addCreate(levelContainer);

            auto levelsWidth = levelsInRow * levelShapeWidth;
            levelContainer.resize(levelsWidth, levelShapeHeight);

            auto labelContainer = new HBox;
            labelContainers ~= labelContainer;
            addCreate(labelContainer);

            foreach (i; 0 .. levelsInRow)
            {
                dstring levelName = levelNameProvider ? levelNameProvider(i + (ri * levelsInRow))
                    : "0";
                auto text = new Text(levelName);
                text.setSmallSize;
                labels ~= text;
                labelContainer.addCreate(text);
            }
        }

    }

    override void drawContent()
    {
        super.drawContent;

        assert(levelContainers.length == rows);

        auto levelsInRow = levels / rows;

        foreach (ri; 0 .. rows)
        {
            auto levelContainer = levelContainers[ri];
            auto currentY = Math.round(levelContainer.y + levelContainer.height);

            assert(levelNumValueProvider);
            assert(levelMaxValueProvider);

            auto maxValue = levelMaxValueProvider();
            auto halfLevelW = levelShapeWidth / 2;
            foreach (i; 0 .. levelsInRow)
            {
                auto levelIndex = i + (ri * levelsInRow);
                auto label = labels[levelIndex];
                auto currentX = label.boundsRect.middleX - halfLevelW;
                auto levelValue = levelNumValueProvider(levelIndex);
                float normValue = levelValue / maxValue;
                if (normValue > 1)
                {
                    normValue = 1;
                }
                auto levelHeight = Math.round(normValue * levelShapeHeight);
                if(levelHeight > levelShapeHeight){
                    levelHeight = levelShapeHeight;
                }

                graphic.color(levelColors[levelIndex]);
                scope (exit)
                {
                    graphic.restoreColor;
                }

                auto levelY = Math.round(currentY - levelHeight);

                graphic.fillRect(currentX, levelY, levelShapeWidth, levelHeight);
                currentX += levelShapeWidth;
            }
        }
    }
}
