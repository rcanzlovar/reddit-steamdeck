extends Node
class_name RedditReader

@onready var rtl: RichTextLabel = $HBoxContainer/Features
@onready var csharp_test: Node = $CSharpTest

# abstract the http here 
@onready var http_request = $HBoxContainer/HTTPRequest
@onready var timeout_timer = $HBoxContainer/timeout_timer
# status is going to tell me if i am using offline content 
var status = "-"

# global place to stash a place 
@export var uri = "https://www.reddit.com/r/gamedev.json"
@export var subreddits: Array = [
	"https://www.reddit.com/r/gonewildstories.json",
	"https://www.reddit.com/r/gamedev.json",
	"https://www.reddit.com/r/boomersbeingfools.json",
	"https://www.reddit.com/r/anythinggoesnews.json",
	"https://www.reddit.com/r/flipperzero.json",
	"https://www.reddit.com/r/hitchhiking.json",
	"https://www.reddit.com/r/leaves.json",
	"https://www.reddit.com/r/petioles.json",
	"https://www.reddit.com/r/nlp.json",
	"https://www.reddit.com/r/outoftheloop.json",
	"https://www.reddit.com/r/longmont.json"
]




@onready var i : int = 0 
# track what paragraph we are in the scrollable window

@onready var j : int = 0 
# track what line we are in the scrollable window

@onready var k : int = 0 
# track which subreddit index we are using 
@onready var DEBUG : int = 0

# this is the array that has line offsets for the 
# article headers for easier skipping around
@onready var paragraphs : Array = [ 0 ]

## subreddit list stuff below
@onready var subreddit_list = $HBoxContainer/subredditDialog/VBoxContainer/subredditList
@onready var subreddit_edit = $HBoxContainer/subredditDialog/VBoxContainer/subredditEdit
@onready var subreddit_add = $HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Add
@onready var subreddit_delete = $HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Delete
@onready var subreddit_dialog = $HBoxContainer/subredditDialog

#This is for caching subreddit content so i don't have 
# to call the server just to move from one sub to 
# another. Also will allow for caching stuff to read 
# offline eventually. 
@onready var subreddit_cache = {}


# Populate the ItemList with the current subreddits
func populate_subreddit_list():
	subreddit_list.clear()
	for subreddit in subreddits:
		subreddit_list.add_item(subreddit)

# Add a new subreddit when the "Add" button is pressed
func _on_add_pressed():
	print("Add pressed")
	var new_subreddit = subreddit_edit.text.strip_edges()
	if new_subreddit != "":
		var formatted_subreddit = "https://www.reddit.com/r/%s.json" % new_subreddit
		subreddits.append(formatted_subreddit)
		subreddit_edit.clear()  # Clear the input field
		populate_subreddit_list()  # Refresh the list
	else:
		print("No value entered to add.")

# Delete the selected subreddit when the "Delete" button is pressed
func _on_delete_pressed():
	print("delete pressed")
	var selected = subreddit_list.get_selected_items()
	if selected.size() > 0:
		var index = selected[0]  # Get the first selected index
		subreddits.remove_at(index)
		populate_subreddit_list()  # Refresh the list
	else:
		print("No item selected to delete.")
##########################################################
# Routines Related to writing to the scrollable RichTextLabel
# RTL Related routines 
# clear the rtl RichTextLabel
func clear_display() -> void:
	rtl.clear()

func add_title(header: String) -> void:
	rtl.append_text("\n[font_size=24][color=#6df]{header}[/color][/font_size]\n".format({
		header = header,
	}))

func add_date(header: Variant) -> void:
	rtl.append_text("[font_size=16][color=#2df]{header}[/color][/font_size]\n".format({
		header = header,
	}))

func add_body(header: String) -> void:
	rtl.append_text("\n[font_size=20][color=#fff8
	]{header}[/color][/font_size]\n\n".format({
		header = header,
	}))

func add_header(header: String) -> void:
	rtl.append_text("\n[font_size=32][color=#FF4500]r/{header}[/color][/font_size]\n\n".format({
		header = header,
	}))

