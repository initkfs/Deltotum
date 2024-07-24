module app.core.supports.errors.err_status;

/**
 * Authors: initkfs
 */
class ErrStatus
{
    protected
    {
        string[] errors;
        bool _error;
    }

    void error(string err)
    {
        //TODO hash and duplicates
        errors ~= err;
        if (!_error)
        {
            _error = true;
        }
    }

    bool isError() const pure @safe
    {
        return _error;
    }

}
