#class Actions:
extends Node

func _on_open_shell_web_pressed() -> void:
	#OS.shell_open(url)
	#print("url ",url)
	OS.shell_open("https://rcanzlovar.com/drugfiend/")
	var script_a = get_node("res://actions.gd")
	#OS.shell_open(script_a.url)  # Acces shared_value from Script A
	print(script_a)  # Acces shared_value from Script A
	


func _on_open_shell_folder_pressed() -> void:
	var path := OS.get_environment("HOME")
	if path == "":
		# Windows-specific.
		path = OS.get_environment("USERPROFILE")

	if OS.get_name() == "macOS":
		# MacOS-specific.
		path = "file://" + path

	OS.shell_open(path)


func _on_change_window_title_pressed() -> void:
	DisplayServer.window_set_title("Modified window title. Unicode characters for testing: é € × Ù ¨")


func _on_change_window_icon_pressed() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_ICON):
		OS.alert("Changing the window icon is not supported by the current display server (%s)." % DisplayServer.get_name())
		return

	var image := Image.create(128, 128, false, Image.FORMAT_RGB8)
	image.fill(Color(1, 0.6, 0.3))
	DisplayServer.set_icon(image)


func _on_move_window_to_foreground_pressed() -> void:
	DisplayServer.window_set_title("Will move window to foreground in 5 seconds, try unfocusing the window...")
	await get_tree().create_timer(5).timeout
	DisplayServer.window_move_to_foreground()
	# Restore the previous window title.
	DisplayServer.window_set_title(ProjectSettings.get_setting("application/config/name"))


func _on_request_attention_pressed() -> void:
	DisplayServer.window_set_title("Will request attention in 5 seconds, try unfocusing the window...")
	await get_tree().create_timer(5).timeout
	DisplayServer.window_request_attention()
	# Restore the previous window title.
	DisplayServer.window_set_title(ProjectSettings.get_setting("application/config/name"))


func _on_get_clipboard_pressed() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		OS.alert("Clipboard I/O is not supported by the current display server (%s)." % DisplayServer.get_name())
		return

	OS.alert("Clipboard contents:\n\n%s" % DisplayServer.clipboard_get())


func _on_set_clipboard_pressed() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		OS.alert("Clipboard I/O is not supported by the current display server (%s)." % DisplayServer.get_name())
		return

	DisplayServer.clipboard_set("Modified clipboard contents. Unicode characters for testing: é € × Ù ¨")


func _on_display_alert_pressed() -> void:
	OS.alert("Hello from Godot! Close this dialog to resume the main window.")


func _on_kill_current_process_pressed() -> void:
	OS.kill(OS.get_process_id())
