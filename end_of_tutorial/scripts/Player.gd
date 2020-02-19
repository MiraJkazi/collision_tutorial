extends KinematicBody2D

enum {MOVING, STOP}

var speed = Vector2(150, 400)
var gravity = 1000
var velocity = Vector2()

var state = MOVING

func _ready():
	$AnimationPlayer.play("Idle")
	$Sprite.rotation_degrees = 0
	$Sprite.position = Vector2(0,-8)
	
func _on_VisibilityNotifier2D_screen_exited():
	get_tree().reload_current_scene()

func _physics_process(delta):
	var is_jump_interrupted = Input.is_action_just_released("game_jump") and velocity.y < 0.0
	var direction = get_direction()
	
	calculate_move_velocity(direction, is_jump_interrupted)
	if(state == STOP):
		velocity.x = 0
	velocity = move_and_slide(velocity, Vector2.UP)
	set_animation()
	set_flip()
	
	if Input.is_action_just_pressed("test_key"):
		die()
	
	
func die():
	state = STOP
	$AnimationPlayer.play("Die")
	yield(get_node("AnimationPlayer"), "animation_finished")
	get_tree().reload_current_scene()
	

func set_flip():
	if velocity.x == 0:
		return
	$Sprite.flip_h = true if velocity.x < 0 else false

func set_animation():
	if state == STOP:
		return
		
	var anim_name = "Idle"
	if velocity.x != 0:
		anim_name = "Run"
	if !is_on_floor():
		anim_name = "Jump"
	
	$AnimationPlayer.play(anim_name)


func calculate_move_velocity(direction, is_jump_interrupted):
	var new_velo = velocity
	new_velo.x = speed.x * direction.x
	new_velo.y += gravity * get_physics_process_delta_time()
	if direction.y == -1:
		new_velo.y = speed.y * direction.y
	if is_jump_interrupted:
		new_velo.y = 0.0
	
	velocity = new_velo

func get_direction():
	return Vector2(
		Input.get_action_strength("game_right") - Input.get_action_strength("game_left"),
		-1.0 if Input.is_action_just_pressed("game_jump") and is_on_floor() else 0.0
	)






