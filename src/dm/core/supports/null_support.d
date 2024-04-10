module dm.core.supports.null_support;

import dm.core.supports.support : Support;
import dm.core.supports.errors.err_status : ErrStatus;

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
