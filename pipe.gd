class_name Pipe 
extends AnimatableBody2D

var velocity = Vector2.ZERO
var limit = 0

signal scored

# Called when the node enters the scene tree for the first time.
func _ready():
	$ScoredArea.body_entered.connect(func(body: Node2D): 
		print("area entered")
		scored.emit()
	)

func _physics_process(delta):
	position += velocity * delta
	if position.x < limit:
		queue_free()

func stop():
	velocity = Vector2.ZERO
