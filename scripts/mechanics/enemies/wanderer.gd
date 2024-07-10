class_name Wanderer
extends Enemy

@onready var move: BasicMovement = $Movement
@onready var behaviour_timer: VariableTimer = $BehaviourTimer
@onready var look_at_target: LookAtTarget = $LookAtTarget
@onready var fire: FireFromPoint = $Fire
@onready var spawn_tube: SpawnTube = $Pivot/SpawnTube

func _ready():
	look_at_target.pivot = pivot
	fire.pivot = pivot
	behaviour_timer.named_timeout.connect(_on_behaviour_timer_timeout)

func _on_intro_animation_start():
	spawn_tube.play_animation()

func _on_intro_animation_complete():
	call_deferred("set_hit_detection")
	spawn_tube.call_deferred("queue_free")
	behaviour_timer.restart()

func _physics_process(delta):
	super(delta)
	if knockback.knockback_direction.length():
		return
	velocity = move.movement
	move_and_slide()

func _on_behaviour_timer_timeout(timer_name: String):
	match timer_name.to_lower():
		"walk": move.set_new_movement()
		"fire": fire.fire()
		_: move.stop()

func set_target(target: Node3D):
	look_at_target.target = target

func die():
	super()
	look_at_target.target = null
	behaviour_timer.stop()
	move.stop()
