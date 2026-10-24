module entities

import json

const service_json = '{"ID":"abc","Version":{"Index":42},"Spec":{"Name":"stack_app","Labels":{"com.docker.stack.namespace":"stack"},"TaskTemplate":{"ContainerSpec":{"Image":"app:1.0@sha256:0123","Mounts":[{"Type":"tmpfs","Target":"/tmp","TmpfsOptions":{"Mode":511}}]},"Resources":{"Limits":{"NanoCPUs":1500000000,"MemoryBytes":2147483648}},"RestartPolicy":{"Condition":"none","Delay":5000000000,"MaxAttempts":0},"Networks":[{"Target":"net1","Aliases":["app"]}]},"Mode":{"Replicated":{"Replicas":0}},"UpdateConfig":{"Parallelism":1,"MaxFailureRatio":0.25}}}'

fn test_get_replicas() {
	service := json.decode(ServiceInspect, service_json)!
	assert service.id == 'abc'
	assert service.version.index == 42
	assert service.get_replicas()! == 0
}

fn test_get_spec_with_replicas_changes_only_replicas() {
	service := json.decode(ServiceInspect, service_json)!
	spec := service.get_spec_with_replicas(3)!
	assert spec == service.spec.replace('"Replicas":0', '"Replicas":3')
	assert spec.contains('"NanoCPUs":1500000000')
	assert spec.contains('"Delay":5000000000')
	assert spec.contains('"TmpfsOptions":{"Mode":511}')
}

fn test_replicated_without_replicas() {
	service := json.decode(ServiceInspect, '{"ID":"abc","Version":{"Index":1},"Spec":{"Name":"x","Mode":{"Replicated":{}}}}')!
	assert service.get_replicas()! == 0
	assert service.get_spec_with_replicas(2)! == '{"Name":"x","Mode":{"Replicated":{"Replicas":2}}}'
}

fn test_global_mode_fails() {
	service := json.decode(ServiceInspect, '{"ID":"abc","Version":{"Index":1},"Spec":{"Name":"x","Mode":{"Global":{}}}}')!
	service.get_replicas() or {
		assert err.msg().starts_with('service is not in replicated mode')
		return
	}
	assert false
}

fn test_update_response_without_warnings() {
	response := json.decode(ServiceUpdateResponse, '{"Warnings":null}')!
	assert response.warnings.len == 0
}
