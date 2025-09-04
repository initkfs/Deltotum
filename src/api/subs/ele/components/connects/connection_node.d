module api.subs.ele.components.connects.connection_node;

import api.subs.ele.components.base_component : BaseComponent;
import api.subs.ele.components.connects.connector_two_pin: ConnectorTwoPin;

class ConnectionNode : BaseComponent
{
    ConnectorTwoPin[] fromPins;
    ConnectorTwoPin[] toPins;
}