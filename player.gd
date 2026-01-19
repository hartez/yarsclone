extends Area2D
class_name Player

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var bullet_scene: PackedScene = preload("res://bullet.tscn")

var screen_size # Size of the game window
var destroying = false
var armed = false

signal fire_cannon
signal destroyed

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	
func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false
	$Ship.show()
	$Splosion.hide()
	destroying = false
	armed = true

func destroy():
	destroying = true
	armed = false
	$Ship.hide()
	$Exhaust.hide()
	
	# TODO See if you can just change the animation for the ship from default to explosion, not have a separate entity to worry about
	$Splosion.show()
	$Splosion.play()
	$ExplosionSound.play()

func _process(delta):
	processMovement(delta)
	processWeapons(delta)

func processWeapons(delta):
	if !armed:
		return
	
	if Input.is_action_pressed(&"ui_fire") && $PrimaryWeaponCooldown.is_stopped():
		firePrimary()	
	elif Input.is_action_pressed(&"ui_cannon"):
		fire_cannon.emit()
	
func processMovement(delta):
	if destroying:
		return
	
	var velocity = Vector2.ZERO # The player's movement vector.
	
	var theta = 0
		
	if Input.is_action_pressed(&"ui_right"):
		velocity.x += 1
		theta += PI/2
	if Input.is_action_pressed(&"ui_left"):
		velocity.x -= 1
		theta += -PI/2
	if Input.is_action_pressed(&"ui_down"):
		velocity.y += 1
		theta = PI - (theta/2)
	if Input.is_action_pressed(&"ui_up"):
		velocity.y -= 1
		theta = theta / 2

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		rotation = theta
		$Ship.play()
		$Exhaust.show()
		$Exhaust.play()
	else:
		$Ship.stop()
		$Exhaust.stop()
		$Exhaust.hide()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	$Ship.animation = &"default"

func firePrimary():
	var instance: Node2D = bullet_scene.instantiate()
	instance.position = $BulletOrigin.global_position
	instance.rotation = rotation
	get_parent().add_child(instance)
	$PrimaryWeaponCooldown.start()
	$FireSound.play()
	
func _on_splosion_animation_finished() -> void:
	destroyed.emit()

func _on_neutral_zone_area_entered(area: Area2D) -> void:
	if(area == self && armed):
		armed = false

func _on_neutral_zone_area_exited(area: Area2D) -> void:
	if(area == self && !armed):
		armed = true

func _on_turret_area_entered(area: Area2D) -> void:
	if(area == self):
		destroy()
