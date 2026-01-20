module cmd

import cli

fn templates(command cli.Command) ! {
	command.execute_help()
}

fn templates_command() cli.Command {
	return cli.Command{
		name:        'templates'
		description: 'Manage templates'
		execute:     templates
		commands:    [
			templates_render_command(),
		]
	}
}

fn get_template_file_flag() []cli.Flag {
	return [
		cli.Flag{
			flag:        .string
			name:        'file'
			abbrev:      'f'
			description: 'Template file'
			required:    true
		},
	]
}
