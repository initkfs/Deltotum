module deltotum.sys.cairo.libs.v116.types;

version(Cairo116):

struct cairo_t;
struct cairo_surface_t;

enum cairo_format_t
{
	INVALID = -1,
	ARGB32 = 0,
	RGB24 = 1,
	A8 = 2,
	A1 = 3,
	RGB16_565 = 4,
	RGB30 = 5
}