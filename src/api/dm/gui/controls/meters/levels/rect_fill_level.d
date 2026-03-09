module api.dm.gui.controls.meters.levels.rect_fill_level;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.base.spaceable_container : SpaceableContainer;
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
class RectFillLevel : Control
{
    SpaceableContainer[] labelContainers;
    Text[] labels;

    SpaceableContainer[] levelContainers;

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
            startLevelColor = RGBA.red;
        }

        if (levelColorPaletteDeltaDeg == 0)
        {
            levelColorPaletteDeltaDeg = 360.0f / levels * rows;
        }

        HSLA startColor = startLevelColor.toHSLA;
        startColor.l = 0.7;
        startColor.s = 0.8;

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
            levelShapeHeight = theme.controlDefaultHeight * 2;
        }
    }

    override void create()
    {
        super.create;

        auto levelsInRow = levels / rows;

        auto spacing = 1;
        foreach (ri; 0 .. rows)
        {
            auto levelContainer = new HBox(spacing);
            levelContainers ~= levelContainer;
            addCreate(levelContainer);

            auto levelsWidth = levelsInRow * levelShapeWidth;
            levelContainer.resize(levelsWidth + levels * levelContainer.spacing, levelShapeHeight);

            auto labelContainer = new HBox(spacing);
            labelContainers ~= labelContainer;
            addCreate(labelContainer);
            labelContainer.width = levelContainer.width;

            foreach (i; 0 .. levelsInRow)
            {
                dstring levelName = levelNameProvider ? levelNameProvider(i + (ri * levelsInRow))
                    : "0";
                auto text = new Text(levelName);
                text.setSmallSize;
                text.isLayoutManaged = false;
                labels ~= text;
                labelContainer.addCreate(text);
                text.isLayoutManaged = false;
            }
        }
    }

    void onLevelXY(scope bool delegate(size_t, size_t, float, float) onIndexLevelRowXYIsContinue)
    {
        assert(levelContainers.length == rows);

        auto levelsInRow = levels / rows;

        foreach (ri; 0 .. rows)
        {
            auto levelContainer = levelContainers[ri];
            auto currentY = Math.round(levelContainer.y + levelContainer.height);
            float currentX = levelContainer.x + levelContainer.padding.left;

            foreach (i; 0 .. levelsInRow)
            {
                auto levelIndex = i + (ri * levelsInRow);

                if (!onIndexLevelRowXYIsContinue(levelIndex, ri, currentX, currentY))
                {
                    return;
                }

                currentX += levelShapeWidth + levelContainer.spacing;
            }
        }
    }

    override void applyLayout()
    {
        super.applyLayout;

        onLevelXY((li, ri, currX, currY) {
            auto levelCenter = currX + levelShapeWidth / 2;
            auto label = labels[li];
            label.x = levelCenter - label.halfWidth;
            label.y = label.parent.y;
            return true;
        });
    }

    override void drawContent()
    {
        super.drawContent;

        assert(levelMaxValueProvider);
        auto maxValue = levelMaxValueProvider();

        onLevelXY((levelIndex, rowIndex, currentX, currentY) {
            
            assert(levelNumValueProvider);

            auto levelValue = levelNumValueProvider(levelIndex);
            float normValue = levelValue / maxValue;
            normValue = Math.clamp01(normValue);

            auto levelHeight = Math.round(normValue * levelShapeHeight);
            if (levelHeight > levelShapeHeight)
            {
                levelHeight = levelShapeHeight;
            }

            graphic.color(levelColors[levelIndex]);
            scope (exit)
            {
                graphic.restoreColor;
            }

            auto levelY = Math.round(currentY - levelHeight);

            graphic.fillRect(currentX, levelY, levelShapeWidth, levelHeight);

            return true;
        });
    }
}
