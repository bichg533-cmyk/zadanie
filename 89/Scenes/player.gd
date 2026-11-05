extends CharacterBody2D
class_name Player

const ACCELERATION_SMOOTHING: int = 25
@export var MAX_SPEED: int = 100
@onready var shooting_component : ShootingComponent = $ShootingComponent
var reloading = false

func _physics_process(delta: float) -> void:
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	var target_vel = direction * MAX_SPEED
	velocity = velocity.lerp(target_vel, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	look_at(get_global_mouse_position())
	move_and_slide()
	_handle_animations(movement_vector)
	_handle_shooting()

func get_movement_vector() -> Vector2:
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement, y_movement)

func _handle_animations(move_vect) -> void:
	if (move_vect.x != 0.0 or move_vect.y != 0.0) and !reloading:
		$AnimatedSprite2D.play("move")
	elif reloading:
		$AnimatedSprite2D.play("reload")
	elif move_vect == Vector2.ZERO:
		$AnimatedSprite2D.play("idle")

func _handle_shooting() -> void:
	if Input.is_action_pressed("shoot") and !reloading:
		shooting_component.try_shoot()
	if Input.is_action_just_pressed("reload"):
		reload_gun()

func play_audio_shoot() -> void:
	var shoot_sounds = $Sounds/FireSounds.get_children()
	var random_pitch = randf_range(0.85, 1.15)
	var audio_to_play = shoot_sounds[randi_range(0,2)]
	audio_to_play.pitch_scale = random_pitch
	audio_to_play.play()

func _on_shooting_component_shot_fired() -> void:
	$AnimatedSprite2D.play("shoot")
	$FXAnimPlayer.play("fire")
	play_audio_shoot()

func _on_shooting_component_shot_failed() -> void:
	$Sounds/OutOfAmmoSounds/OutOfAmmoSound.play()

func reload_gun() -> void:
	if shooting_component.current_ammo_on_mag == shooting_component.max_bullets_on_mag:
		return
	if shooting_component.current_ammo == 0:
		return
	reloading = true
	$Sounds/ReloadSounds/ReloadSound1.play()
	await $AnimatedSprite2D.animation_finished
	shooting_component.reload()
	reloading = false
