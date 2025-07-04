module api.dm.lib.cairo.native.v116.types;
/**
 * Authors: initkfs
 */

extern (C):

alias cairo_bool_t = int;

struct cairo_t;
struct cairo_surface_t;
struct cairo_device_t;

struct cairo_matrix_t
{
    double xx;
    double yx;
    double xy;
    double yy;
    double x0;
    double y0;
}

struct cairo_pattern_t;

enum cairo_status_t
{
    CAIRO_STATUS_SUCCESS = 0,

    CAIRO_STATUS_NO_MEMORY = 1,
    CAIRO_STATUS_INVALID_RESTORE = 2,
    CAIRO_STATUS_INVALID_POP_GROUP = 3,
    CAIRO_STATUS_NO_CURRENT_POINT = 4,
    CAIRO_STATUS_INVALID_MATRIX = 5,
    CAIRO_STATUS_INVALID_STATUS = 6,
    CAIRO_STATUS_NULL_POINTER = 7,
    CAIRO_STATUS_INVALID_STRING = 8,
    CAIRO_STATUS_INVALID_PATH_DATA = 9,
    CAIRO_STATUS_READ_ERROR = 10,
    CAIRO_STATUS_WRITE_ERROR = 11,
    CAIRO_STATUS_SURFACE_FINISHED = 12,
    CAIRO_STATUS_SURFACE_TYPE_MISMATCH = 13,
    CAIRO_STATUS_PATTERN_TYPE_MISMATCH = 14,
    CAIRO_STATUS_INVALID_CONTENT = 15,
    CAIRO_STATUS_INVALID_FORMAT = 16,
    CAIRO_STATUS_INVALID_VISUAL = 17,
    CAIRO_STATUS_FILE_NOT_FOUND = 18,
    CAIRO_STATUS_INVALID_DASH = 19,
    CAIRO_STATUS_INVALID_DSC_COMMENT = 20,
    CAIRO_STATUS_INVALID_INDEX = 21,
    CAIRO_STATUS_CLIP_NOT_REPRESENTABLE = 22,
    CAIRO_STATUS_TEMP_FILE_ERROR = 23,
    CAIRO_STATUS_INVALID_STRIDE = 24,
    CAIRO_STATUS_FONT_TYPE_MISMATCH = 25,
    CAIRO_STATUS_USER_FONT_IMMUTABLE = 26,
    CAIRO_STATUS_USER_FONT_ERROR = 27,
    CAIRO_STATUS_NEGATIVE_COUNT = 28,
    CAIRO_STATUS_INVALID_CLUSTERS = 29,
    CAIRO_STATUS_INVALID_SLANT = 30,
    CAIRO_STATUS_INVALID_WEIGHT = 31,
    CAIRO_STATUS_INVALID_SIZE = 32,
    CAIRO_STATUS_USER_FONT_NOT_IMPLEMENTED = 33,
    CAIRO_STATUS_DEVICE_TYPE_MISMATCH = 34,
    CAIRO_STATUS_DEVICE_ERROR = 35,
    CAIRO_STATUS_INVALID_MESH_CONSTRUCTION = 36,
    CAIRO_STATUS_DEVICE_FINISHED = 37,
    CAIRO_STATUS_JBIG2_GLOBAL_MISSING = 38,
    CAIRO_STATUS_PNG_ERROR = 39,
    CAIRO_STATUS_FREETYPE_ERROR = 40,
    CAIRO_STATUS_WIN32_GDI_ERROR = 41,
    CAIRO_STATUS_TAG_ERROR = 42,

    CAIRO_STATUS_LAST_STATUS = 43
}

enum cairo_content_t
{
    CAIRO_CONTENT_COLOR = 0x1000,
    CAIRO_CONTENT_ALPHA = 0x2000,
    CAIRO_CONTENT_COLOR_ALPHA = 0x3000
}

enum cairo_format_t
{
    CAIRO_FORMAT_INVALID = -1,
    CAIRO_FORMAT_ARGB32 = 0,
    CAIRO_FORMAT_RGB24 = 1,
    CAIRO_FORMAT_A8 = 2,
    CAIRO_FORMAT_A1 = 3,
    CAIRO_FORMAT_RGB16_565 = 4,
    CAIRO_FORMAT_RGB30 = 5
}

struct cairo_rectangle_int_t
{
    int x;
    int y;
    int width;
    int height;
}

enum cairo_operator_t
{
    CAIRO_OPERATOR_CLEAR = 0,

    CAIRO_OPERATOR_SOURCE = 1,
    CAIRO_OPERATOR_OVER = 2,
    CAIRO_OPERATOR_IN = 3,
    CAIRO_OPERATOR_OUT = 4,
    CAIRO_OPERATOR_ATOP = 5,

