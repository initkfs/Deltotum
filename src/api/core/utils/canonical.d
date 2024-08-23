module api.core.utils.canonical;

/**
 * Authors: initkfs
 */
mixin template Canonical()
{
    import api.core.utils.equals_other;
    import api.core.utils.hashcode;
    import api.core.utils.tostring;

    mixin EqualsOther;
    mixin HashCode;
    mixin ToString;
}
