extends Area2D
class_name Seeker

var baseSpeed = 100
var speed = 100 ## How fast the seeker will move (pixels/sec).
@export var neutralZoneUncertainty = 100 ## Range of uncertainty the seeker will have about the player position inside the neutral zone

signal hit

var screen_size 
var direction = Vector2.ZERO
var armed = false
var paused = false

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	
func start(pos, speedBoost : int = 0):
	position = pos
	rotation = 0
	speed = baseSpeed + speedBoost
	show()
	armed = true
	paused = false

func pause():
	paused = true

func aim(target : Vector2):
	if !armed:
		# If the seeker is in the neutral zone, it should look like it's 
		# having trouble tracking the ship, so we'll add some random 
		# uncertainty to its perception of the ship's location
		target.x += randi_range(-neutralZoneUncertainty, neutralZoneUncertainty)
		target.y += randi_range(-neutralZoneUncertainty, neutralZoneUncertainty)
		
	direction = (target - position).normalized()
		
func _process(delta):
	if paused:
		return
		
	position += direction * delta * speed
	position = position.clamp(Vector2.ZERO, screen_size)

func _on_neutral_zone_area_entered(area: Area2D) -> void:
	if(area == self && armed):
		armed = false
	
func _on_neutral_zone_area_exited(area: Area2D) -> void:
	if(area == self && !armed):
		armed = true
	
func _on_player_area_entered(area: Area2D) -> void:
	if(area == self && armed):
		hit.emit()
		self.hide()
