module cmd

import cli
import api
import template

fn stacks_apply(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	name := command.flags.get_string('name')!
	client.get_stack(endpoint_id, name) or {
		stacks_create(command, client, parser)!
		return
	}
	stacks_update(command, client, parser)!
}

fn stacks_apply_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_vault_flags()
	flags << get_stacks_flags()
	flags << cli.Flag{
		flag: .bool
		name: 'prune'
		abbrev: 'p'
		description: 'Prune stack services'
		default_value: ['true']
	}
	return cli.Command{
		name: 'apply'
		description: 'Create or upate stack'
		execute: command
		flags: flags
	}
}
