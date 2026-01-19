module entities

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
