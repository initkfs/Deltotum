module core.utils.canonical;

/**
 * Authors: initkfs
 */
mixin template Canonical()
{
    import core.utils.equals_other;
    import core.utils.hashcode;
    import core.utils.tostring;

    mixin EqualsOther;
    mixin HashCode;
    mixin ToString;
}
