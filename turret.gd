extends Area2D
class_name Turret

@export var bullet_scene: PackedScene = preload("res://turret_shot.tscn")

signal firing(projectile)
signal hit
signal destroyed

var exploding = false
var direction = Vector2.ZERO
var fireCooldown = 10.0

func start(cooldown):
	fireCooldown = cooldown
	exploding = false
	$AnimatedSprite2D.animation = &"default"
	self.show()
	$FireCooldown.start(fireCooldown)

func pause():
	$FireCooldown.stop()
	$FireCountdown.stop()

func _on_fire_cooldown_timeout() -> void:
	charge()

func aim(target):
	direction = (target - position).normalized()

func charge():
	$ChargeUpSound.play()
	$ChargeUp.show()
	$ChargeUp.play()
	$FireCountdown.start()
	
func fire():
	$ChargeUp.hide()
	var instance: Node2D = bullet_scene.instantiate() as TurretShot
	instance.position = global_position
	instance.direction = direction
	firing.emit(instance)
	$FireSound.play()
	$FireCooldown.start(fireCooldown)

func destroy():
	hit.emit()
	exploding = true
	$ChargeUp.hide()
	$FireCooldown.stop()
	$FireCountdown.stop()
	$AnimatedSprite2D.animation = &"explode"
	$AnimatedSprite2D.play()
	$ExplosionSound.play()

func _on_fire_countdown_timeout() -> void:
	fire()

func _on_area_entered(area: Area2D) -> void:
	if area is CannonShot:
		area.hide()
		area.queue_free()
		destroy()
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if exploding:
		self.hide()
		destroyed.emit()
