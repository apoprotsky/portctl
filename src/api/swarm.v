module api

import net.http
import src.entities

// get_swarm returns Swarm by endpoint_id
pub fn (s &Service) get_swarm(endpoint_id u32) !entities.Swarm {
	return s.call<Empty, entities.Swarm>('endpoints/$endpoint_id/docker/swarm', http.Method.get,
		Empty{})
}
