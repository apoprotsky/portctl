module entities

pub struct StackVariable {
pub:
	name  string
	value string
}

type StackEnvironment = []StackVariable

// update_variable returns new StackEnvironment with updated variable
pub fn (se []StackVariable) update_variable(name string, value string) StackEnvironment {
	func := fn [name, value] (item StackVariable) StackVariable {
		if item.name == name {
			return StackVariable{
				name: name
				value: value
			}
		}
		return item
	}
	return se.map(func)
}

pub struct Stack {
pub:
	id          u32             [json: Id]
	endpoint_id u32             [json: EndpointId]
	name        string          [json: Name]
	swarm_id    string          [json: SwarmId]
	env         []StackVariable [json: Env]
}

// get_variable_value returns value of Stack envinment by name
pub fn (s Stack) get_variable_value(name string) string {
	for item in s.env {
		if item.name == name {
			return item.value
		}
	}
	return ''
}

pub struct StackFile {
pub:
	content string [json: StackFileContent]
}
