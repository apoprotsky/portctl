module template

import os
import regex

fn (s Service) parse(data string) !string {
	mut re := regex.regex_opt('\\{\\{\\s*(env)|(vault)\\s*:\\s*[-_a-zA-Z0-9\\/\\.]+\\s*\\}\\}') or {
		return error('cannot create regular expression object to parse template')
	}
	return re.replace_by_fn(data, s.parse_variables)
}

fn (s Service) parse_variables(re regex.RE, data string, start int, end int) string {
	parts := data[start + 2..end - 2].split(':')
	source := parts[0].trim_space()
	name := parts[1].trim_space()
	return match source {
		'env' { s.get_enviroment_variable(name) }
		'vault' { s.get_vault_variable(name) }
		else { '' }
	}
}

fn (s Service) get_enviroment_variable(name string) string {
	return os.getenv_opt(name) or { return '' }
}
