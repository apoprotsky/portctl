module entities

import json

pub struct Service {
pub:
	id   string      @[json: ID]
	spec ServiceSpec @[json: Spec]
}

struct ServiceSpec {
pub:
	name          string              @[json: Name]
	task_template ServiceTaskTemplate @[json: TaskTemplate]
}

struct ServiceTaskTemplate {
pub:
	spec ServiceContainerSpec @[json: ContainerSpec]
}

struct ServiceContainerSpec {
pub:
	image string @[json: Image]
}

// ServiceInspect keeps Spec as raw JSON so it can be sent back to Docker unchanged
pub struct ServiceInspect {
pub:
	id      string         @[json: ID]
	version ServiceVersion @[json: Version]
	spec    string         @[json: Spec; raw]
}

struct ServiceVersion {
pub:
	index u64 @[json: Index]
}

struct ServiceSpecMode {
	mode string @[json: Mode; raw]
}

struct ServiceMode {
	replicated string @[json: Replicated; raw]
}

struct ServiceModeReplicated {
	replicas u64 @[json: Replicas]
}

pub struct ServiceUpdateResponse {
pub:
	warnings []string @[json: Warnings]
}

fn (s ServiceInspect) get_mode() !(string, string) {
	spec := json.decode(ServiceSpecMode, s.spec)!
	mode := json.decode(ServiceMode, spec.mode)!
	if mode.replicated == '' {
		return error('service is not in replicated mode: ${spec.mode}')
	}
	return spec.mode, mode.replicated
}

// get_replicas returns number of replicas of replicated Service
pub fn (s ServiceInspect) get_replicas() !u64 {
	_, replicated := s.get_mode()!
	return json.decode(ServiceModeReplicated, replicated)!.replicas
}

// get_spec_with_replicas returns raw spec with replaced number of replicas
pub fn (s ServiceInspect) get_spec_with_replicas(replicas u64) !string {
	mode, _ := s.get_mode()!
	old := '"Mode":${mode}'
	if !s.spec.contains(old) {
		return error('cannot find service mode in spec')
	}
	return s.spec.replace_once(old, '"Mode":{"Replicated":{"Replicas":${replicas}}}')
}
