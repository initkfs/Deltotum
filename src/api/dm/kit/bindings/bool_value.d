module api.dm.kit.bindings.bool_value;

import api.dm.kit.bindings.bindable_value: BindableValue;

/**
 * Authors: initkfs
 */
struct BoolValue
{
   mixin BindableValue!bool;
}
