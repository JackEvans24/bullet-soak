class_name Dash
extends Node

signal dash_triggered(direction: Vector3)
signal dash_failed

@export var dash_timeout: float = 0.8

var initialised = false
var move_state: MoveStateMachine
var body: Node3D

var is_dashing = false
var has_dash_power = false

func initialise(passed_msm: MoveStateMachine, passed_body: Node3D):
	move_state = passed_msm
	body = passed_body
	initialised = true

func _process(_delta):
	if not initialised:
		return
	if Input.is_action_just_pressed("dash"):
		try_dash()

func try_dash():
	if is_dashing:
		return
	if not has_dash_power:
		dash_failed.emit()
		return
	is_dashing = true

	var dash_direction = move_state.movement
	if dash_direction.length() < 0.01:
		dash_direction = -body.basis.z

	dash_triggered.emit(dash_direction)

	await get_tree().create_timer(dash_timeout).timeout

	is_dashing = false
