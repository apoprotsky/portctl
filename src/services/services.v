module services

import cli
import src.common
import src.api
import src.template

// new returns instance of Services service
pub fn new(flags []cli.Flag) common.Services {
	return Services{
		flags: flags
	}
}

struct Services {
	flags []cli.Flag
}

// get_service returns instance of requested service
pub fn (s &Services) get_service(name common.ServicesNames) common.Service {
	mut svc := match name {
		.api { api.new(s.flags) }
		.template { template.new() }
	}
	svc.set_services(s)
	return svc
}

// get_flag returns value of requested flag
pub fn (s &Services) get_flag(name string) string {
	return s.flags.get_string(name) or { return '' }
}
