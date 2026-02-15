module api.core.core_versions;

version (EnableTrace)
{
    enum EnableTrace = true;
}
else
{
    enum EnableTrace = false;
}