func add_line(key: String, value: Variant) -> void:
	if typeof(value) == TYPE_BOOL:
		# Colorize boolean values.
		value = "[color=8f8]true[/color]" if value else "[color=#f88]false[/color]"
	rtl.append_text("[color=#adf]{key}:[/color] {value}\n".format({
		key = key,
		value = value if str(value) != "" else "[color=#fff8](empty)[/color]",
	}))
##########################################################

func sysstat() -> void:
	# Grab focus so that the list can be scrolled (for keyboard/controller-friendly navigation).
	rtl.grab_focus()
	rtl.clear()

	add_title("Audio")
	add_line("Mix rate", "%d Hz" % AudioServer.get_mix_rate())
	add_line("Output latency", "%f ms" % (AudioServer.get_output_latency() * 1000))
	add_line("Output device list", ", ".join(AudioServer.get_output_device_list()))
	add_line("Capture device list", ", ".join(AudioServer.get_input_device_list()))

	add_title("Date")
	add_line("Date and time (local)", Time.get_datetime_string_from_system(false, true))
	add_line("Date and time (UTC)", Time.get_datetime_string_from_system(true, true))
	add_line("Date (local)", Time.get_date_string_from_system(false))
	add_line("Date (UTC)", Time.get_date_string_from_system(true))
	add_line("Time (local)", Time.get_time_string_from_system(false))
	add_line("Time (UTC)", Time.get_time_string_from_system(true))
	add_line("Timezone", Time.get_time_zone_from_system())
	add_line("UNIX time", Time.get_unix_time_from_system())

	add_title("Display")
	add_line("Screen count", DisplayServer.get_screen_count())
	add_line("DPI", DisplayServer.screen_get_dpi())
	add_line("Scale factor", DisplayServer.screen_get_scale())
	add_line("Maximum scale factor", DisplayServer.screen_get_max_scale())
	add_line("Startup screen position", DisplayServer.screen_get_position())
	add_line("Startup screen size", DisplayServer.screen_get_size())
	add_line("Startup screen refresh rate", ("%f Hz" % DisplayServer.screen_get_refresh_rate()) if DisplayServer.screen_get_refresh_rate() > 0.0 else "")
	add_line("Usable (safe) area rectangle", DisplayServer.get_display_safe_area())
	add_line("Screen orientation", [
		"Landscape",
		"Portrait",
		"Landscape (reverse)",
		"Portrait (reverse)",
		"Landscape (defined by sensor)",
		"Portrait (defined by sensor)",
		"Defined by sensor",
	][DisplayServer.screen_get_orientation()])

	add_title("Engine")
	add_line("Version", Engine.get_version_info()["string"])
	add_line("Command-line arguments", str(OS.get_cmdline_args()))
	add_line("Is debug build", OS.is_debug_build())
	add_line("Executable path", OS.get_executable_path())
	add_line("User data directory", OS.get_user_data_dir())
	add_line("Filesystem is persistent", OS.is_userfs_persistent())

	add_title("Environment")
	add_line("Value of `PATH`", OS.get_environment("PATH"))
	add_line("Value of `path`", OS.get_environment("path"))

	add_title("Hardware")
	add_line("Model name", OS.get_model_name())
	add_line("Processor name", OS.get_processor_name())
	add_line("Processor count", OS.get_processor_count())
	add_line("Device unique ID", OS.get_unique_id())

	add_title("Input")
	add_line("Device has touch screen", DisplayServer.is_touchscreen_available())
	var has_virtual_keyboard := DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)
	add_line("Device has virtual keyboard", has_virtual_keyboard)
	if has_virtual_keyboard:
		add_line("Virtual keyboard height", DisplayServer.virtual_keyboard_get_height())

	add_title("Localization")
	add_line("Locale", OS.get_locale())

	add_title("Mobile")
	add_line("Granted permissions", OS.get_granted_permissions())

	add_title(".NET (C#)")
	var csharp_enabled := ResourceLoader.exists("res://CSharpTest.cs")
	add_line("Mono module enabled", "Yes" if csharp_enabled else "No")
	if csharp_enabled:
		csharp_test.set_script(load("res://CSharpTest.cs"))
		add_line("Operating System", csharp_test.OperatingSystem())
		add_line("Platform Type", csharp_test.PlatformType())

	add_title("Software")
	add_line("OS name", OS.get_name())
	add_line("Process ID", OS.get_process_id())
	add_line("System dark mode supported", DisplayServer.is_dark_mode_supported())
	add_line("System dark mode enabled", DisplayServer.is_dark_mode())
	add_line("System accent color", "#%s" % DisplayServer.get_accent_color().to_html())

	add_title("System directories")
	add_line("Desktop", OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP))
	add_line("DCIM", OS.get_system_dir(OS.SYSTEM_DIR_DCIM))
	add_line("Documents", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	add_line("Downloads", OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS))
	add_line("Movies", OS.get_system_dir(OS.SYSTEM_DIR_MOVIES))
	add_line("Music", OS.get_system_dir(OS.SYSTEM_DIR_MUSIC))
	add_line("Pictures", OS.get_system_dir(OS.SYSTEM_DIR_PICTURES))
	add_line("Ringtones", OS.get_system_dir(OS.SYSTEM_DIR_RINGTONES))

	add_title("Video")
	add_line("Adapter name", RenderingServer.get_video_adapter_name())
	add_line("Adapter vendor", RenderingServer.get_video_adapter_vendor())
	add_line("Adapter type", [
		"Other (Unknown)",
		"Integrated",
		"Discrete",
		"Virtual",
		"CPU",
	][RenderingServer.get_video_adapter_type()])
	add_line("Adapter graphics API version", RenderingServer.get_video_adapter_api_version())

	var video_adapter_driver_info := OS.get_video_adapter_driver_info()
	if video_adapter_driver_info.size() > 0:
		add_line("Adapter driver name", video_adapter_driver_info[0])
	if video_adapter_driver_info.size() > 1:
		add_line("Adapter driver version", video_adapter_driver_info[1])


