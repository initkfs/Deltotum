module api.dm.lib.freetype.native.types;
/**
 * Authors: initkfs
 */

import core.stdc.config : c_long, c_ulong;

struct FT_LibraryRec;
alias FT_Library = FT_LibraryRec*;

alias FT_Int16 = short;
alias FT_UInt16 = ushort;
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

alias FT_List = FT_ListRec*;

struct FT_ListNodeRec;
alias FT_ListNode = FT_ListNodeRec*;

//TODO enum
alias FT_Encoding = int;

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

struct FT_GlyphSlotRec;
alias FT_GlyphSlot = FT_GlyphSlotRec*;

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
