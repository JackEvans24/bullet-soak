class_name Enemy
extends CharacterBody3D

@export var hurt_particles_scene: PackedScene

@onready var health: Health = $Health
@onready var knockback: Knockback = $Knockback
@onready var hit_detection: Area3D = $HitDetection
@onready var pivot: Node3D = $Pivot
@onready var body: MeshInstance3D = $Pivot/Body
@onready var collider: CollisionShape3D = $Collider

func _ready():
	hit_detection.area_entered.connect(_on_area_entered)
	health.damage_taken.connect(_on_damage_taken)

func _physics_process(_delta):
	velocity = knockback.knockback_direction
	move_and_slide()

func _on_area_entered(area: Area3D):
	health.take_damage(1.0, area)

func _on_damage_taken(damage_taken: float, taken_from: Node3D):
	if damage_taken <= 0:
		return

	add_hurt_particles()
	do_knockback(taken_from)

	if health.current_health <= 0:
		die()

func add_hurt_particles():
	var hurt_particles = hurt_particles_scene.instantiate()
	add_child(hurt_particles)
	hurt_particles.position = pivot.position

func do_knockback(taken_from: Node3D):
	var direction = -taken_from.basis.z
	knockback.set_knockback_direction(direction)

func die():
	body.visible = false
	collider.call_deferred("queue_free")