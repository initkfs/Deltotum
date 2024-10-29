module api.dm.kit.factories.uda;

/**
 * Authors: initkfs
 */

struct StubF
{
    double width = 50;
    double height = 50;
    bool isAdd;
}

struct StubsF
{
    size_t count;
    double width = 50;
    double height = 50;
    bool isAdd;
}

struct ImageF
{
    string path;
    double width = -1;
    double height = -1;
    bool isAdd;
}

struct ImagesF
{
    string path;
    bool isAdd;
}

struct AnimImageF
{
    string path;
    int frameWidth;
    int frameHeight;
    size_t frameDelay = 100;
    bool isAdd;
}

struct AnimImagesF
{
    string path;
    int frameWidth;
    int frameHeight;
    size_t frameDelay = 100;
    size_t count = 1;
    bool isAdd;
}
