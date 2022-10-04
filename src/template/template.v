module template

import cli
import os

// new returns instance of template service
pub fn new(flags []cli.Flag) Service {
	return Service{
		flags: flags
	}
}

pub struct Service {
	flags []cli.Flag
}

// parse_file parses template ini file to string
pub fn (s &Service) parse_file(file string) ?string {
	if !os.exists(file) {
		return error('file $file not exists')
	}
	data := os.read_file(file)?
	return s.parse(data)
}

// parse_ini_file parses template ini file to map
pub fn (s &Service) parse_ini_file(file string) ?map[string]string {
	data := s.parse_file(file)?
	lines := data.replace('\r', '').split('\n')
	mut result := map[string]string{}
	for line in lines {
		parts := line.split('=')
		if parts.len < 2 {
			continue
		}
		result[parts[0].trim_space()] = parts[1].trim_space()
	}
	return result
}

fn (s &Service) get_flag(name string) string {
	return s.flags.get_string(name) or { return '' }
}
