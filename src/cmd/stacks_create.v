module cmd

import cli
import os
import api
import entities
import template

fn stacks_create(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	name := command.flags.get_string('name')!
	swarm_id := client.get_swarm_id(endpoint_id)!
	file := command.flags.get_string('file')!
	if !os.exists(file) {
		return error('file ${file} not exists')
	}
	content := os.read_file(file)!
	vars := command.flags.get_string('vars')!
	variables := parser.parse_ini_file(vars)!
	keys := variables.keys()
	mut env := []entities.StackVariable{}
	for key in keys {
		env << entities.StackVariable{
			name:  key
			value: variables[key]
		}
	}
	client.get_stack(endpoint_id, name) or {
		request := api.StackCreateRequest{
			name:               name
			swarm_id:           swarm_id
			stack_file_content: content
			env:                env
		}
		eprint('Stack ${name} not found in endpoint ${endpoint}, creating ... ')
		client.create_stack(endpoint_id, request)!
		eprintln('OK')
		return
	}
	return error('stack ${name} already exists in endpoint ${endpoint}')
}

fn stacks_create_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_vault_flags()
	flags << get_stacks_flags()
	return cli.Command{
		name:        'create'
		description: 'Create stack'
		execute:     command
		flags:       flags
	}
}
