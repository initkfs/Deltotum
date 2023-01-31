module deltotum.engine.ui.controls.tabs.tab;

import deltotum.engine.ui.containers.container: Container;

/**
 * Authors: initkfs
 */
class Tab : Container {
    
    string text;

    this(string text = "Tab"){
        super();
        this.text = text;
    }
}