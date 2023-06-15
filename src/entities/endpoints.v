module entities

pub struct Endpoint {
pub:
	id   u32    [json: Id]
	name string [json: Name]
	url  string [json: URL]
}
