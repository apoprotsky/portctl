module common

pub enum ServicesNames {
	api
	template
}

pub interface Service {
mut:
	set_services(services Services)
}

pub interface Services {
	get_service(name ServicesNames) Service
	get_flag(name string) string
}

pub struct EmptyService {}

fn (s EmptyService) set_services(services Services) {}

pub struct EmptyServices {}

fn (s EmptyServices) get_service(name ServicesNames) Service {
	return EmptyService{}
}

fn (s EmptyServices) get_flag(name string) string {
	return ''
}