func _ready() -> void:
	# Grab focus so that the list can be scrolled (for keyboard/controller-friendly navigation).
	rtl.grab_focus()
	# wipe out the stuff in the display
	clear_display()
	populate_subreddit_list()
	
	#get_reddit(url)
	sysstat()
	
##########################################################
# Time display (should be in a subroutine file) 
func epoch_to_datetime(epoch: int) -> Dictionary:
	var dt = Time.get_datetime_dict_from_unix_time(epoch) 
	return {
		"year": dt.year,
		"month": dt.month,
		"day": dt.day,
		"hour": dt.hour,
		"minute": dt.minute,
		"second": dt.second
	}

# Returns a human-readable string from a date and time, date, or time dictionary.
func datetime_to_string(date: Dictionary):
	if (
		date.has("year")
		and date.has("month")
		and date.has("day")
		and date.has("hour")
		and date.has("minute")
		and date.has("second")
	):
		# Date and time.
		return "{year}-{month}-{day} {hour}:{minute}:{second}".format({
			year = str(date.year).pad_zeros(2),
			month = str(date.month).pad_zeros(2),
			day = str(date.day).pad_zeros(2),
			hour = str(date.hour).pad_zeros(2),
			minute = str(date.minute).pad_zeros(2),
			second = str(date.second).pad_zeros(2),
		})
	elif date.has("year") and date.has("month") and date.has("day"):
		# Date only.
		return "{year}-{month}-{day}".format({
			year = str(date.year).pad_zeros(2),
			month = str(date.month).pad_zeros(2),
			day = str(date.day).pad_zeros(2),
		})
	else:
		# Time only.
		return "{hour}:{minute}:{second}".format({
			hour = str(date.hour).pad_zeros(2),
			minute = str(date.minute).pad_zeros(2),
			second = str(date.second).pad_zeros(2),
		})
	
##########################################################
# SubReddit Related routines 
# go to the next subreddit in the list, wrap around
	
func next_subreddit() -> void:
	print ("next-sub subsize = ",subreddits.size(),"k=",k)
	if k > subreddits.size() - 2:
		k = 0
	else:
		k += 1
	uri = subreddits[k]
	#OS.alert("subreddits:",subreddits[2])
	clear_display()
	# clear the paragraphs index, make line 0 be the first paragraph
	# to include the header 
	paragraphs = [ 0 ]
	print ("==next)subreddit uri is ",uri)
	get_reddit(uri)
	
