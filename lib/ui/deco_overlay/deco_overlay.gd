extends CanvasLayer
# Decorative animation which plays when the player enters a world
# (or potentially, switches bots)

# Random-looking numbers
const PRETTY_NUMBERS = [
	"866872147929799", "290956846492235", "244396778564400", "364805832595899",
	"655850008194013", "332537383280083", "834218265364893", "976518079288721",
	"534183072231265", "123788366379008", "357587498422741", "208621210527079",
	"913905588094016", "125337460626072", "871588121875364", "739195204086143",
	"902115314376031", "549759979454658", "721035780181509", "962800469227746",
	"611921069828898", "843603125185017", "755124141610370", "335882453124137",
	"811828994526924", "516061275511135", "946110744016035", "650429545965546",
	"104026017044135", "511755889513421", "725859305339301", "160998058162995"]
var num_place = 0

func flicker():
	if $Flicker.is_playing() == true: return
	$Flicker.play("flicker")
	$PrettyNumberUpdate.start()

func _ready():
	Global.connect("deco_triggered", flicker)
	
	await get_tree().create_timer(0.7).timeout
	flicker()

func _on_pretty_number_update_timeout():
	$DecoFrame/PrettyNumbers.text = "[center]" + PRETTY_NUMBERS[num_place] + "[/center]"
	if num_place == len(PRETTY_NUMBERS) - 1:
		num_place = 0
		return
	else:
		num_place += 1
	
	if $DecoFrame.modulate.a > 0.1:
		$PrettyNumberUpdate.start()
