module api.dm.lib.freetype.native.types;
/**
 * Authors: initkfs
 */

import core.stdc.config : c_long, c_ulong;

struct FT_LibraryRec;
alias FT_Library = FT_LibraryRec*;

alias FT_Int16 = short;
alias FT_UInt16 = ushort;
alias FT_Int32 = int;
alias FT_UInt32 = uint;
alias FT_Int64 = c_long;
alias FT_UInt64 = c_ulong;

alias ft_ptrdiff_t = ptrdiff_t;

alias FT_FWord = short; /* distance in FUnits */
alias FT_UFWord = ushort; /* unsigned distance */
alias FT_Char = char;
alias FT_Byte = ubyte;
alias FT_Bytes = const(FT_Byte)*;
alias FT_Tag = FT_UInt32;
alias FT_String = char;
alias FT_Short = short;
alias FT_UShort = ushort;
alias FT_Int = int;
alias FT_UInt = uint;
alias FT_Long = c_long;
alias FT_ULong = c_ulong;
alias FT_F2Dot14 = short;
alias FT_F26Dot6 = c_long;
alias FT_Fixed = c_long;
alias FT_Error = int;
alias FT_Pointer = void*;
alias FT_Offset = size_t;
alias FT_PtrDist = ft_ptrdiff_t;

alias FT_Bool = ubyte;
alias FT_Pos = c_long;

alias FT_Face = FT_FaceRec*;

struct FT_DriverRec;
alias FT_Driver = FT_DriverRec*;

struct FT_MemoryRec;
alias FT_Memory = FT_MemoryRec*;

struct FT_StreamRec;
alias FT_Stream = FT_StreamRec*;

struct FT_Face_InternalRec;
alias FT_Face_Internal = FT_Face_InternalRec*;

struct FT_Size_InternalRec;
alias FT_Size_Internal = FT_Size_InternalRec*;

struct FT_SubGlyphRec;
alias FT_SubGlyph = FT_SubGlyphRec*;

alias FT_List = FT_ListRec*;

struct FT_ListNodeRec;
alias FT_ListNode = FT_ListNodeRec*;

struct FT_Slot_InternalRec;
alias FT_Slot_Internal = FT_Slot_InternalRec*;

struct FT_Glyph_Class;

//TODO enum
alias FT_Encoding = int;

int FT_ENC_TAG(char a, char b, char c, char d)
{
    int value =
        ((cast(FT_UInt32) a) << 24) | ((cast(FT_UInt32) b) << 16) | (
            (cast(FT_UInt32) c) << 8) | cast(
            FT_UInt32) d;
    return value;
}

enum FT_ENCODING_UNICODE = FT_ENC_TAG('u', 'n', 'i', 'c');

alias FT_Glyph_Format = int;

enum FT_LOAD_DEFAULT = 0x0;
enum FT_LOAD_NO_SCALE = (1L << 0);
enum FT_LOAD_NO_HINTING = (1L << 1);
enum FT_LOAD_RENDER = (1L << 2);
enum FT_LOAD_NO_BITMAP = (1L << 3);
enum FT_LOAD_VERTICAL_LAYOUT = (1L << 4);
enum FT_LOAD_FORCE_AUTOHINT = (1L << 5);
enum FT_LOAD_CROP_BITMAP = (1L << 6);
enum FT_LOAD_PEDANTIC = (1L << 7);
enum FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH = (1L << 9);
enum FT_LOAD_NO_RECURSE = (1L << 10);
enum FT_LOAD_IGNORE_TRANSFORM = (1L << 11);
enum FT_LOAD_MONOCHROME = (1L << 12);
enum FT_LOAD_LINEAR_DESIGN = (1L << 13);
enum FT_LOAD_NO_AUTOHINT = (1L << 15);
/* Bits 16-19 are used by `FT_LOAD_TARGET_` */
enum FT_LOAD_COLOR = (1L << 20);
enum FT_LOAD_COMPUTE_METRICS = (1L << 21);
enum FT_LOAD_BITMAP_METRICS_ONLY = (1L << 22);

