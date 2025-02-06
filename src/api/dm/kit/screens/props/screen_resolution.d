module api.dm.kit.screens.props.screen_resolution;

import api.dm.kit.screens.props.screen_ratio : ScreenRatio, ratio16on9;

import std.math.traits: isFinite;

/**
 * Authors: initkfs
 */
struct ScreenResolution
{
    double width = 0;
    double height = 0;

    ScreenRatio ratio;

    static ScreenResolution fromWidth(double newWidth, ScreenRatio ratio = ratio16on9)
    {
        assert(isFinite(newWidth));
        assert(newWidth > 0);

        auto newHeight = ratio.getHeight(newWidth);
        return ScreenResolution(newWidth, newHeight, ratio);
    }

    static ScreenResolution fromHeight(double newHeight, ScreenRatio ratio = ratio16on9)
    {
        assert(isFinite(newHeight));
        assert(newHeight > 0);
        
        auto newWidth = ratio.getWidth(newHeight);
        return ScreenResolution(newWidth, newHeight, ratio);
    }
}

unittest
{
    auto res1 = ScreenResolution.fromHeight(720);
    assert(isClose(res1.width, 1280));
    assert(isClose(res1.height, 720));

    assert(isClose(res1.ratio.widthRatio, 16));
    assert(isClose(res1.ratio.heightRatio, 9));

    auto res2 = ScreenResolution.fromWidth(1280);
    assert(isClose(res2.width, 1280));
    assert(isClose(res2.height, 720));
}
