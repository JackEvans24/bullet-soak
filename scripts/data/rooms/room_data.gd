class_name RoomData extends Resource

@export var room_name: String = "Room"
@export var is_hidden_room := false
@export_flags("NORTH", "SOUTH", "EAST", "WEST") var untouched_doors := 0
@export_flags("NORTH", "SOUTH", "EAST", "WEST") var completed_doors := 0
@export var waves: Array[RoomConfiguration]
@export var boss_data: BossData
@export var reward: Reward.RewardType
