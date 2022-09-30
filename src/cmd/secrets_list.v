module cmd

import cli
import net.http
import src.common
import src.api

struct SecretSpec {
	name string [json: Name]
}

struct Secret {
	id   string     [json: ID]
	spec SecretSpec [json: Spec]
}

fn secrets_list(command cli.Command) ? {
	services := get_services(command.flags)
	client := services.get_service(common.ServicesNames.api)
	if client is api.Service {
		endpoint := command.flags.get_string('endpoint')?
		endpoint_id := client.get_endpoint_id_by_name(endpoint)?
		response := client.call<common.Empty, []Secret>('endpoints/$endpoint_id/docker/secrets',
			http.Method.get, common.Empty{}) or {
			eprintln(err.msg())
			exit(1)
		}
		println('${'ID':-30}${'NAME'}')
		for item in response {
			println('${item.id:-30}$item.spec.name')
		}
	}
}

fn secrets_list_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	return cli.Command{
		name: 'list'
		description: 'List secrets.'
		execute: secrets_list
		flags: flags
	}
}
