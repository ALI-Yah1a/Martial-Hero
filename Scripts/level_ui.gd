extends CanvasLayer
@onready var pause_menu: Control = $PauseMenu
@onready var level_complete_menu: Control = $LevelCompleteMenu
@onready var health_bar: TextureProgressBar = $HUD/PlayerStats/VitalsAndStats/Control/HealthBar
@onready var coins_label: Label = $HUD/PlayerStats/VitalsAndStats/Control2/VBoxContainer/CoinsTracker/CoinsLabel
@onready var gorgon_label: Label = $HUD/PlayerStats/VitalsAndStats/Control2/VBoxContainer/GorgonsTracker/GorgonLabel
@onready var current_level: Label = $HUD/PlayerStats/VitalsAndStats/Control2/VBoxContainer/CurrentLevelLabel

@export var player: Player
@export var required_coins: int = 10
@export var required_gorgons: int = 10
@export var current_level_number: int = 1
@export_file("*.tscn") var next_level_path: String
var current_coins: int = 0
var current_gorgons: int = 0

func _ready() -> void:
	current_level.text = "Level " + str(current_level_number)
	if player:
		health_bar.max_value = player.max_health
		health_bar.value = player.current_health
		player.health_changed.connect(update_hp)
	pause_menu.visible = false
	update_coins_ui()
	update_gorgons_ui()
func update_hp(new_health):
	health_bar.value = new_health
func add_coin(amount: int = 1):
	current_coins += amount
	update_coins_ui()
	check_level_completion()
func add_gorgon(amount: int = 1):
	current_gorgons += amount
	update_gorgons_ui()
	check_level_completion()
func update_coins_ui():
	coins_label.text = str(current_coins) + " / " + str(required_coins)
func update_gorgons_ui():
	gorgon_label.text = str(current_gorgons) + " / " + str(required_gorgons)

func check_level_completion():
	if current_coins >= required_coins and current_gorgons >= required_gorgons:
		level_complete_menu.visible = true
		get_tree().paused = true

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	pause_menu.visible = new_pause_state
func set_level(level_number: int) -> void:
	current_level.text = "LEVEL %02d" % level_number

func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_next_level_button_pressed() -> void:
	get_tree().paused = false
	if next_level_path != "":
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
