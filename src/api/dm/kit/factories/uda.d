module api.dm.kit.factories.uda;

/**
 * Authors: initkfs
 */

struct Load
{
    double width = 0;
    double height = 0;
    string path;
    size_t count = 1;
    bool isAdd;
}

struct LAnimImage
{
    string path;
    size_t frameCols;
    size_t frameRows;
    size_t frameDelay = 100;
    bool isAdd;
    int frameWidth;
    int frameHeight;
}

struct LAnimImages
{
    string path;
    int frameWidth;
    int frameHeight;
    size_t frameDelay = 100;
    size_t count = 1;
    bool isAdd;
}