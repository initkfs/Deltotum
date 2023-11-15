module dm.core.utils.canonical;

/**
 * Authors: initkfs
 */
mixin template Canonical()
{
    import dm.core.utils.equals_other;
    import dm.core.utils.hashcode;
    import dm.core.utils.tostring;

    mixin EqualsOther;
    mixin HashCode;
    mixin ToString;
}
