module api.dm.gui.interacts.dialogs.gui_dialog;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.kit.events.event_kit_target : EventKitPhase;
import api.dm.gui.controls.containers.vbox : VBox;

enum DialogButton
{
    ok,
    cancel
}

/**
 * Authors: initkfs
 */
class GuiDialog : Container
{
    void delegate() onAction;
    void delegate() onExit;

    bool isOnceAction;

    protected
    {
        Text _title;
        Text _message;
    }

    Text delegate() titleFactory;
    Text delegate() messageFactory;
    Container delegate() contentFactory;
    Container delegate() buttonPanelFactory;
    Button delegate(DialogButton) buttonFactory;

    void delegate(Text) onTitleCreate;
    void delegate(Text) onMessageCreate;
    void delegate(Container) onContentCreate;
    void delegate(Container) onButtonPanelCreate;
    void delegate(Button) onButtonCreate;

    this(float width = 100, float height = 150)
    {
        _width = width;
        _height = height;

        isBackground = true;
        isBorder = true;
        isLayoutManaged = false;
    }

    override void initialize()
    {
        super.initialize;

        if (!titleFactory)
        {
            titleFactory = () {
                auto t = new Text("Title");
                t.isHGrow = true;
                return t;
            };
        }

        if (!messageFactory)
        {
            messageFactory = () {
                auto message = new Text("Message");
                message.isGrow = true;
                return message;
            };
        }

        if (!contentFactory)
        {
            contentFactory = () {
                auto root = new VBox(5);
                root.isGrow = true;
                root.width = width;
                root.height = height;
                return root;
            };
        }

        if (!buttonPanelFactory)
        {
            buttonPanelFactory = () {
                import api.dm.gui.controls.containers.hbox : HBox;

                auto panel = new HBox(5);
                return panel;
            };
        }

        if (!buttonFactory)
        {
            buttonFactory = (DialogButton buttonType) {
                Button button;
                final switch (buttonType) with (DialogButton)
                {
                    case ok:
                        button = new Button("OK");
                        break;
                    case cancel:
                        button = new Button("Cancel");
                        break;
                }
                return button;
            };
        }
    }

    override void onEventPhase(ref PointerEvent e, EventKitPhase phase)
    {
        super.onEventPhase(e, phase);
        if (phase != EventKitPhase.postDispatch)
        {
            return;
        }
        e.isConsumed = true;
    }

    override void create()
    {
        super.create;

        enablePadding;

        assert(contentFactory);
        auto root = contentFactory();
        assert(root);
        addCreate(root);

        //TODO how disable it?
        root.enablePadding;
        root.layout.isAlignX = true;

        if (onContentCreate)
        {
            onContentCreate(root);
        }

        assert(titleFactory);
        _title = titleFactory();
        root.addCreate(_title);

        if (onTitleCreate)
        {
            onTitleCreate(_title);
        }

        assert(messageFactory);
        _message = messageFactory();
        root.addCreate(_message);

        if (onMessageCreate)
        {
            onMessageCreate(_message);
        }

        assert(buttonPanelFactory);
        auto buttonPanel = buttonPanelFactory();
        root.addCreate(buttonPanel);

        if (onButtonPanelCreate)
        {
            onButtonPanelCreate(buttonPanel);
        }

        assert(buttonFactory);
        auto buttonOk = buttonFactory(DialogButton.ok);
        buttonPanel.addCreate(buttonOk);

        if (onButtonCreate)
        {
            onButtonCreate(buttonOk);
        }

        buttonOk.onAction ~= (ref e) {
            if (onAction)
            {
                onAction();
                if (isOnceAction)
                {
                    onAction = null;
                }
            }

            if (onExit)
            {
                onExit();
            }
        };
    }

    Text title() => _title;
    Text message() => _message;

    void titleText(dstring text)
    {
        assert(_title);
        _title.text = text;
    }

    void messageText(dstring msg)
    {
        assert(_message);
        _message.text = msg;
    }

}
