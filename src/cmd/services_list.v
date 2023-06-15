module cmd

import cli
import api
import template

fn services_list(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	response := client.get_services(endpoint_id)!
	println('${'ID':-25}  ${'NAME':-40}  ${'IMAGE'}')
	for item in response {
		image := item.spec.task_template.spec.image.split('@')[0]
		println('${item.id:-25}  ${item.spec.name:-40}  ${image}')
	}
}

fn services_list_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	return cli.Command{
		name: 'list'
		description: 'List services'
		execute: command
		flags: flags
	}
}
