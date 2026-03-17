module api.dm.kit.domains.domain_set;

import api.dm.kit.domains.phys.mech : Mech;
import api.dm.kit.domains.phys.therm : Therm;

/*
 * Authors: initkfs
 */

class DomainSet
{
    protected
    {
        Mech _mech;
        Therm _therm;
    }

    bool hasMech() => _therm !is null;
    Mech mech()
    {
        assert(_mech, "Mechanics is null");
        return _mech;
    }

    void mech(Mech value)
    {
        assert(value);
        _mech = value;
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