struct FT_FaceRec
{
    FT_Long num_faces;
    FT_Long face_index;

    FT_Long face_flags;
    FT_Long style_flags;

    FT_Long num_glyphs;

    FT_String* family_name;
    FT_String* style_name;

    FT_Int num_fixed_sizes;
    FT_Bitmap_Size* available_sizes;

    FT_Int num_charmaps;
    FT_CharMap* charmaps;

    FT_Generic generic;

    /*# The following member variables (down to `underline_thickness`) */
    /*# are only relevant to scalable outlines; cf. @FT_Bitmap_Size    */
    /*# for bitmap fonts.                                              */
    FT_BBox bbox;

    FT_UShort units_per_EM;
    FT_Short ascender;
    FT_Short descender;
    FT_Short height;

    FT_Short max_advance_width;
    FT_Short max_advance_height;

    FT_Short underline_position;
    FT_Short underline_thickness;

    FT_GlyphSlot glyph;
    FT_Size size;
    FT_CharMap charmap;

    /*@private begin */

    FT_Driver driver;
    FT_Memory memory;
    FT_Stream stream;

    FT_ListRec sizes_list;

    FT_Generic autohint; /* face-specific auto-hinter data */
    void* extensions; /* unused                         */

    FT_Face_Internal internal;

    /*@private end */
}

struct FT_Bitmap_Size
{
    FT_Short height;
    FT_Short width;
    FT_Pos size;
    FT_Pos x_ppem;
    FT_Pos y_ppem;
}

alias FT_CharMap = FT_CharMapRec*;

struct FT_CharMapRec
{
    FT_Face face;
    FT_Encoding encoding;
    FT_UShort platform_id;
    FT_UShort encoding_id;
}

alias FT_Generic_Finalizer = void function(void* object);

struct FT_Generic
{
    void* data;
    FT_Generic_Finalizer finalizer;
}

struct FT_BBox
{
    FT_Pos xMin, yMin;
    FT_Pos xMax, yMax;
}

alias FT_Size = FT_SizeRec*;

struct FT_SizeRec
{
    FT_Face face; /* parent face object              */
    FT_Generic generic; /* generic pointer for client uses */
    FT_Size_Metrics metrics; /* size metrics                    */
    FT_Size_Internal internal;
}

enum FT_Size_Request_Type
{
    FT_SIZE_REQUEST_TYPE_NOMINAL,
    FT_SIZE_REQUEST_TYPE_REAL_DIM,
    FT_SIZE_REQUEST_TYPE_BBOX,
    FT_SIZE_REQUEST_TYPE_CELL,
    FT_SIZE_REQUEST_TYPE_SCALES,

    FT_SIZE_REQUEST_TYPE_MAX
}

struct FT_Size_Metrics
{
    FT_UShort x_ppem; /* horizontal pixels per EM               */
    FT_UShort y_ppem; /* vertical pixels per EM                 */

    FT_Fixed x_scale; /* scaling values used to convert font    */
    FT_Fixed y_scale; /* units to 26.6 fractional pixels        */

    FT_Pos ascender; /* ascender in 26.6 frac. pixels          */
    FT_Pos descender; /* descender in 26.6 frac. pixels         */
    FT_Pos height; /* text height in 26.6 frac. pixels       */
    FT_Pos max_advance; /* max horizontal advance, in 26.6 pixels */
}

struct FT_ListRec
{
    FT_ListNode head;
    FT_ListNode tail;
}

alias FT_GlyphSlot = FT_GlyphSlotRec*;

struct FT_GlyphSlotRec
{
    FT_Library library;
    FT_Face face;
    FT_GlyphSlot next;
    FT_UInt glyph_index; /* new in 2.10; was reserved previously */
    FT_Generic generic;

    FT_Glyph_Metrics metrics;
    FT_Fixed linearHoriAdvance;
    FT_Fixed linearVertAdvance;
    FT_Vector advance;

