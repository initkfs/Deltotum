module api.core.versions;

version (EnableTrace)
{
    enum EnableTrace = true;
}
else
{
    enum EnableTrace = false;
}
