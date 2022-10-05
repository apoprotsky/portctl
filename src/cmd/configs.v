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
			configs_apply_command(),
			configs_create_command(),
			configs_delete_command(),
			configs_list_command(),
		]
	}
}

fn get_configs_name_flag() []cli.Flag {
	return [
		cli.Flag{
			flag: .string
			name: 'name'
			abbrev: 'n'
			description: 'Config name'
			required: true
		},
	]
}

fn get_configs_flags() []cli.Flag {
	mut flags := get_configs_name_flag()
	flags << cli.Flag{
		flag: .string
		name: 'file'
		abbrev: 'f'
		description: 'Config template file'
		required: true
	}
	return flags
}
