module api

import net.http
import src.entities
import src.common

pub struct StackPostRequest {
pub:
	name               string
	swarm_id           string                   [json: swarmID]
	stack_file_content string                   [json: stackFileContent]
	env                []entities.StackVariable [json: env]
}

// get_stacks returns array of Stack
pub fn (s &Service) get_stacks() ?[]entities.Stack {
	return s.call<common.Empty, []entities.Stack>('stacks', http.Method.get, common.Empty{})
}

// get_stack_by_endpoint_id_and_name returns Stack by endpoint_id and name
pub fn (s &Service) get_stack_by_endpoint_id_and_name(endpoint_id u32, name string) ?entities.Stack {
	response := s.get_stacks()?
	for item in response {
		if item.endpoint_id == endpoint_id && item.name == name {
			return item
		}
	}
	return error('stack not found')
}

// get_swarm_id_by_endpoint_id returns swarm_id by endpoint_id
pub fn (s &Service) get_swarm_id_by_endpoint_id(endpoint_id u32) ?string {
	response := s.get_stacks()?
	for item in response {
		if item.endpoint_id == endpoint_id {
			return item.swarm_id
		}
	}
	return error('stack not found')
}

// create_stack creates new stack
pub fn (s &Service) create_stack(endpoint_id u32, data StackPostRequest) ? {
	typ := 1 // Swarm stack
	method := 'string' // Stack data passed as string
	s.call<StackPostRequest, common.Empty>('stacks?type=$typ&method=$method&endpointId=$endpoint_id',
		http.Method.post, data)?
}
