extends CharacterBody2D
class_name Player
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

const SPEED = 170
const JUMP_VELOCITY = -400

var is_attacking = false
var can_attack = true
var is_hurt = false

var max_health = 100
var current_health = 100
signal health_changed(new_health)
func _input(event) -> void:
	if is_hurt:
		return
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if can_attack and not is_hurt:
		if event.is_action_pressed("attack_1"):
			attack("attack_1")
		if event.is_action_pressed("attack_2"):
			attack("attack_2")
		if event.is_action_pressed("attack_3"):
			attack("attack_3")

func _physics_process(delta):
	if is_hurt or is_attacking:
		velocity.x = 0
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	var direction = Input.get_axis("run_left", "run_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	update_facing_direction(direction)
	update_animation(direction)
func update_facing_direction(direction: float):
	if direction == 0:
		return
	var is_facing_left = direction < 0
	animated_sprite_2d.flip_h = is_facing_left
	if is_facing_left:
		animated_sprite_2d.position.x = 12
		hitbox.scale.x = -1
	else:
		animated_sprite_2d.position.x = 0
		hitbox.scale.x = 1
func update_animation(direction: float):
	if is_attacking:
		return
		
	if not is_on_floor():
		if velocity.y < 0.0:
			animated_sprite_2d.play("jump")
		elif velocity.y > 0.0:
			animated_sprite_2d.play("fall")
	elif direction != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
func attack(attack_anim: String):
	is_attacking = true
	can_attack = false
	animated_sprite_2d.play(attack_anim)
	$Hitbox.monitoring = true
func take_damage(amount):
	if is_hurt:
		return
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	health_changed.emit(current_health)
	if is_attacking:
		is_attacking = false
		can_attack = true
		$Hitbox.set_deferred("monitoring", false)
	if current_health > 0:
		is_hurt = true
		animated_sprite_2d.play("hurt")
		await animated_sprite_2d.animation_finished
		is_hurt = false
	else:
		die()
func die():
	set_physics_process(false)
	animated_sprite_2d.play("death")
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()



func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation in ["attack_1", "attack_2", "attack_3"]:
		is_attacking = false
		can_attack = true
		$Hitbox.monitoring = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if not is_attacking:
		return
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(1)
