module api.dm.lib.libpng.native.types;
/**
 * Authors: initkfs
 */
public import core.stdc.limits;
public import core.stdc.stddef;

enum PNG_FORMAT_FLAG_ALPHA = 0x01U; /* format with an alpha channel */
enum PNG_FORMAT_FLAG_COLOR = 0x02U; /* color format: otherwise grayscale */
enum PNG_FORMAT_FLAG_LINEAR = 0x04U; /* 2-byte channels else 1-byte */
enum PNG_FORMAT_FLAG_COLORMAP = 0x08U; /* image data is color-mapped */

enum PNG_FORMAT_RGB = PNG_FORMAT_FLAG_COLOR;
enum PNG_FORMAT_RGBA = (PNG_FORMAT_RGB | PNG_FORMAT_FLAG_ALPHA);

alias png_imagep = png_image*;

enum PNG_IMAGE_VERSION = 1;

alias png_controlp = png_control*;
struct png_control;

struct png_color;
alias png_colorp = png_color*;
alias png_const_colorp = const png_color*;

struct png_image
{
    png_controlp opaque; /* Initialize to NULL, free with png_image_free */
    png_uint_32 _version; /* Set to PNG_IMAGE_VERSION */
    png_uint_32 width; /* Image width in pixels (columns) */
    png_uint_32 height; /* Image height in pixels (rows) */
    png_uint_32 format; /* Image format as defined below */
    png_uint_32 flags; /* A bit mask containing informational flags */
    png_uint_32 colormap_entries;
    /* Number of entries in the color-map */

    /* In the event of an error or warning the following field will be set to a
    * non-zero value and the 'message' field will contain a '\0' terminated
    * string with the libpng error or warning message.  If both warnings and
    * an error were encountered, only the error is recorded.  If there
    * are multiple warnings, only the first one is recorded.
    *
    * The upper 30 bits of this value are reserved, the low two bits contain
    * a value as follows:
    */
    png_uint_32 warning_or_error;
    char[64] message;
};

alias png_byte = ubyte;
//or int alias png_int_16 = int;
alias png_int_16 = short;
alias png_uint_16 = ushort;
alias png_int_32 = int;
alias png_uint_32 = uint;
alias png_size_t = size_t;
alias png_ptrdiff_t = ptrdiff_t;
alias png_alloc_size_t = size_t;

alias png_fixed_point = png_int_32;

/* Add typedefs for pointers */
alias png_voidp = void*;
alias png_const_voidp = const(void)*;
alias png_bytep = png_byte*;
alias png_const_bytep = const(png_byte)*;
alias png_uint_32p = png_uint_32*;
alias png_const_uint_32p = const(png_uint_32)*;
alias png_int_32p = png_int_32*;
alias png_const_int_32p = const(png_int_32)*;
alias png_uint_16p = png_uint_16*;
alias png_const_uint_16p = const(png_uint_16)*;
alias png_int_16p = png_int_16*;
alias png_const_int_16p = const(png_int_16)*;
alias png_charp = char*;
alias png_const_charp = const(char)*;
alias png_fixed_point_p = png_fixed_point*;
alias png_const_fixed_point_p = const(png_fixed_point)*;
alias png_size_tp = size_t*;
alias png_const_size_tp = const(size_t)*;

alias png_doublep = double*;
alias png_const_doublep = const(double)*;

alias png_bytepp = png_byte**;
alias png_uint_32pp = png_uint_32**;
alias png_int_32pp = png_int_32**;
alias png_uint_16pp = png_uint_16**;
alias png_int_16pp = png_int_16**;
alias png_const_charpp = const(char)**;
alias png_charpp = char**;
alias png_fixed_point_pp = png_fixed_point**;
alias png_doublepp = double**;
alias png_charppp = char***;

struct png_struct;
alias png_structp = png_struct*;
alias png_structpp = png_struct**;

struct png_info;

alias png_infop = png_info*;
alias png_const_infop = const(png_info*);
alias png_infopp = png_info**;
