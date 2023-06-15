module entities

pub struct Service {
pub:
	id   string      [json: ID]
	spec ServiceSpec [json: Spec]
}

pub struct ServiceSpec {
pub:
	name          string              [json: Name]
	task_template ServiceTaskTemplate [json: TaskTemplate]
}

pub struct ServiceTaskTemplate {
pub:
	spec ServiceContainerSpec [json: ContainerSpec]
}

pub struct ServiceContainerSpec {
pub:
	image string [json: Image]
}
