module api.math.versions;

version (EnableMathCustom)
{
    enum EnableMathCustom = true;
}
else
{
    enum EnableMathCustom = false;
}
