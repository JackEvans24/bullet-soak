class_name Wanderer
extends Enemy

@onready var move: BasicMovement = $Movement
@onready var behaviour_timer: VariableTimer = $BehaviourTimer
@onready var look_at_target: LookAtTarget = $LookAtTarget
@onready var fire: FireFromPoint = $Fire
@onready var spawn_tube: SpawnTube = $Pivot/SpawnTube
@onready var windup_particles: GPUParticles3D = $Pivot/WindupParticles
@onready var animation: AnimationPlayer = $Animator

func _ready():
	super()
	fire.pivot = pivot
	behaviour_timer.named_timeout.connect(_on_behaviour_timer_timeout)

func _on_intro_animation_start():
	spawn_tube.play_animation()

func activate_enemy():
	look_at_target.pivot = pivot
	call_deferred("activate_knockback")
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
		"windup": do_windup()
		"fire": do_fire()
		_: move.stop()

func set_target(target: Node3D):
	look_at_target.target = target

func do_windup():
	move.stop()
	windup_particles.restart()

func do_fire():
	animation.play("fire")
	sfx.play("Fire")
	fire.fire()

func die():
	super()
	look_at_target.target = null
	behaviour_timer.stop()
	move.stop()
