# npc.gd
extends Node3D

# NPC dialog identifier
var dialog_npc: String

# Character configuration exports
@export_group("Character Data")
@export var selected_npc: NPCType = NPCType.LIZ  # Selected NPC type from enum
@export var dialog_text: String = "intro"  # Default dialog branch
@export var itemgiven: String = "none"  # Item this NPC can give

# Visual customization exports
@export_group("Colors")
@export var hair_color: HairColor = HairColor.BLACK  # Hair color selection
@export var outfit_color: OutfitColor = OutfitColor.PINK  # Outfit color selection

# Hair style toggle exports
@export_group("Hair")
@export var show_hairbacklong: bool = false
@export var show_hairbackshort: bool = false
@export var show_hairbackwave: bool = false
@export var show_hairbaseshort: bool = false
@export var show_hairbaseshorter: bool = false
@export var show_hairfringeemoleft: bool = false
@export var show_hairfringeemoright: bool = false
@export var show_hairfringemiddle: bool = false
@export var show_hairfringepart: bool = false
@export var show_hairfringestraight: bool = false
@export var show_hairfringetiny: bool = false
@export var show_hairsidelong: bool = false
@export var show_hairsideshort: bool = false
@export var show_hairsidewave: bool = false

# Enum defining all NPC types
enum NPCType {
	ELRIC,
	LYRA,
	JACK,
	FLAVIA,
	NPC5,
	NPC6,
	NPC7,
	NPC8,
	NPC9,
	NPC10,
	LIZ,
	NARRATOR
}

# Mapping of NPC types to dialogue keys
var npc_dialogue_keys = {
	NPCType.ELRIC: "elric",
	NPCType.LYRA: "lyra",
	NPCType.JACK: "jack",
	NPCType.FLAVIA: "flavia",
	NPCType.NPC5: "npc_5",
	NPCType.NPC6: "npc_6",
	NPCType.NPC7: "npc_7",
	NPCType.NPC8: "npc_8",
	NPCType.NPC9: "npc_9",
	NPCType.NPC10: "npc_10",
	NPCType.LIZ: "liz",
	NPCType.NARRATOR: "narrator"
}

# Hair color options
enum HairColor {
	BLACK,
	BLONDE,
	BROWN,
	WHITE,
	ORANGE
}

# Outfit color options
enum OutfitColor {
	BLUE,
	GREEN,
	ORANGE,
	PINK
}

# Tracks if player is in interaction range
var player_in_range = false

# Preloaded hair materials for different colors
var hair_materials = {
	HairColor.BLACK: preload("res://npchairs/blackhair.tres"),
	HairColor.BLONDE: preload("res://npchairs/blondehair.tres"),
	HairColor.BROWN: preload("res://npchairs/brownhair.tres"),
	HairColor.WHITE: preload("res://npchairs/whitehair.tres"),
	HairColor.ORANGE: preload("res://npchairs/orangehair.tres")
}

# Preloaded outfit materials for different colors
var outfit_materials = {
	OutfitColor.BLUE: preload("res://npcoutfits/blue.tres"),
	OutfitColor.GREEN: preload("res://npcoutfits/green.tres"),
	OutfitColor.ORANGE: preload("res://npcoutfits/orange.tres"),
	OutfitColor.PINK: preload("res://npcoutfits/pink.tres")
}

func _ready():
	# Connect signals for interaction area
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	
	# Set up initial dialog NPC key
	dialog_npc = npc_dialogue_keys[selected_npc]
	
	# Connect to dialogue UI signal
	%DialogueUI.npc_set_branch.connect(_on_npc_set_branch)
	
	# Initialize visual appearance
	update_hair_visibility()
	update_outfit_material()

func _process(_delta):
	# Handle player interaction input
	if player_in_range and Input.is_action_just_pressed("interact") and not Global.gamedone and not Global.inventorypaused and not Global.cookingpaused and not Global.dialoguepaused:
		show_dialog()
		
		# Make NPC face player during interaction
		var player_position = %Player.global_transform.origin
		self.look_at(player_position, Vector3.UP)

# Called when body enters interaction area
func _on_body_entered(body):
	if body.is_in_group("player"):  # Check if it's the player
		print(body, body.is_on_floor())
		player_in_range = true
		$Label3D.visible = true  # Show interaction prompt

# Called when body exits interaction area
func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		$Label3D.visible = false  # Hide interaction prompt

# Called when dialogue branch changes externally
func _on_npc_set_branch(character_id: String, new_branch: String):
	if dialog_npc == character_id:
		dialog_text = new_branch

# Start dialogue interaction
func show_dialog():
	print(dialog_text)
	
	# Pause game for dialogue
	Global.dialoguepaused = true
	
	# Start dialogue from global system
	%DialogueUI.start_from_global(dialog_npc, dialog_text)
	
	# Wait for dialogue to finish
	await %DialogueUI.dialogue_finished

# Update visible hair parts based on export toggles
func update_hair_visibility():
	var hair_mat = hair_materials[hair_color]

	# Mapping of hair properties to node paths
	var hair_parts = {
		"show_hairbacklong": "hairbacklong/hairbacklong",
		"show_hairbackshort": "hairbackshort/hairbackshort",
		"show_hairbackwave": "hairbackwave/hairbackwave",
		"show_hairbaseshort": "hairbaseshort/hairbaseshort",
		"show_hairbaseshorter": "hairbaseshorter/hairbaseshorter",
		"show_hairfringeemoleft": "hairfringeemoleft/hairfringeemoleft",
		"show_hairfringeemoright": "hairfringeemoright/hairfringeemoright",
		"show_hairfringemiddle": "hairfringemiddle/hairfringemiddle",
		"show_hairfringepart": "hairfringepart/hairfringepart",
		"show_hairfringestraight": "hairfringestraight/hairfringestraight",
		"show_hairfringetiny": "hairfringetiny/hairfringetiny",
		"show_hairsidelong": "hairsidelong/hairsidelong",
		"show_hairsideshort": "hairsideshort/hairsideshort",
		"show_hairsidewave": "hairsidewave/hairsidewave"
	}

	# Toggle visibility and apply material for each hair part
	for prop_name in hair_parts.keys():
		var node_path = "NPCmaker/Armature/Skeleton3D/" + hair_parts[prop_name]
		var node = get_node(node_path)
		if node:
			node.visible = self.get(prop_name)
			node.material_override = hair_mat

# Update outfit materials based on selected color
func update_outfit_material():
	var outfit_mat = outfit_materials[outfit_color]
	var outfit_parts = ["Body", "Cylinder", "Hat", "legs"]

	# Apply material to each outfit part
	for part in outfit_parts:
		var node = get_node("NPCmaker/Armature/Skeleton3D/" + part)
		if node:
			node.material_override = outfit_mat
