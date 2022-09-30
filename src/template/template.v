module template

import os
import src.common

// new returns instance of template service
pub fn new() common.Service {
	return Service{}
}

pub struct Service {
mut:
	services common.Services = common.EmptyServices{}
}

// set_services updates services field
pub fn (mut s Service) set_services(services common.Services) {
	s.services = services
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
