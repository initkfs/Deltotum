module api.dm.kit.domains.domain_set;

import api.dm.kit.domains.phys.therm : Therm;

/*
 * Authors: initkfs
 */

class DomainSet
{
    protected
    {
        Therm _therm;
    }

    bool hasTherm() => _therm !is null;
    Therm therm()
    {
        assert(_therm, "Therm is null");
        return _therm;
    }

    void therm(Therm value)
    {
        assert(value);
        _therm = value;
    }
}
