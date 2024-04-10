module dm.gui.controls.gauges.hlinear_gauge;

import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.control : Control;
import dm.gui.containers.container : Container;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import Math = dm.math;

import dm.kit.sprites.layouts.vlayout : VLayout;
import dm.kit.sprites.layouts.hlayout : HLayout;

import dm.gui.containers.hbox : HBox;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.colors.palettes.material_palette : MaterialPalette;

struct RangeInfo
{
    RGBA color;
    double range;
}

struct TickInfo
{
    double value;
    Sprite tick;
}

/**
 * Authors: initkfs
 */
class HLinearGauge : Control
{
    double minValue = 0;
    double maxValue = 0;
    double step = 0;
    double measurementUnitStep = 5;

    double tickWidth = 2;

    Sprite[] ticks;

    Container tickContainer;
    Container pointerContainer;
    HBox labelContainer;

    Sprite[] pointers;
    TickInfo[] measureTicks;

    size_t pointerCount = 4;

    RangeInfo[] rangeInfo;

    Sprite lastUsedPointer;

    double mouseWheelDeltaX = 2;

    void delegate(double newValue, size_t pointerIndex)[] onPointerMove;

    this(
        double minValue = 0,
        double maxValue = 1,
        double step = 0.05,
        double width = 150,
        double height = 50)
    {
        assert(width > 0);
        this.width = width;

        assert(height > 0);
        this.height = height;

        assert(minValue < maxValue);

        this.minValue = minValue;
        this.maxValue = maxValue;

        assert(step > 0);
        this.step = step;

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

    override void create()
    {
        super.create;

        const range = Math.abs(maxValue - minValue);

        labelContainer = new HBox;
        labelContainer.width = width;
        //TODO from font?
        labelContainer.height = 15;
        addCreate(labelContainer);

        auto rangeContainer = new HBox;
        rangeContainer.width = width;
        addCreate(rangeContainer);

        auto colorStep = range / 4;
        //TODO from settings
        rangeInfo = [
            RangeInfo(RGBA.web(MaterialPalette.redA700), colorStep),
            RangeInfo(RGBA.web(MaterialPalette.orangeA700), colorStep),
            RangeInfo(RGBA.web(MaterialPalette.yellowA700), colorStep),
            RangeInfo(RGBA.web(MaterialPalette.greenA700), colorStep)
        ];

        foreach (r; rangeInfo)
        {
            auto style = createDefaultStyle;
            style.isFill = true;
            style.color = r.color;
            import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            auto rectWidth = (r.range * (width + tickWidth)) / range;
            auto rect = new VRegularPolygon(rectWidth, 5, style, 0);
            rangeContainer.addCreate(rect);
        }

        const ticksCount = Math.trunc(range / step);

        const tickSpace = Math.round(width - ticksCount * tickWidth) / ticksCount;
        tickContainer = new HBox(tickSpace);
        tickContainer.width = width;
        tickContainer.layout.isAlignY = true;
        addCreate(tickContainer);

        //+1 0-tick
        foreach (i; 0 .. ticksCount + 1)
        {
            bool isMeasureUnit = (i == 0 || i % measurementUnitStep == 0);
            auto tick = isMeasureUnit ? newMaxStepTick : newMinStepTick;
            tickContainer.addCreate(tick);
            if (isMeasureUnit)
            {
                double value = (i * maxValue) / ticksCount;
                measureTicks ~= TickInfo(value, tick);
            }
            ticks ~= tick;
        }

        pointerContainer = new HBox;
        pointerContainer.width = tickContainer.width;
        addCreate(pointerContainer);

        double maxHeight = 0;
        foreach (i; 0 .. pointerCount)
        {
            auto pointer = newPointer;
            if(pointer.height > maxHeight){
                maxHeight = pointer.height;
            }
            pointer.isLayoutManaged = false;
            pointerContainer.addCreate(pointer);
            pointers ~= pointer;
        }
        pointerContainer.height = maxHeight;

        const tickInfoSpace = width / measureTicks.length;
        labelContainer.spacing = tickInfoSpace;

        tickContainer.applyLayout;

        foreach (tickInfo; measureTicks)
        {
            import dm.gui.controls.texts.text : Text;
            import dm.kit.assets.fonts.font_size : FontSize;

            import std.conv : to;

            dstring text = tickInfo.value.to!dstring;
            auto label = new Text(text);
            label.isLayoutManaged = false;
            label.fontSize = FontSize.small;
            label.x = tickInfo.tick.boundsInParent.x;
            labelContainer.addCreate(label);
            label.x = tickInfo.tick.boundsInParent.x - label.bounds.halfWidth;
        }

        layoutPointers;
    }

    private size_t pointerIndex(Sprite pointer)
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
        firstPointer.x = tickContainer.bounds.x - firstPointer.bounds.halfWidth;

        if (firstPointerIndex != lastPointerIndex)
        {
            auto lastPointer = pointers[lastPointerIndex];
            lastPointer.x = tickContainer.bounds.right - lastPointer.bounds.halfWidth;

            auto mediumPointers = pointers.length - 2;
            if (mediumPointers > 0)
            {
                auto freeSpace = tickContainer.width - firstPointer.bounds.width - lastPointer
                    .bounds.width;
                auto dtX = Math.trunc(freeSpace / mediumPointers);
                double nextX = firstPointer.bounds.right;

                foreach (i; (firstPointerIndex + 1) .. lastPointerIndex)
                {
                    auto pointer = pointers[i];
                    pointer.x = nextX;
                    nextX += dtX;
                }
            }
        }
    }

