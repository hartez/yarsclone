extends Node

var game_active = false
var level_active = false

var turret : Turret 
var seeker : Seeker
var player : Player
var cannon : Cannon
var shield : Shield
var hud : HUD
var bgm : AudioStreamPlayer2D

var level : int = 1
var maxLevel : int = 10

func _ready():
	turret = $Turret
	seeker = $Seeker
	player = $Player
	cannon = $Cannon
	shield = $Shield
	hud = $HUD
	bgm = $BGM
	
func new_game():
	level = 1
	hud.toggle_help(false)
	game_active = true
	start_level(level)
	
func end_game(win : bool = false):
	game_active = false
	player.hide()
	hud.game_over(win)
		
func start_level(level : int):
	level_active = true
	await hud.start(level) 
	
	var seekerSpeedBoost = level_seeker_speed_boost(level)
	var shieldHealing = level_shield_healing(level)
	var shieldChunkHP = level_shield_hp(level)
	var cannonCooldown = level_cannon_cooldown(level)
	var turretCooldown = level_turret_cooldown(level)	
		
	seeker.start($SeekerStartPosition.position, seekerSpeedBoost)
	player.start($StartPosition.position)
	cannon.start(cannonCooldown)
	shield.start(shieldHealing, shieldChunkHP)
	turret.start(turretCooldown)
	bgm.play()

func level_seeker_speed_boost(level : int):
	return (level - 1) * 5

func level_shield_healing(level : int):
	return level > 3
		 
func level_shield_hp(level : int):
	match level:
		1, 2:
			return 1
		3, 4, 5, 6:
			return 2
	return 3

func level_cannon_cooldown(level : int):
	if level > 2:
		return ((level - 2) * 0.25) + 8.0
	
	return 8.0

func level_turret_cooldown(level : int):
	if level > 2:
		return 10.0 - ((level - 2) * 0.25) 
	
	return 10.0

func end_level(game_over = false):
	if !level_active:
		return
	
	level_active = false
	turret.pause()
	cannon.pause()
	shield.pause()
	bgm.stop()
	
	if(game_over):
		end_game(false)
		return
	
	level += 1
	$LevelWinSound.play()
	await get_tree().create_timer(2.5).timeout
			
	if(level > maxLevel):
		end_game(true)
	else:
		start_level(level)
	

	
func _process(_delta):
	if !game_active:
		if Input.is_action_just_pressed(&"ui_start"):
			new_game()
			return
		
		if Input.is_action_just_pressed(&"ui_help"):
			hud.toggle_help(!hud.helpVisible)
			return
		
	var playerPosition  = player.position
	turret.aim(playerPosition)	
	seeker.aim(playerPosition)
	
	cannon.position.y = playerPosition.y
		
func _on_seeker_hit() -> void:
	if !level_active:
		return 
		
	player.destroy()

func _on_turret_firing(projectile: Variant) -> void:
	add_child(projectile)	

func _on_cannon_firing(projectile: Variant) -> void:
	add_child(projectile)

func _on_turret_destroyed() -> void:
	end_level()

func _on_player_destroyed() -> void:
	end_level(true)

func _on_turret_hit() -> void:
	seeker.pause()
