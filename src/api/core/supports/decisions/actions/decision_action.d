module api.core.supports.decisions.actions.decision_action;

import api.core.supports.decisions.rules.decision_rule: DecisionRule;

/**
 * Authors: initkfs
 */

abstract class DecisionAction
{
    bool canAccept(DecisionRule rule){
        return true;
    }

    bool accept(DecisionRule rule);
}
