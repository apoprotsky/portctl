module cmd

import cli
import os
import src.api
import src.template

const (
	desc_env               = 'Environment variable'
	env_portainer_api      = 'PORTAINER_API'
	env_portainer_token    = 'PORTAINER_TOKEN'
	env_portainer_endpoint = 'PORTAINER_ENDPOINT'
	env_vault_addr         = 'VAULT_ADDR'
	env_vault_token        = 'VAULT_TOKEN'
)

// get_commands returns array of available commands
pub fn get_commands() []cli.Command {
	return [
		endpoints_command(),
		configs_command(),
		secrets_command(),
		stacks_command(),
	]
}

fn command(command cli.Command) ? {
	client := api.new(command.flags)
	parser := template.new(command.flags)
	match command.name {
		'apply' {
			match command.parent.name {
				'configs' {
					return configs_apply(command, client, parser)
				}
				'secrets' {
					return secrets_apply(command, client, parser)
				}
				'stacks' {
					return stacks_apply(command, client, parser)
				}
				else {
					println('Unknown command')
				}
			}
		}
		'create' {
			match command.parent.name {
				'configs' {
					return configs_create(command, client, parser)
				}
				'secrets' {
					return secrets_create(command, client, parser)
				}
				'stacks' {
					return stacks_create(command, client, parser)
				}
				else {
					println('Unknown command')
				}
			}
		}
		'list' {
			match command.parent.name {
				'configs' {
					return configs_list(command, client)
				}
				'endpoints' {
					return endpoints_list(command, client)
				}
				'secrets' {
					return secrets_list(command, client)
				}
				'stacks' {
					return stacks_list(command, client)
				}
				else {
					println('Unknown command')
				}
			}
		}
		'update' {
			match command.parent.name {
				'update' {
					return stacks_update(command, client, parser)
				}
				else {
					println('Unknown command')
				}
			}
		}
		else {
			println('Unknown command')
		}
	}
}

fn get_default_flag_value(flag string) string {
	value := os.getenv_opt(flag) or { return '' }
	return value
}

fn get_common_flags() []cli.Flag {
	default_api := get_default_flag_value(cmd.env_portainer_api)
	default_token := get_default_flag_value(cmd.env_portainer_token)
	return [
		cli.Flag{
			flag: .string
			name: 'api'
			abbrev: 'a'
			description: 'Portainer base URL\n$cmd.desc_env $cmd.env_portainer_api'
			required: default_api.len == 0
			default_value: [default_api]
		},
		cli.Flag{
			flag: .string
			name: 'token'
			abbrev: 't'
			description: 'Token to access Portainer API\n$cmd.desc_env $cmd.env_portainer_token'
			required: default_token.len == 0
			default_value: [default_token]
		},
	]
}

fn get_endpoint_flag() []cli.Flag {
	default_endpoint := get_default_flag_value(cmd.env_portainer_endpoint)
	return [
		cli.Flag{
			flag: .string
			name: 'endpoint'
			abbrev: 'e'
			description: 'Name of Portainrt endpoint\n$cmd.desc_env $cmd.env_portainer_endpoint'
			required: default_endpoint.len == 0
			default_value: [default_endpoint]
		},
	]
}

fn get_vault_flags() []cli.Flag {
	default_addr := get_default_flag_value(cmd.env_vault_addr)
	default_token := get_default_flag_value(cmd.env_vault_token)
	return [
		cli.Flag{
			flag: .string
			name: 'vault-addr'
			abbrev: 'va'
			description: 'Hashicorp Vault server address\n$cmd.desc_env $cmd.env_vault_addr'
			default_value: [default_addr]
		},
		cli.Flag{
			flag: .string
			name: 'vault-token'
			abbrev: 'vt'
			description: 'Hashicorp Vault token\n$cmd.desc_env $cmd.env_vault_token'
			required: default_token.len == 0 && default_addr.len > 0
			default_value: [default_token]
		},
	]
}
