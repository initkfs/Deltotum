module core.supports.null_support;

import core.supports.support : Support;
import core.supports.errors.err_status : ErrStatus;

/**
 * Authors: initkfs
 */

class NullSupport : Support
{
    this()
    {
        super(new ErrStatus);
    }
}
