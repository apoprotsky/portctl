module cmd

import cli

fn endpoints(command cli.Command) ? {
	command.execute_help()
}

fn endpoints_command() cli.Command {
	return cli.Command{
		name: 'endpoints'
		description: 'Endpoints management.'
		execute: endpoints
		commands: [
			endpoints_list_command(),
		]
	}
}
