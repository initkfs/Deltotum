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
    bool isAdd;
    double width = -1;
    double height = -1;
}

struct ImagesF
{
    string path;
    bool isAdd;
    size_t count = 1;
}

struct AnimImageF
{
    string path;
    size_t frameCols;
    size_t frameRows;
    size_t frameDelay = 100;
    bool isAdd;
    int frameWidth;
    int frameHeight;
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

struct Texture2dF 
{
    int width = 1;
    int height = 1;
    bool isAdd;
}
