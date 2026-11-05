extends Area2D

@export var lifetime: float = 3.0
@export var damage: int = 25
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var speed = 0.0
var _time_alive = 0.0

func setup_bullet(bullet_direction: float, bullet_speed: float, spread_angle: float):
	var random_spread = deg_to_rad(randf_range(-spread_angle, spread_angle))
	direction = Vector2(1, 0).rotated(bullet_direction).rotated(random_spread)
	speed = bullet_speed
	velocity = direction * speed

func _physics_process(delta: float) -> void:
	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()
	position += velocity * delta

func _on_body_entered(body):
	queue_free()

func _on_area_entered(area):
	queue_free()
