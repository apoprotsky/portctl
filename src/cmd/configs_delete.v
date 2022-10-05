module cmd

import cli
import src.api
import src.template

fn configs_delete(command cli.Command, client api.Service, parser template.Service) ? {
	endpoint := command.flags.get_string('endpoint')?
	endpoint_id := client.get_endpoint_id_by_name(endpoint)?
	name := command.flags.get_string('name')?
	config := client.get_config(endpoint_id, name) or {
		eprint('Config $name not found, nothing to do ... OK')
		return
	}
	eprint('Config $name found, deleting ... ')
	client.delete_config(endpoint_id, config.id)?
	eprintln('OK')
}

fn configs_delete_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << get_configs_name_flag()
	return cli.Command{
		name: 'delete'
		description: 'Delete config.'
		execute: command
		flags: flags
	}
}
