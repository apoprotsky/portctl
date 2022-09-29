module cmd

import cli

fn secrets(command cli.Command) ? {
	command.execute_help()
}

fn secrets_command() cli.Command {
	return cli.Command{
		name: 'secrets'
		description: 'Secrets management.'
		execute: secrets
		commands: [
			secrets_list_command(),
			secrets_create_command(),
		]
	}
}
