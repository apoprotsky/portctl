module api

import net.http

struct ConfigSpec {
pub:
	name string [json: Name]
	data string [json: Data]
}

pub struct Config {
pub:
	id   string     [json: ID]
	spec ConfigSpec [json: Spec]
}

pub struct ConfigPostRequest {
pub:
	name string [json: Name]
	data string [json: Data]
}

// get_configs returns array of Config
pub fn (s &Service) get_configs(endpoint_id u32) ?[]Config {
	return s.call<Empty, []Config>('endpoints/$endpoint_id/docker/configs', http.Method.get,
		Empty{})
}

// get_config returns Config by name
pub fn (s &Service) get_config(endpoint_id u32, name string) ?Config {
	response := s.get_configs(endpoint_id)?
	for config in response {
		if config.spec.name == name {
			return config
		}
	}
	return error('config not found')
}

// create_config creates new Config
pub fn (s &Service) create_config(endpoint_id u32, data ConfigPostRequest) ? {
	s.call<ConfigPostRequest, Empty>('endpoints/$endpoint_id/docker/configs/create', http.Method.post,
		data)?
}

// delete_config deletes Config by id
pub fn (s &Service) delete_config(endpoint_id u32, id string) ? {
	s.call<Empty, Empty>('endpoints/$endpoint_id/docker/configs/$id', http.Method.delete,
		Empty{})?
}
