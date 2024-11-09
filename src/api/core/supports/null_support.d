module api.core.supports.null_support;

import api.core.supports.support : Support;
import api.core.supports.errors.err_status : ErrStatus;

/**
 * Authors: initkfs
 */

class NullSupport : Support
{
    this() pure @safe
    {
        super(new ErrStatus);
    }
}
