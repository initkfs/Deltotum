module api.dm.lib.vips.native.v8.types;
/**
 * Authors: initkfs
 */

extern (C):

struct VipsImage;

enum VipsBandFormat
{
    VIPS_FORMAT_NOTSET = -1,
    VIPS_FORMAT_UCHAR = 0,
    VIPS_FORMAT_CHAR = 1,
    VIPS_FORMAT_USHORT = 2,
    VIPS_FORMAT_SHORT = 3,
    VIPS_FORMAT_UINT = 4,
    VIPS_FORMAT_INT = 5,
    VIPS_FORMAT_FLOAT = 6,
    VIPS_FORMAT_COMPLEX = 7,
    VIPS_FORMAT_DOUBLE = 8,
    VIPS_FORMAT_DPCOMPLEX = 9,
    VIPS_FORMAT_LAST = 10
}
