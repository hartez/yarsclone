extends Node2D
class_name Shield

var healTimer : Timer
var healQueue : Array[ShieldChunk]
var healing : bool

func _ready():
	healing = false
	healTimer = $RebuildTimer
	var chunks = get_tree().get_nodes_in_group("Chunks")
	for c in chunks:
		listenForDestruction(c)

func start(heal : bool = false, chunkHP : int = 1):
	get_tree().call_group("Chunks", "create", chunkHP)
	
	healQueue.clear()
	healing = heal
	
	if healing:
		healTimer.start() 

func queueForHealing(chunk : ShieldChunk):
	if healing:
		healQueue.push_back(chunk)
		healTimer.start()

func listenForDestruction(chunk : ShieldChunk):
	var callable = func() : queueForHealing(chunk)
	chunk.connect("destroyed", callable)

func pause():
	healing = false
	healTimer.stop()

func heal_chunk():
	var chunk = healQueue.pop_front()
	if chunk != null:
		chunk.create()

func _on_rebuild_timer_timeout() -> void:
	heal_chunk()
