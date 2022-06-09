extends Control

signal textbox_closed

export(Resource) var enemy = null

var battle_start = false
var current_player_health = 0
var current_enemy_health = 0
var is_defending = false
var current_selection = 0

func _ready():
	
	set_current_selection(0)
	set_health($BattleBG/Enemy/ProgressBarEnemy, enemy.health, enemy.health)
	set_health($PlayerPanel/PlayerData/ProgressBarPlayer, State.current_health, State.max_health)
	$BattleBG/Enemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	$TextBox.hide()
	$ActionPanel.hide()
	
	display_text("A WILD %s DRAWS NEAR!" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	$Select.play()
	$ActionPanel.show()
	battle_start = true

func _process(delta):
	if Input.is_action_just_pressed("ui_right") and current_selection < 4 and battle_start == true and $ActionPanel.is_visible():
		$SelectionMove.play()
		current_selection += 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_left") and current_selection > 0 and battle_start == true and $ActionPanel.is_visible():
		$SelectionMove.play()
		current_selection -= 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept") and battle_start == true and $ActionPanel.is_visible():
		handle_selection(current_selection)
	

func handle_selection(_current_selection):
	if _current_selection == 0:
		Attack()
	elif _current_selection == 1:
		Defend()
	elif _current_selection == 2:
		$ActionConfirm.play()
		print("TODO = SPECIAL ")
		enemy_turn()
	elif _current_selection == 3:
		$ActionConfirm.play()
		print("TODO = ITEMS ")
		enemy_turn()
	elif _current_selection == 4:
		Run()

func set_current_selection(_current_selection):
	$ActionPanel/Actions/Attack.text = "ATTACK"
	$ActionPanel/Actions/Defend.text = "DEFEND"
	$ActionPanel/Actions/Special.text = "SPECIAL"
	$ActionPanel/Actions/Items.text = "ITEMS"
	$ActionPanel/Actions/Run.text = "RUN"
	
	if _current_selection == 0:
		$ActionPanel/Actions/Attack.text = "> ATTACK"
	elif _current_selection == 1:
		$ActionPanel/Actions/Defend.text = "> DEFEND"
	elif _current_selection == 2:
		$ActionPanel/Actions/Special.text = "> SPECIAL"
	elif _current_selection == 3:
		$ActionPanel/Actions/Items.text = "> ITEMS"
	elif _current_selection == 4:
		$ActionPanel/Actions/Run.text = "> RUN"

	
func set_health(progress_bar,health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	
func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(BUTTON_LEFT)) and $TextBox.visible:
		yield(get_tree().create_timer(0.05), "timeout")
		$TextBox.hide()
		emit_signal("textbox_closed")
	
func display_text(text):
	$ActionPanel.hide()
	$TextBox.show()
	$TextBox/BattleText.text = text

func _on_Run_pressed():
	Run()

func Run():
	$ActionConfirm.play()
	display_text("YOU ESCAPE!")
	yield(self, "textbox_closed")
	$Select.play()
	yield(get_tree().create_timer(0.25), "timeout")
	$RunAway.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Scenes/World.tscn")

func enemy_turn():
	display_text("%s ADVANCES ON YOU FURIOUSLY"% enemy.name.to_upper())
	yield(self, "textbox_closed")
	
	if is_defending:
		is_defending = false
		$HitPlayer.play()
		$AnimationPlayer.play("mini_screen_shake")
		yield($AnimationPlayer, "animation_finished")
		display_text("BLOCKED! YOU DEFENDED SUCESSFULLY!")
		$Defended.play()
		yield(self, "textbox_closed")
		$Select.play()
	else:
		current_player_health = max(0, current_player_health - enemy.damage)
		set_health($PlayerPanel/PlayerData/ProgressBarPlayer, current_player_health, enemy.health)
		print("Enemy: %d" % current_enemy_health)
		$AnimationPlayer.play("Screenshake")
		$HitPlayer.play()
		yield($AnimationPlayer, "animation_finished")
		display_text("SLASH! YOU RECEIVED %d DAMAGE" % enemy.damage) 
		yield(self, "textbox_closed")
		$Select.play()
	$ActionPanel.show()
		
	if current_player_health == 0:
		$PlayerPanel.modulate = Color(1, 0, 0)
		$TextBox.modulate = Color(1, 0, 0)
		display_text("KNOCKED OUT!!!")
		$AnimationPlayer.play("Screenshake")
		$Critical.play()
		yield(self, "textbox_closed")
		
		$Critical.stop()
		$Select.play()
		$OST.stop()
		display_text("YOU LOST THE BATTLE!")
		$Lost.play()
		yield(self, "textbox_closed")
		$PlayerPanel.hide()
		$Select.play()
		yield(get_tree().create_timer(0.25), "timeout")
		get_tree().quit()
		
func _on_Attack_pressed():
	Attack()

func Attack():
	$ActionConfirm.play()
	display_text("YOU TRY TO HIT %s" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	$Select.play()
	
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($BattleBG/Enemy/ProgressBarEnemy, current_enemy_health, enemy.health)
	print(current_enemy_health)
	$AnimationPlayer.play("enemy_damaged")
	$HitEnemy.play()
	yield($AnimationPlayer, "animation_finished")
	
	display_text("SLASH! ENEMY RECEIVED %d DAMAGE" % State.damage) 
	yield(self, "textbox_closed")
	$Select.play()
	
	if current_enemy_health == 0:
		display_text("%s WAS DEFEATED!" % enemy.name.to_upper())
		yield(self, "textbox_closed")
		$Select.play()
		$OST.stop()
		$AnimationPlayer.play("EnemyDied")
		$EnemyDied.play()
		yield($AnimationPlayer, "animation_finished")
		display_text("YOU WIN!")
		$Victory.play()
		yield(self, "textbox_closed")
		$Select.play()
		display_text("YOU GOT: XP")
		yield(self, "textbox_closed")
		$Select.play()
		yield(get_tree().create_timer(0.25), "timeout")

		get_tree().change_scene("res://Scenes/World.tscn")
	enemy_turn()

func _on_Defend_pressed():
	Defend()

func Defend():
	is_defending = true
	$ActionConfirm.play()
	display_text("YOU TRY TO DEFEND A BASH FROM %s" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	$Select.play()
	yield(get_tree().create_timer(0.25), "timeout")
	enemy_turn()


func _on_Special_pressed():
	$ActionConfirm.play()
	enemy_turn()

func _on_Items_pressed():
	$ActionConfirm.play()
	enemy_turn()
