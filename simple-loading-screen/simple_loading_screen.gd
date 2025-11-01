extends UIOverlay
class_name SimpleLoadingScreen

@onready var animation_player: AnimationPlayer = $VBoxContainer/AnimationPlayer


func _ready() -> void:
	super._ready()
	animation_player.play("loading")


func _set_loading_info(info: String) -> void:
	%LoadingInfoLabel.text = "Loading" if info.is_empty() else info
