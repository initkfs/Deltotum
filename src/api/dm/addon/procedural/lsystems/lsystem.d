module api.dm.addon.procedural.lsystems.lsystem;

struct LSystemData
{
    dstring startAxiom;
    dstring[dchar] rules;

    float step = 2;
    float angleDeg = 0;
    size_t generations = 1;
}

/**
 * Authors: initkfs
 */
dstring applyRules(const dstring axiom, const dstring[dchar] rules, size_t generations = 1, scope void delegate(
        size_t, dstring) onGeneration = null)
{

    //TODO linked list and inserts optimizations
    dstring result = axiom;

    foreach (i; 0 .. generations)
    {
        dstring temp;
        foreach (const ch; result)
        {
            if (const rulePtr = ch in rules)
            {
                temp ~= *rulePtr;
            }
            else
            {
                temp ~= ch;
            }
        }

        result = temp;

        if (onGeneration)
        {
            onGeneration(i, result);
        }
    }

    return result;
}

unittest
{
    import std;

    enum generations1 = 7;

    size_t ruleCount;
    applyRules("A", [
        'A': "AB",
        'B': "A"
    ], generations1, (i, result) {

        switch (i)
        {
            case 0:
                assert(result == "AB");
                break;
            case 1:
                assert(result == "ABA");
                break;
            case 2:
                assert(result == "ABAAB");
                break;
            case 3:
                assert(result == "ABAABABA");
                break;
            case 4:
                assert(result == "ABAABABAABAAB");
                break;
            case 5:
                assert(result == "ABAABABAABAABABAABABA");
                break;
            case 6:
                assert(result == "ABAABABAABAABABAABABAABAABABAABAAB");
                break;
            default:
                break;
        }

        ruleCount++;

    });

    assert(ruleCount == generations1);
}
