module api.sims.ele.components.connects.connection_node;

import api.sims.ele.components.base_component : BaseComponent;
import api.sims.ele.components.connects.connector_two_pin: ConnectorTwoPin;

class ConnectionNode : BaseComponent
{
    ConnectorTwoPin[] fromPins;
    ConnectorTwoPin[] toPins;
}