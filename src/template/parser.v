module template

import os
import regex

fn (s &Service) parse(data string) ?string {
	mut re := regex.regex_opt('\$\\{(env)|(vault):[-_a-zA-Z0-9\\/\\.]+\\}')?
	return re.replace_by_fn(data, s.parse_variables)
}

fn (s Service) parse_variables(re regex.RE, data string, start int, end int) string {
	parts := data[start + 2..end - 1].split(':')
	return match parts[0] {
		'env' { s.get_enviroment_variable(parts[1]) }
		'vault' { s.get_vault_variable(parts[1]) }
		else { '' }
	}
}

fn (s &Service) get_enviroment_variable(name string) string {
	return os.getenv_opt(name) or { return '' }
}
