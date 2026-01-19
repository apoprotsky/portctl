module cmd

import cli
import api
import template

fn configs_list(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	response := client.get_configs(endpoint_id)!
	println('${'ID':-30}${'NAME'}')
	for item in response {
		println('${item.id:-30}${item.spec.name}')
	}
}

fn configs_list_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	return cli.Command{
		name:        'list'
		description: 'List configs'
		execute:     command
		flags:       flags
	}
}
