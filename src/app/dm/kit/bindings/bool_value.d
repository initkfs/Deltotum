module app.dm.kit.bindings.bool_value;

import app.dm.kit.bindings.bindable_value: BindableValue;

/**
 * Authors: initkfs
 */
struct BoolValue
{
   mixin BindableValue!bool;
}
