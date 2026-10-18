extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	$Description.show()
	$AnimationPlayer.play("Describtion animation")


func _on_button_2_pressed() -> void:
	$AnimationPlayer.play("folding animation")


func _on_exit_button_pressed() -> void:
	$QuitPopup.show()
	$DarkQuit.show()
	$AnimationPlayer.play("Quitpopup")


func _on_back_pop_button_pressed() -> void:
	$QuitPopup.hide()
	$DarkQuit.hide()


func _on_exit_pop_button_pressed() -> void:
	get_tree().quit()


func _on_new_adv_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels.tscn")
