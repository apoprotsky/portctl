module api

import cli
import crypto.md5
import encoding.base58
import json
import net.http
import src.common

pub struct Service {
	api   string = 'http://127.0.0.1:9000'
	token string
mut:
	services common.Services = common.EmptyServices{}
}

// set_services updates services field
pub fn (mut s Service) set_services(services common.Services) {
	s.services = services
}

// new returns instance of Portainer API service
pub fn new(flags []cli.Flag) common.Service {
	api := flags.get_string('api') or { panic(err) }
	token := flags.get_string('token') or { panic(err) }
	return Service{
		api: api + '/api'
		token: token
	}
}

// call<I, O> sends request to Portainer API endpoint
pub fn (s &Service) call<I, O>(endpoint string, method http.Method, request I) ?O {
	mut header := http.new_header()
	header.add_custom('X-API-Key', s.token)?
	config := http.FetchConfig{
		url: '$s.api/$endpoint'
		method: method
		header: header
		data: json.encode(request)
	}
	result := http.fetch(config)?
	status := http.Status.ok
	if status.int() == result.status_code {
		response := json.decode(O, result.body)?
		return response
	}
	return error('Error in API call: $result.status_code $result.status_msg\nResponse: $result.body')
}

// get_postfix returns postfix base on data
pub fn get_postfix(data string) string {
	sum := md5.sum(data.bytes())
	return '-' + base58.encode(sum.bytestr())[0..5]
}
