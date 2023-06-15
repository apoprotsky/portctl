module api

import net.http
import entities

// get_services returns array of Services
pub fn (s Service) get_services(endpoint_id u32) ![]entities.Service {
	return s.call[Empty, []entities.Service]('endpoints/${endpoint_id}/docker/services',
		http.Method.get, Empty{})
}
