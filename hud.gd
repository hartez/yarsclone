extends CanvasLayer
class_name HUD

var chargeBar
var startInstructions
var helpInstructions
var cannon : Cannon
var levelIntro : GridContainer
var levelHud : Label
var helpVisible = false

func _ready():
	startInstructions = get_node("Root/StartInstructions")
	helpInstructions = get_node("Root/HelpInstructions")
	chargeBar = get_node("Root/CannonCharge/ProgressBar")
	cannon = get_parent().get_node("Cannon") as Cannon
	levelIntro = $Root/LevelIntro
	levelHud = $Root/Level

	startInstructions.text = "Press Start or Enter for New Game"

func start(level : int):
	updateLevel(level)
	startInstructions.hide()
	helpInstructions.hide()
	levelHud.show()
	levelIntro.show()
	await countDown()
	levelIntro.hide()

func toggle_help(on : bool):
	if on:
		$Root/Instructions.show()
		startInstructions.hide()
		helpInstructions.hide()
		helpVisible = true
	else:
		$Root/Instructions.hide()
		startInstructions.show()
		helpInstructions.show()
		helpVisible = false
		
func countDown():
	var countDown = levelIntro.get_node("Countdown")
	for n in 3:
		countDown.text = str(3 - n)
		$Root/CountdownTick.play()
		await get_tree().create_timer(1.0).timeout

func updateLevel(level : int):
	levelHud.text = "Level %d" % get_node("..").level	
	levelIntro.get_node("Level").text = levelHud.text
	
func game_over(win : bool = false):
	levelHud.hide()
	
	if win:
		startInstructions.text = "Congratulations, a winner is you!\nPress Start or Enter for New Game"
		$WinSound.play()
	else:
		$LoseSound.play()
		startInstructions.text = "Better luck next time.\nPress Start or Enter for New Game"	
	
	startInstructions.show()
	helpInstructions.show()

func _process(delta):
	chargeBar.value = cannon.charge * 100
