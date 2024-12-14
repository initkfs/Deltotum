module api.dm.gui.controls.pickers.time_picker;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.layouts.layout2d : Layout2d;
import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.circle_box : CircleBox;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.containers.stack_box : StackBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;

import std.conv : to;
import std.format : format;
import Math = api.dm.math;

abstract class TimeChooser : Control
{
    void delegate(dstring) onStrValue;
    void delegate(int) onNumValue;

    Sprite2d selectionSlider;

    this()
    {
        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResize = true;
        isResizedByParent = false;
    }

    abstract void setValue(int value);

    override void create()
    {
        super.create;
        import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;

        auto sliderStyle = createStyle;
        sliderStyle.isFill = true;

        selectionSlider = new class VCircle
        {
            this()
            {
                super(15, sliderStyle);
            }

            override void createTextureContent()
            {
                super.createTextureContent;
                import Math = api.dm.math;
                auto gc = canvas;
                gc.arc(0, 0, 2, 0, 2 * Math.PI);
                gc.color(theme.colorAccent);
                gc.fill;
            }
        };

        selectionSlider.isLayoutManaged = false;
        selectionSlider.isVisible = false;
        addCreate(selectionSlider);

        selectionSlider.opacity = 0.8;
    }

    override void drawContent()
    {
        super.drawContent;
        if (selectionSlider && selectionSlider.isVisible)
        {
            auto center = boundsRect.center;
            auto selectCenter = selectionSlider.boundsRect.center;
            auto color = theme.colorAccent;
            graphics.line(center.x, center.y, selectCenter.x, selectCenter.y, color);
        }
    }

    override void hide()
    {
        super.hide;
        if (selectionSlider && selectionSlider.isVisible)
        {
            selectionSlider.isVisible = false;
        }
    }

    override void show()
    {
        super.show;
        if (selectionSlider)
        {
            selectionSlider.isVisible = true;
        }
    }

}

//TODO remove duplication
class HourChooser : TimeChooser
{
    enum innerBoxRadius = 50;
    enum outerBoxRadius = 80;
    enum startAngle = 300;

    override void create()
    {
        super.create;

        import api.dm.gui.containers.circle_box : CircleBox;

        auto hour1to12Box = new CircleBox(innerBoxRadius, startAngle);
        addCreate(hour1to12Box);

        foreach (int i; 1 .. 13)
            (int j) {
            auto button = new Text(j.to!dstring);
            button.isFocusable = false;
            button.isBorder = false;
            button.isBackground = false;
            hour1to12Box.addCreate(button);
            button.onPointerPress ~= (ref e) {
                if (onStrValue)
                {
                    onStrValue(button.text);
                }

                if (onNumValue)
                {
                    onNumValue(j);
                }

                selectionSlider.xy(button.center.x - selectionSlider.boundsRect.halfWidth, button.center.y - selectionSlider
                        .boundsRect.halfHeight);
            };
        }(i);

        auto hour12to23Box = new CircleBox(outerBoxRadius, startAngle);
        addCreate(hour12to23Box);

        foreach (i; 13 .. 25)
            (size_t j) {
            dstring valueStr = j == 24 ? "00" : j.to!dstring;
            auto button = new Text(valueStr);
            button.isFocusable = false;
            button.onPointerPress ~= (ref e) {
                if (onStrValue)
                {
                    onStrValue(button.text);
                }

                if (onNumValue)
                {
                    onNumValue(button.text.to!int);
                }

                selectionSlider.xy(button.center.x - selectionSlider.boundsRect.halfWidth, button.center.y - selectionSlider
                        .boundsRect.halfHeight);
            };
            button.isBorder = false;
            button.isBackground = false;
            hour12to23Box.addCreate(button);
        }(i);
    }

    override void setValue(int v)
    {
        const sliderBounds = selectionSlider.boundsRect;
        auto angle = ((360.0 / 12) * (v % 12) + 270) % 360;

        Vec2d pos;
        if (v >= 1 && v <= 12)
        {
            pos = Vec2d.fromPolarDeg(angle, innerBoxRadius);
        }
        else
        {
            pos = Vec2d.fromPolarDeg(angle, outerBoxRadius);
        }

        selectionSlider.xy(center.x + pos.x - sliderBounds.halfWidth, center.y + pos.y - sliderBounds
                .halfHeight);
    }
}

class MinSecChooser : TimeChooser
{
    CircleBox minSec0to55Box;
    CircleBox labelBox;
    Sprite2d textLabels;

    enum innerBoxRadius = 80;
    enum startAngle = 270;
    enum buttonSize = 20;

