module api.dm.versions;

public import api.core.core_versions;
public import api.math.versions;

version (EnableValidation)
{
    enum EnableValidation = true;
}
else
{
    enum EnableValidation = false;
}
