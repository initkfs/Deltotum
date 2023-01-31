module deltotum.core.utils.canonical;

/**
 * Authors: initkfs
 */
mixin template Canonical()
{
    import deltotum.core.utils.equals_other;
    import deltotum.core.utils.hashcode;
    import deltotum.core.utils.tostring;

    mixin EqualsOther;
    mixin HashCode;
    mixin ToString;
}
