module api

import entities
import net.http

pub struct SecretPostRequest {
pub:
	name   string            [json: Name]
	labels map[string]string [json: Labels]
	data   string            [json: Data]
}

// get_secrets returns array of Secret
pub fn (s Service) get_secrets(endpoint_id u32) ![]entities.Secret {
	return s.call[Empty, []entities.Secret]('endpoints/${endpoint_id}/docker/secrets',
		http.Method.get, Empty{})!
}

// get_secrets_staled returns array of Secret by label value
pub fn (s Service) get_secrets_staled(endpoint_id u32, label string, value string, exclude []string) ![]entities.Secret {
	swarm := s.get_swarm(endpoint_id)!
	mut response := s.get_secrets(endpoint_id)!
	response.sort(a.updated_at > b.updated_at)
	mut secrets := []entities.Secret{}
	mut count := 0
	for secret in response {
		val := secret.spec.labels[label] or { continue }
		if val == value && secret.spec.name !in exclude {
			if count < swarm.spec.orchestration.task_history_retention_limit {
				count++
				continue
			}
			secrets << secret
		}
	}
	return secrets
}

// get_secret_by_name returns Secret by name
pub fn (s Service) get_secret_by_name(endpoint_id u32, name string) !entities.Secret {
	response := s.get_secrets(endpoint_id)!
	for secret in response {
		if secret.spec.name == name {
			return secret
		}
	}
	return error('secret not found')
}

// create_secret creates new Secret
pub fn (s Service) create_secret(endpoint_id u32, data SecretPostRequest) ! {
	s.call[SecretPostRequest, Empty]('endpoints/${endpoint_id}/docker/secrets/create',
		http.Method.post, data)!
}

// delete_secret deletes Secret by id
pub fn (s Service) delete_secret(endpoint_id u32, id string) ! {
	s.call[Empty, Empty]('endpoints/${endpoint_id}/docker/secrets/${id}', http.Method.delete,
		Empty{})!
}
