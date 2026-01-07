module api.dm.kit.platforms.platform;

import api.core.components.component_service : ComponentService;
import api.dm.com.platforms.com_platform : ComPlatform;
import api.dm.kit.platforms.timers.timing : Timing;
import api.dm.kit.platforms.caps.cap_graphics : CapGraphics;
import api.dm.kit.platforms.screens.screening : Screening;

/**
 * Authors: initkfs
 */
class Platform : ComponentService
{
    protected
    {
        ComPlatform system;
    }

    CapGraphics cap;
    Screening screen;
    Timing timer;

    float loopFixedDtSec = 1;

    this(ComPlatform system, CapGraphics caps, Screening screens, Timing timing) pure @safe
    {
        assert(system);
        this.system = system;

        assert(caps);
        this.cap = caps;

        assert(screens);
        this.screen = screens;

        assert(timing);
        this.timer = timing;
    }

    void openURL(string url)
    {
        import std.uri : uriLength;

        immutable len = url.uriLength;
        if (len <= 0)
        {
            throw new Exception("Invalid URL received: " ~ url);
        }

        if (const err = system.openURL(url))
        {
            throw new Exception("Error opening url: " ~ err.toString);
        }
    }

    void dispose()
    {
        if(timer){
            timer.dispose;
        }
    }
}
