module app.dm.sys.cairo.libs;

/**
 * Authors: initkfs
 */
version (Cairo116)
    public import app.dm.sys.cairo.libs.v116;
else
    static assert(0, "Cairo library version not set");
