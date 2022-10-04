module cmd

import cli
import encoding.base64
import src.api
import src.template

fn secrets_apply(command cli.Command, client api.Service, parser template.Service) ? {
	endpoint := command.flags.get_string('endpoint')?
	endpoint_id := client.get_endpoint_id_by_name(endpoint)?
	mut name := command.flags.get_string('name')?
	file := command.flags.get_string('file')?
	content := parser.parse_file(file)?
	data := base64.encode_str(content)
	name = name + api.get_postfix(data)
	client.get_secret_by_name(endpoint_id, name) or {
		request := api.SecretPostRequest{
			name: name
			data: data
		}
		eprint('Secret $name not found, creating ... ')
		client.create_secret(endpoint_id, request)?
		eprintln('OK')
		print(name)
		return
	}
	eprintln('Secret $name found, nothing to do ... OK')
	print(name)
}

fn secrets_apply_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_vault_flags()
	flags << get_secrets_flags()
	return cli.Command{
		name: 'apply'
		description: 'Create secret.'
		execute: command
		flags: flags
	}
}
