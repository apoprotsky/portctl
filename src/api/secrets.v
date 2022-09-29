module api

import net.http
import src.common

struct SecretSpec {
pub:
	name string [json: Name]
}

pub struct Secret {
pub:
	id   string     [json: ID]
	spec SecretSpec [json: Spec]
}

pub struct SecretPostRequest {
pub:
	name string [json: Name]
	data string [json: Data]
}

// get_secrets returns array of Secret
pub fn (s &Service) get_secrets(endpoint_id u32) ?[]Secret {
	return s.call<common.Empty, []Secret>('endpoints/$endpoint_id/docker/secrets', http.Method.get,
		common.Empty{})
}

// get_secret_by_name returns Secret by name
pub fn (s &Service) get_secret_by_name(endpoint_id u32, name string) ?Secret {
	response := s.get_secrets(endpoint_id)?
	for secret in response {
		if secret.spec.name == name {
			return secret
		}
	}
	return error('secret not found')
}

// create_secret creates new Secret
pub fn (s &Service) create_secret(endpoint_id u32, data SecretPostRequest) ? {
	s.call<SecretPostRequest, common.Empty>('endpoints/$endpoint_id/docker/secrets/create',
		http.Method.post, data)?
}
