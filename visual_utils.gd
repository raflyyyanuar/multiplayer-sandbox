extends Node


func set_transparency(node: CanvasItem, alpha: float, duration: float) -> void:
	if !node or node is not CanvasItem: return
	
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate:a", alpha, duration)
	tween.play()


func turn_transparent(node: CanvasItem, duration: float = 0.0) -> void:
	set_transparency(node, 0.0, duration)


func turn_opaque(node: CanvasItem, duration: float = 0.0) -> void:
	set_transparency(node, 1.0, duration)
