extends Control

signal start_client(ip_address)
signal start_server

@onready var start_game_button: Button = $%StartGameButton
@onready var options_menu: Control = $%OptionsMenu
@onready var content: Control = $%Content 
@onready var ip_address: LineEdit =  $Content/IPAddressLineEdit

func _ready():
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
	emit_signal("start_client", ip_address.text)
	self.visible = false

func _on_server_button_pressed():
	emit_signal("start_server")
	self.visible = false
