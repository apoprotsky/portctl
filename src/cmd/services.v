module cmd

import cli

fn services(command cli.Command) ! {
	command.execute_help()
}

fn services_command() cli.Command {
	return cli.Command{
		name:        'services'
		description: 'Services management'
		execute:     services
		commands:    [
			services_list_command(),
		]
	}
}
