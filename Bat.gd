extends KinematicBody2D

const battle_scene =  preload("res://Scenes/Battle_Batty.tscn")

func _on_Hitbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	get_parent().add_child(battle_scene.instance())
	queue_free()
