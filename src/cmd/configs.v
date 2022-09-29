module cmd

import cli

fn configs(command cli.Command) ? {
	command.execute_help()
}

fn configs_command() cli.Command {
	return cli.Command{
		name: 'configs'
		description: 'Configs management.'
		execute: configs
		commands: [
			configs_list_command(),
			configs_create_command(),
		]
	}
}
