module entities

pub struct Secret {
pub:
	id         string     [json: ID]
	created_at string     [json: CreatedAt]
	updated_at string     [json: UpdatedAt]
	spec       SecretSpec [json: Spec]
}

struct SecretSpec {
pub:
	name   string            [json: Name]
	labels map[string]string [json: Labels]
}
