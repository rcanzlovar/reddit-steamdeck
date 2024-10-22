extends AcceptDialog

@onready var RedditReader = load("res://reddit-reader.gd")
@onready var reader_instance = RedditReader.new()  # Creates a new instance of the class
@onready var subreddit_list_data = reader_instance.subreddits  # Store the subreddit data

@onready var subreddit_edit = get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/subredditEdit")
@onready var subreddit_list = get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/subredditList")
@onready var add_button = (get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Add"))
@onready var delete_button = (get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Delete"))
#@onready var delete_button = get_node("HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Delete")

func _ready() -> void:
	#print("subreddit_list: ", subreddit_list)
	#print("add_button: ", add_button)
	#print("addbutton: ", $"HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Delete")
	#print ("one",get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Delete"))
	#print ("two",get_node("/root/Reddit-reader/"))
	#print ("three",get_node("VBoxContainer/HBoxContainer/Delete"))
	#print ("four",get_node("/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Delete"))
	#if add_button and delete_button:
	if delete_button:
		add_button.connect("pressed", Callable(self, "_on_add_pressed"))
		delete_button.connect("pressed", Callable(self, "_on_delete_pressed"))
	else:
		print("One or both buttons not found!")
	populate_subreddit_list()

	#populate_subreddit_list()
	
# Called when the node enters the scene tree for the first time.

func populate_subreddit_list():
	subreddit_list.clear()
	#for subreddit in subreddit_list_data:
	for subreddit in reader_instance.subreddits:
		subreddit_list.add_item(subreddit)

# Add a new subreddit when the "Add" button is pressed
func _on_add_pressed():
	print("Add pressed")
	var new_subreddit = subreddit_edit.text.strip_edges()
	if new_subreddit != "":
		var formatted_subreddit = "https://www.reddit.com/r/%s.json" % new_subreddit
		subreddit_list_data.append(formatted_subreddit)
		print (subreddit_list_data)
		print (reader_instance.subreddits)
		reader_instance.subreddits.append(formatted_subreddit)
		#reader_instance.subreddits = subreddit_list_data 
		reader_instance.save_data()
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
		reader_instance.save_data()
		reader_instance.subreddits = subreddit_list_data 
		subreddit_edit.clear()  # Clear the input field
		populate_subreddit_list()  # Refresh the list
	else:
		print("No item selected to delete.")
