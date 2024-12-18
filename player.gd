extends Area2D

signal hit

@export var speed = 400 # how fast player will move (pixels/sec)
var screen_size
var is_dead

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dead:
		return
	else:
		var velocity = Vector2.ZERO # The player's movement vector.
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
			
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.stop()
			
		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)
		
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$AnimatedSprite2D.animation = "up"
			$AnimatedSprite2D.flip_v = velocity.y > 0

func start(pos):
	is_dead = false
	position = pos
	$AnimatedSprite2D.animation = "up"
	$AnimatedSprite2D.scale.x = 0.75
	$AnimatedSprite2D.scale.y = 0.75
	show()
	print("showing character")
	$CollisionShape2D.disabled = false
	
func _on_body_entered(body: Node2D) -> void:
	is_dead = true
	$DeathSound.play()
	$AnimatedSprite2D.scale.x = 3
	$AnimatedSprite2D.scale.y = 3
	$AnimatedSprite2D.play("death")
	print("animating")
	
func end_the_game():
	hit.emit()
	hide() # Player disappears after being hit!
	$CollisionShape2D.set_deferred("disabled", true)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	print("anim over")
	if $AnimatedSprite2D.animation == "death":
		end_the_game()