    CAIRO_OPERATOR_DEST = 6,
    CAIRO_OPERATOR_DEST_OVER = 7,
    CAIRO_OPERATOR_DEST_IN = 8,
    CAIRO_OPERATOR_DEST_OUT = 9,
    CAIRO_OPERATOR_DEST_ATOP = 10,

    CAIRO_OPERATOR_XOR = 11,
    CAIRO_OPERATOR_ADD = 12,
    CAIRO_OPERATOR_SATURATE = 13,

    CAIRO_OPERATOR_MULTIPLY = 14,
    CAIRO_OPERATOR_SCREEN = 15,
    CAIRO_OPERATOR_OVERLAY = 16,
    CAIRO_OPERATOR_DARKEN = 17,
    CAIRO_OPERATOR_LIGHTEN = 18,
    CAIRO_OPERATOR_COLOR_DODGE = 19,
    CAIRO_OPERATOR_COLOR_BURN = 20,
    CAIRO_OPERATOR_HARD_LIGHT = 21,
    CAIRO_OPERATOR_SOFT_LIGHT = 22,
    CAIRO_OPERATOR_DIFFERENCE = 23,
    CAIRO_OPERATOR_EXCLUSION = 24,
    CAIRO_OPERATOR_HSL_HUE = 25,
    CAIRO_OPERATOR_HSL_SATURATION = 26,
    CAIRO_OPERATOR_HSL_COLOR = 27,
    CAIRO_OPERATOR_HSL_LUMINOSITY = 28
}

enum cairo_antialias_t
{
    CAIRO_ANTIALIAS_DEFAULT = 0,

    CAIRO_ANTIALIAS_NONE = 1,
    CAIRO_ANTIALIAS_GRAY = 2,
    CAIRO_ANTIALIAS_SUBPIXEL = 3,

    CAIRO_ANTIALIAS_FAST = 4,
    CAIRO_ANTIALIAS_GOOD = 5,
    CAIRO_ANTIALIAS_BEST = 6
}

enum cairo_fill_rule_t
{
    CAIRO_FILL_RULE_WINDING = 0,
    CAIRO_FILL_RULE_EVEN_ODD = 1
}

enum cairo_line_cap_t
{
    CAIRO_LINE_CAP_BUTT = 0,
    CAIRO_LINE_CAP_ROUND = 1,
    CAIRO_LINE_CAP_SQUARE = 2
}

enum cairo_line_join_t
{
    CAIRO_LINE_JOIN_MITER = 0,
    CAIRO_LINE_JOIN_ROUND = 1,
    CAIRO_LINE_JOIN_BEVEL = 2
}

struct cairo_rectangle_t
{
    double x;
    double y;
    double width;
    double height;
}

struct cairo_rectangle_list_t
{
    cairo_status_t status;
    cairo_rectangle_t* rectangles;
    int num_rectangles;
}

struct cairo_text_cluster_t
{
    int num_bytes;
    int num_glyphs;
}

enum cairo_text_cluster_flags_t
{
    CAIRO_TEXT_CLUSTER_FLAG_BACKWARD = 0x00000001
}

struct cairo_text_extents_t
{
    double x_bearing;
    double y_bearing;
    double width;
    double height;
    double x_advance;
    double y_advance;
}

struct cairo_font_extents_t
{
    double ascent;
    double descent;
    double height;
    double max_x_advance;
    double max_y_advance;
}

enum cairo_font_slant_t
{
    CAIRO_FONT_SLANT_NORMAL = 0,
    CAIRO_FONT_SLANT_ITALIC = 1,
    CAIRO_FONT_SLANT_OBLIQUE = 2
}

enum cairo_font_weight_t
{
    CAIRO_FONT_WEIGHT_NORMAL = 0,
    CAIRO_FONT_WEIGHT_BOLD = 1
}

enum cairo_subpixel_order_t
{
    CAIRO_SUBPIXEL_ORDER_DEFAULT = 0,
    CAIRO_SUBPIXEL_ORDER_RGB = 1,
    CAIRO_SUBPIXEL_ORDER_BGR = 2,
    CAIRO_SUBPIXEL_ORDER_VRGB = 3,
    CAIRO_SUBPIXEL_ORDER_VBGR = 4
}

enum cairo_hint_style_t
{
    CAIRO_HINT_STYLE_DEFAULT = 0,
    CAIRO_HINT_STYLE_NONE = 1,
    CAIRO_HINT_STYLE_SLIGHT = 2,
    CAIRO_HINT_STYLE_MEDIUM = 3,
    CAIRO_HINT_STYLE_FULL = 4
}

