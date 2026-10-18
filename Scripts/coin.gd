extends Area2D
@onready var pickup_sfx: AudioStreamPlayer2D = $PickupSFX

func collect():
	$CollisionShape2D.set_deferred("disabled", true)
	hide()
	pickup_sfx.play()
	await pickup_sfx.finished
	queue_free()
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().call_group("UI", "add_coin")
		collect()
