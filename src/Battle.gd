extends Control

signal textbox_closed

export(Resource) var enemy = null

var current_player_health = 0
var current_enemy_health = 0

func _ready():
	set_health($BattleBG/Enemy/ProgressBarEnemy, enemy.health, enemy.health)
	set_health($PlayerPanel/PlayerData/ProgressBarPlayer, State.current_health, State.max_health)
	$BattleBG/Enemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	$TextBox.hide()
	$ActionPanel.hide()
	
	display_text("A %s DRAWS NEAR!" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	$Select.play()
	$ActionPanel.show()
	
func set_health(progress_bar,health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	#progress_bar.get_node("Label").text = "HP:%d/%d" % [health, max_health]
	
func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(BUTTON_LEFT)) and $TextBox.visible:
		$TextBox.hide()
		emit_signal("textbox_closed")
	
func display_text(text):
	$TextBox.show()
	$TextBox/BattleText.text = text

func _on_Run_pressed():
	$Select.play()
	display_text("YOU ESCAPE!")
	yield(self, "textbox_closed")
	$Select.play()
	yield(get_tree().create_timer(0.25), "timeout")
	$RunAway.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://World.tscn")

func enemy_turn():
	display_text("%s ADVANCES ON YOU FURIOUSLY"% enemy.name.to_upper())
	yield(self, "textbox_closed")
	$Select.play()
	
	current_player_health = max(0, current_player_health - enemy.damage)
	set_health($PlayerPanel/PlayerData/ProgressBarPlayer, current_player_health, enemy.health)
	print(current_enemy_health)
	
	$AnimationPlayer.play("Screenshake")
	$HitPlayer.play()
	yield($AnimationPlayer, "animation_finished")
	
	display_text("SLASH! YOU RECEIVED %d DAMAGE" % enemy.damage) # TODO fonte atual não tem numeros, trocar de fonte
	yield(self, "textbox_closed")
	$Select.play()
	

func _on_Attack_pressed():
	$Select.play()
	display_text("YOU TRY TO HIT %s" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	$Select.play()
	
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($BattleBG/Enemy/ProgressBarEnemy, current_enemy_health, enemy.health)
	print(current_enemy_health)
	$AnimationPlayer.play("enemy_damaged")
	$HitEnemy.play()
	yield($AnimationPlayer, "animation_finished")
	
	display_text("SLASH! ENEMY RECEIVED %d DAMAGE" % State.damage) # TODO fonte atual não tem numeros, trocar de fonte
	yield(self, "textbox_closed")
	$Select.play()
	
	enemy_turn()

