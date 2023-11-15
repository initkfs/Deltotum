module dm.sys.cairo.libs.v116;

version (Cairo116)
{
    public import dm.sys.cairo.libs.v116.types;

    version (BindCairoStatic)
    {
        static assert(0, "Cairo static linking not supported yet.");
    }
    else
    {
        public import dm.sys.cairo.libs.v116.binddynamic;
    }
}
