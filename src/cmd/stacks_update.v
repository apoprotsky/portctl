module cmd

import cli
import os
import src.api
import src.common
import src.entities
import src.template

fn stacks_update(command cli.Command) ? {
	services := get_services(command.flags)
	client := services.get_service(common.ServicesNames.api)
	parser := services.get_service(common.ServicesNames.template)
	if client is api.Service && parser is template.Service {
		return stacks_update_work(command, client, parser)
	}
}

fn stacks_update_work(command cli.Command, client api.Service, parser template.Service) ? {
	endpoint := get_default_flag_value(env_portainer_endpoint)
	endpoint_id := client.get_endpoint_id_by_name(endpoint)?
	name := command.flags.get_string('name')?
	file := command.flags.get_string('file')?
	if !os.exists(file) {
		return error('file $file not exists')
	}
	content := os.read_file(file)?
	vars := command.flags.get_string('vars')?
	variables := parser.parse_ini_file(vars)?
	keys := variables.keys()
	mut env := []entities.StackVariable{}
	for key in keys {
		env << entities.StackVariable{
			name: key
			value: variables[key]
		}
	}
	prune := command.flags.get_bool('prune')?
	stack := client.get_stack_by_endpoint_id_and_name(endpoint_id, name) or {
		return error('stack $name not exists in endpoint $endpoint')
	}
	request := api.StackUpdateRequest{
		stack_file_content: content
		env: env
		prune: prune
	}
	client.update_stack(stack.id, endpoint_id, request)?
}

fn stacks_update_command() cli.Command {
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
		name: 'update'
		description: 'Update stack.'
		execute: stacks_update
		flags: flags
	}
}