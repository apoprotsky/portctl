module entities

pub struct Stack {
pub:
	id          u32    [json: Id]
	endpoint_id u32    [json: EndpointId]
	name        string [json: Name]
	swarm_id    string [json: SwarmId]
}

pub struct StackVariable {
	name  string
	value string
}
