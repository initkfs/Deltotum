module dm.core.supports.support;

import dm.core.supports.errors.err_status: ErrStatus;

/**
 * Authors: initkfs
 */

class Support
{
    ErrStatus errStatus;

    this(ErrStatus errStatus)
    {
        this.errStatus = errStatus;
    }
}
