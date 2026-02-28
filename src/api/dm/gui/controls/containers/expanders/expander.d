module api.dm.gui.controls.containers.expanders.expander;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.center_box : CenterBox;
import api.dm.kit.sprites2d.tweens.min_max_tween : MinMaxTween;

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

    Control expandBar;

    bool isCreateExpandBar = true;
    Control delegate(Control) onNewExpandBar;
    void delegate(Control) onConfiguredExpandBar;
    void delegate(Control) onCreatedExpandBar;

    Sprite2d expandButton;

    bool isCreateExpandButton = true;
    Sprite2d delegate(Sprite2d) onNewExpandButton;
    void delegate(Sprite2d) onConfiguredExpandButton;
    void delegate(Sprite2d) onCreatedExpandButton;

    MinMaxTween!float clipTween;

    protected
    {
        ExpanderState state = ExpanderState.opened;
        float labelAngleDt = 0;
    }

    this()
    {
        super();
        isMoveClip = true;
        //isResizeClip = true;
    }

    Sprite2d contentContainer;

    protected void createHLayout()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        this.layout = new HLayout;
        layout.isParentSizeReduce = true;
        layout.isAutoResize = true;
    }

    protected void createVLayout()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        layout.isParentSizeReduce = true;
        layout.isAutoResize = true;
    }

    protected void createExpandBar(float w, float h)
    {
        auto expBar = newExpandBar;
        expandBar = (!onNewExpandBar) ? expBar : onNewExpandBar(expBar);

        configureExpandBar(expandBar);

        expandBar.onPointerPress ~= (ref e) {

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

        if (onConfiguredExpandBar)
        {
            onConfiguredExpandBar(expBar);
        }

        addCreate(expandBar);

        expandBar.enablePadding;

        if (onCreatedExpandBar)
        {
            onCreatedExpandBar(expandBar);
        }

        createExpandButton;
    }

    Control newExpandBar()
    {
        import api.dm.gui.controls.containers.hbox;

        return new class HBox
        {
            import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

            this()
            {
                super(0);
            }

            override protected GraphicStyle createBackgroundStyle() => createSelectStyle;
        };
    }

    void configureExpandBar(Control expandBar)
    {
        if (expandBar.hasLayout)
        {
            expandBar.layout.isAlignY = true;
        }
        expandBar.width = w;
        expandBar.height = h;
        expandBar.isBackground = true;
        expandBar.isBorder = true;
    }

    protected void createExpandButton()
    {
        auto button = newExpandButton;
        expandButton = !onNewExpandButton ? button : onNewExpandButton(button);

        button.id = "expand_button";

        if (onConfiguredExpandButton)
        {
            onConfiguredExpandButton(expandButton);
        }

        auto root = expandBar ? expandBar : this;
        root.addCreate(expandButton);

        expandButton.enablePadding;
        //TODO from layout
        expandButton.margin.left = expandButton.halfWidth;

        if (onCreatedExpandButton)
        {
            onCreatedExpandButton(expandButton);
        }
    }

    Sprite2d newExpandButton()
    {
        import api.dm.kit.sprites2d.textures.vectors.shapes.vtriangle : VTriangle;

        auto style = createFillStyle;

        const size = theme.iconSize / 1.5;

        return new VTriangle(size, size, style);
    }

    protected void createContentBar()
    {
        contentContainer = new CenterBox;
        addCreate(contentContainer);
    }

    override void create()
    {
        super.create;

        float w = width;
        float h = height;
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

        clipTween = new MinMaxTween!float(0, 1, 250);
        addCreate(clipTween);

        clipTween.onOldNewValue ~= (oldValue, newValue) {
            clip.height = newValue;

            if (state == ExpanderState.opened)
            {
                if (expandPosition == ExpanderPosition.top)
                {
                    expandButton.angle = expandButton.angle - labelAngleDt;
                }
                else if (expandPosition == ExpanderPosition.bottom)
                {
                    expandButton.angle = expandButton.angle + labelAngleDt;
                }
            }
            else if (state == ExpanderState.closed)
            {
                if (expandPosition == ExpanderPosition.top)
                {
                    expandButton.angle = expandButton.angle + labelAngleDt;
                }
                else if (expandPosition == ExpanderPosition.bottom)
                {
                    expandButton.angle = expandButton.angle - labelAngleDt;
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
            expandButton.angle = 180;
        }
        else if (expandPosition == ExpanderPosition.bottom)
        {
            expandButton.angle = 0;
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
            expandButton.angle = 90;
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
