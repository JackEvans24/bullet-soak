class_name RoomController extends Node

signal doors_changed
signal wall_destroyed
signal boss_entered(boss: Boss)
signal reward_collected(reward_type: Reward.RewardType)
signal room_completed(room_id: String)
signal room_reentered(room_id: String)

@export var room_item_lookup: RoomItemLookup
var reward_lookup: RewardLookup

var rooms: Dictionary

func initialise(data: GameData):
	var children = get_children()
	for child in children:
		var room = child as Room

		if rooms.has(room.data.room_name):
			printerr("Duplicate room name found whilst processing ", room.name, ": ", room.data.room_name)
			continue

		room.room_item_lookup = room_item_lookup
		room.reward_lookup = reward_lookup

		if room.data.is_hidden_room:
			room.visible = false

		if data.completed_rooms.has(room.data.room_name):
			room.set_room_complete(true)

		room.doors_changed.connect(_on_room_doors_changed)
		room.wall_destroyed.connect(_on_room_wall_destroyed)
		room.boss_entered.connect(_on_boss_entered)
		room.reward_collected.connect(_on_reward_collected)
		room.room_completed.connect(_on_room_completed)
		room.room_reentered.connect(_on_room_reentered)

		rooms[room.data.room_name] = room

func get_room(id: String) -> Room:
	if not rooms.has(id):
		printerr("Trying to retrieve room that doesn't exist: ", id)
		return null
	return rooms[id]

func _on_room_doors_changed():
	doors_changed.emit()

func _on_room_wall_destroyed(linked_room_name: String):
	if not rooms.has(linked_room_name):
		printerr("Destroyed wall is linked to room that doesn't exist: ", linked_room_name)
		return

	var linked_room = rooms[linked_room_name] as Room
	if not linked_room.data.is_hidden_room:
		printerr("Destroyed wall is linked to a room that isn't marked as hidden: ", linked_room_name)

	wall_destroyed.emit()
	linked_room.visible = true

func _on_boss_entered(boss: Boss):
	boss_entered.emit(boss)

func _on_reward_collected(reward_type: Reward.RewardType):
	reward_collected.emit(reward_type)

func _on_room_completed(room_id: String):
	room_completed.emit(room_id)

func _on_room_reentered(room_id: String):
	room_reentered.emit(room_id)