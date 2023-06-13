module api

import cli
import crypto.md5
import encoding.base58
import json
import net.http
import time

pub struct Empty {}

pub struct Service {
	api   string = 'http://127.0.0.1:9000'
	token string
}

// new returns instance of Portainer API service
pub fn new(flags []cli.Flag) Service {
	api := flags.get_string('api') or { panic(err) }
	token := flags.get_string('token') or { panic(err) }
	return Service{
		api: api + '/api'
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
	for count < 5 {
		result = http.fetch(config)!
		if result.status_code == http.Status.bad_gateway.int()
			&& endpoint.ends_with('/docker/configs') {
			count++
			eprintln('Error in API call: ${method} ${s.api}/${endpoint}, status code ${result.status_code}, will try again in ${count} sec')
			time.sleep(count * time.second)
			continue
		}
		match result.status_code {
			status_ok {
				response := json.decode(O, result.body) or {
					return error('Error in API call: cannot decode result: ${err.msg()}')
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
	return error_with_code('Error in API call: ${result.status_code} ${result.status_msg}\nResponse: ${result.body}',
		result.status_code)
}

// get_postfix returns postfix base on data
pub fn get_postfix(data string) string {
	sum := md5.sum(data.bytes())
	return '-' + base58.encode(sum.bytestr())[0..5]
}