    Sprite newPointer()
    {
        auto style = createDefaultStyle;
        style.isFill = true;
        style.color = graphics.theme.colorAccent;
        import dm.kit.sprites.textures.vectors.shapes.vtriangle : VTriangle;

        auto pointer = new VTriangle(20, 15, style);
        pointer.isDraggable = true;

        pointer.onDrag = (x, y) {
            movePointer(pointer, x, y);
            return false;
        };
        return pointer;
    }

    protected void movePointer(Sprite pointer, double x, double y)
    {
        import std.math.operations : isClose;

        if (lastUsedPointer !is pointer)
        {
            lastUsedPointer = pointer;
        }

        auto bounds = tickContainer.bounds;

        const pointerIndex = pointerIndex(pointer);
        if (pointerIndex == -1)
        {
            logger.error("Not found pointer index for pointer: ", pointer.toString);
            return;
        }

        double minX = bounds.x - pointer.width / 2;
        double maxX = bounds.right - pointer.width / 2;

        if (pointers.length > 1)
        {
            if (pointerIndex > 0)
            {
                const leftPointerIndex = pointerIndex - 1;
                auto leftPointer = pointers[leftPointerIndex];
                minX = leftPointer.bounds.right;
            }

            //TODO overflow
            auto nextIndex = pointerIndex + 1;
            if (nextIndex < pointers.length)
            {
                auto nextPointer = pointers[pointerIndex + 1];
                maxX = nextPointer.bounds.x - pointer.bounds.width;
            }

        }

        if (x <= minX || x >= maxX)
        {
            return;
        }

        pointer.x = x;

        const pointerX = pointer.bounds.middleX;
        const pointerTickX = pointerX - tickContainer.bounds.x;

        auto value = (Math.abs(maxValue - minValue) * pointerTickX) / width;
        value = Math.clamp(value, minValue, maxValue);

        foreach (dg; onPointerMove)
        {
            dg(value, pointerIndex);
        }
    }

    Sprite newMinStepTick()
    {
        GraphicStyle style = createDefaultStyle;
        style.isFill = true;
        import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

        return new VRegularPolygon(tickWidth, 10, style, 0);
    }

    Sprite newMaxStepTick()
    {
        GraphicStyle style = createDefaultStyle;
        style.isFill = true;
        import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

        return new VRegularPolygon(tickWidth, 20, style, 0);
    }
}
