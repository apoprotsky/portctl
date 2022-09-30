module cmd

import cli
import encoding.base64
import src.common
import src.api
import src.template

fn configs_apply(command cli.Command) ? {
	services := get_services(command.flags)
	client := services.get_service(common.ServicesNames.api)
	parser := services.get_service(common.ServicesNames.template)
	if client is api.Service && parser is template.Service {
		return configs_apply_work(command, client, parser)
	}
}

fn configs_apply_work(command cli.Command, client api.Service, parser template.Service) ? {
	endpoint := get_default_flag_value(env_portainer_endpoint)
	endpoint_id := client.get_endpoint_id_by_name(endpoint)?
	mut name := command.flags.get_string('name')?
	file := command.flags.get_string('file')?
	content := parser.parse_file(file)?
	data := base64.encode_str(content)
	name = name + api.get_postfix(data)
	config := client.get_config_by_name(endpoint_id, name) or {
		request := api.ConfigPostRequest{
			name: name
			data: data
		}
		eprint('Config $name not found, creating ... ')
		client.create_config(endpoint_id, request)?
		eprintln('OK')
		print(name)
		return
	}
	if config.spec.data != data {
		return error('config name $name does not match content')
	}
	eprintln('Config $name found, nothing to do ... OK')
	print(name)
}

fn configs_apply_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_vault_flags()
	flags << get_configs_flags()
	return cli.Command{
		name: 'apply'
		description: 'Create config.'
		execute: configs_apply
		flags: flags
	}
}