module api.dm.addon.procedural.lsystems.lsystem_parser;

import api.dm.addon.procedural.lsystems.lsystem : applyRules;

/**
 * Authors: initkfs
 */
class LSystemParser
{
    void delegate() onMoveDraw;
    void delegate() onMove;
    void delegate() onRotateRight;
    void delegate() onRotateLeft;
    void delegate() onSaveState;
    bool delegate() onRestoreState;
    void delegate(dchar) onConstant;

    void parse(const dstring startAxiom, const dstring[dchar] rules, size_t generations = 1)
    {
        const result = applyRules(startAxiom, rules, generations);

        foreach (commandChar; result)
        {
            switch (commandChar)
            {
                case 'A', 'B', 'F', 'G', '0', '1':
                    if (onMoveDraw)
                    {
                        onMoveDraw();
                    }
                    break;
                case 'f':
                    if (onMove)
                    {
                        onMove();
                    }
                    break;
                case '+':
                    if (onRotateRight)
                    {
                        onRotateRight();
                    }
                    break;
                case '-':
                    if (onRotateLeft)
                    {
                        onRotateLeft();
                    }
                    break;
                case '[':
                    if (onSaveState)
                    {
                        onSaveState();
                    }
                    break;
                case ']':
                    if (onRestoreState)
                    {
                        onRestoreState();
                    }
                    break;
                default:
                    if (onConstant)
                    {
                        onConstant(commandChar);
                    }
                    break;
            }
        }
    }
}
