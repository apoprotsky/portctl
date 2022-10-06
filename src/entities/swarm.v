module entities

pub struct Swarm {
pub:
	id   string    [json: ID]
	spec SwarmSpec [json: Spec]
}

struct SwarmSpec {
pub:
	orchestration SwarmSpecOrchestration [json: Orchestration]
}

struct SwarmSpecOrchestration {
pub:
	task_history_retention_limit u8 [json: TaskHistoryRetentionLimit]
}
