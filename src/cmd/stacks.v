module cmd

import cli

fn stacks(command cli.Command) {
	command.execute_help()
}

fn stacks_command() cli.Command {
	return cli.Command{
		name: 'stacks'
		description: 'Stacks management.'
		execute: stacks
		commands: [
			stacks_apply_command(),
			stacks_create_command(),
			stacks_delete_command(),
			stacks_list_command(),
			stacks_update_command(),
		]
	}
}

fn get_stacks_name_flag() []cli.Flag {
	return [
		cli.Flag{
			flag: .string
			name: 'name'
			abbrev: 'n'
			description: 'Stack name'
			required: true
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
