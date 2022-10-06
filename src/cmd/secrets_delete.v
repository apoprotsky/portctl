module cmd

import cli
import src.api
import src.template

fn secrets_delete(command cli.Command, client api.Service, parser template.Service) ? {
	endpoint := command.flags.get_string('endpoint')?
	endpoint_id := client.get_endpoint_id_by_name(endpoint)?
	name := command.flags.get_string('name')?
	secret := client.get_secret_by_name(endpoint_id, name) or {
		eprintln('Secret $name not found, nothing to do ... OK')
		return
	}
	eprint('Secret $name found, deleting ... ')
	client.delete_secret(endpoint_id, secret.id)?
	eprintln('OK')
}

fn secrets_delete_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_secrets_name_flag()
	return cli.Command{
		name: 'delete'
		description: 'Delete secret.'
		execute: command
		flags: flags
	}
}
