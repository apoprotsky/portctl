module api

import cli
import crypto.md5
import encoding.base58
import json
import net.http
import time

pub struct Empty {}

pub struct Service {
	api     string = 'http://127.0.0.1:9000'
	retries int
	token   string
}

// new returns instance of Portainer API service
pub fn new(flags []cli.Flag) Service {
	api := flags.get_string('api') or { panic(err) }
	retries := flags.get_int('retries') or { panic(err) }
	token := flags.get_string('token') or { panic(err) }
	return Service{
		api: api + '/api'
		retries: retries
		token: token
	}
}

// call[I, O] sends request to Portainer API endpoint
pub fn (s Service) call[I, O](endpoint string, method http.Method, request I) !O {
	mut header := http.new_header()
	header.add(http.CommonHeader.content_type, 'application/json')
	header.add_custom('X-API-Key', s.token)!
	config := http.FetchConfig{
		url: '${s.api}/${endpoint}'
		method: method
		header: header
		data: json.encode(request)
	}
	status_ok := http.Status.ok.int()
	status_no_content := http.Status.no_content.int()
	mut result := http.Response{}
	mut count := 0
	mut retry := false
	for count < s.retries {
		result = http.fetch(config)!
		retry = false
		if result.status_code == http.Status.bad_gateway.int() && method == http.Method.get
			&& endpoint.ends_with('/docker/configs') {
			retry = true
		}
		if result.status_code == http.Status.internal_server_error.int()
			&& method == http.Method.put && endpoint.starts_with('stacks/')
			&& result.body.contains('rpc error: code = Unknown desc = update out of sequence') {
			retry = true
		}
		if retry {
			count++
			eprintln('Error ${result.status_code} ${result.status_msg} in API call ${method} ${s.api}/${endpoint}: will try again in ${count} sec')
			time.sleep(count * time.second)
			continue
		}
		match result.status_code {
			status_ok {
				response := json.decode(O, result.body) or {
					return error('Error in API call ${method} ${s.api}/${endpoint}: cannot decode result: ${err.msg()}')
				}
				return response
			}
			status_no_content {
				return O{}
			}
			else {
				break
			}
		}
	}
	return error_with_code('Error ${result.status_code} ${result.status_msg} in API call ${method} ${s.api}/${endpoint}\nResponse: ${result.body}',
		result.status_code)
}

// get_postfix returns postfix base on data
pub fn get_postfix(data string) string {
	sum := md5.sum(data.bytes())
	return '-' + base58.encode(sum.bytestr())[0..5]
}
