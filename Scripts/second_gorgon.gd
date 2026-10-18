extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var speed = 80
var chase_speed = 120
var direction = 1
var attack_range = 44
var attack_cooldown = 0.8
var max_hp = 2
var current_hp = 2
var is_alive = true
var can_attack = true
var is_hurt = false
var is_attacking = false 
var is_chasing = false
var player_ref: Node2D = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	health_bar.max_value = max_hp
	health_bar.value = current_hp
func _physics_process(delta: float) -> void:
	if not is_alive:
		return
		
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_hurt or is_attacking:
		velocity.x = 0
		move_and_slide()
		return
		
	if is_chasing and is_instance_valid(player_ref):
		var distance_to_player = global_position.distance_to(player_ref.global_position)
		var dir_to_player = sign(player_ref.global_position.x - global_position.x)
		if dir_to_player != 0:
			direction = dir_to_player
			
		
		update_facing_direction()
		
		if distance_to_player <= attack_range:
			velocity.x = 0
			if can_attack:
				start_attack()
		else:
			if (not ray_cast.is_colliding() and is_on_floor()) or is_on_wall():
				velocity.x = 0
			else:
				velocity.x = chase_speed * direction
	else:
		if is_on_wall() or (not ray_cast.is_colliding() and is_on_floor()):
			direction *= -1
			update_facing_direction()
		velocity.x = speed * direction
		
	move_and_slide()
	update_animation()

func update_facing_direction():
	if direction > 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.position.x = 0
		ray_cast.position.x = abs(ray_cast.position.x)
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.position.x = -10
		ray_cast.position.x = -abs(ray_cast.position.x)
func update_animation():
	if is_attacking or is_hurt or not is_alive:
		return
	if velocity.x != 0:
		if is_chasing:
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")
func start_attack() -> void:
	is_attacking = true
	can_attack = false
	velocity.x = 0
	if animated_sprite_2d.sprite_frames.has_animation("attack"):
		animated_sprite_2d.play("attack")
		await get_tree().create_timer(0.5).timeout
		if is_attacking and is_alive and not is_hurt and is_instance_valid(player_ref):
			if global_position.distance_to(player_ref.global_position) <= attack_range + 20.0:
				if player_ref.has_method("take_damage"):
					player_ref.take_damage(1)
					
		if is_attacking and animated_sprite_2d.is_playing() and animated_sprite_2d.animation == "attack":
			await animated_sprite_2d.animation_finished
	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
func take_damage(amount: int) -> void:
	if not is_alive or is_hurt:
		return
		
	is_hurt = true
	is_attacking = false
	current_hp -= amount
	health_bar.value = current_hp
	
	if current_hp > 0:
		if animated_sprite_2d.sprite_frames.has_animation("hurt"):
			animated_sprite_2d.play("hurt")
		await get_tree().create_timer(0.4).timeout
		is_hurt = false
	else:
		die()

func die() -> void:
	if not is_alive:
		return
	is_alive = false
	is_attacking = false
	velocity = Vector2.ZERO
	
	if animated_sprite_2d.sprite_frames.has_animation("death"):
		await get_tree().create_timer(0.2).timeout
		animated_sprite_2d.play("death")
		
	collision_shape_2d.set_deferred("disabled", true)
	await get_tree().create_timer(0.5).timeout
	
	var ui = get_tree().get_root().find_child("Level_UI", true, false)
	if ui and ui.has_method("add_gorgon_kill"):
		ui.add_gorgon_kill(1)
		
	queue_free()



func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_ref = body
		is_chasing = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		is_chasing = false
