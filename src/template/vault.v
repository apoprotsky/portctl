module template

import net.http
import json

struct VaultKVData {
	data map[string]string
}

struct VaultKVResponse {
	data VaultKVData
}

fn (s Service) get_vault_variable(name string) string {
	vault_addr := s.get_flag('vault-addr')
	vault_token := s.get_flag('vault-token')
	parts := name.split('.')
	if parts.len < 2 {
		eprintln('Field name of Vault secret is not specified: $name')
		exit(1)
	}
	path := parts[0].replace_once('/', '/data/')
	field := parts[1]
	url := '$vault_addr/v1/$path'
	mut header := http.new_header()
	header.add_custom('X-Vault-Token', vault_token) or {
		eprintln(err.msg())
		exit(1)
	}
	config := http.FetchConfig{
		url: url
		method: http.Method.get
		header: header
	}
	result := http.fetch(config) or {
		eprintln(err.msg())
		exit(1)
	}
	status := http.Status.ok
	if status.int() == result.status_code {
		response := json.decode(VaultKVResponse, result.body) or {
			eprintln(err.msg())
			exit(1)
		}
		value := response.data.data[field] or {
			eprintln('Field $field not found in Vault secret ${parts[0]}')
			exit(1)
		}
		return value
	}
	eprintln('Error in Vault API call for $name: $result.status_code $result.status_msg\nResponse: $result.body')
	exit(1)
}
