module deltotum.sys.julia.libs.v1;

version (JuliaV1)
{
    public import deltotum.sys.julia.libs.v1.types;

    version (BindJuliaStatic)
    {
        static assert(0, "Julia static linking not supported yet.");
    }
    else
    {
        public import deltotum.sys.julia.libs.v1.binddynamic;
    }
}
