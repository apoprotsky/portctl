module cmd

import cli
import encoding.base64
import api
import template

fn secrets_create(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	name_flag := command.flags.get_string('name')!
	file := command.flags.get_string('file')!
	content := parser.parse_file(file)!
	data := base64.encode_str(content)
	name := name_flag + api.get_postfix(data)
	client.get_secret_by_name(endpoint_id, name) or {
		request := api.SecretPostRequest{
			name:   name
			labels: {
				label_name: name_flag
			}
			data:   data
		}
		eprint('Secret ${name} not found, creating ... ')
		client.create_secret(endpoint_id, request)!
		eprintln('OK')
		print(name)
		return
	}
	return error('secret ${name} already exists')
}

fn secrets_create_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_vault_flags()
	flags << get_secrets_flags()
	return cli.Command{
		name:        'create'
		description: 'Create secret'
		execute:     command
		flags:       flags
	}
}
