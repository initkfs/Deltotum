module api.dm.gui.controls.meters.gauges.hlinear_gauge;

import api.dm.gui.controls.meters.min_value_meter : MinValueMeter;
import api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic : BaseScaleDynamic;
import api.dm.gui.controls.indicators.range_bars.color_range_bar : ColorRangeBar;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

import api.dm.gui.controls.control : Control;
import api.dm.gui.containers.container : Container;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import Math = api.dm.math;

import api.dm.kit.sprites.sprites2d.layouts.vlayout : VLayout;
import api.dm.kit.sprites.sprites2d.layouts.hlayout : HLayout;

import api.dm.gui.containers.hbox : HBox;
import api.dm.kit.graphics.colors.rgba : RGBA;
import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;

struct RangeInfo
{
    RGBA color;
    double range;
}

struct TickInfo
{
    double value;
    Sprite2d tick;
}

/**
 * Authors: initkfs
 */
class HLinearGauge : MinValueMeter!double
{
    Sprite2d scale;
    ColorRangeBar colorRangeBar;

    bool isCreateScale = true;
    Sprite2d delegate(Sprite2d) onScaleCreate;
    void delegate(Sprite2d) onScaleCreated;

    bool isCreateColorBar = true;
    ColorRangeBar delegate(ColorRangeBar) onColorBarCreate;
    void delegate(ColorRangeBar) onColorBarCreated;

    Container scaleContainer;

    bool isCreateScaleContainer = true;
    Container delegate(Container) onScaleContainerCreate;
    void delegate(Container) onScaleContainerCreated;

    double thumbWidth = 0;
    double thumbHeight = 0;

    Sprite2d[] thumbs;

    size_t thumbsCount = 4;

    protected
    {
        Sprite2d lastUsedThumb;
        double mouseWheelDeltaX = 2;

    }

    void delegate(double newValue, size_t thumbIndex)[] onThumbMove;

    this(double minValue = 0, double maxValue = 1, double width = 0, double height = 0)
    {
        super(minValue, maxValue);

        this._width = width;
        this._height = height;

        layout = new VLayout;
        layout.isAlignX = true;
    }

    override void initialize()
    {
        super.initialize;
        onPointerWheel ~= (ref e) {
            if (!isCreated)
            {
                return;
            }
            //TODO check bounds;
            const double dx = e.y * mouseWheelDeltaX;
            if (lastUsedThumb)
            {
                auto newX = lastUsedThumb.x + dx;
                moveThumb(lastUsedThumb, newX, lastUsedThumb.y);
            }
        };
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadControlSizeTheme;

        if (thumbWidth == 0)
        {
            thumbWidth = theme.meterThumbWidth;
        }

        if (thumbHeight == 0)
        {
            thumbHeight = theme.meterThumbHeight;
        }
    }

    Container newScaleContainer()
    {
        import api.dm.gui.containers.vbox: VBox;

        auto container = new VBox(0);
        return container;
    }

    override void create()
    {
        super.create;

        if (!scaleContainer && isCreateScaleContainer)
        {
            auto newContainer = newScaleContainer;
            scaleContainer = !onScaleContainerCreate ? newScaleContainer : onScaleContainerCreate(
                newContainer);
            addCreate(scaleContainer);
            if (onScaleContainerCreated)
            {
                onScaleContainerCreated(scaleContainer);
            }
        }

        if (!colorRangeBar && isCreateColorBar)
        {
            auto newBar = new ColorRangeBar(width, theme.meterTickMinorHeight);

            colorRangeBar = !onColorBarCreate ? newBar : onColorBarCreate(newBar);
            auto root = scaleContainer ? scaleContainer : this;
            root.addCreate(colorRangeBar);
            if (onColorBarCreated)
            {
                onColorBarCreated(colorRangeBar);
            }
        }

        if (!scale && isCreateScale)
        {
            import api.dm.gui.controls.meters.scales.dynamics.hscale_dynamic : HScaleDynamic;

            auto dynScale = new HScaleDynamic(width);
            dynScale.isInvertY = true;
            buildInitCreate(dynScale);
            scope(exit){
                dynScale.dispose;
            }

            auto scaleTexture = dynScale.toTexture;
            scaleTexture.isResizedByParent = false;

            scale = !onScaleCreate ? scaleTexture : onScaleCreate(scaleTexture);
            auto root = scaleContainer ? scaleContainer : this;
            root.addCreate(scale);

            if (root.width < scale.width)
            {
                root.width = scale.width;
            }

            if (onScaleCreated)
            {
                onScaleCreated(scale);
            }
        }

        foreach (i; 0 .. thumbsCount)
            (ii) {
            auto thumb = newThumb;

            thumb.isLayoutManaged = false;
            thumb.isDraggable = true;
            thumb.isResizedByParent = false;

            thumb.onDragXY = (x, y) { moveThumb(thumb, x, y); return false; };

            thumbContainer.addCreate(thumb);
            thumbs ~= thumb;
        }(i);

        layoutThumbs;
    }

