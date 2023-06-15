module api

import entities
import net.http

// get_endpoints returns array of Endpoint structures
pub fn (s Service) get_endpoints() ![]entities.Endpoint {
	return s.call[Empty, []entities.Endpoint]('endpoints', http.Method.get, Empty{})
}

// get_endpoint_id_by_name returns ID of endpoint by name
pub fn (s Service) get_endpoint_id_by_name(name string) !u32 {
	response := s.get_endpoints()!
	for endpoint in response {
		if endpoint.name == name {
			return endpoint.id
		}
	}
	return error('endpoint not found')
}
