module deltotum.sys.julia.libs;

/**
 * Authors: initkfs
 */
version (JuliaV1)
    public import deltotum.sys.julia.libs.v1;
else
    static assert(0, "Julia library version not set");
