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
import dm.kit.graphics.colors.rgba : RGBA;
import dm.math.vector2 : Vector2;

import std.conv : to;
import std.format : format;
import Math = dm.math;

class TimeChooser : Control
{
    void delegate(dstring) onStrValue;
    void delegate(int) onNumValue;

    Sprite selectionSlider;

    this()
    {
        import dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResize = true;
        isResizedByParent = false;
    }

    override void create()
    {
        super.create;
        import dm.kit.sprites.textures.vectors.shapes.vcircle : VCircle;

        auto style = createDefaultStyle;
        style.isFill = true;

        selectionSlider = new VCircle(15, style);
        selectionSlider.isLayoutManaged = false;
        selectionSlider.isVisible = false;
        addCreate(selectionSlider);
    }

    override void drawContent()
    {
        super.drawContent;
        if (selectionSlider && selectionSlider.isVisible)
        {
            auto center = bounds.center;
            auto selectCenter = selectionSlider.bounds.center;
            auto color = graphics.theme.colorAccent;
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

        import dm.gui.containers.circle_box : CircleBox;

        auto hour1to12Box = new CircleBox(innerBoxRadius, startAngle);
        addCreate(hour1to12Box);

        foreach (int i; 1 .. 13)
            (int j) {
            auto button = new Text(j.to!dstring);
            button.isBorder = false;
            button.isBackground = false;
            hour1to12Box.addCreate(button);
            button.onPointerDown ~= (ref e) {
                if (onStrValue)
                {
                    onStrValue(button.text);
                }

                if (onNumValue)
                {
                    onNumValue(j);
                }

                selectionSlider.xy(button.center.x - selectionSlider.bounds.halfWidth, button.center.y - selectionSlider
                        .bounds.halfHeight);
            };
        }(i);

        auto hour12to23Box = new CircleBox(outerBoxRadius, startAngle);
        addCreate(hour12to23Box);

        foreach (i; 13 .. 25)
            (size_t j) {
            dstring valueStr = j == 24 ? "00" : j.to!dstring;
            auto button = new Text(valueStr);
            button.onPointerDown ~= (ref e) {
                if (onStrValue)
                {
                    onStrValue(button.text);
                }

                if (onNumValue)
                {
                    onNumValue(button.text.to!int);
                }

                selectionSlider.xy(button.center.x - selectionSlider.bounds.halfWidth, button.center.y - selectionSlider
                        .bounds.halfHeight);
            };
            button.isBorder = false;
            button.isBackground = false;
            hour12to23Box.addCreate(button);
        }(i);
    }

    void setValue(int v)
    {
        const sliderBounds = selectionSlider.bounds;
        auto angle = ((360.0 / 12) * (v % 12) + 270) % 360;

        Vector2 pos;
        if (v >= 1 && v <= 12)
        {
            pos = Vector2.fromPolarDeg(angle, innerBoxRadius);
        }
        else
        {
            pos = Vector2.fromPolarDeg(angle, outerBoxRadius);
        }

        selectionSlider.xy(center.x + pos.x - sliderBounds.halfWidth, center.y + pos.y - sliderBounds
                .halfHeight);
    }
}

class MinSecChooser : TimeChooser
{
    CircleBox minSec0to55Box;
    Sprite textLabels;

    enum innerBoxRadius = 80;
    enum startAngle = 270;
    enum buttonSize = 20;

    override void create()
    {
        super.create;

        auto style = createDefaultStyle;
        style.isFill = true;

        selectionSlider.isDraggable = true;
        selectionSlider.onDrag = (ddx, ddy) {

            immutable sliderBounds = selectionSlider.bounds;
            immutable center = minSec0to55Box.bounds.center;

            immutable angleDeg = center.angleDeg360To(input.mousePos);
            immutable sliderPos = center.fromPolarDeg(angleDeg, innerBoxRadius);
            selectionSlider.x = center.x + sliderPos.x - sliderBounds.halfWidth;
            selectionSlider.y = center.y + sliderPos.y - sliderBounds.halfHeight;

            double angleOffset = (angleDeg + 90) % 360;
            double angleRangeMinSec = 60 / 360.0;

            auto value = cast(int) Math.round(angleOffset * angleRangeMinSec);
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

        minSec0to55Box = new CircleBox(innerBoxRadius, startAngle);
        addCreate(minSec0to55Box);

        int minValue = 0;
        foreach (int i; 0 .. 12)
            (int j, int min) {
            auto button = new Text(format("%02d", minValue).to!dstring);

            button.isBorder = false;
            button.isBackground = false;
            minSec0to55Box.addCreate(button);

            button.onPointerDown ~= (ref e) {
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

    void setValue(int v)
    {
        const sliderBounds = selectionSlider.bounds;

        auto angle = ((360.0 / 60) * v + 270) % 360;
        auto pos = Vector2.fromPolarDeg(angle, innerBoxRadius);

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

    FontSize fontSize = fontSize.large;

    HourChooser hourChooser;

    //TODO mode
    MinSecChooser minChooser;
    MinSecChooser secChooser;

    Sprite chooserContainer;

    protected
    {

    }

    this()
    {
        import dm.kit.sprites.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        this.layout.isAutoResize = true;
        this.layout.isAlignX = true;

        isBorder = true;
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
        timeValuesContainer.enableInsets;

        hoursLabel = newTextLabel;
        hoursLabel.isFocusable = false;
        hoursLabel.onPointerDown ~= (ref e) {

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
        minutesLabel.onPointerDown ~= (ref e) {

            hoursLabel.backgroundUnsafe.isVisible = false;
            minutesLabel.backgroundUnsafe.isVisible = true;
            secsLabel.backgroundUnsafe.isVisible = false;

            hourChooser.hideForLayout;

            minChooser.showForLayout;
            minChooser.setValue(minutesLabel.text.to!int);

            secChooser.hideForLayout;
        };

        secsLabel = newTextLabel;
        secsLabel.onPointerDown ~= (ref e) {

            hoursLabel.backgroundUnsafe.isVisible = false;
            minutesLabel.backgroundUnsafe.isVisible = false;
            secsLabel.backgroundUnsafe.isVisible = true;

            hourChooser.hideForLayout;
            minChooser.hideForLayout;
            secChooser.showForLayout;
            secChooser.setValue(secsLabel.text.to!int);
        };

        timeValuesContainer.addCreate([
            hoursLabel,
            newText(":"),
            minutesLabel,
            newText(":"),
            secsLabel
        ]);

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

        window.showingTasks ~= (dt){
             hourChooser.setValue(0);
        };

        minChooser.hideForLayout;
        secChooser.hideForLayout;

        reset;
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
