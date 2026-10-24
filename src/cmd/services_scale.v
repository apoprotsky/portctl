module cmd

import cli
import api
import template

fn services_scale(command cli.Command, client api.Service, parser template.Service) ! {
	endpoint := command.flags.get_string('endpoint')!
	endpoint_id := client.get_endpoint_id_by_name(endpoint)!
	name := command.flags.get_string('name')!
	replicas_flag := command.flags.get_int('replicas')!
	if replicas_flag < 0 {
		return error('number of replicas cannot be negative')
	}
	replicas := u64(replicas_flag)
	service := client.get_service(endpoint_id, name)!
	current := service.get_replicas() or { return error('${err.msg()}, service ${name}') }
	if current == replicas {
		eprintln('Service ${name} already has ${replicas} replicas ... SKIP')
		return
	}
	spec := service.get_spec_with_replicas(replicas)!
	eprint('Service ${name} scaling from ${current} to ${replicas} replicas ... ')
	response := client.update_service(endpoint_id, service.id, service.version.index,
		spec)!
	eprintln('OK')
	for warning in response.warnings {
		eprintln('Warning: ${warning}')
	}
}

fn services_scale_command() cli.Command {
	mut flags := get_common_flags()
	flags << get_endpoint_flag()
	flags << cli.Flag{
		flag:        .string
		name:        'name'
		abbrev:      'n'
		description: 'Service name or ID'
		required:    true
	}
	flags << cli.Flag{
		flag:        .int
		name:        'replicas'
		description: 'Number of replicas'
		required:    true
	}
	return cli.Command{
		name:        'scale'
		description: 'Scale replicated service'
		execute:     command
		flags:       flags
	}
}
