extends Control

@onready var options_v_box: VBoxContainer = %OptionsVBox

@onready var ip_address_le: LineEdit = %IPAddressLE
@onready var error_label: Label = %ErrorLabel

@onready var result_v_box: VBoxContainer = %ResultVBox
@onready var id_label: Label = %IdLabel
@onready var result_label: Label = %ResultLabel

@onready var simple_loading_screen: SimpleLoadingScreen = $SimpleLoadingScreen
@onready var leave_confirmation_panel: ConfirmationPanel = $LeaveConfirmationPanel

@onready var logs_container: VBoxContainer = %LogsContainer

@onready var interaction_v_box: HBoxContainer = $VBoxContainer/InteractionVBox
@onready var peer_options_button: OptionButton = %PeerOptionsButton

func _ready() -> void:
	DebugUtils.setup_multiplayer_windows()
	
	Lobby.player_connection_failed.connect(_on_join_failed)
	Lobby.player_connected.connect(_on_join_successful)
	Lobby.server_created.connect(_on_host_successful)
	Lobby.server_creation_failed.connect(_on_host_failed)
	Lobby.player_disconnected.connect(_on_disconnected)
	
	
	leave_confirmation_panel.positive_pressed.connect(_on_confirm_leave_button_pressed)
	leave_confirmation_panel.negative_pressed.connect(_on_confirm_stay_button_pressed)
	
	scene_setup(true)


func scene_setup(is_initial_setup: bool = false) -> void:
	var hide_duration = 0.0 if is_initial_setup else 0.2
	leave_confirmation_panel \
		._reset() \
		._set_title("Leave the game?") \
		._set_subtitle("") \
		._hide(hide_duration)
	simple_loading_screen._hide(hide_duration)
	
	error_label.hide()
	result_v_box.hide()
	interaction_v_box.hide()
	
	options_v_box.show()
	
	clear_logs()
	
	ip_address_le.text = Lobby.DEFAULT_SERVER_IP


#region Joining Option
func _on_join_button_pressed() -> void:
	on_option_chosen("Joining")
	Lobby.join_game(ip_address_le.text)


func _on_join_failed() -> void:
	on_option_failed("Failed to join!")


func _on_join_successful(peer_id: int, _player_info) -> void:
	var my_id = multiplayer.get_unique_id()
	
	if peer_id == my_id:
		id_label.text = "ID: " + str(peer_id)
		add_log("You just joined with id %d" % peer_id)
	
	peer_options_button.clear()
	for peer in multiplayer.get_peers():
		if peer != my_id:
			peer_options_button.add_item(str(peer), peer)
	
	if !multiplayer.is_server():
		on_option_successful("You have joined!")
#endregion


#region Hosting Option
func _on_host_button_pressed() -> void:
	on_option_chosen("Hosting")
	Lobby.host_game()


func _on_host_failed() -> void:
	on_option_failed("Failed to host!")


func _on_host_successful() -> void:
	on_option_successful("You are hosting!")
#endregion


#region Generic Option
func on_option_chosen(info: String) -> void:
	simple_loading_screen._set_loading_info(info)
	simple_loading_screen._show(0.2)


func on_option_failed(error: String) -> void:
	#OS.alert(error)
	simple_loading_screen._hide(0.2)
	error_label.show()
	error_label.text = error


func on_option_successful(result: String) -> void:
	#OS.alert(result)
	simple_loading_screen._hide(0.2)
	options_v_box.hide()
	
	interaction_v_box.show()
	result_v_box.show()
	result_label.text = result
#endregion


#region Leaving
func _on_leave_button_pressed() -> void:
	var is_server = self.is_multiplayer_authority()
	var subtitle = ""
	
	if is_server:
		subtitle = "As you are the server, leaving will cause everyone to disconnect."
	
	show_leave_confirmation(subtitle)


func show_leave_confirmation(subtitle: String) -> void:
	leave_confirmation_panel._set_subtitle(subtitle)
	leave_confirmation_panel._show(0.2)


func hide_leave_confirmation() -> void:
	leave_confirmation_panel._hide(0.2)


func _on_confirm_stay_button_pressed() -> void:
	hide_leave_confirmation()


func _on_confirm_leave_button_pressed() -> void:
	if multiplayer.is_server():
		# Notify everyone (except self) that server is closing
		_server_shutdown.rpc()
		
		# Shut down server locally
		_close_server()
	else:
		# actually disconnect
		# this triggers `multiplayer.peer_disconnected` on others
		_close_client()


@rpc("authority", "reliable")
func _server_shutdown():
	add_log("Server is shutting down")
	DebugUtils._print(self, "Server is shutting down...")


func _close_client() -> void:
	multiplayer.multiplayer_peer = null
	scene_setup() # Reset UI


func _close_server() -> void:
	DebugUtils._print(self, "Closing server, disconnecting all players...")
	
	# Disconnect everyone gracefully
	for peer_id in multiplayer.get_peers():
		multiplayer.disconnect_peer(peer_id)
	
	# Finally remove peer
	multiplayer.multiplayer_peer = null
	scene_setup()


func _on_disconnected(peer_id):
	if peer_id == 1:
		add_log("Host just disconnected")
		leave_confirmation_panel \
			._force_positive() \
			._set_title("Host has left the game") \
			._set_subtitle("Host or join a new game.") \
			._show(0.2)
	else:
		add_log("Player %d just disconnected" % peer_id)
		var peer_idx = peer_options_button.get_item_index(peer_id)
		peer_options_button.remove_item(peer_idx)
		if peer_options_button.has_selectable_items():
			peer_options_button.select(0)
#endregion


@rpc("any_peer", "reliable", "call_local")
func add_log(text: String) -> void:
	var new_log = Label.new()
	new_log.text = text
	new_log.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logs_container.add_child(new_log)


func _on_say_hi_button_pressed() -> void:
	var greeted_peer_id = peer_options_button.get_selected_id()
	if greeted_peer_id == -1:
		return
	
	var my_id = multiplayer.multiplayer_peer.get_unique_id()
	add_log.rpc_id(my_id, "You greeted %d" % greeted_peer_id)
	add_log.rpc_id(greeted_peer_id, "You got greeted by %d" % my_id)


func _on_clear_log_button_pressed() -> void:
	clear_logs()


func clear_logs() -> void:
	for l in logs_container.get_children():
		l.queue_free()
