module deltotum.sys.cairo.libs;
/**
 * Authors: initkfs
 */
public import deltotum.sys.cairo.libs.config;

version (Cairo116)
    public import deltotum.sys.cairo.libs.v116;
else
    static assert(0, "Cairo library version not set");
