class_name Bird
extends CharacterBody2D

signal death

@export var JUMP_VELOCITY = -270.0

var last_jump_time : int = 0
@export var jump_animation_delay : int = 150
@onready var animator : AnimatedSprite2D = $AnimatedSprite2D
@onready var corpse_scene = preload("res://corpse.tscn")
@onready var audio_jump = $JumpPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var started = false

func start():
	started = true

func  _process(delta):
	if Time.get_ticks_msec() - last_jump_time > jump_animation_delay:
		if velocity.y > 0:
			animator.play("fall")
		else:
			animator.play("up")

func _physics_process(delta):
	if !started:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		last_jump_time = Time.get_ticks_msec()
		animator.play("jump")
		audio_jump.pitch_scale = randf_range(0.9, 1.1)
		audio_jump.play()

	var col = move_and_collide(velocity * delta)
	if col:
		print("death")
		death.emit()
		queue_free()
		spawn_corpse()
	
func spawn_corpse():
	var corpse = corpse_scene.instantiate() as Node2D
	add_sibling(corpse)
	corpse.global_position = global_position
