module cmd

import cli
import encoding.base64
import src.common
import src.api
import src.template

fn secrets_create(command cli.Command) ? {
	services := get_services(command.flags)
	client := services.get_service(common.ServicesNames.api)
	parser := services.get_service(common.ServicesNames.template)
	if client is api.Service && parser is template.Service {
		return secrets_create_work(command, client, parser)
	}
}

fn secrets_create_work(command cli.Command, client api.Service, parser template.Service) ? {
	endpoint := get_default_flag_value(env_portainer_endpoint)
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
		client.create_secret(endpoint_id, request)?
		print(request.name)
		return
	}
	return error('secret $name already exists')
}

fn secrets_create_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_vault_flags()
	flags << cli.Flag{
		flag: .string
		name: 'name'
		abbrev: 'n'
		description: 'Secret name'
		required: true
	}
	flags << cli.Flag{
		flag: .string
		name: 'file'
		abbrev: 'f'
		description: 'Secret template file'
		required: true
	}
	return cli.Command{
		name: 'create'
		description: 'Create secret.'
		execute: secrets_create
		flags: flags
	}
}