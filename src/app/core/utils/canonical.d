module app.core.utils.canonical;

/**
 * Authors: initkfs
 */
mixin template Canonical()
{
    import app.core.utils.equals_other;
    import app.core.utils.hashcode;
    import app.core.utils.tostring;

    mixin EqualsOther;
    mixin HashCode;
    mixin ToString;
}