    FT_Glyph_Format format;

    FT_Bitmap bitmap;
    FT_Int bitmap_left;
    FT_Int bitmap_top;

    FT_Outline outline;

    FT_UInt num_subglyphs;
    FT_SubGlyph subglyphs;

    void* control_data;
    long control_len;

    FT_Pos lsb_delta;
    FT_Pos rsb_delta;

    void* other;

    FT_Slot_Internal internal;

}

struct FT_Glyph_Metrics
{
    FT_Pos width;
    FT_Pos height;

    FT_Pos horiBearingX;
    FT_Pos horiBearingY;
    FT_Pos horiAdvance;

    FT_Pos vertBearingX;
    FT_Pos vertBearingY;
    FT_Pos vertAdvance;

}

struct FT_Vector
{
    FT_Pos x;
    FT_Pos y;
}

struct FT_Bitmap
{
    uint rows;
    uint width;
    int pitch;
    ubyte* buffer;
    ushort num_grays;
    ubyte pixel_mode;
    ubyte palette_mode;
    void* palette;
}

struct FT_Outline
{
    ushort n_contours; /* number of contours in glyph        */
    ushort n_points; /* number of points in the glyph      */

    FT_Vector* points; /* the outline's points               */
    ubyte* tags; /* the points flags                   */
    ushort* contours; /* the contour end points             */
    int flags; /* outline masks                      */
}

enum FT_Glyph_BBox_Mode
{
    FT_GLYPH_BBOX_UNSCALED = 0,
    FT_GLYPH_BBOX_SUBPIXELS = 0,
    FT_GLYPH_BBOX_GRIDFIT = 1,
    FT_GLYPH_BBOX_TRUNCATE = 2,
    FT_GLYPH_BBOX_PIXELS = 3
}

alias FT_Glyph = FT_GlyphRec*;

struct FT_GlyphRec
{
    FT_Library library;
    const FT_Glyph_Class* clazz;
    FT_Glyph_Format format;
    FT_Vector advance;
}

enum FT_Render_Mode
{
    FT_RENDER_MODE_NORMAL = 0,
    FT_RENDER_MODE_LIGHT,
    FT_RENDER_MODE_MONO,
    FT_RENDER_MODE_LCD,
    FT_RENDER_MODE_LCD_V,
    FT_RENDER_MODE_SDF,

    FT_RENDER_MODE_MAX
}

alias FT_BitmapGlyph = FT_BitmapGlyphRec*;

struct FT_BitmapGlyphRec
{
    FT_GlyphRec root;
    FT_Int left;
    FT_Int top;
    FT_Bitmap bitmap;
}

enum FT_LcdFilter
{
    FT_LCD_FILTER_NONE = 0,
    FT_LCD_FILTER_DEFAULT = 1,
    FT_LCD_FILTER_LIGHT = 2,
    FT_LCD_FILTER_LEGACY1 = 3,
    FT_LCD_FILTER_LEGACY = 16,

    FT_LCD_FILTER_MAX /* do not remove */
}

int FT_LOAD_TARGET_(int x) => (cast(FT_Int32)(x & 15)) << 16;

enum FT_LOAD_TARGET_NORMAL = FT_LOAD_TARGET_(FT_Render_Mode.FT_RENDER_MODE_NORMAL);
enum FT_LOAD_TARGET_LIGHT = FT_LOAD_TARGET_(FT_Render_Mode.FT_RENDER_MODE_LIGHT);
enum FT_LOAD_TARGET_MONO = FT_LOAD_TARGET_(FT_Render_Mode.FT_RENDER_MODE_MONO);
enum FT_LOAD_TARGET_LCD = FT_LOAD_TARGET_(FT_Render_Mode.FT_RENDER_MODE_LCD);
enum FT_LOAD_TARGET_LCD_V = FT_LOAD_TARGET_(FT_Render_Mode.FT_RENDER_MODE_LCD_V);
