module api.dm.gui.controls.selects.time_pickers.dialogs.choosers.hour_chooser;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.selects.time_pickers.dialogs.choosers.base_circular_time_chooser : BaseCircularTimeChooser;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.vec2 : Vec2d;

import std.conv : to;

/**
 * Authors: initkfs
 */
class HourChooser : BaseCircularTimeChooser
{
    float outerBoxRadius = 0;

    Container hour1to12Box;
    bool isCreateHour1To12Box = true;
    Container delegate(Container) onNewHour1to12Box;
    void delegate(Container) onConfiguredHour1to12Box;
    void delegate(Container) onCreatedHour1to12Box;

    Container hour12to23Box;
    bool isCreateHour12to23Box = true;
    Container delegate(Container) onNewHour12to23Box;
    void delegate(Container) onConfiguredHour12to23Box;
    void delegate(Container) onCreatedHour12to23Box;

    override void initialize()
    {
        super.initialize;

        if (startAngleDeg == 0)
        {
            startAngleDeg = 300;
        }

        if (outerBoxRadius == 0)
        {
            outerBoxRadius = radius * 1.5;
        }
    }

    override void create()
    {
        super.create;

        if (!hour1to12Box && isCreateHour1To12Box)
        {
            auto box = newCircleBox(radius, startAngleDeg);
            hour1to12Box = !onNewHour1to12Box ? box : onNewHour1to12Box(box);

            if (onConfiguredHour1to12Box)
            {
                onConfiguredHour1to12Box(hour1to12Box);
            }

            addCreate(hour1to12Box);

            if (onCreatedHour1to12Box)
            {
                onCreatedHour1to12Box(hour1to12Box);
            }
        }

        if (hour1to12Box)
        {
            foreach (int i; 1 .. 13)
                (int j) {

                auto hourStr = j.to!dstring;
                createNewTextLabel(hourStr, hour1to12Box);
            }(i);
        }

        if (!hour12to23Box && isCreateHour12to23Box)
        {
            auto box = newCircleBox(outerBoxRadius, startAngleDeg);
            hour12to23Box = !onNewHour12to23Box ? box : onNewHour12to23Box(box);

            if (onConfiguredHour12to23Box)
            {
                onConfiguredHour12to23Box(hour12to23Box);
            }

            addCreate(hour12to23Box);

            if (onCreatedHour12to23Box)
            {
                onCreatedHour12to23Box(hour12to23Box);
            }
        }

        if (hour12to23Box)
        {
            foreach (i; 13 .. 25)
                (size_t j) {
                dstring houtStr = j == 24 ? "00" : j.to!dstring;
                createNewTextLabel(houtStr, hour12to23Box);
            }(i);
        }
    }

    override void value(int v)
    {
        if (!thumb)
        {
            return;
        }

        if (!thumb.isVisible)
        {
            showThumb;
        }

        const sliderBounds = thumb.boundsRect;
        auto angle = ((360.0 / 12) * (v % 12) + 270) % 360;

        Vec2d pos;
        if (v >= 1 && v <= 12)
        {
            pos = Vec2d.fromPolarDeg(angle, radius);
        }
        else
        {
            pos = Vec2d.fromPolarDeg(angle, outerBoxRadius);
        }

        thumb.xy(center.x + pos.x - sliderBounds.halfWidth, center.y + pos.y - sliderBounds
                .halfHeight);
    }
}
