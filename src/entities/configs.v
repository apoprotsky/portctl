module entities

pub struct Config {
pub:
	id         string     [json: ID]
	created_at string     [json: CreatedAt]
	updated_at string     [json: UpdatedAt]
	spec       ConfigSpec [json: Spec]
}

struct ConfigSpec {
pub:
	name   string            [json: Name]
	labels map[string]string [json: Labels]
	data   string            [json: Data]
}
