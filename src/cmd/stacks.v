module cmd

import cli

fn stacks(command cli.Command) ? {
	command.execute_help()
}

fn stacks_command() cli.Command {
	return cli.Command{
		name: 'stacks'
		description: 'Stacks management.'
		execute: stacks
		commands: [
			stacks_list_command(),
			stacks_create_command(),
		]
	}
}
