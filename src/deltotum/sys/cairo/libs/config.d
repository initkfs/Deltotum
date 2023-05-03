module deltotum.sys.cairo.libs.config;

/**
 * Authors: initkfs
 */
enum CairoSupport
{
    noLibrary,
    badLibrary,
    cairo116 = 116
}

version (Cairo116)
{
    enum luaSupport = CairoSupport.cairo116;
}
else
{
    static assert(0, "No Cairo version found");
}
