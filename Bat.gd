extends KinematicBody2D

const battle_scene =  preload("res://Scenes/Battle_Batty.tscn")

func _on_Area2D_body_entered(body):
	get_parent().add_child(battle_scene.instance())
	queue_free()
