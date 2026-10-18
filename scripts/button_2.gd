
extends Button

@onready var texture_button_3: TextureButton = $TextureButton3


var normal_icon: Texture2D
var hover_icon: Texture2D
var pressed_icon: Texture2D

var is_hovered := false
var is_pressed := false


func _ready() -> void:
	normal_icon = texture_button_3.texture_normal
	hover_icon = texture_button_3.texture_hover
	pressed_icon = texture_button_3.texture_pressed

	# The parent Button handles mouse input.
	texture_button_3.mouse_filter = Control.MOUSE_FILTER_IGNORE

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
		texture_button_3.texture_normal = pressed_icon
	elif is_hovered and hover_icon != null:
		texture_button_3.texture_normal = hover_icon
	else:
		texture_button_3.texture_normal = normal_icon
