extends Area2D
class_name ShieldChunk

var hitPoints : int 

var explosion
var block : Sprite2D
var collisionShape

signal destroyed

var normal_texture = load("res://art/Platform_01_png_processed.png")
var partial_damage_texture = load("res://art/Platform_01_damaged.png")
var heavy_damage_texture = load("res://art/Platform_01_damaged2.png")
var maxHP : float

func _ready():
	block = $BlockSprite
	block.texture = normal_texture
	explosion = $Explosion
	collisionShape = $CollisionShape2D

func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		hitPoints -= 1
		area.hide()
		area.queue_free()
			
		if hitPoints == 0:
			destroy()
		else:
			show_damage()
		return

	# Cannon Shots should immediately destroy shield chunks no matter the HP
	if area is CannonShot:
		hitPoints = 0
		destroy()
		area.hide()
		area.queue_free()
		return
	
	var player = area as Player
	if player != null:
		player.destroy()
		destroy()

func show_damage():
	if hitPoints / maxHP > 0.5:
		block.texture = partial_damage_texture
	else:
		block.texture = heavy_damage_texture
			
func create(hp: int = 1):
	maxHP = hp
	hitPoints = hp
	explosion.hide()
	block.texture = normal_texture
	block.show()
	collisionShape.set_deferred("disabled", false) 
	self.show()
						
func destroy():
	block.hide()
	collisionShape.set_deferred("disabled", true) 
	explosion.show()
	explosion.play()
	$ExplosionSound.play()
	destroyed.emit()
	
func _on_explosion_animation_finished() -> void:
	self.hide()
