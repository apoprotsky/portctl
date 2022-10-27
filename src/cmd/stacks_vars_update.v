module cmd

import cli
import src.api
import src.template

fn stacks_vars_update(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	name := command.flags.get_string('name')!
	variable := command.flags.get_string('variable')!
	value := command.flags.get_string('value')!
	stack := client.get_stack(endpoint_id, name) or {
		return error('stack $name not exists in endpoint $endpoint')
	}
	val := stack.get_variable_value(variable)
	if val == '' {
		return error('variable $variable not fount in stack $name, endpoint $endpoint')
	}
	if value != val {
		request := api.StackUpdateRequest{
			stack_file_content: client.get_stack_file(stack.id)!
			env: stack.env.update_variable(variable, value)
			prune: false
		}
		eprint('Stack $name found in endpoint $endpoint, updating variable $variable ... ')
		client.update_stack(endpoint_id, stack.id, request)!
		eprintln('OK')
	} else {
		eprintln('Variable $variable in stack $name, endpoint $endpoint already has value $value, nothing to do ... OK')
	}
}

fn stacks_vars_update_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_stacks_name_flag()
	flags << get_stacks_variable_flag()
	flags << cli.Flag{
		flag: .string
		name: 'value'
		abbrev: 'val'
		description: 'Variable value'
		required: true
	}
	return cli.Command{
		name: 'update'
		description: 'Update value of the stack variable.'
		execute: command_l3
		flags: flags
	}
}
