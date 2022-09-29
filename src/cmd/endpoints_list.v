module cmd

import cli
import src.common
import src.api

fn endpoints_list(command cli.Command) ? {
	services := get_services(command.flags)
	client := services.get_service(common.ServicesNames.api)
	if client is api.Service {
		response := client.get_endpoints()?
		println('${'ID':-5}${'NAME':-15}${'URL':-20}')
		for endpoint in response {
			println('${endpoint.id:-5}${endpoint.name:-15}${endpoint.url:-20}')
		}
	}
}

fn endpoints_list_command() cli.Command {
	flags := get_common_flags()
	return cli.Command{
		name: 'list'
		description: 'List endpoints.'
		execute: endpoints_list
		flags: flags
	}
}
