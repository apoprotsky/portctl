module entities

pub struct StackVariable {
pub:
	name  string
	value string
}

type StackEnvironment = []StackVariable

// set_variable returns new StackEnvironment with setteled variable
pub fn (se []StackVariable) set_variable(name string, value string) StackEnvironment {
	mut exists := false
	mut result := []StackVariable{}
	for item in se {
		if item.name == name {
			exists = true
			result << StackVariable{
				name: name
				value: value
			}
		} else {
			result << item
		}
	}
	if !exists {
		result << StackVariable{
			name: name
			value: value
		}
	}
	return result
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
