module cmd

import cli
import api
import template

fn stacks_delete(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	name := command.flags.get_string('name')!
	stack := client.get_stack(endpoint_id, name) or {
		eprintln('Stack ${name} not found, nothing to do ... OK')
		return
	}
	eprint('Stack ${name} found, deleting ... ')
	client.delete_stack(endpoint_id, stack.id)!
	eprintln('OK')
}

fn stacks_delete_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_stacks_name_flag()
	return cli.Command{
		name: 'delete'
		description: 'Delete stack'
		execute: command
		flags: flags
	}
}
