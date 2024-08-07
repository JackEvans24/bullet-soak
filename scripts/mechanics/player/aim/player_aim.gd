class_name PlayerAim
extends Node

signal bullet_fired
signal fire_failed

const SHOOT_LEFT = "shoot_left"
const SHOOT_RIGHT = "shoot_right"

@export var pivot_ref: NodePath
@export var arm_cannon_refs: Array[NodePath]
@export var aim_point_ref: NodePath
@export var reticule_ref: NodePath
@export var animator_ref: NodePath
@export var cooldown = 0.4
@export var bullet_scene: PackedScene
@export var fire_fail_particles_scene: PackedScene

@onready var controller_aim: ControllerAimDirection = $ControllerAim
@onready var mouse_aim: MouseAimDirection = $MouseAim
@onready var pivot: Node3D = get_node(pivot_ref)
@onready var aim_point: Node3D = get_node(aim_point_ref)
@onready var reticule: Reticule = get_node(reticule_ref)
@onready var animator: AnimationPlayer = get_node(animator_ref)

var stats: PlayerStats

var arm_cannons: Array[ArmCannon]
var arm_cannon_index := 0
var aim_service: AimDirection

var aim_direction: Vector3 = Vector3.FORWARD

var can_aim = true
var can_fire = true
var is_firing = false
var has_ammo = false

func _ready():
	aim_service = mouse_aim
	mouse_aim.player = pivot

	for arm_cannon_ref in arm_cannon_refs:
		arm_cannons.push_back(get_node(arm_cannon_ref))

func _process(_delta: float):
	if not can_aim:
		return

	for arm_cannon in arm_cannons:
		arm_cannon.aim_towards(aim_point.global_position)

	var direction = aim_service.get_aim_direction()
	if direction:
		aim_direction = direction
		reticule.aim_distance = aim_direction.length()

func _input(event: InputEvent):
	check_input_method(event)

	if can_fire and event.is_action_pressed("fire"):
		fire()

func check_input_method(event: InputEvent):
	if event is InputEventMouseMotion:
		if aim_service != mouse_aim:
			aim_service = mouse_aim
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	if aim_service == controller_aim or controller_aim.get_aim_direction().length() <= 0.1:
		return

	aim_service = controller_aim
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func fire():
	if is_firing:
		return

	is_firing = true

	var tree = get_tree()
	var arm_cannon = get_next_cannon_for_fire()

	if not has_ammo:
		arm_cannon.trigger_fire_fail()
		fire_failed.emit()
	else:
		var bullet = bullet_scene.instantiate()
		tree.root.add_child(bullet)

		arm_cannon.fire(bullet)

		bullet_fired.emit()

	await tree.create_timer(stats.get_fire_cooldown(cooldown)).timeout

	is_firing = false

func get_next_cannon_for_fire() -> ArmCannon:
	var next_cannon = arm_cannons[arm_cannon_index]

	animator.play(SHOOT_LEFT if arm_cannon_index % 2 == 0 else SHOOT_RIGHT)

	arm_cannon_index += 1
	if arm_cannon_index % len(arm_cannons) == 0:
		arm_cannon_index = 0

	return next_cannon
