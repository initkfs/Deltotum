module api.dm.lib.cairo.native;

version (Cairo116)
{
    public import api.dm.lib.cairo.native.v116.types;

    version (BindCairoStatic)
    {
        static assert(0, "Cairo static linking not supported yet.");
    }
    else
    {
        public import api.dm.lib.cairo.native.v116.binddynamic;
    }
}
else
{
    static assert(0, "No found Cairo version");
}
