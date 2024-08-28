extends Node2D

var score = 0
var pb_score = 0

@export var pipe_speed = 70

@onready var top = $PipeLimits/TopLimit.position.y
@onready var bot = $PipeLimits/BottomLimit.position.y
@onready var left = $PipeLimits/LeftLimit.position.x
@onready var right = $PipeLimits/RightLimit.position.x

@onready var pipe_scene = preload("res://pipe.tscn")

@onready var bird : Bird = $Bird

@onready var audio_scored = $Sounds/ScoredPlayer
@onready var audio_hit = $Sounds/HitPlayer

var interval = 3000
var last_spawn_time = 0

var is_game_started = false
var is_game_over = false

func _ready():
	bird.death.connect(game_over)
	$StartLabel.visible = true
	$GameOverLabel.visible = false
	$Score.visible = false
	$BestScore.visible = true
	load_pb()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if !is_game_started:
			start_game()
		if is_game_over:
			reload_game()
			
	$Score.text = str(score)
	$BestScore.text = "PB: " + str(pb_score)

func _physics_process(delta):
	if !is_game_started or is_game_over:
		return
	var time = Time.get_ticks_msec()
	if time > last_spawn_time + interval:
		last_spawn_time = time
		spawn_pipe()

func start_game():
	is_game_started = true
	$Score.visible = true
	$StartLabel.visible = false
	$BestScore.visible = false
	bird.start()
	
func game_over():
	print("game over")
	is_game_over = true
	$GameOverLabel.visible = true
	$BestScore.visible = true
	audio_hit.play()
	
	if score > pb_score:
		pb_score = score
		save_pb()
		
func save_pb():
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_string(str(pb_score))
	file.close()
	
func load_pb():
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	pb_score = int(content)

func reload_game():
	get_tree().reload_current_scene()
	
func spawn_pipe():
	print("pipe")
	var pipe = pipe_scene.instantiate() as Pipe
	pipe.velocity.x = -pipe_speed
	pipe.position.x = right
	
	var height = get_pipe_height()
	print(height)
	pipe.position.y = top + height
	pipe.limit = left
	add_child(pipe)
	bird.death.connect(pipe.stop)
	
	pipe.scored.connect(func(): 
		score += 1
		audio_scored.play()
	)
	
func get_pipe_height() -> int:
	return randi_range(0, ((bot - top) / 16)) * 16
