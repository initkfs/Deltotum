module deltotum.utils.canonical;

/**
 * Authors: initkfs
 */
mixin template Canonical()
{
    import deltotum.utils.equals_other;
    import deltotum.utils.hashcode;
    import deltotum.utils.tostring;

    mixin EqualsOther;
    mixin HashCode;
    mixin ToString;
}