    override void create()
    {
        super.create;

        auto style = createStyle;
        style.isFill = true;

        selectionSlider.isDraggable = true;
        selectionSlider.onDragXY = (ddx, ddy) {

            immutable sliderBounds = selectionSlider.boundsRect;
            immutable center = minSec0to55Box.boundsRect.center;

            immutable angleDeg = center.angleDeg360To(input.pointerPos);
            immutable sliderPos = center.fromPolarDeg(angleDeg, innerBoxRadius);
            selectionSlider.x = center.x + sliderPos.x - sliderBounds.halfWidth;
            selectionSlider.y = center.y + sliderPos.y - sliderBounds.halfHeight;

            double angleOffset = (angleDeg + 90) % 360;
            double angleRangeMinSec = 60 / 360.0;

            auto value = cast(int) Math.round(angleOffset * angleRangeMinSec);
            if(value > 59){
                value = 59;
            }

            if (onNumValue)
            {
                onNumValue(value);
            }

            if (onStrValue)
            {
                onStrValue(value.to!dstring);
            }

            return false;
        };

        labelBox = new CircleBox(innerBoxRadius - 15, startAngle);
        addCreate(labelBox);

        foreach (int i; 0..60)
        {
            auto minSecLabel = new Text("▪");
            labelBox.addCreate(minSecLabel);
        }

        minSec0to55Box = new CircleBox(innerBoxRadius, startAngle);
        addCreate(minSec0to55Box);

        int minValue = 0;
        foreach (int i; 0 .. 12)
            (int j, int min) {
            auto button = new Text(format("%02d", minValue).to!dstring);
            button.isFocusable = false;

            button.isBorder = false;
            button.isBackground = false;
            minSec0to55Box.addCreate(button);

            button.onPointerPress ~= (ref e) {
                if (onStrValue)
                {
                    onStrValue(button.text);
                }

                if (onNumValue)
                {
                    onNumValue(min);
                }

                if (!selectionSlider.isDrag)
                {
                    selectionSlider.x = button.boundsRect.middleX - selectionSlider.boundsRect.halfWidth;
                    selectionSlider.y = button.boundsRect.middleY - selectionSlider.boundsRect.halfHeight;
                    selectionSlider.isVisible = true;
                }
            };
            minValue += 5;
        }(i, minValue);
    }

    override void setValue(int v)
    {
        const sliderBounds = selectionSlider.boundsRect;

        auto angle = ((360.0 / 60) * v + 270) % 360;
        auto pos = Vec2d.fromPolarDeg(angle, innerBoxRadius);

        selectionSlider.xy(center.x + pos.x - sliderBounds.halfWidth, center.y + pos.y - sliderBounds
                .halfHeight);
    }

    double angleFromXY(double cx, double cy, double eventX, double eventY)
    {
        auto dy = eventY - cy;
        auto dx = eventX - cx;
        return Math.atan2(dy, dx);
    }
}

/**
 * Authors: initkfs
 */
class TimePicker : Control
{
    Text hoursLabel;
    Text minutesLabel;
    Text secsLabel;

    Button hoursUp;
    Button hoursDown;

    FontSize fontSize = fontSize.large;

    HourChooser hourChooser;

    //TODO mode
    MinSecChooser minChooser;
    MinSecChooser secChooser;

    Sprite2d chooserContainer;

    protected
    {

    }

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        this.layout.isAutoResize = true;
        this.layout.isAlignX = true;

        isBorder = true;
        //TODO sliderRadius
        paddingBottom = 10;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        auto timeValuesContainer = new HBox(2);
        timeValuesContainer.isAlignY = true;
        addCreate(timeValuesContainer);
        timeValuesContainer.enableInsets;

        hoursLabel = newTextLabel;
        hoursLabel.isFocusable = false;
        hoursLabel.onPointerPress ~= (ref e) {

            hoursLabel.backgroundUnsafe.isVisible = true;
            minutesLabel.backgroundUnsafe.isVisible = false;
            secsLabel.backgroundUnsafe.isVisible = false;

            hourChooser.showForLayout;
            hourChooser.setValue(hoursLabel.text.to!int);
            minChooser.hideForLayout;
            secChooser.hideForLayout;
        };
        minutesLabel = newTextLabel;
        minutesLabel.isFocusable = false;
        minutesLabel.onPointerPress ~= (ref e) {

            hoursLabel.backgroundUnsafe.isVisible = false;
            minutesLabel.backgroundUnsafe.isVisible = true;
            secsLabel.backgroundUnsafe.isVisible = false;

            hourChooser.hideForLayout;

            minChooser.showForLayout;
            minChooser.setValue(minutesLabel.text.to!int);

            secChooser.hideForLayout;
        };

        secsLabel = newTextLabel;
        secsLabel.onPointerPress ~= (ref e) {

            hoursLabel.backgroundUnsafe.isVisible = false;
            minutesLabel.backgroundUnsafe.isVisible = false;
            secsLabel.backgroundUnsafe.isVisible = true;

            hourChooser.hideForLayout;
            minChooser.hideForLayout;
            secChooser.showForLayout;
            secChooser.setValue(secsLabel.text.to!int);
        };

