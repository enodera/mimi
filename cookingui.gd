extends CanvasLayer

# --- UI Node References ---
@onready var item_list = $Panel/ScrollContainer/VBoxContainer  # The container that holds item buttons
@onready var close_button = $Panel/CloseButton  # Close button to hide inventory UI

# --- Inventory State ---
var justupdated = true  # Flag to track whether the hover text was updated
var inventory: Inventory  # Reference to the inventory data object
var projscale = ProjectSettings.get_setting("display/window/stretch/scale")

# --- For the model preview! ---
@onready var model_preview_container = $Panel/Panel/SubViewportContainer
@onready var model_viewport = model_preview_container.get_viewport()
@onready var modelpreview = $Panel/Panel/SubViewportContainer/SubViewport/ModelPreview3D

var current_preview_instance: Node3D = null

# --- Initialization ---
func _ready():
	inventory = Global.inventory_ref
	
	if projscale != 1:
		$Panel.set_pivot_offset($Panel.size * (1 / projscale))
	$Panel.scale = Vector2(0, 0)
	
	inventory.add_recipe("muffin")
	show_item("none")

	update_ui()
	close_button.pressed.connect(self._on_close_button_pressed)


# --- UI Update ---
func update_ui():
	for child in item_list.get_children():
		child.queue_free()

	for recipe in inventory.get_recipes():
		var recipe_data = ItemDatabase.recipes[recipe["id"]]
		var display_text = recipe_data["name"]
		var item_description = recipe_data["description"]

		var container = MarginContainer.new()
		container.add_theme_constant_override("margin_left", 30 * 1 / projscale)
		container.add_theme_constant_override("margin_right", 40 * 1 / projscale)
		container.add_theme_constant_override("margin_top", 2 * 1 / projscale)
		container.add_theme_constant_override("margin_bottom", 2 * 1 / projscale)

		var node = Button.new()
		node.text = display_text
		node.custom_minimum_size = Vector2(300 * 1 / projscale, 20 * 1 / projscale)
		node.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		if has_all_ingredients(recipe_data["ingredients"]):
			node.pressed.connect(_on_item_pressed.bind(recipe))
		else:
			node.disabled = true
			node.focus_mode = Control.FOCUS_NONE

		container.add_child(node)
		item_list.add_child(container)

		# Fix: pass both item_id and description
		node.mouse_entered.connect(_on_item_hovered.bind(recipe["id"], item_description))
		node.mouse_exited.connect(_on_item_hover_exited)
		node.focus_mode = Control.FOCUS_NONE


# --- Show Inventory ---
func show_inventory():
	update_ui()
	visible = true
	Global.cookingpaused = true
	$Panel.scale = Vector2(0, 0)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Engine.time_scale = 0.0001
	await get_tree().process_frame

	var tween := create_tween()
	tween.tween_property($Panel, "scale", Vector2(1, 1), 0.00002).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.00002).timeout

# --- Hover Effect ---
func _on_item_hovered(item_id: String, item_description: String):
	# Get the recipe data for this item (if exists)
	var recipe_data = ItemDatabase.recipes.get(item_id, null)
	var ingredients_text = ""
	if recipe_data and recipe_data.has("ingredients"):
		var ingredient_names := []
		for ingr_id in recipe_data["ingredients"]:
			var ingr_name = ItemDatabase.items.get(ingr_id, {}).get("name", "")
			if ingr_name != "":
				ingredient_names.append(ingr_name.to_lower())
		ingredients_text = ", ".join(ingredient_names)
	
	%ItemDescription.text = "%s\nNeeds: %s" % [item_description, ingredients_text]
	
	show_item(item_id)
	print(item_id)
	show_model_preview(item_id)
	print("Hi!")
	modelpreview.visible = true

func _on_item_hover_exited():
	if not justupdated:
		%ItemDescription.text = ""
		show_item("none")
		print("Bye!")
		modelpreview.visible = false
	
	justupdated = false

# --- Close Inventory ---
func _on_close_button_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Panel.scale = Vector2(1, 1)
	var tween := create_tween()
	tween.tween_property($Panel, "scale", Vector2(0, 0), 0.00002).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.00002).timeout

	visible = false
	Engine.time_scale = 1
	Global.cookingpaused = false
	print("bye")

# --- Item Interaction ---
func _on_item_pressed(item):
	print("Crafted item: ", item["id"])
	inventory.add_item(item["id"])
	for ingredient_id in ItemDatabase.recipes[item["id"]]["ingredients"]:
		inventory.remove_item(ingredient_id, 1)  # remove 1 unit per ingredient; adjust if needed
	%ItemDescription.text = ""
	show_item("none")
	justupdated = true
	update_ui()

# --- Model Preview ---
func show_model_preview(item_id: String):
	if current_preview_instance:
		current_preview_instance.queue_free()
		current_preview_instance = null

	var item_data = ItemDatabase.items.get(item_id, null)
	if item_data and item_data.has("model_scene"):
		print("Showing preview for item_id:", item_id, " | Scene path:", item_data["model_scene"])  # Debug info

		var scene = load(item_data["model_scene"])
		if scene:
			current_preview_instance = scene.instantiate()
			current_preview_instance.global_position = Vector3.ZERO
			current_preview_instance.look_at(Vector3(0, 0, -1), Vector3.UP)

			var cam = current_preview_instance.get_node_or_null("Camera3D")
			if cam:
				cam.current = true


func show_item(item_id: String):
	var item_container = modelpreview.get_node_or_null("Item")
	if not item_container:
		print("Error: 'Item' node not found under ModelPreview3D.")
		return

	# Hide all item previews first
	for child in item_container.get_children():
		child.visible = false

	# Show only the selected item
	var item_node = item_container.get_node_or_null(item_id)
	if item_node:
		item_node.visible = true
	else:
		print("Item mesh not found for id:", item_id)


func has_all_ingredients(recipe_ingredients):
	var inventory_items = inventory.get_items()
	for ingredient_id in recipe_ingredients:
		var found = false
		for item_dict in inventory_items:
			if item_dict["id"] == ingredient_id and item_dict["quantity"] >= 1:
				found = true
				break
		if not found:
			print("Missing ingredient in list:", ingredient_id)
			return false
	return true
