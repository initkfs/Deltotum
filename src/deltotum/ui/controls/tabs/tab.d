module deltotum.ui.controls.tabs.tab;

import deltotum.ui.containers.container: Container;
import deltotum.ui.theme.theme: Theme;

/**
 * Authors: initkfs
 */
class Tab : Container {
    
    @property string text;

    this(Theme theme, string text = "Tab"){
        super(theme);
        this.text = text;
    }
}