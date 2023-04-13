module api

import net.http

struct ConfigSpec {
pub:
	name   string            [json: Name]
	labels map[string]string [json: Labels]
	data   string            [json: Data]
}

pub struct Config {
pub:
	id         string     [json: ID]
	created_at string     [json: CreatedAt]
	updated_at string     [json: UpdatedAt]
	spec       ConfigSpec [json: Spec]
}

pub struct ConfigPostRequest {
pub:
	name   string            [json: Name]
	labels map[string]string [json: Labels]
	data   string            [json: Data]
}

// get_configs returns array of Config
pub fn (s Service) get_configs(endpoint_id u32) ![]Config {
	return s.call[Empty, []Config]('endpoints/${endpoint_id}/docker/configs', http.Method.get,
		Empty{})
}

// get_configs_staled returns array of Config by label value
pub fn (s Service) get_configs_staled(endpoint_id u32, label string, value string, exclude []string) ![]Config {
	swarm := s.get_swarm(endpoint_id)!
	mut response := s.get_configs(endpoint_id)!
	response.sort(a.updated_at > b.updated_at)
	mut configs := []Config{}
	mut count := 0
	for config in response {
		val := config.spec.labels[label] or { continue }
		if val == value && config.spec.name !in exclude {
			if count < swarm.spec.orchestration.task_history_retention_limit {
				count++
				continue
			}
			configs << config
		}
	}
	return configs
}

// get_config returns Config by name
pub fn (s Service) get_config(endpoint_id u32, name string) !Config {
	response := s.get_configs(endpoint_id)!
	for config in response {
		if config.spec.name == name {
			return config
		}
	}
	return error('config not found')
}

// create_config creates new Config
pub fn (s Service) create_config(endpoint_id u32, data ConfigPostRequest) ! {
	s.call[ConfigPostRequest, Empty]('endpoints/${endpoint_id}/docker/configs/create',
		http.Method.post, data)!
}

// delete_config deletes Config by id
pub fn (s Service) delete_config(endpoint_id u32, id string) ! {
	s.call[Empty, Empty]('endpoints/${endpoint_id}/docker/configs/${id}', http.Method.delete,
		Empty{})!
}