# go to the previous subreddit in the list, wrap around
func prev_subreddit() -> void:
	print ("prev-sub subsize = ",subreddits.size(),"k=",k)
	if k > 0:
		k =  subreddits.size() - 2
	else:
		k -= 1
	uri = subreddits[k]
	# wipe out the stuff in the display
	clear_display()
	paragraphs = [ 0 ]
	get_reddit(uri)

##########################################################
# navigating around inside the posts of a subreddit
var newpara = 0
	
func scroll_next():
	#var newpara = 0
	# Increase the scroll position by 1 line
	# problem was that if you went down by article, then went down by 
	print ("paragraphs[i]=",paragraphs[i]," j=",j)
	if j > paragraphs[i]:
		print ("boo!")
		newpara = 0
		while paragraphs[newpara] < j:
			newpara += 1
		i = newpara -1
	print ("newpara=",newpara," paragraphs[newpara]",paragraphs[newpara]," i=",i," j=",j)
	if i < paragraphs.size()-1:
		i += 1
	else: 
		i = 0
	rtl.scroll_to_line(paragraphs[i])
	j = paragraphs[i]

func scroll_back():
	# Increase the scroll position by 1 line
	if i < paragraphs.size():
		i -= 1
	else: 
		i = paragraphs.size()
	rtl.scroll_to_line(paragraphs[i])
	j = paragraphs[i]
	

func scroll_down():
	#print ("scroll begin of scrolldown",rtl.scroll_vertical)
	# Increase the scroll position by 1/2 screem at a time
	var jump = rtl.get_visible_line_count()/2
	if i < (paragraphs.size() - jump):
		j += jump
	rtl.scroll_to_line(j)
	# Ensure it doesn't scroll beyond the top
#	rtl.scroll_vertical = min(rtl.scroll_vertical, 0)

func scroll_up():
	#print ("scroll begin of scrolldown",rtl.scroll_vertical)
	# Decrease the scroll position by 1/2 screem at a time
	var jump = rtl.get_visible_line_count()/2
	if j > jump:
		j -= jump
	else: 
		print("jump=",jump," i=",i)
	rtl.scroll_to_line(j)

##################################################################
# link the actions to functions
# Handle input for scrolling
# this is where the actions that are defined in Project -> Project Settings -> Input Map
# get tied to the functions here. 
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("down"):
		scroll_down()
	elif event.is_action_pressed("up"):
		scroll_up()
	elif event.is_action_pressed("next"):
		scroll_next()
	elif event.is_action_pressed("previous"):
		scroll_back()
	elif event.is_action_pressed("subnext"):
		next_subreddit()
	elif event.is_action_pressed("subprev"):
		prev_subreddit()
	elif event.is_action_pressed("toggle_controls"):
		toggle_action()
	elif event.is_action_pressed("toggle_subreddits"):
		toggle_subreddits()
	elif event.is_action_pressed("sysstat"):
		sysstat()
	#elif event.is_action_pressed(subreddit_delete):
		#_on_delete_pressed()
	#elif event.is_action_pressed(subreddit_add):
		#_on_add_pressed()
##################################################################

func toggle_action():
	print ("toggle action", j)
	$HBoxContainer/Actions.visible = !$HBoxContainer/Actions.visible
	print($HBoxContainer/Actions.visible)
func toggle_subreddits():
	print ("toggle subreddits", j)
	populate_subreddit_list()
	subreddit_dialog.visible = !subreddit_dialog.visible
	#/root/Reddit-reader/HBoxContainer/subredditDialog/VBoxContainer/HBoxContainer/Add
	
	# Clear existing items and add "foo" to the list
	#var subreddit_list = $HBoxContainer/subredditDialog/VBoxContainer/subredditList
	#subreddit_list.clear()  # Optional: Clear the list if you want to reset it
	#for sub in  subreddits: 
		#print ("sub=",sub)
		#subreddit_list.add_item(sub)
###################################################################

func get_reddit(localurl : String):
	# hack stash in the gloab
	uri = localurl
	#if (DEBUG):
		#get_reddit_offline(url)
		#return
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	# Start the timer for 30 seconds
	timeout_timer.start(30.0)
	
	
	var error = http_request.request(localurl)
	# if we can't connect to the internet, maybe we have some interesting cached stuff
	if error != OK:
		get_reddit_offline(localurl)

