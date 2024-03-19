module dm.gui.controls.expanders.expander;

import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.control : Control;
import dm.gui.containers.stack_box : StackBox;
import dm.kit.sprites.transitions.min_max_transition : MinMaxTransition;

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
        MinMaxTransition!double clipTransition;
        ExpanderState state = ExpanderState.opened;
        double labelAngleDt = 0;
    }

    Sprite contentContainer;

    protected void createHLayout()
    {
        import dm.kit.sprites.layouts.hlayout : HLayout;

        this.layout = new HLayout;
        layout.isAutoResize = true;
        isResizeClip = true;
        isMoveClip = true;
    }

    protected void createVLayout()
    {
        import dm.kit.sprites.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        layout.isAutoResize = true;
    }

    protected void createExpandBar(double w, double h)
    {
        import dm.gui.containers.hbox;

        expandBar = new HBox(5);
        expandBar.layout.isAlignY = true;
        expandBar.width = w;
        expandBar.height = h;
        expandBar.isBackground = true;
        expandBar.isBorder = true;
        addCreate(expandBar);

        expandBar.onPointerDown ~= (ref e) {

            if (clipTransition.isRunning)
            {
                return;
            }

            clip.x = x;
            clip.y = y;
            if (state == ExpanderState.closed)
            {
                clip.width = width;
                clip.height = expandBar.height;

                clipTransition.minValue = expandBar.height;
                clipTransition.maxValue = height;
            }
            else if (state == ExpanderState.opened)
            {
                clip.width = width;
                clip.height = height;

                clipTransition.minValue = height;
                clipTransition.maxValue = expandBar.height;
            }

            if (state == ExpanderState.closed)
            {
                contentContainer.isVisible = true;
                contentContainer.isLayoutManaged = true;
            }

            auto labelRange = clipTransition.getFrameCount;
            labelAngleDt = 90 / labelRange; 

            clipTransition.run;
        };

        createExpandLabel;
    }

    protected void createExpandLabel()
    {
        import dm.kit.sprites.textures.vectors.vtriangle : VTriangle;

        auto style = createDefaultStyle;
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

        clipTransition = new MinMaxTransition!double(0, 1, 200);
        addCreate(clipTransition);

        clipTransition.onOldNewValue ~= (oldValue, newValue) {
            clip.height = newValue;

            if(state == ExpanderState.opened){
                expandLabel.angle = expandLabel.angle - labelAngleDt;
            }else if(state == ExpanderState.closed){
                expandLabel.angle = expandLabel.angle + labelAngleDt;
            }

        };

        clipTransition.onStop ~= () {
            if (state == ExpanderState.opened)
            {
                contentContainer.isVisible = false;
                contentContainer.isLayoutManaged = false;
                state = ExpanderState.closed;
            }
            else if (state == ExpanderState.closed)
            {
                state = ExpanderState.opened;
            }
        };

        setOpen;
    }

    protected void setOpen()
    {
        expandLabel.angle = 180;
    }

    protected void setClose()
    {
        expandLabel.angle = 90;
    }

}
