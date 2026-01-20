module cmd

import cli
import os
import api
import template

const desc_env = 'Environment variable'
const default_portainer_retries = 60
const env_portainer_api = 'PORTAINER_API'
const env_portainer_endpoint = 'PORTAINER_ENDPOINT'
const env_portainer_retries = 'PORTAINER_RETRIES'
const env_portainer_stack = 'PORTAINER_STACK'
const env_portainer_token = 'PORTAINER_TOKEN'
const env_vault_addr = 'VAULT_ADDR'
const env_vault_token = 'VAULT_TOKEN'
const label_name = 'portctl.name'

type Command = fn (cli.Command, api.Service, template.Service) !

// get_commands returns array of available commands
pub fn get_commands() []cli.Command {
	return [
		configs_command(),
		endpoints_command(),
		secrets_command(),
		services_command(),
		stacks_command(),
		templates_command(),
	]
}

fn command(command cli.Command) ! {
	client := api.new(command.flags)
	parser := template.new(command.flags)
	commands := {
		'configs apply':    configs_apply
		'configs create':   configs_create
		'configs delete':   configs_delete
		'configs list':     configs_list
		'endpoints list':   endpoints_list
		'secrets apply':    secrets_apply
		'secrets create':   secrets_create
		'secrets delete':   secrets_delete
		'secrets list':     secrets_list
		'services list':    services_list
		'stacks apply':     stacks_apply
		'stacks create':    stacks_create
		'stacks delete':    stacks_delete
		'stacks list':      stacks_list
		'stacks update':    stacks_update
		'templates render': templates_render
	}
	func := commands['${command.parent.name} ${command.name}']
	func(command, client, parser)!
}

fn command_l3(command cli.Command) ! {
	client := api.new(command.flags)
	parser := template.new(command.flags)
	commands := {
		'stacks vars get':    stacks_vars_get
		'stacks vars update': stacks_vars_update
	}
	func := commands['${command.parent.parent.name} ${command.parent.name} ${command.name}']
	func(command, client, parser)!
}

fn get_default_flag_value(flag string) string {
	value := os.getenv_opt(flag) or { return '' }
	return value
}

fn get_common_flags() []cli.Flag {
	env_retries := get_default_flag_value(env_portainer_retries).u8()
	default_api := get_default_flag_value(env_portainer_api)
	default_retries := if env_retries > 0 { env_retries } else { default_portainer_retries }
	default_token := get_default_flag_value(env_portainer_token)
	return [
		cli.Flag{
			flag:          .string
			name:          'api'
			abbrev:        'a'
			description:   'Portainer base URL\n${desc_env} ${env_portainer_api}'
			required:      default_api.len == 0
			default_value: [default_api]
		},
		cli.Flag{
			flag:          .int
			name:          'retries'
			abbrev:        'r'
			description:   'Number of retry calls of Portainer API\n${desc_env} ${env_portainer_retries}'
			required:      false
			default_value: [default_retries.str()]
			global:        true
		},
		cli.Flag{
			flag:          .string
			name:          'token'
			abbrev:        't'
			description:   'Token to access Portainer API\n${desc_env} ${env_portainer_token}'
			required:      default_token.len == 0
			default_value: [default_token]
		},
	]
}

fn get_endpoint_flag() []cli.Flag {
	default_endpoint := get_default_flag_value(env_portainer_endpoint)
	return [
		cli.Flag{
			flag:          .string
			name:          'endpoint'
			abbrev:        'e'
			description:   'Name of Portainrt endpoint\n${desc_env} ${env_portainer_endpoint}'
			required:      default_endpoint.len == 0
			default_value: [default_endpoint]
		},
	]
}

fn get_vault_flags() []cli.Flag {
	default_addr := get_default_flag_value(env_vault_addr)
	default_token := get_default_flag_value(env_vault_token)
	return [
		cli.Flag{
			flag:          .string
			name:          'vault-addr'
			abbrev:        'va'
			description:   'Hashicorp Vault server address\n${desc_env} ${env_vault_addr}'
			default_value: [default_addr]
		},
		cli.Flag{
			flag:          .string
			name:          'vault-token'
			abbrev:        'vt'
			description:   'Hashicorp Vault token\n${desc_env} ${env_vault_token}'
			required:      default_token.len == 0 && default_addr.len > 0
			default_value: [default_token]
		},
	]
}
