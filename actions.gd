#class Actions:
extends Node

var subreddit_list_data = RedditGlobals.subreddits  # Store the subreddit data

func _on_open_shell_web_pressed() -> void:
	#OS.shell_open(url)
	#print("url ",url)
	#OS.shell_open("https://rcanzlovar.com/drugfiend/")
	RedditGlobals.uri = "https://reddit.com/r/longmont"
	OS.shell_open(RedditGlobals.uri)
	#var script_a = get_node("res://reddit-reader.gd")
	#OS.shell_open(RedditReader.url)  # Acces shared_value from Script A res://reddit-reader.gd
	#print(script_a)  # Acces shared_value from Script A



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
# Load the reddit-reader.gd script and access its variables

func _on_change_window_icon_pressed() -> void:
	## demonstrate pulling variable from other script
	print(RedditGlobals.uri)  # Access the `uri` variable
	#print(reader_instance.subreddits)  # Access the `url` variable
	print (subreddit_list_data)


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
