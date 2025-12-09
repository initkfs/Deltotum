module api.dm.gui.controls.selects.time_pickers.dialogs.choosers.minsec_chooser;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.selects.time_pickers.dialogs.choosers.base_circular_time_chooser : BaseCircularTimeChooser;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.containers.circle_box : CircleBox;
import api.math.geom2.vec2 : Vec2f;

import Math = api.math;

import std.conv : to;
import std.format : format;

/**
 * Authors: initkfs
 */
class MinSecChooser : BaseCircularTimeChooser
{
    Container minSec0to55Box;
    bool isCreateMinSec0to55Box = true;
    Container delegate(Container) onNewMinSec0to55Box;
    void delegate(Container) onConfiguredMinSec0to55Box;
    void delegate(Container) onCreatedMinSec0to55Box;

    float labelSize = 0;
    Sprite2d labelBox;
    bool isCreateLabelBox = true;
    Sprite2d delegate(Sprite2d) onNewLabelBox;
    void delegate(Sprite2d) onConfiguredLabelBox;
    void delegate(Sprite2d) onCreatedLabelBox;

    Sprite2d textLabels;

    override void loadTheme()
    {
        loadMinSecChooserTheme;
        super.loadTheme;
    }

    void loadMinSecChooserTheme()
    {
        if (labelSize == 0)
        {
            labelSize = theme.meterTickMinorWidth * 3;
        }

        if (startAngleDeg == 0)
        {
            startAngleDeg = 270;
        }

        if (radius == 0)
        {
            radius = theme.meterThumbDiameter * 1.5;
        }
    }

    override void create()
    {
        super.create;

        auto style = createStyle;
        style.isFill = true;

        if (thumb)
        {
            thumb.isDraggable = true;
            thumb.onDragXY = (ddx, ddy) {

                immutable sliderBounds = thumb.boundsRect;
                immutable center = minSec0to55Box.boundsRect.center;

                immutable angleDeg = center.angleDeg360To(input.pointerPos);
                immutable sliderPos = center.fromPolarDeg(angleDeg, radius);
                thumb.x = center.x + sliderPos.x - sliderBounds.halfWidth;
                thumb.y = center.y + sliderPos.y - sliderBounds.halfHeight;

                float angleOffset = (angleDeg + 90) % 360;
                float angleRangeMinSec = 60 / 360.0;

                auto value = cast(int) Math.round(angleOffset * angleRangeMinSec);
                if (value > 59)
                {
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
        }

        if (!labelBox && isCreateLabelBox)
        {
            import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

            auto boxRadius = radius * 0.8;
            auto boxSize = boxRadius * 2;
            //auto box = newCircleBox(radius - 15, startAngleDeg);
            auto newLabelBox = new Texture2d(boxSize, boxSize);
            labelBox = newLabelBox;

            if (onConfiguredLabelBox)
            {
                onConfiguredLabelBox(newLabelBox);
            }

            addCreate(newLabelBox);
            if (onCreatedLabelBox)
            {
                onCreatedLabelBox(newLabelBox);
            }

            newLabelBox.createTargetRGBA32;
            newLabelBox.blendModeBlend;

            const halfLabelSize = labelSize / 2;
            auto proto = theme.circleShape(labelSize, createFillStyle);
            scope (exit)
            {
                proto.dispose;
            }

            buildInitCreate(proto);

            newLabelBox.setRendererTarget;
            scope (exit)
            {
                newLabelBox.restoreRendererTarget;
            }

            graphic.clearTransparent;

            const textureCenter = newLabelBox.center;
            const protoBounds = proto.boundsRect;

            size_t labelsCount = 60;
            float angleDiff = Math.round(360 / labelsCount);
            float currAngle = 0;
            foreach (i; 0 .. labelsCount)
            {
                auto pos = Vec2f.fromPolarDeg(currAngle, boxRadius - halfLabelSize);
                proto.xy(textureCenter.x + pos.x - protoBounds.halfWidth, textureCenter.y + pos.y - protoBounds
                        .halfHeight);
                proto.draw;
                currAngle += angleDiff;
            }

        }

        if (!minSec0to55Box && isCreateMinSec0to55Box)
        {
            auto box = newCircleBox(radius, startAngleDeg);
            minSec0to55Box = !onNewMinSec0to55Box ? box : onNewMinSec0to55Box(box);

            if (onConfiguredMinSec0to55Box)
            {
                onConfiguredMinSec0to55Box(minSec0to55Box);
            }

            addCreate(minSec0to55Box);

            if (onCreatedMinSec0to55Box)
            {
                onCreatedMinSec0to55Box(minSec0to55Box);
            }
        }

        if (minSec0to55Box)
        {
            int minValue = 0;
            foreach (int i; 0 .. 12)
                (int j, int min) {
                auto labelText = format("%02d", minValue).to!dstring;
                createNewTextLabel(labelText, minSec0to55Box);
                minValue += 5;
            }(i, minValue);
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

        auto angle = ((360.0 / 60) * v + 270) % 360;
        auto pos = Vec2f.fromPolarDeg(angle, radius);

        thumb.xy(center.x + pos.x - sliderBounds.halfWidth, center.y + pos.y - sliderBounds
                .halfHeight);
    }

    float angleFromXY(float cx, float cy, float eventX, float eventY)
    {
        auto dy = eventY - cy;
        auto dx = eventX - cx;
        return Math.atan2(dy, dx);
    }
}
