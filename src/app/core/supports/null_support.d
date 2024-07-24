module app.core.supports.null_support;

import app.core.supports.support : Support;
import app.core.supports.errors.err_status : ErrStatus;

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
