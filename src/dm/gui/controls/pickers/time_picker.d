module dm.gui.controls.pickers.time_picker;

import dm.gui.controls.control : Control;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.layouts.layout : Layout;
import dm.kit.sprites.layouts.hlayout : HLayout;
import dm.gui.containers.hbox : HBox;
import dm.gui.containers.circle_box : CircleBox;
import dm.gui.containers.vbox : VBox;
import dm.gui.containers.stack_box : StackBox;
import dm.gui.controls.texts.text : Text;
import dm.kit.assets.fonts.font_size : FontSize;
import dm.gui.controls.buttons.button : Button;

import std.conv : to;
import std.format : format;
import Math = dm.math;

//TODO remove duplication
class HourChooser : Control
{

    void delegate(dstring) onStrValue;
    void delegate(int) onNumValue;

    this()
    {
        import dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        import dm.gui.containers.circle_box : CircleBox;

        enum innerBoxRadius = 50;
        enum outerBoxRadius = 80;
        enum startAngle = 300;
        enum buttonSize = 20;

        auto hour1to12Box = new CircleBox(innerBoxRadius, startAngle);
        addCreate(hour1to12Box);

        foreach (int i; 1 .. 13)(int j)
        {
            auto button = new Button(j.to!dstring, buttonSize, buttonSize);
            button.isBorder = false;
            button.isBackground = false;
            hour1to12Box.addCreate(button);
            button.onAction = (ref e) {
                if (onStrValue)
                {
                    onStrValue(button.text);
                }

                if(onNumValue){
                    onNumValue(j);
                }
            };
        }(i);

        auto hour12to23Box = new CircleBox(outerBoxRadius, startAngle);
        addCreate(hour12to23Box);

        foreach (i; 13 .. 25)(size_t j)
        {
            dstring valueStr = j == 24 ? "00" : j.to!dstring;
            auto button = new Button(valueStr, buttonSize, buttonSize);
            button.onAction = (ref e) {
                if (onStrValue)
                {
                    onStrValue(button.text);
                }

                if(onNumValue){
                    onNumValue(button.text.to!int);
                }
            };
            button.isBorder = false;
            button.isBackground = false;
            hour12to23Box.addCreate(button);
        }(i);
    }
}

class MinSecChooser : Control
{
    void delegate(dstring) onStrValue;
    void delegate(int) onNumValue;

    CircleBox minSec0to55Box;

    this()
    {
        import dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        enum innerBoxRadius = 80;
        enum startAngle = 270;
        enum buttonSize = 20;

        import dm.kit.sprites.textures.vectors.vcircle : VCircle;

        auto style = createDefaultStyle;
        style.isFill = true;

        auto selectionSlider = new VCircle(15, style);
        selectionSlider.isDraggable = true;
        selectionSlider.onDrag = (ddx, ddy) {

            immutable sliderBounds = selectionSlider.bounds;
            immutable center = minSec0to55Box.bounds.center;

            immutable angleDeg = center.angleDeg360To(input.mousePos);
            immutable sliderPos = center.fromPolarDeg(angleDeg, innerBoxRadius);
            selectionSlider.x = center.x + sliderPos.x - sliderBounds.halfWidth;
            selectionSlider.y = center.y + sliderPos.y - sliderBounds.halfHeight;

            double angleOffset = (angleDeg + 90) % 360;
            double angleRangeMinSec = 59 / 360.0;

            auto value = cast(int) Math.round(angleOffset * angleRangeMinSec);
            if (onNumValue)
            {
                onNumValue(value);
            }

            if(onStrValue){
                onStrValue(value.to!dstring);
            }

            return false;
        };
        selectionSlider.isLayoutManaged = false;
        selectionSlider.isVisible = false;
        addCreate(selectionSlider);

        minSec0to55Box = new CircleBox(innerBoxRadius, startAngle);
        addCreate(minSec0to55Box);

        int minValue = 0;
        foreach (int i; 0 .. 12)
            (int j, int min) {
            auto button = new Button(format("%02d", minValue).to!dstring, buttonSize, buttonSize);

            button.isBorder = false;
            button.isBackground = false;
            minSec0to55Box.addCreate(button);

            button.onAction = (ref e) {
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
                    selectionSlider.x = button.bounds.middleX - selectionSlider.bounds.halfWidth;
                    selectionSlider.y = button.bounds.middleY - selectionSlider.bounds.halfHeight;
                    selectionSlider.isVisible = true;
                }
            };
            minValue += 5;
        }(i, minValue);
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

    FontSize fontSize = fontSize.medium;

    HourChooser hourChooser;
    MinSecChooser minSecChooser;

    protected
    {

    }

    this()
    {
        import dm.kit.sprites.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        this.layout.isAutoResize = true;
        this.layout.isAlignX = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        auto timeValuesContainer = new HBox(2);
        addCreate(timeValuesContainer);
        hoursLabel = newText;
        hoursLabel.isFocusable = false;
        hoursLabel.onPointerDown ~= (ref e) {
            hourChooser.isVisible = true;
            minSecChooser.isVisible = false;
        };
        minutesLabel = newText;
        minutesLabel.isFocusable = false;
        minutesLabel.onPointerDown ~= (ref e) {
            hourChooser.isVisible = false;
            minSecChooser.isVisible = true;
        };
        secsLabel = newText;
        secsLabel.onPointerDown ~= (ref e) {
            hourChooser.isVisible = false;
            minSecChooser.isVisible = true;
        };

        timeValuesContainer.addCreate([
            hoursLabel,
            newText(":"),
            minutesLabel,
            newText(":"),
            secsLabel
        ]);

        StackBox chooserContainer = new StackBox;
        addCreate(chooserContainer);

        hourChooser = new HourChooser;
        chooserContainer.addCreate(hourChooser);
        hourChooser.onNumValue = (hourValue) { hoursLabel.text = formatTimeValue(hourValue); };

        minSecChooser = new MinSecChooser;
        chooserContainer.addCreate(minSecChooser);

        minSecChooser.onNumValue = (numValue) {
            minutesLabel.text = formatTimeValue(numValue);
        };

        hourChooser.isVisible = true;
        minSecChooser.isVisible = false;

        reset;
    }

    protected Text newText(dstring text = "")
    {
        auto t = new Text(text);
        t.fontSize = fontSize;
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
