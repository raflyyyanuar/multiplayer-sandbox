extends Node


func setup_multiplayer_windows() -> void:
	if not OS.is_debug_build(): return
	
	var window_size = DisplayServer.screen_get_size()
	var screen_size = window_size / Vector2i(4, 2)
	var args = OS.get_cmdline_args()
	
	var order = 0
	if args.has("order"):
		var idx = args.find("order")
		order = int(args[idx + 1])
	
	# Determine client position
	# order: 1 2 3 4
	@warning_ignore("integer_division")
	var row = 0
	var col = (order - 1) % 4
	
	var x_offset = col * screen_size.x
	var y_offset = row * screen_size.y
	
	get_window().position = Vector2i(x_offset, y_offset)
	get_window().size = screen_size


func _print(caller: Node, ...args: Array) -> void:
	print(caller.multiplayer.multiplayer_peer.get_unique_id(), ": ", " ".join(args))