    private size_t thumbIndex(Sprite2d th)
    {
        foreach (i, thumb; thumbs)
        {
            if (thumb is th)
            {
                return i;
            }
        }
        return -1;
    }

    override void applyLayout()
    {
        super.applyLayout;

        foreach (thumb; thumbs)
        {
            thumb.y = thumbContainer.boundsRect.bottom;
        }
    }

    void layoutThumbs()
    {
        if (thumbs.length == 0)
        {
            return;
        }

        size_t firstThumbIndex = 0;
        size_t lastThumbIndex = thumbs.length - 1;

        auto firstThumb = thumbs[firstThumbIndex];
        firstThumb.x = thumbContainer.boundsRect.x - firstThumb.boundsRect.halfWidth;

        if (firstThumbIndex != lastThumbIndex)
        {
            auto lastThumb = thumbs[lastThumbIndex];
            lastThumb.x = thumbContainer.boundsRect.right - lastThumb.boundsRect.halfWidth;

            auto mediumThumbs = thumbs.length - 2;
            if (mediumThumbs > 0)
            {
                auto freeSpace = thumbContainer.width - firstThumb.boundsRect.width - lastThumb
                    .boundsRect.width;
                auto dtX = Math.trunc(freeSpace / mediumThumbs);
                double nextX = firstThumb.boundsRect.right;

                foreach (i; (firstThumbIndex + 1) .. lastThumbIndex)
                {
                    auto thumb = thumbs[i];
                    thumb.x = nextX;
                    nextX += dtX;
                }
            }
        }
    }

    Control thumbContainer() => scaleContainer ? scaleContainer : this;

    Sprite2d newThumb()
    {
        auto style = createFillStyle;
        auto thumb = theme.triangleShape(thumbWidth, thumbHeight, angle, style);
        return thumb;
    }

    protected void moveThumb(Sprite2d thumb, double x, double y)
    {
        import std.math.operations : isClose;

        if (lastUsedThumb !is thumb)
        {
            lastUsedThumb = thumb;
        }

        auto bounds = thumbContainer.boundsRect;

        const thumbIndex = thumbIndex(lastUsedThumb);
        if (thumbIndex == -1)
        {
            logger.error("Not found thumb index for thumb: ", lastUsedThumb.toString);
            return;
        }

        double minX = bounds.x - lastUsedThumb.width / 2;
        double maxX = bounds.right - lastUsedThumb.width / 2;

        if (thumbs.length > 1)
        {
            if (thumbIndex > 0)
            {
                const leftThumbIndex = thumbIndex - 1;
                auto leftThumb = thumbs[leftThumbIndex];
                minX = leftThumb.boundsRect.right;
            }

            //TODO overflow
            auto nextIndex = thumbIndex + 1;
            if (nextIndex < thumbs.length)
            {
                auto nextThumb = thumbs[thumbIndex + 1];
                maxX = nextThumb.boundsRect.x - thumb.boundsRect.width;
            }

        }

        if (x <= minX || x >= maxX)
        {
            return;
        }

        lastUsedThumb.x = x;

        const pointerX = lastUsedThumb.boundsRect.middleX;
        const pointerTickX = pointerX - thumbContainer.boundsRect.x;

        auto value = (Math.abs(maxValue - minValue) * pointerTickX) / width;
        value = Math.clamp(value, minValue, maxValue);

        foreach (dg; onThumbMove)
        {
            dg(value, thumbIndex);
        }
    }
}
