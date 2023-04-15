module deltotum.ui.controls.tabs.tab;

import deltotum.ui.containers.container: Container;

/**
 * Authors: initkfs
 */
class Tab : Container {
    
    dstring text;

    this(dstring text = "Tab"){
        super();
        this.text = text;
    }
}