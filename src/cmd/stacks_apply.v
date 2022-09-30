module cmd

import cli
import src.api
import src.common
import src.template

fn stacks_apply(command cli.Command) ? {
	services := get_services(command.flags)
	client := services.get_service(common.ServicesNames.api)
	parser := services.get_service(common.ServicesNames.template)
	if client is api.Service && parser is template.Service {
		return stacks_apply_work(command, client, parser)
	}
}

fn stacks_apply_work(command cli.Command, client api.Service, parser template.Service) ? {
	endpoint := command.flags.get_string('endpoint')?
	endpoint_id := client.get_endpoint_id_by_name(endpoint)?
	name := command.flags.get_string('name')?
	client.get_stack_by_endpoint_id_and_name(endpoint_id, name) or {
		stacks_create_work(command, client, parser)?
		return
	}
	stacks_update_work(command, client, parser)?
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
		description: 'Create or upate stack.'
		execute: stacks_apply
		flags: flags
	}
}
