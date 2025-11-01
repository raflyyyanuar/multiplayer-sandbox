extends CanvasItem
class_name UIOverlay

@onready var screen_block: ColorRect = null


func _ready() -> void:
	screen_block = get_node_or_null("ScreenBlock")
	show()
	_hide()


func _show(duration: float = 0.0) -> void:
	VisualUtils.turn_opaque(screen_block, duration)
	VisualUtils.turn_opaque(self, duration)
	self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED


func _hide(duration: float = 0.0) -> void:
	VisualUtils.turn_transparent(screen_block, duration)
	VisualUtils.turn_transparent(self, duration)
	self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
