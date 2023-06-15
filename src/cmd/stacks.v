module cmd

import cli

fn stacks(command cli.Command) ! {
	command.execute_help()
}

fn stacks_command() cli.Command {
	return cli.Command{
		name: 'stacks'
		description: 'Stacks management'
		execute: stacks
		commands: [
			stacks_apply_command(),
			stacks_create_command(),
			stacks_delete_command(),
			stacks_list_command(),
			stacks_update_command(),
			stacks_vars_command(),
		]
	}
}

fn get_stacks_name_flag() []cli.Flag {
	default_stack := get_default_flag_value(env_portainer_stack)
	return [
		cli.Flag{
			flag: .string
			name: 'name'
			abbrev: 'n'
			description: 'Stack name'
			required: default_stack.len == 0
			default_value: [default_stack]
		},
	]
}

fn get_stacks_variable_flag() []cli.Flag {
	return [
		cli.Flag{
			flag: .string
			name: 'variable'
			abbrev: 'var'
			description: 'Variable name'
			required: true
		},
	]
}

fn get_stacks_skip_no_stack_flag() []cli.Flag {
	return [
		cli.Flag{
			flag: .bool
			name: 'skip-no-stack'
			description: 'Do not raise error if stack not found'
		},
	]
}

fn get_stacks_flags() []cli.Flag {
	mut flags := get_stacks_name_flag()
	flags << [
		cli.Flag{
			flag: .string
			name: 'file'
			abbrev: 'f'
			description: 'Stack file'
			required: true
		},
		cli.Flag{
			flag: .string
			name: 'vars'
			abbrev: 'v'
			description: 'Stack variables'
			required: true
		},
	]
	return flags
}
