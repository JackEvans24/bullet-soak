class_name Burster
extends Enemy

@onready var move: BasicMovement = $Movement
@onready var fire: FireFromRing = $Fire
@onready var behaviour_timer: VariableTimer = $BehaviourTimer

func _ready():
	super()
	behaviour_timer.named_timeout.connect(_on_behaviour_timer_timeout)

func _physics_process(delta):
	super(delta)
	if knockback.knockback_direction.length():
		return
	velocity = move.movement
	move_and_slide()

func _on_behaviour_timer_timeout(timer_name: String):
	print("RECEIVED TIMEOUT: %s" % timer_name)
	match timer_name.to_lower():
		"walk": move.set_new_movement()
		"fire": fire.fire()
		_: move.stop()

func die():
	super()
	behaviour_timer.stop()