module api.core.validations.errors.err_status;

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

    void delegate(string)[] onNewError;

    void error(string err)
    {
        //TODO hash and duplicates
        errors ~= err;
        if (!_error)
        {
            _error = true;
        }

        foreach (dg; onNewError)
        {
            dg(err);
        }
    }

    bool isError() const pure @safe
    {
        return _error;
    }

}
