
extends Button

@onready var icon_button: TextureButton = $TextureButton

var normal_icon: Texture2D
var hover_icon: Texture2D
var pressed_icon: Texture2D

var is_hovered := false
var is_pressed := false


func _ready() -> void:
	normal_icon = icon_button.texture_normal
	hover_icon = icon_button.texture_hover
	pressed_icon = icon_button.texture_pressed

	# The parent Button handles mouse input.
	icon_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

	update_icon()


func _on_mouse_entered() -> void:
	is_hovered = true
	update_icon()


func _on_mouse_exited() -> void:
	is_hovered = false
	update_icon()


func _on_button_down() -> void:
	is_pressed = true
	update_icon()


func _on_button_up() -> void:
	is_pressed = false
	update_icon()


func update_icon() -> void:
	if is_pressed and pressed_icon != null:
		icon_button.texture_normal = pressed_icon
	elif is_hovered and hover_icon != null:
		icon_button.texture_normal = hover_icon
	else:
		icon_button.texture_normal = normal_icon
