module cmd

import cli
import api
import template

fn templates_render(command cli.Command, client api.Service, parser template.Service) ! {
	file := command.flags.get_string('file')!
	result := parser.parse_file(file)!
	println(result)
}

fn templates_render_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_vault_flags()
	flags << get_template_file_flag()
	return cli.Command{
		name:        'render'
		description: 'Render template to stdout'
		execute:     command
		flags:       flags
	}
}
