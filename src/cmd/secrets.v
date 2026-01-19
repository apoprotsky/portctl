module cmd

import cli

fn secrets(command cli.Command) ! {
	command.execute_help()
}

fn secrets_command() cli.Command {
	return cli.Command{
		name:        'secrets'
		description: 'Secrets management'
		execute:     secrets
		commands:    [
			secrets_apply_command(),
			secrets_create_command(),
			secrets_delete_command(),
			secrets_list_command(),
		]
	}
}

fn get_secrets_name_flag() []cli.Flag {
	return [
		cli.Flag{
			flag:        .string
			name:        'name'
			abbrev:      'n'
			description: 'Secret name'
			required:    true
		},
	]
}

fn get_secrets_flags() []cli.Flag {
	mut flags := get_secrets_name_flag()
	flags << cli.Flag{
		flag:        .string
		name:        'file'
		abbrev:      'f'
		description: 'Secret template file'
		required:    true
	}
	return flags
}
