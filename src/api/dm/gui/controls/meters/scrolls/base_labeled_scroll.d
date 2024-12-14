module api.dm.gui.controls.meters.scrolls.base_labeled_scroll;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.meters.scrolls.base_mono_scroll : BaseMonoScroll;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.texts.text : Text;
import api.math.position : Position;

/**
 * Authors: initkfs
 */
abstract class BaseLabeledScroll : BaseMonoScroll
{
    protected
    {
        Text label;
    }

    Position labelPos = Position.topCenter;

    bool isCreateLabel;
    Text delegate(Text) onNewLabel;
    void delegate(Text) onCreatedLabel;

    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);
    }

    Text newLabel()
    {
        auto label = new Text("0");
        label.isLayoutManaged = false;
        label.setSmallSize;
        return label;
    }

    override void create()
    {
        super.create;

        if (!label && isCreateLabel)
        {
            auto l = newLabel;
            label = onNewLabel ? onNewLabel(l) : l;
            addCreate(label);
            if (onCreatedLabel)
            {
                onCreatedLabel(label);
            }
        }

        invalidateListeners ~= () {

            if (!isCreated || !thumb || !label)
            {
                return;
            }

            updateLabelPos;
        };
    }

    void updateLabelPos()
    {
        import api.math.geom2.vec2 : Vec2d;

        Vec2d newPos;

        const thumbBounds = thumb.boundsRect;

        switch (labelPos) with (Position)
        {
            case topCenter:
                newPos = Vec2d(thumbBounds.middleX - label.halfWidth, thumbBounds.y - label
                        .height);
                break;
            case bottomCenter:
                newPos = Vec2d(thumbBounds.middleX - label.halfWidth, thumbBounds.bottom);
                break;
            case centerLeft:
                newPos = Vec2d(thumbBounds.x - label.width, thumbBounds.middleY - label.halfHeight);
                break;
            case centerRight:
                newPos = Vec2d(thumbBounds.right, thumbBounds.middleY - label.halfHeight);
                break;
            default:
                import std.conv : text;

                throw new Exception(text("Not supported position: ", labelPos));
                break;
        }

        label.pos = newPos;
    }

    void setLabelValue(double v)
    {
        if (!label || !label.isVisible)
        {
            return;
        }

        import std.format : format;

        label.text = format("%.2f", v);
    }

    alias value = BaseMonoScroll.value;

    override bool value(double v, bool isTriggerListeners = true)
    {
        if (!super.value(v, isTriggerListeners))
        {
            return false;
        }

        setLabelValue(v);

        return true;
    }
}
