# subreddit_dialog.gd - handle things for the subreddits list like add and delete 
# 22-oct-2024 rca
extends AcceptDialog


# Where are we storing the subreddits?
@onready var subreddit_list_data = RedditGlobals.subreddits  # Store the subreddit data
# Paths to the subreddit editing popup. Don't know why but i've only been able to get it to work using the absolute path 
@onready var subreddit_edit = get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/subredditEdit")
@onready var subreddit_list = get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/subredditList")
@onready var add_button = (get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Add"))
@onready var delete_button = (get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Delete"))
#@onready var refresh_button = (get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Refresh"))

func _ready() -> void:
	#print("subreddit_list: ", subreddit_list)
	#print("add_button: ", add_button)
	#print("addbutton: ", $"HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Delete")
	#print ("one",get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Delete"))
	#print ("two",get_node("/root/Reddit-reader/"))
	#print ("three",get_node("VBoxContainer/HBoxContainer/Delete"))
	#print ("four",get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Delete"))
	if add_button and delete_button:
		add_button.connect("pressed", Callable(self, "_on_add_pressed"))
		delete_button.connect("pressed", Callable(self, "_on_delete_pressed"))
		#refresh_button.connect("pressed", Callable(self, "_on_refresh_pressed"))
	else:
		print("One or both buttons not found!")
	populate_subreddit_list()

func populate_subreddit_list():
	subreddit_list.clear()
	#for subreddit in subreddit_list_data:
	for subreddit in  RedditGlobals.subreddits:
		print ("sub:", subreddit)
		subreddit_list.add_item(subreddit)
func _on_refresh_pressed():
	print("Refresh pressed")
	subreddit_edit.clear()  # Clear the input field
	populate_subreddit_list()  # Refresh the list

# Add a new subreddit when the "Add" button is pressed
func _on_add_pressed():
	print("Add pressed")
	var new_subreddit = subreddit_edit.text.strip_edges()
	if new_subreddit != "":
		var formatted_subreddit = "https://www.reddit.com/r/%s.json" % new_subreddit
		print ("before append ", RedditGlobals.subreddits)
		RedditGlobals.subreddits.append(formatted_subreddit)
		print ("after append ", RedditGlobals.subreddits)
		#reader_instance.subreddits = subreddit_list_data 
		subreddit_edit.clear()  # Clear the input field
		populate_subreddit_list()  # Refresh the list
		#reader_instance:save_data()
	else:
		print("No value entered to add.")

# Delete the selected subreddit when the "Delete" button is pressed
func _on_delete_pressed():
	print("Delete pressed")
	var selected = subreddit_list.get_selected_items()
	if selected.size() > 0:
		var index = selected[0]  # Get the first selected index
		subreddit_list_data.remove_at(index)
		subreddit_edit.clear()  # Clear the input field
		populate_subreddit_list()  # Refresh the list
	else:
		print("No item selected to delete.")
