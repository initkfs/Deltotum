module api.dm.gui.controls.viewers.webs.web_browser;

import api.dm.gui.controls.control : Control;
import api.dm.kit.webs.web_engine : WebEngine;
import api.dm.gui.controls.viewers.webs.wbrowser_main_panel : WBrowserMainPanel;

/**
 * Authors: initkfs
 */

class WebBrowser : Control
{
    WBrowserMainPanel mainPanel;
    WebEngine engine;

    this(float width = 300, float height = 300)
    {
        initSize(width, height);
        setVLayout;

        isBorder = true;
    }

    override void create()
    {
        super.create;

        mainPanel = new WBrowserMainPanel;
        addCreate(mainPanel);

        engine = new WebEngine(width, height);
        addCreate(engine);

        mainPanel.onGo = () { engine.loadUri(mainPanel.url); };

        mainPanel.onPrev = () {

        };

        mainPanel.onNext = () {

        };

        enablePadding;
    }
}
