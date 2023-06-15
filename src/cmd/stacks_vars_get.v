module cmd

import cli
import api
import template

fn stacks_vars_get(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	name := command.flags.get_string('name')!
	variable := command.flags.get_string('variable')!
	skip_no_stack := command.flags.get_bool('skip-no-stack')!
	stack := client.get_stack(endpoint_id, name) or {
		message := 'stack ${name} not found in endpoint ${endpoint}'
		if skip_no_stack {
			eprintln('${message} ... SKIP')
			return
		}
		return error(message)
	}
	val := stack.get_variable_value(variable)
	if val == '' {
		return error('variable ${variable} not found in stack ${name}, endpoint ${endpoint}')
	}
	print(val)
}

fn stacks_vars_get_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_stacks_name_flag()
	flags << get_stacks_variable_flag()
	flags << get_stacks_skip_no_stack_flag()
	return cli.Command{
		name: 'get'
		description: 'Get value of the stack variable'
		execute: command_l3
		flags: flags
	}
}
