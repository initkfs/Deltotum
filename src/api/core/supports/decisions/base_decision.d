module api.core.supports.decisions.base_decision;

import api.core.supports.decisions.rules.decision_rule : DecisionRule;
import api.core.supports.decisions.actions.decision_action : DecisionAction;

/**
 * Authors: initkfs
 */
class BaseDecision
{
    DecisionRule[] rules;
    DecisionAction[] actions;
}
