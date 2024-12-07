module api.dm.gui.controls.meters.gauges.hlinear_gauge;

import api.dm.gui.controls.meters.min_value_meter: MinValueMeter;
import api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic: BaseScaleDynamic;

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
    BaseScaleDynamic scale;

    double step = 0;
    double measurementUnitStep = 5;

    double tickWidth = 2;

    Sprite2d[] ticks;

    Container tickContainer;
    Container pointerContainer;
    HBox labelContainer;

    Sprite2d[] pointers;
    TickInfo[] measureTicks;

    size_t pointerCount = 4;

    RangeInfo[] rangeInfo;

    Sprite2d lastUsedPointer;

    double mouseWheelDeltaX = 2;

    void delegate(double newValue, size_t pointerIndex)[] onPointerMove;

    this(double minValue = 0, double maxValue = 1, double width = 0, double height = 0)
    {
        super(minValue, maxValue);

        this._width = width;
        this._height = height;

        this.minValue = minValue;
        this.maxValue = maxValue;

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
            if (lastUsedPointer)
            {
                auto newX = lastUsedPointer.x + dx;
                movePointer(lastUsedPointer, newX, lastUsedPointer.y);
            }
        };
    }

    override void loadTheme(){
        super.loadTheme;
    }

    override void create()
    {
        super.create;

        // const range = Math.abs(maxValue - minValue);

        // labelContainer = new HBox;
        // labelContainer.width = width;
        // //TODO from font?
        // labelContainer.height = 15;
        // addCreate(labelContainer);

        // auto rangeContainer = new HBox;
        // rangeContainer.width = width;
        // addCreate(rangeContainer);

        // auto colorStep = range / 4;
        // //TODO from settings
        // rangeInfo = [
        //     RangeInfo(RGBA.web(MaterialPalette.redA700), colorStep),
        //     RangeInfo(RGBA.web(MaterialPalette.orangeA700), colorStep),
        //     RangeInfo(RGBA.web(MaterialPalette.yellowA700), colorStep),
        //     RangeInfo(RGBA.web(MaterialPalette.greenA700), colorStep)
        // ];

        // foreach (r; rangeInfo)
        // {
        //     auto style = createStyle;
        //     style.isFill = true;
        //     style.color = r.color;
        //     import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

        //     auto rectWidth = (r.range * (width + tickWidth)) / range;
        //     auto rect = new VConvexPolygon(rectWidth, 5, style, 0);
        //     rangeContainer.addCreate(rect);
        // }

        // const ticksCount = Math.trunc(range / step);

        // const tickSpace = Math.round(width - ticksCount * tickWidth) / ticksCount;
        // tickContainer = new HBox(tickSpace);
        // tickContainer.width = width;
        // tickContainer.layout.isAlignY = true;
        // addCreate(tickContainer);

        // //+1 0-tick
        // foreach (i; 0 .. ticksCount + 1)
        // {
        //     bool isMeasureUnit = (i == 0 || i % measurementUnitStep == 0);
        //     auto tick = isMeasureUnit ? newMaxStepTick : newMinStepTick;
        //     tickContainer.addCreate(tick);
        //     if (isMeasureUnit)
        //     {
        //         double value = (i * maxValue) / ticksCount;
        //         measureTicks ~= TickInfo(value, tick);
        //     }
        //     ticks ~= tick;
        // }

        // pointerContainer = new HBox;
        // pointerContainer.width = tickContainer.width;
        // addCreate(pointerContainer);

        // double maxHeight = 0;
        // foreach (i; 0 .. pointerCount)
        // {
        //     auto pointer = newPointer;
        //     if(pointer.height > maxHeight){
        //         maxHeight = pointer.height;
        //     }
        //     pointer.isLayoutManaged = false;
        //     pointerContainer.addCreate(pointer);
        //     pointers ~= pointer;
        // }
        // pointerContainer.height = maxHeight;

        // const tickInfoSpace = width / measureTicks.length;
        // labelContainer.spacing = tickInfoSpace;

        // tickContainer.applyLayout;

        // foreach (tickInfo; measureTicks)
        // {
        //     import api.dm.gui.controls.texts.text : Text;
        //     import api.dm.kit.assets.fonts.font_size : FontSize;

        //     import std.conv : to;

        //     dstring text = tickInfo.value.to!dstring;
        //     auto label = new Text(text);
        //     label.isLayoutManaged = false;
        //     label.fontSize = FontSize.small;
        //     label.x = tickInfo.tick.boundsRectInParent.x;
        //     labelContainer.addCreate(label);
        //     label.x = tickInfo.tick.boundsRectInParent.x - label.boundsRect.halfWidth;
        // }

        // layoutPointers;
    }

    private size_t pointerIndex(Sprite2d pointer)
    {
        foreach (i, p; pointers)
        {
            if (p is pointer)
            {
                return i;
            }
        }
        return -1;
    }

    void layoutPointers()
    {
        if (pointers.length == 0)
        {
            return;
        }
        size_t firstPointerIndex = 0;
        size_t lastPointerIndex = pointers.length - 1;

        auto firstPointer = pointers[firstPointerIndex];
        firstPointer.x = tickContainer.boundsRect.x - firstPointer.boundsRect.halfWidth;

        if (firstPointerIndex != lastPointerIndex)
        {
            auto lastPointer = pointers[lastPointerIndex];
            lastPointer.x = tickContainer.boundsRect.right - lastPointer.boundsRect.halfWidth;

            auto mediumPointers = pointers.length - 2;
            if (mediumPointers > 0)
            {
                auto freeSpace = tickContainer.width - firstPointer.boundsRect.width - lastPointer
                    .boundsRect.width;
                auto dtX = Math.trunc(freeSpace / mediumPointers);
                double nextX = firstPointer.boundsRect.right;

                foreach (i; (firstPointerIndex + 1) .. lastPointerIndex)
                {
                    auto pointer = pointers[i];
                    pointer.x = nextX;
                    nextX += dtX;
                }
            }
        }
    }

    Sprite2d newPointer()
    {
        auto style = createStyle;
        style.isFill = true;
        style.color = theme.colorAccent;
        import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vtriangle : VTriangle;

        auto pointer = new VTriangle(20, 15, style);
        pointer.isDraggable = true;

        pointer.onDragXY = (x, y) {
            movePointer(pointer, x, y);
            return false;
        };
        return pointer;
    }

    protected void movePointer(Sprite2d pointer, double x, double y)
    {
        import std.math.operations : isClose;

        if (lastUsedPointer !is pointer)
        {
            lastUsedPointer = pointer;
        }

        auto bounds = tickContainer.boundsRect;

        const pointerIndex = pointerIndex(pointer);
        if (pointerIndex == -1)
        {
            logger.error("Not found pointer index for pointer: ", pointer.toString);
            return;
        }

        double minX = boundsRect.x - pointer.width / 2;
        double maxX = boundsRect.right - pointer.width / 2;

        if (pointers.length > 1)
        {
            if (pointerIndex > 0)
            {
                const leftPointerIndex = pointerIndex - 1;
                auto leftPointer = pointers[leftPointerIndex];
                minX = leftPointer.boundsRect.right;
            }

            //TODO overflow
            auto nextIndex = pointerIndex + 1;
            if (nextIndex < pointers.length)
            {
                auto nextPointer = pointers[pointerIndex + 1];
                maxX = nextPointer.boundsRect.x - pointer.boundsRect.width;
            }

        }

        if (x <= minX || x >= maxX)
        {
            return;
        }

        pointer.x = x;

        const pointerX = pointer.boundsRect.middleX;
        const pointerTickX = pointerX - tickContainer.boundsRect.x;

        auto value = (Math.abs(maxValue - minValue) * pointerTickX) / width;
        value = Math.clamp(value, minValue, maxValue);

        foreach (dg; onPointerMove)
        {
            dg(value, pointerIndex);
        }
    }

    Sprite2d newMinStepTick()
    {
        GraphicStyle style = createStyle;
        style.isFill = true;
        import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

        return new VConvexPolygon(tickWidth, 10, style, 0);
    }

    Sprite2d newMaxStepTick()
    {
        GraphicStyle style = createStyle;
        style.isFill = true;
        import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

        return new VConvexPolygon(tickWidth, 20, style, 0);
    }
}
