module api.core.supports.decisions.rules.decision_rule;

/**
 * Authors: initkfs
 */
enum DecisionRuleType
{
    mandatory,
    optional
}

abstract class DecisionRule
{
    DecisionRuleType type;

    bool test();
}
