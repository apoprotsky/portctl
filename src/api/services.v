module api

import net.http
import entities

// get_services returns array of Services
pub fn (s Service) get_services(endpoint_id u32) ![]entities.Service {
	return s.call[Empty, []entities.Service]('endpoints/${endpoint_id}/docker/services',
		http.Method.get, Empty{})
}

// get_service returns Service with raw spec by endpoint_id and service name or id
pub fn (s Service) get_service(endpoint_id u32, name string) !entities.ServiceInspect {
	return s.call[Empty, entities.ServiceInspect]('endpoints/${endpoint_id}/docker/services/${name}',
		http.Method.get, Empty{})
}

// update_service replaces spec of Service by endpoint_id, id and version
pub fn (s Service) update_service(endpoint_id u32, id string, version u64, spec string) !entities.ServiceUpdateResponse {
	return s.call_raw[entities.ServiceUpdateResponse]('endpoints/${endpoint_id}/docker/services/${id}/update?version=${version}',
		http.Method.post, spec)
}
