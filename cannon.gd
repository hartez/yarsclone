extends Node2D
class_name Cannon

@export var projectileScene : PackedScene = preload("res://cannon_shot.tscn")

signal firing(projectile)

var charge : float = 0
var armed = false
var charging = false
var cooldown_timer 

func _ready():
	cooldown_timer = $Cooldown

func start(coolDown : int = 8.0):
	charging = true
	cooldown_timer.start(coolDown)

func pause():
	charging = false
	cooldown_timer.stop()

func _process(delta):
	if !charging:
		return
	
	var total = cooldown_timer.wait_time
	var left = cooldown_timer.time_left
	charge = (total - left) / total
	
func _on_cooldown_timeout() -> void:
	armed = true
	charging = false
	charge = 1
	$ChargedSound.play()

func _on_player_fire_cannon() -> void:
	if armed:
		fire()

func fire():
	var projectile = projectileScene.instantiate() as CannonShot
	projectile.position = global_position
	firing.emit(projectile)
	$FireSound.play()
	armed = false
	charging = true 
	cooldown_timer.start()
