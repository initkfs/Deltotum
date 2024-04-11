module dm.kit.bindings.bool_value;

import dm.kit.bindings.bindable_value: BindableValue;

/**
 * Authors: initkfs
 */
struct BoolValue
{
   mixin BindableValue!bool;
}
