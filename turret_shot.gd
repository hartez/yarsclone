extends Area2D
class_name TurretShot

@export var speed = 600
var direction : Vector2 = Vector2.ZERO

func _ready():
	$AnimatedSprite2D.play()

func _process(delta):
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func destroy():
	self.hide()
	queue_free()
	
func _on_area_entered(area: Area2D) -> void:
	var player = area as Player
	if player != null:
		player.destroy()
		destroy()
