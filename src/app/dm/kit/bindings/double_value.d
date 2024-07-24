module app.dm.kit.bindings.double_value;

import app.dm.kit.bindings.bindable_value : BindableValue;

/**
 * Authors: initkfs
 */
struct DoubleValue
{
    mixin BindableValue!(double, 0);
}

unittest
{
    DoubleValue v1 = {5}, v2, v3;
    assert(!v1.isBound);
    assert(v1 == 5);
    v1.bind(&v2);
    assert(v1.isBound(&v2));
    v2.bind(&v3);
    assert(v2.isBound(&v3));

    v1 = 10;
    assert(v2 == 10, v2.toString);
    assert(v3 == 10, v3.toString);

    v1++;
    assert(v3 == 11, v3.toString);

    v1 += 10;
    assert(v3 == 21, v3.toString);

    v1.dispose;
    v2.dispose;
    v3.dispose;
}