func get_reddit_offline(uri):
	#OS.alert("Load cache ",url)
	print("**** Load cache ",uri," ****")
	status = "+cache" 
	load_data()
	var data = subreddit_cache["cache"][uri]["data"]
	process_reddit_data(data)
	
# Handle the timeout case
func _on_timeout():
	http_request.disconnect("request_completed", Callable(self, "_on_request_completed"))
	print("Request timed out.")
	# get the url that is in the global
	get_reddit_offline(uri)
	
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		var json = JSON.new()  # Create a new instance of JSON
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var data = json.get_data()  # Use get_data() to retrieve the parsed JSON object
			# make sure the parents are there 
			if not subreddit_cache.has("cache"):
				subreddit_cache["cache"] = {}  # Initialize it as an empty dictionary
			if not subreddit_cache["cache"].has(uri):
				subreddit_cache["cache"][uri] = {}
			# stash the returned data into the cache...
			subreddit_cache["cache"][uri]["data"] = data
			# and save a copy for the next time we need it offline
			save_data()
			# reset it to online
			status = "-"
			process_reddit_data(data)
		else:
			print("Failed to parse JSON")
	else:
		print("HTTP request failed with code: %d" % response_code)
		
		
# as long as we save each time we get a subreddit, we can always read offline
# whatever the latest was that we had. 
func save_data():
	#var file = FileAccess.open("user://redditcache.json", FileAccess.WRITE)
	var file = FileAccess.open("user://redditcache.json", FileAccess.WRITE)
	var saved_data = {}
	saved_data["cache"] = subreddit_cache
	saved_data["subreddits"] = subreddits
	
	var json = JSON.stringify(saved_data)
	file.store_string(json)
	file.close()
# if we can't get something from the internet, then we just load whatever the
# last thing was from the cache
func load_data():
	#var file = FileAccess.open("user://redditcache.json", FileAccess.WRITE)
	var file = FileAccess.open("user://redditcache.json", FileAccess.READ)
	
	var json = file.get_as_text()
	var saved_data = JSON.parse_string(json)
	#print (saved_data)
	
	subreddit_cache = saved_data["cache"]
	#print(JSON.stringify(subreddit_cache, "\t"))

	subreddits =  saved_data["subreddits"]
	
	file.close()
	
func process_reddit_data(data):
	var flag = 0
	i = 0
	j = 0
	# Show the name of the subreddit we're looking at 
	var subreddit : String = uri.get_file().get_basename()
	DisplayServer.window_set_title(subreddit)


	$HBoxContainer/Actions/Label.text = subreddit + status
	# make a header of it 
	add_header(subreddit)
	for post in data["data"]["children"]:
		if flag == 0:
			for element in post["data"]:
				#print ("element: ", element)
				pass
			flag = 1
		var post_title = post["data"]["title"]
		var post_body = post["data"]["selftext"]
		var post_created = post["data"]["created"]
		var date_dict = epoch_to_datetime(post_created)
		var date_string = datetime_to_string(date_dict)  # Output: "2024-10-04 00:00:00"

		var post_url = post["data"]["url"]
#		var post_date = post["data"]["date"]

		if rtl is RichTextLabel:
			# stash the line count before we add the post
			var scrollbar = rtl.get_line_count()
			paragraphs.append(scrollbar)
			#print (scrollbar)
			if scrollbar:
				#scrollbar.value += 1
				pass
			
			else:
				print("Scrollbar not found on RichTextLabel")
		else:
			print("RTL is not a RichTextLabel")
		
		add_title(post_title)
		add_date(date_string)
		add_body(post_body)
		add_date(post_url)
		# see if i can detect a post that is just a picture
		#print ("check post for image")
		var regex = RegEx.new()
		regex.compile("(http.?//+?[png|gif|jpg|jpeg|art])")
		var result1 = regex.search(post_body)
		if result1:
			print("picture ",result1.strings[1]) # Would print n-0123
			print ("******************************************")
		#regex.compile("\\[(http.+)\\]")
		regex.compile("\\[(http.+)\\]")
		var result = regex.search(post_body)
		if result:
			print("first ",result.strings[1]) # Would print n-0123
			print("found ",result.get_string()) # Would print n-0123
	
	subreddit_cache["cache"][uri]["paragraphs"] = paragraphs
