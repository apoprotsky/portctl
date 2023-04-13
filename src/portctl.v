module main

import cli
import os
import cmd

fn main() {
	mut app := cli.Command{
		name: 'portctl'
		description: 'portctl is a command line interface for Portainer'
		version: version
		posix_mode: true
		commands: cmd.get_commands()
	}
	app.setup()
	app.parse(os.args)
}
