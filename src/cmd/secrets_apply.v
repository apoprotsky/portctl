module cmd

import cli
import encoding.base64
import net.http
import api
import template

fn secrets_apply(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	name_flag := command.flags.get_string('name')!
	file := command.flags.get_string('file')!
	content := parser.parse_file(file)!
	data := base64.encode_str(content)
	name := name_flag + api.get_postfix(data)
	client.get_secret_by_name(endpoint_id, name) or {
		request := api.SecretPostRequest{
			name: name
			labels: {
				label_name: name_flag
			}
			data: data
		}
		eprint('Secret ${name} not found, creating ... ')
		client.create_secret(endpoint_id, request)!
		eprintln('OK')
		secrets_apply_clean(client, endpoint_id, name_flag, [name])!
		print(name)
		return
	}
	eprintln('Secret ${name} found, nothing to do ... OK')
	secrets_apply_clean(client, endpoint_id, name_flag, [name])!
	print(name)
}

fn secrets_apply_clean(client api.Service, endpoint_id u32, name string, exclude []string) ! {
	secrets := client.get_secrets_staled(endpoint_id, label_name, name, exclude)!
	if secrets.len == 0 {
		return
	}
	for secret in secrets {
		eprint('Delete old secret ${secret.spec.name} ... ')
		mut result := 'OK'
		client.delete_secret(endpoint_id, secret.id) or {
			result = if err.code() == http.Status.bad_request.int() {
				'FAIL, secret is in use'
			} else {
				err.msg()
			}
		}
		eprintln(result)
	}
}

fn secrets_apply_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_vault_flags()
	flags << get_secrets_flags()
	return cli.Command{
		name: 'apply'
		description: 'Create secret'
		execute: command
		flags: flags
	}
}
