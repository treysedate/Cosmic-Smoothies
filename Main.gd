extends Node

export (float) var SHAKE = 0.0

var enemyScene = preload("res://Enemy.tscn")
var enemyPathScene = preload("res://EnemyPath.tscn")
var orderScene = preload("res://Order.tscn")

func _ready():
	randomize()
	$Camera.make_current()
	$HUD.connect("restart_game", self, "_reload_game")
	$BackgroundMusic.play()
	start_game()

func _process(delta):
	$Camera.set_offset(Vector2( \
        rand_range(-1.0, 1.0) * SHAKE, \
        rand_range(-1.0, 1.0) * SHAKE \
    ))

func _reload_game():
	get_tree().reload_current_scene()

func start_game():
	$HUD/HealthBar.value = 100
	$HUD.reset()
	
	$Player.set_process(true)
	$Player.set_process_input(true)
	
	start_order()
#	spawn_enemy()
	$EnemySpawnTimer.start()

func start_order():
	var order = orderScene.instance()
	order.position = Vector2(-213, 97)
	add_child(order)
	$FoodCart.connect("smoothie_accepted", order, "_process_order")
	order.connect("order_processed", self, "start_order")
	order.add_to_group("orders")

func spawn_enemy():
	var enemyPath = enemyPathScene.instance()
	enemyPath.position.x += randi() % 750 - 500
	if (randi() % 2 == 1):
		enemyPath.scale.x = -1
		enemyPath.position.x = 750
	
	add_child(enemyPath)
	var enemy = enemyScene.instance()
	enemy.connect("enemy_died", self, "_explosion_shake_screen")
		
	enemyPath.get_node("PathFollow2D").add_child(enemy)
	enemyPath.connect("path_completed", enemy, "_path_completed")
	
func take_damage(damage):
	$HUD/HealthBar.value -= damage
	if ($HUD/HealthBar.value <= 0):
		game_over()

func game_over():
	$HUD.game_over()
	$Player.set_process(false)
	$Player.set_process_input(false)
	$Player/AnimatedSprite.animation = "shooting"
	$Player/AnimatedSprite.stop()
	$Player/AnimatedSprite.frame = 0
	$EnemySpawnTimer.stop()

func _on_Player_shooting():
	shake_screen(5.0)

func _on_Player_stop_shooting():
	shake_screen(0.0)

func shake_screen(screenshake):
	SHAKE = screenshake

func _explosion_shake_screen():
	$Camera/AnimationPlayer.play("Enemy_Explosion_Shake_Anim")

func _on_Floor_area_entered(area):
	if (area.is_in_group("enemies")):
		area.velocity = Vector2(0, 0)
		take_damage(area.DAMAGE_GIVEN)
		area.destroy_enemy()

func _on_EnemySpawnTimer_timeout():
	spawn_enemy()

func _on_Floor_body_entered(body):
	if (body.is_in_group("fruit")):
		body.splat()