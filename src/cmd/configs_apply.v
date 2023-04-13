module cmd

import cli
import encoding.base64
import net.http
import api
import template

fn configs_apply(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	name_flag := command.flags.get_string('name')!
	file := command.flags.get_string('file')!
	content := parser.parse_file(file)!
	data := base64.encode_str(content)
	name := name_flag + api.get_postfix(data)
	config := client.get_config(endpoint_id, name) or {
		request := api.ConfigPostRequest{
			name: name
			labels: {
				label_name: name_flag
			}
			data: data
		}
		eprint('Config ${name} not found, creating ... ')
		client.create_config(endpoint_id, request)!
		eprintln('OK')
		configs_apply_clean(client, endpoint_id, name_flag, [name])!
		print(name)
		return
	}
	if config.spec.data != data {
		return error('config name ${name} does not match content')
	}
	eprintln('Config ${name} found, nothing to do ... OK')
	configs_apply_clean(client, endpoint_id, name_flag, [name])!
	print(name)
}

fn configs_apply_clean(client api.Service, endpoint_id u32, name string, exclude []string) ! {
	configs := client.get_configs_staled(endpoint_id, label_name, name, exclude)!
	if configs.len == 0 {
		return
	}
	for config in configs {
		eprint('Delete old config ${config.spec.name} ... ')
		mut result := 'OK'
		client.delete_config(endpoint_id, config.id) or {
			result = if err.code() == http.Status.bad_request.int() {
				'FAIL, config is in use'
			} else {
				err.msg()
			}
		}
		eprintln(result)
	}
}

fn configs_apply_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_vault_flags()
	flags << get_configs_flags()
	return cli.Command{
		name: 'apply'
		description: 'Create config.'
		execute: command
		flags: flags
	}
}
