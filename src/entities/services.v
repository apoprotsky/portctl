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

struct ServiceSpecRaw {
	mode          string @[json: Mode; raw]
	task_template string @[json: TaskTemplate; raw]
}

struct ServiceTaskTemplateForceUpdate {
	force_update u64 @[json: ForceUpdate]
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
	spec := json.decode(ServiceSpecRaw, s.spec)!
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

// get_spec_with_replicas returns raw spec with replaced number of replicas,
// with force it also increments TaskTemplate.ForceUpdate to recreate tasks
pub fn (s ServiceInspect) get_spec_with_replicas(replicas u64, force bool) !string {
	mode, _ := s.get_mode()!
	mut spec := replace_raw_value(s.spec, 'Mode', mode, '{"Replicated":{"Replicas":${replicas}}}')!
	if force {
		task := json.decode(ServiceSpecRaw, s.spec)!.task_template
		count := json.decode(ServiceTaskTemplateForceUpdate, task)!.force_update
		new_task := if task.contains('"ForceUpdate":') {
			task.replace_once('"ForceUpdate":${count}', '"ForceUpdate":${count + 1}')
		} else if task == '{}' {
			'{"ForceUpdate":1}'
		} else {
			'{"ForceUpdate":1,' + task[1..]
		}
		spec = replace_raw_value(spec, 'TaskTemplate', task, new_task)!
	}
	return spec
}

fn replace_raw_value(spec string, key string, old string, new string) !string {
	old_pair := '"${key}":${old}'
	if !spec.contains(old_pair) {
		return error('cannot find ${key} in service spec')
	}
	return spec.replace_once(old_pair, '"${key}":${new}')
}
