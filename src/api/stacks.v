module api

import net.http
import src.entities

pub struct StackCreateRequest {
pub:
	name               string
	swarm_id           string                   [json: swarmID]
	stack_file_content string                   [json: stackFileContent]
	env                []entities.StackVariable [json: env]
}

pub struct StackUpdateRequest {
pub:
	stack_file_content string                   [json: stackFileContent]
	env                []entities.StackVariable [json: env]
	prune              bool
}

// get_stacks returns array of Stack
pub fn (s &Service) get_stacks() ?[]entities.Stack {
	return s.call<Empty, []entities.Stack>('stacks', http.Method.get, Empty{})
}

// get_stack returns Stack by endpoint_id and name
pub fn (s &Service) get_stack(endpoint_id u32, name string) ?entities.Stack {
	response := s.get_stacks()?
	for item in response {
		if item.endpoint_id == endpoint_id && item.name == name {
			return item
		}
	}
	return error('stack not found')
}

// get_swarm_id returns swarm_id by endpoint_id
pub fn (s &Service) get_swarm_id(endpoint_id u32) ?string {
	response := s.get_stacks()?
	for item in response {
		if item.endpoint_id == endpoint_id {
			return item.swarm_id
		}
	}
	return error('stack not found')
}

// create_stack creates new stack
pub fn (s &Service) create_stack(endpoint_id u32, data StackCreateRequest) ? {
	typ := 1 // Swarm stack
	method := 'string' // Stack data passed as string
	s.call<StackCreateRequest, Empty>('stacks?type=$typ&method=$method&endpointId=$endpoint_id',
		http.Method.post, data)?
}

// update_stack updates existing stack
pub fn (s &Service) update_stack(endpoint_id u32, stack_id u32, data StackUpdateRequest) ? {
	s.call<StackUpdateRequest, Empty>('stacks/$stack_id?endpointId=$endpoint_id', http.Method.put,
		data)?
}

// delete_stack deletes existing stack
pub fn (s &Service) delete_stack(endpoint_id u32, stack_id u32) ? {
	s.call<Empty, Empty>('stacks/$stack_id?endpointId=$endpoint_id', http.Method.delete,
		Empty{})?
}
