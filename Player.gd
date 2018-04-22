extends Area2D

signal shooting
signal stop_shooting

export (int) var SPEED = 400;
var screensize
var bulletScene = preload("res://Bullet.tscn")

var isCatching = false
var isHoldingFruit = false
var heldFruit
var startingPos

func _ready():
	screensize = get_viewport_rect().size
	set_process_input(true)
	startingPos = position

func _input(event):
	if event.is_action_pressed("ui_toggle_catch"):
		if (isCatching):
			if (isHoldingFruit):
				dropFruit()
			startShooting()
		else:
			startCatching()

func _process(delta):
	move(delta)
	shoot()

func dropFruit():
	if ($Fruit != null):
		var fruit = $Fruit
		print(fruit.get_name())
		
		var main = get_tree().get_root().get_node("Main")
		var pos = fruit.get_global_transform()

		self.remove_child(fruit)
		main.add_child(fruit)
		fruit.set_owner(main)

		fruit.mode = RigidBody2D.MODE_RIGID
		fruit.global_transform = pos
		isHoldingFruit = false

func startShooting():
	isCatching = false
	$AnimatedSprite.animation = "shooting"
	
func startCatching():
	isCatching = true
	$AnimatedSprite.animation = "catching"

func resetPlayer():
	for child in self.get_children():
		if (child.is_in_group("fruit")):
			child.queue_free()
	startShooting()
	position = startingPos

func shoot():
	if (Input.is_action_pressed("ui_shoot") && !isCatching):
		emit_signal("shooting")
		var bulletInstance = bulletScene.instance()
		bulletInstance.position = $AnimatedSprite/Gunpoint.global_position
		get_tree().get_root().add_child(bulletInstance)
	else:
		emit_signal("stop_shooting")

func move(delta):
	var velocity = Vector2() 
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		$AnimatedSprite.flip_h = false
		$AnimatedSprite/Gunpoint.position.x = 22
		$AnimatedSprite.playing = true
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		$AnimatedSprite.flip_h = true
		$AnimatedSprite/Gunpoint.position.x = -22
		$AnimatedSprite.playing = true
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		
	if (velocity.length() == 0):
		$AnimatedSprite.playing = false
	
	position += velocity * delta
	
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, screensize.y * 0.75, screensize.y)


func _on_CatchArea_body_entered(body):
	if (body.is_in_group("fruit") && isCatching && !isHoldingFruit):
		var fruit = body
		var main = get_tree().get_root().get_node("Main")
		var pos = $AnimatedSprite/CatchArea/CatchAreaCollision.global_position

		if (fruit.get_parent() == main):
			main.remove_child(fruit)
			self.add_child(fruit)
			fruit.set_owner(self)
			fruit.set_name("Fruit")
			heldFruit = fruit
			isHoldingFruit = true
			
			fruit.mode = RigidBody2D.MODE_STATIC
			fruit.global_position = pos