module cmd

import cli
import src.api
import src.template

fn stacks_list(command cli.Command, client api.Service, parser template.Service) ! {
	response := client.get_stacks()!
	println('${'ID':-5}${'ENDPOINT_ID':-12}${'SWARM_ID':-27}${'NAME'}')
	for item in response {
		println('${item.id:-5}${item.endpoint_id:-12}${item.swarm_id:-27}$item.name')
	}
}

fn stacks_list_command() cli.Command {
	mut flags := get_common_flags()
	return cli.Command{
		name: 'list'
		description: 'List stacks.'
		execute: command
		flags: flags
	}
}
