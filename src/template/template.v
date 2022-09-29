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

// parse_file reads template from file and
pub fn (s &Service) parse_file(file string) ?string {
	if !os.exists(file) {
		return error('file $file not exists')
	}
	data := os.read_file(file)?
	return s.parse(data)
}
