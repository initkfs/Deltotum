module api.core.supports.decisions.decision_system;

import api.core.supports.decisions.base_decision : BaseDecision;

/**
 * Authors: initkfs
 */
class DecisionSystem
{
    BaseDecision[] decisions;

    void check()
    {
        foreach (dec; decisions)
        {
            foreach (rule; dec.rules)
            {
                if (rule.test)
                {
                    foreach (action; dec.actions)
                    {
                        if (action.canAccept(rule))
                        {
                            action.accept(rule);
                        }
                    }
                }
            }
        }
    }
}
