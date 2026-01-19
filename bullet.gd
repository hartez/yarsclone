extends Area2D
class_name Bullet

var speed = 600

func _process(delta):
	var velocity = Vector2.ZERO 
	velocity.x = sin(rotation)
	velocity.y = -cos(rotation)
	position += velocity * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
