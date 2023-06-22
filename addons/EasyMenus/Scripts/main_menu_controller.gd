extends Control

signal start_client(ip_address)
signal start_server
signal start_offline

@onready var start_game_button: Button = $%StartGameButton
@onready var options_menu: Control = $%OptionsMenu
@onready var content: Control = $%Content 
@onready var config = ConfigFile.new()

func _ready():
	var err = config.load(OptionsConstants.config_file_name)
	start_game_button.grab_focus()

func quit():
	get_tree().quit()

func open_options():
	options_menu.show()
	content.hide()
	options_menu.on_open()

func close_options():
	content.show();
	start_game_button.grab_focus()
	options_menu.hide()

func _on_start_game_button_pressed():
	var ip_address = config.get_value(OptionsConstants.section_name, OptionsConstants.ip_address, "")
	emit_signal("start_client", ip_address)
	$MainMenuAudioStreamPlayer.stop()
	$InGameMusicAudioStreamPlayer.play()
	self.visible = false

func _on_server_button_pressed():
	emit_signal("start_server")
	self.visible = false

func _on_start_offline_button_pressed():
	emit_signal("start_offline")
	$MainMenuAudioStreamPlayer.stop()
	$InGameMusicAudioStreamPlayer.play()
	self.visible = false
