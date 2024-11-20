module api.dm.gui.controls.expanders.expander;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.control : Control;
import api.dm.gui.containers.stack_box : StackBox;
import api.dm.kit.sprites.tweens.min_max_tween : MinMaxTween;

enum ExpanderPosition
{
    top,
    bottom,
    left,
    right
}

enum ExpanderState
{
    opened,
    closed
}

/**
 * Authors: initkfs
 */
class Expander : Control
{
    ExpanderPosition expandPosition = ExpanderPosition.top;

    protected
    {
        Control expandBar;
        Sprite expandLabel;
        MinMaxTween!double clipTween;
        ExpanderState state = ExpanderState.opened;
        double labelAngleDt = 0;
    }

    this()
    {
        super();
        isMoveClip = true;
        //isResizeClip = true;
    }

    Sprite contentContainer;

    protected void createHLayout()
    {
        import api.dm.kit.sprites.layouts.hlayout : HLayout;

        this.layout = new HLayout;
        layout.isParentSizeReduce = true;
        layout.isAutoResize = true;
    }

    protected void createVLayout()
    {
        import api.dm.kit.sprites.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        layout.isParentSizeReduce = true;
        layout.isAutoResize = true;
    }

    protected void createExpandBar(double w, double h)
    {
        import api.dm.gui.containers.hbox;

        expandBar = new HBox(5);
        expandBar.layout.isAlignY = true;
        expandBar.width = w;
        expandBar.height = h;
        expandBar.isBackground = true;
        expandBar.isBorder = true;
        addCreate(expandBar);

        expandBar.onPointerDown ~= (ref e) {

            if (clipTween.isRunning)
            {
                return;
            }

            if (state == ExpanderState.closed)
            {
                contentContainer.isVisible = true;
                contentContainer.isLayoutManaged = true;
                applyLayout;
            }

            clip.x = x;
            clip.y = y;
            if (state == ExpanderState.closed)
            {
                clip.width = width;
                clip.height = expandBar.height;

                clipTween.minValue = expandBar.height;
                clipTween.maxValue = height;
            }
            else if (state == ExpanderState.opened)
            {
                clip.width = width;
                clip.height = height;

                clipTween.minValue = height;
                clipTween.maxValue = expandBar.height;
            }

            auto labelRange = clipTween.frameCount;
            labelAngleDt = 90 / labelRange;

            clipTween.run;
        };

        createExpandLabel;
    }

    protected void createExpandLabel()
    {
        import api.dm.kit.sprites.textures.vectors.shapes.vtriangle : VTriangle;

        auto style = createStyle;
        style.isFill = true;
        auto label = new VTriangle(10, 10, style);
        label.id = "expand_label";
        label.margin.left = 10;
        expandBar.addCreate(label);
        expandLabel = label;
    }

    protected void createContentBar()
    {
        contentContainer = new StackBox;
        addCreate(contentContainer);
    }

    override void create()
    {
        super.create;

        double w = width;
        double h = height;
        if (w == 0)
        {
            w = 15;
        }
        if (h == 0)
        {
            h = 15;
        }

        final switch (expandPosition) with (ExpanderPosition)
        {
            case top:
                createVLayout;
                createExpandBar(w, 15);
                expandBar.isHGrow = true;
                createContentBar;
                break;
            case bottom:
                createVLayout;
                createContentBar;
                createExpandBar(w, 15);
                expandBar.isHGrow = true;
                break;
            case left:
                createHLayout;
                createExpandBar(15, h);
                expandBar.isVGrow = true;
                createContentBar;
                break;
            case right:
                createHLayout;
                createContentBar;
                createExpandBar(15, h);
                expandBar.isVGrow = true;
                break;
        }

        clipTween = new MinMaxTween!double(0, 1, 250);
        addCreate(clipTween);

        clipTween.onOldNewValue ~= (oldValue, newValue) {
            clip.height = newValue;

            if (state == ExpanderState.opened)
            {
                if(expandPosition == ExpanderPosition.top){
                    expandLabel.angle = expandLabel.angle - labelAngleDt;
                }else if(expandPosition == ExpanderPosition.bottom){
                    expandLabel.angle = expandLabel.angle + labelAngleDt;
                }
            }
            else if (state == ExpanderState.closed)
            {
                if(expandPosition == ExpanderPosition.top){
                    expandLabel.angle = expandLabel.angle + labelAngleDt;
                }else if(expandPosition == ExpanderPosition.bottom){
                    expandLabel.angle = expandLabel.angle - labelAngleDt;
                }
            }

        };

        clipTween.onStop ~= () {
            if (state == ExpanderState.opened)
            {
                contentContainer.isVisible = false;
                contentContainer.isLayoutManaged = false;
                state = ExpanderState.closed;
                clip.width = 0;
                clip.height = 0;
            }
            else if (state == ExpanderState.closed)
            {
                state = ExpanderState.opened;
            }
        };

        open;
    }

    void open()
    {
        if (expandPosition == ExpanderPosition.top)
        {
            expandLabel.angle = 180;
        }
        else if (expandPosition == ExpanderPosition.bottom)
        {
            expandLabel.angle = 0;
        }

        clip.x = x;
        clip.y = y;
        clip.width = width;
        clip.height = height;
        contentContainer.isVisible = true;
        contentContainer.isLayoutManaged = true;
        state = ExpanderState.opened;
    }

    void close()
    {
        if (expandPosition == ExpanderPosition.top || expandPosition == ExpanderPosition.bottom)
        {
            expandLabel.angle = 90;
        }

        clip.x = x;
        clip.y = y;
        clip.width = width;
        clip.height = expandBar.height;
        contentContainer.isVisible = false;
        contentContainer.isLayoutManaged = false;
        state = ExpanderState.closed;
    }

}
