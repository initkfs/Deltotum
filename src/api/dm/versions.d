module api.dm.versions;

public import api.core.versions;
public import api.math.versions;

version (EnableAddon)
{
    enum EnableAddon = true;
}
else
{
    enum EnableAddon = false;
}
