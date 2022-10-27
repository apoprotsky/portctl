module cmd

import cli
import src.api
import src.template

fn stacks_vars_get(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	name := command.flags.get_string('name')!
	variable := command.flags.get_string('variable')!
	stack := client.get_stack(endpoint_id, name) or {
		return error('stack $name not exists in endpoint $endpoint')
	}
	val := stack.get_variable_value(variable)
	if val == '' {
		return error('variable $variable not fount in stack $name, endpoint $endpoint')
	}
	print(val)
}

fn stacks_vars_get_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_stacks_name_flag()
	flags << get_stacks_variable_flag()
	return cli.Command{
		name: 'get'
		description: 'Get value of the stack variable.'
		execute: command_l3
		flags: flags
	}
}
