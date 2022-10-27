module cmd

import cli

fn stacks_vars(command cli.Command) {
	command.execute_help()
}

fn stacks_vars_command() cli.Command {
	return cli.Command{
		name: 'vars'
		description: 'Manage stack variables.'
		execute: stacks_vars
		commands: [
			stacks_vars_get_command(),
			stacks_vars_update_command(),
		]
	}
}
