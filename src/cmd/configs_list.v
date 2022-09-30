module cmd

import cli
import src.common
import src.api

fn configs_list(command cli.Command) ? {
	services := get_services(command.flags)
	client := services.get_service(common.ServicesNames.api)
	if client is api.Service {
		endpoint := command.flags.get_string('endpoint')?
		endpoint_id := client.get_endpoint_id_by_name(endpoint)?
		response := client.get_configs(endpoint_id)?
		println('${'ID':-30}${'NAME'}')
		for item in response {
			println('${item.id:-30}$item.spec.name')
		}
	}
}

fn configs_list_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	return cli.Command{
		name: 'list'
		description: 'List configs.'
		execute: configs_list
		flags: flags
	}
}
