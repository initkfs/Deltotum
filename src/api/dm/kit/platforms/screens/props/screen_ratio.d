module api.dm.kit.screens.props.screen_ratio;

/**
 * Authors: initkfs
 */
struct ScreenRatio
{
    float widthRatio = 0;
    float heightRatio = 0;

    invariant
    {
        assert(widthRatio > 0);
        assert(heightRatio > 0);
    }

    const  pure @safe
    {
        float getHeight(float width) => heightRatio * width / widthRatio;
        float getWidth(float height) => widthRatio * height / heightRatio;
    }
}

ScreenRatio ratio16on9() => ScreenRatio(16, 9);

unittest
{
    import std.math.operations: isClose;

    const ratio1 = ratio16on9;
    const width1 = cast(int) ratio1.getWidth(720);
    assert(isClose(width1, 1280));

    const height1 = cast(int) ratio1.getHeight(1280);
    assert(isClose(height1, 720));
}
