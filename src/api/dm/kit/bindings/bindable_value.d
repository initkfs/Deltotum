module api.dm.kit.bindings.bindable_value;

/**
 * Authors: initkfs
 */
mixin template BindableValue(Value, Value initValue = Value.init)
{
    Value value = initValue;

    private
    {
        bool _bound;
        typeof(this)*[] otherValues;
    }

    alias value this;

    //Should be more strict than the sprite destructor
    ~this() @nogc pure @safe nothrow
    {
        if (_bound)
        {
            // debug
            // {
            //     import std.stdio : stderr;

            //     stderr.writeln("Error. Unbound value: ", this);
            // }
            unbind;
        }
    }

    private void changeValue(Value v) @nogc nothrow pure @safe
    {
        value = v;
        if (otherValues.length > 0)
        {
            foreach (otherValue; otherValues)
            {
                // if (otherValue.isBound(&this))
                // {
                // }
                otherValue.opAssign(v);
            }
        }
    }

    void opAssign(Value v) @nogc nothrow pure @safe
    {
        changeValue(v);
    }

    void opAssign(typeof(this) v) @nogc nothrow pure @safe
    {
        changeValue(v);
    }

    void opUnary(string op)()
    {
        //not value++ self-reference
        static if (op == "--")
            changeValue(value - 1);
        else static if (op == "++")
            changeValue(value + 1);
        else static if (op == "-")
            changeValue(0 - value);
        else
            static assert(0, "Operator " ~ op ~ " not implemented");
    }

    void opOpAssign(string op)(Value rhs)
    {
        mixin("changeValue(value", op, "rhs);");
    }

    typeof(this) bind(typeof(this)*[] others...) nothrow pure @safe
    {
        _bound = true;
        foreach (other; others)
        {
            //TODO canFind
            otherValues ~= other;
        }

        return this;
    }

    bool unbind() @nogc nothrow pure @safe
    {
        if (!_bound)
        {
            return false;
        }
        _bound = false;
        otherValues = null;
        return true;
    }

    bool isBound() const @nogc nothrow pure @safe
    {
        return _bound;
    }

    bool isBound(scope typeof(this)* other) const @nogc nothrow pure @safe
    {
        foreach (v; otherValues)
        {
            if (v is other)
            {
                return true;
            }
        }
        return false;
    }

    void dispose() @nogc nothrow pure @safe
    {
        unbind;
    }

    string toString() const
    {
        import std.format : format;

        return format("%s: %s, bound: %s (%s)", typeof(this).stringof, value, isBound, otherValues.length);
    }
}
