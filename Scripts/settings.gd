
extends Control

@onready var volume_slider: HSlider = $Panel/VolumeSlider
@onready var fullscreen_check: CheckButton = $Panel/FullscreenCheck
@onready var back_button: Button = $Panel/BackButton
@onready var reset_button: Button = $Panel/ResetButton

const MAIN_MENU_PATH := "res://Scenes/MainMenu.tscn"

const DEFAULT_VOLUME: float = 80.0
const DEFAULT_FULLSCREEN: bool = false


func _ready() -> void:
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.step = 1

	volume_slider.value = DEFAULT_VOLUME

	fullscreen_check.button_pressed = (
		DisplayServer.window_get_mode()
		== DisplayServer.WINDOW_MODE_FULLSCREEN
	)

	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)

	_on_volume_changed(volume_slider.value)


func _on_volume_changed(value: float) -> void:
	var master_bus := AudioServer.get_bus_index("Master")

	if master_bus != -1:
		AudioServer.set_bus_volume_linear(
			master_bus,
			value / 100.0
		)


func _on_fullscreen_toggled(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)


func _on_reset_pressed() -> void:

	volume_slider.value = DEFAULT_VOLUME


	fullscreen_check.set_pressed_no_signal(DEFAULT_FULLSCREEN)
	_on_fullscreen_toggled(DEFAULT_FULLSCREEN)


	_on_volume_changed(DEFAULT_VOLUME)


func _on_back_pressed() -> void:
	if ResourceLoader.exists(MAIN_MENU_PATH):
		get_tree().change_scene_to_file(MAIN_MENU_PATH)
	else:
		push_warning(
			"Update MAIN_MENU_PATH to your actual main menu scene."
		)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