enum cairo_hint_metrics_t
{
    CAIRO_HINT_METRICS_DEFAULT = 0,
    CAIRO_HINT_METRICS_OFF = 1,
    CAIRO_HINT_METRICS_ON = 2
}

struct cairo_font_options_t;

enum cairo_font_type_t
{
    CAIRO_FONT_TYPE_TOY = 0,
    CAIRO_FONT_TYPE_FT = 1,
    CAIRO_FONT_TYPE_WIN32 = 2,
    CAIRO_FONT_TYPE_QUARTZ = 3,
    CAIRO_FONT_TYPE_USER = 4
}

enum cairo_path_data_type_t
{
    CAIRO_PATH_MOVE_TO = 0,
    CAIRO_PATH_LINE_TO = 1,
    CAIRO_PATH_CURVE_TO = 2,
    CAIRO_PATH_CLOSE_PATH = 3
}

union cairo_path_data_t
{
    struct _Anonymous_0
    {
        cairo_path_data_type_t type;
        int length;
    }

    _Anonymous_0 header;

    struct _Anonymous_1
    {
        double x;
        double y;
    }

    _Anonymous_1 point;
}

struct cairo_path_t
{
    cairo_status_t status;
    cairo_path_data_t* data;
    int num_data;
}

enum cairo_device_type_t
{
    CAIRO_DEVICE_TYPE_DRM = 0,
    CAIRO_DEVICE_TYPE_GL = 1,
    CAIRO_DEVICE_TYPE_SCRIPT = 2,
    CAIRO_DEVICE_TYPE_XCB = 3,
    CAIRO_DEVICE_TYPE_XLIB = 4,
    CAIRO_DEVICE_TYPE_XML = 5,
    CAIRO_DEVICE_TYPE_COGL = 6,
    CAIRO_DEVICE_TYPE_WIN32 = 7,

    CAIRO_DEVICE_TYPE_INVALID = -1
}

enum cairo_surface_type_t
{
    CAIRO_SURFACE_TYPE_IMAGE = 0,
    CAIRO_SURFACE_TYPE_PDF = 1,
    CAIRO_SURFACE_TYPE_PS = 2,
    CAIRO_SURFACE_TYPE_XLIB = 3,
    CAIRO_SURFACE_TYPE_XCB = 4,
    CAIRO_SURFACE_TYPE_GLITZ = 5,
    CAIRO_SURFACE_TYPE_QUARTZ = 6,
    CAIRO_SURFACE_TYPE_WIN32 = 7,
    CAIRO_SURFACE_TYPE_BEOS = 8,
    CAIRO_SURFACE_TYPE_DIRECTFB = 9,
    CAIRO_SURFACE_TYPE_SVG = 10,
    CAIRO_SURFACE_TYPE_OS2 = 11,
    CAIRO_SURFACE_TYPE_WIN32_PRINTING = 12,
    CAIRO_SURFACE_TYPE_QUARTZ_IMAGE = 13,
    CAIRO_SURFACE_TYPE_SCRIPT = 14,
    CAIRO_SURFACE_TYPE_QT = 15,
    CAIRO_SURFACE_TYPE_RECORDING = 16,
    CAIRO_SURFACE_TYPE_VG = 17,
    CAIRO_SURFACE_TYPE_GL = 18,
    CAIRO_SURFACE_TYPE_DRM = 19,
    CAIRO_SURFACE_TYPE_TEE = 20,
    CAIRO_SURFACE_TYPE_XML = 21,
    CAIRO_SURFACE_TYPE_SKIA = 22,
    CAIRO_SURFACE_TYPE_SUBSURFACE = 23,
    CAIRO_SURFACE_TYPE_COGL = 24
}

enum cairo_pattern_type_t
{
    CAIRO_PATTERN_TYPE_SOLID = 0,
    CAIRO_PATTERN_TYPE_SURFACE = 1,
    CAIRO_PATTERN_TYPE_LINEAR = 2,
    CAIRO_PATTERN_TYPE_RADIAL = 3,
    CAIRO_PATTERN_TYPE_MESH = 4,
    CAIRO_PATTERN_TYPE_RASTER_SOURCE = 5
}

enum cairo_filter_t
{
    CAIRO_FILTER_FAST = 0,
    CAIRO_FILTER_GOOD = 1,
    CAIRO_FILTER_BEST = 2,
    CAIRO_FILTER_NEAREST = 3,
    CAIRO_FILTER_BILINEAR = 4,
    CAIRO_FILTER_GAUSSIAN = 5
}

struct cairo_region_t;

enum cairo_region_overlap_t
{
    CAIRO_REGION_OVERLAP_IN = 0,
    CAIRO_REGION_OVERLAP_OUT = 1,
    CAIRO_REGION_OVERLAP_PART = 2
}

struct cairo_user_data_key_t
{
    int unused;
}