        enum spacing = 2;
        auto hoursContainer = new VBox(spacing);
        timeValuesContainer.addCreate(hoursContainer);

        enum hourMaxValue = 23;
        enum hourMinValue = 0;
        setUpDownButtons(hoursContainer, hoursLabel, () {
            incValueWrap(hoursLabel, hourMinValue, hourMaxValue, hourChooser);
        }, () {
            decValueWrap(hoursLabel, hourMinValue, hourMaxValue, hourChooser);
        });

        timeValuesContainer.addCreate(newText(":"));

        auto minContainer = new VBox(spacing);
        timeValuesContainer.addCreate(minContainer);

        enum minSecMinValue = 0;
        enum minSecMaxValue = 59;

        setUpDownButtons(minContainer, minutesLabel, () {
            incValueWrap(minutesLabel, minSecMinValue, minSecMaxValue, minChooser);
        }, () {
            decValueWrap(minutesLabel, minSecMinValue, minSecMaxValue, minChooser);
        });

        timeValuesContainer.addCreate(newText(":"));

        auto secContainer = new VBox(spacing);
        timeValuesContainer.addCreate(secContainer);

        setUpDownButtons(secContainer, secsLabel, () {
            incValueWrap(secsLabel, minSecMinValue, minSecMaxValue, secChooser);
        }, () {
            decValueWrap(secsLabel, minSecMinValue, minSecMaxValue, secChooser);
        });

        chooserContainer = new StackBox;
        addCreate(chooserContainer);

        hourChooser = new HourChooser;
        chooserContainer.addCreate(hourChooser);
        hourChooser.onNumValue = (hourValue) {
            hoursLabel.text = formatTimeValue(hourValue);
        };

        minChooser = new MinSecChooser;
        chooserContainer.addCreate(minChooser);

        minChooser.onNumValue = (numValue) {
            minutesLabel.text = formatTimeValue(numValue);
        };

        secChooser = new MinSecChooser;
        chooserContainer.addCreate(secChooser);

        secChooser.onNumValue = (numValue) {
            secsLabel.text = formatTimeValue(numValue);
        };

        hourChooser.showForLayout;

        window.showingTasks ~= (dt) { hourChooser.setValue(0); };

        minChooser.hideForLayout;
        secChooser.hideForLayout;

        reset;
    }

    protected void incValueWrap(Text label, int min, int max, TimeChooser chooser)
    {
        auto value = label.text.to!int;
        if (value == max)
        {
            value = min;
        }
        else
        {
            value++;
        }
        label.text = formatTimeValue(value);
        if (chooser && chooser.isVisible)
        {
            chooser.setValue(value);
        }
    }

    protected void decValueWrap(Text label, int min, int max, TimeChooser chooser)
    {
        auto value = label.text.to!int;
        if (value == min)
        {
            value = max;
        }
        else
        {
            value--;
        }
        label.text = formatTimeValue(value);
        if (chooser && chooser.isVisible)
        {
            chooser.setValue(value);
        }
    }

    protected void setUpDownButtons(VBox container, Text label, void delegate() onUp, void delegate() onDown)
    {

        container.isAlignX = true;

        //TODO best size?
        enum size = 15;
        auto up = new Button("▲", 5, 5);
        up.onAction ~= (ref e) { onUp(); };
        up.height = size;
        auto down = new Button("▼", 5, 5);
        down.onAction ~= (ref e) { onDown(); };
        down.height = size;
        label.invalidateListeners ~= () {
            if (label.width <= 0 || label.height <= 0)
            {
                return;
            }
            up.width = label.width;
            down.width = label.width;
        };

        container.addCreate([up, label, down]);
        up.padding = 0;
        down.padding = 0;
    }

    protected Text newText(dstring text = "")
    {
        auto t = new Text(text);
        t.fontSize = fontSize;
        return t;
    }

    protected Text newTextLabel(dstring text = "")
    {
        auto t = newText(text);
        t.isBackground = true;
        t.onCreatedBackground = (bg) {
            //TODO remove hack
            if (t is hoursLabel)
            {
                return;
            }
            bg.isVisible = false;
        };
        return t;
    }

    int getInitTimeValue()
    {
        return 0;
    }

    dstring formatTimeValue(int value)
    {
        import std.format : format;
        import std.conv : to;

        return format("%02d", value).to!dstring;
    }

    dstring getInitTimeValueStr()
    {
        return formatTimeValue(getInitTimeValue);
    }

    void reset()
    {
        hoursLabel.text = getInitTimeValueStr;
        minutesLabel.text = getInitTimeValueStr;
        secsLabel.text = getInitTimeValueStr;
    }
}
