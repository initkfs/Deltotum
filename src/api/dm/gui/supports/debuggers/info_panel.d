module api.dm.gui.supports.debuggers.info_panel;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.containers.hbox : HBox;

/**
 * Authors: initkfs
 */
class InfoPanel : Container
{
    HBox mainInfoContainer;

    Text counterFps;
    Text counterFixedFps;
    Text invalidNodesCount;

    Text timeDrawScene;
    Text timeUpdateScene;

    Text gcUsed;

    Text vramInfo;

    this()
    {
        setHLayout;
        layout.isAlignY = true;
    }

    override void create()
    {
        super.create();

        const margin = 15; //theme.controlPadding;

        mainInfoContainer = new HBox;
        mainInfoContainer.layout.isAlignY = true;
        addCreate(mainInfoContainer);
        mainInfoContainer.enablePadding;

        counterFps = new Text("");
        mainInfoContainer.addCreate([new Text("FPS:"), counterFps]);
        counterFps.margin.right = margin;

        counterFixedFps = new Text("");
        mainInfoContainer.addCreate([new Text("FFS:"), counterFixedFps]);
        counterFixedFps.margin.right = margin;

        invalidNodesCount = new Text("");
        mainInfoContainer.addCreate([new Text("Inv:"), invalidNodesCount]);
        invalidNodesCount.margin.right = margin;

        timeDrawScene = new Text("");
        timeDrawScene.margin.right = margin;
        timeUpdateScene = new Text("");
        timeDrawScene.margin.right = margin;

        mainInfoContainer.addCreate([
            new Text("SD:"), timeDrawScene, new Text("SU:"), timeUpdateScene
        ]);

        gcUsed = new Text("");
        mainInfoContainer.addCreate([new Text("GC:"), gcUsed]);
        gcUsed.margin.right = margin;
    }
}
