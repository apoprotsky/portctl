module cmd

import cli
import os
import src.api
import src.common
import src.entities
import src.template

fn stacks_create(command cli.Command) ? {
	services := get_services(command.flags)
	client := services.get_service(common.ServicesNames.api)
	parser := services.get_service(common.ServicesNames.template)
	if client is api.Service && parser is template.Service {
		return stacks_create_work(command, client, parser)
	}
}

fn stacks_create_work(command cli.Command, client api.Service, parser template.Service) ? {
	endpoint := get_default_flag_value(env_portainer_endpoint)
	endpoint_id := client.get_endpoint_id_by_name(endpoint)?
	name := command.flags.get_string('name')?
	swarm_id := client.get_swarm_id_by_endpoint_id(endpoint_id)?
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
	client.get_stack_by_endpoint_id_and_name(endpoint_id, name) or {
		request := api.StackPostRequest{
			name: name
			swarm_id: swarm_id
			stack_file_content: content
			env: env
		}
		client.create_stack(endpoint_id, request)?
		return
	}
	return error('stack $name already exists in endpoint $endpoint')
}

fn stacks_create_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_vault_flags()
	flags << cli.Flag{
		flag: .string
		name: 'name'
		abbrev: 'n'
		description: 'Stack name'
		required: true
	}
	flags << cli.Flag{
		flag: .string
		name: 'file'
		abbrev: 'f'
		description: 'Stack file'
		required: true
	}
	flags << cli.Flag{
		flag: .string
		name: 'vars'
		abbrev: 'v'
		description: 'Stack variables'
		required: true
	}
	return cli.Command{
		name: 'create'
		description: 'Create stack.'
		execute: stacks_create
		flags: flags
	}
}
