# questui.gd

extends CanvasLayer

@onready var panel = $Panel
@onready var quest_list = $Panel/VBoxContainer
var active_quests := {}  # { quest_id: Label }

func _ready():
	# Connect to global signals from the autoloaded QuestManager singleton
	QuestManager.quest_started.connect(_on_quest_started)
	QuestManager.quest_completed.connect(_on_quest_completed)

func _on_quest_started(quest_id: String) -> void:
	# Create a container for the quest
	var container = VBoxContainer.new()

	# Title label with a larger font
	var title_label = Label.new()
	title_label.text = QuestManager.get_quest_info(quest_id).get("title", quest_id)
	
	# Create a new theme or load an existing one
	var title_theme = preload("res://Fonts/questtitle.tres")  # Path to your theme resource
	
	# Assign the custom theme to the label
	title_label.theme = title_theme
	
	# Add the title label to the container
	container.add_child(title_label)
	
	# Add the description label
	var description_label = Label.new()
	description_label.text = QuestManager.get_quest_info(quest_id).get("description", "No description available.")
	
	# Create a new theme or load an existing one
	var description_theme = preload("res://Fonts/questdescription.tres")  # Path to your theme resource
	
	# Assign the custom theme to the label
	description_label.theme = description_theme
	
	# Add description label to the container
	container.add_child(description_label)
	
	# Check if there's another title after this description, and if so, add an empty label for spacing
	if QuestManager.has_next_quest(quest_id):  # Calls the newly added has_next_quest function
		# Add an empty label to create spacing if there's another title next
		var empty_label = Label.new()
		empty_label.text = ""  # Empty text for spacing
		container.add_child(empty_label)

	# Add container to the quest list
	quest_list.add_child(container)
	
	# Store the container in active_quests
	active_quests[quest_id] = container


func _on_quest_completed(quest_id: String) -> void:
	if active_quests.has(quest_id):
		var container = active_quests[quest_id]
		container.queue_free()  # Remove the container from the scene
		active_quests.erase(quest_id)  # Remove reference from the dictionary
