module api.dm.gui.controls.video.base_filtered_media_worker;

import api.dm.gui.controls.video.base_media_worker: BaseMediaWorker;
import std.logger : Logger;

import cffmpeg;

/**
 * Authors: initkfs
 */
abstract class BaseFilteredMediaWorker : BaseMediaWorker
{

    this(Logger logger)
    {
        super(&run);
        this.logger = logger;
    }

    void initFilter(){
        
    }
}
