module deltotum.toolkit.ui.controls.tabs.tab;

import deltotum.toolkit.ui.containers.container: Container;

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