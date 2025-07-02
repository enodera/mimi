# npc.gd
extends Node3D

var dialog_npc: String
@export_group("Character Data")
@export var selected_npc: NPCType = NPCType.LIZ
@export var dialog_text: String = "intro"
@export var itemgiven: String = "none"

@export_group("Colors")
@export var hair_color: HairColor = HairColor.BLACK
@export var outfit_color: OutfitColor = OutfitColor.PINK

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

# Define the NPCs
enum NPCType {
	ELRIC,
	NPC2,
	NPC3,
	NPC4,
	NPC5,
	NPC6,
	NPC7,
	NPC8,
	NPC9,
	NPC10,
	LIZ,
	NARRATOR
}

var npc_dialogue_keys = {
	NPCType.ELRIC: "elric",
	NPCType.NPC2: "npc_2",
	NPCType.NPC3: "npc_3",
	NPCType.NPC4: "npc_4",
	NPCType.NPC5: "npc_5",
	NPCType.NPC6: "npc_6",
	NPCType.NPC7: "npc_7",
	NPCType.NPC8: "npc_8",
	NPCType.NPC9: "npc_9",
	NPCType.NPC10: "npc_10",
	NPCType.LIZ: "liz",
	NPCType.NARRATOR: "narrator"
}

enum HairColor {
	BLACK,
	BLONDE,
	BROWN,
	WHITE,
	ORANGE
}

enum OutfitColor {
	BLUE,
	GREEN,
	ORANGE,
	PINK
}

#var text_dialogue_keys = {
	#NPCType.GREETING: "npc_john",
	#NPCType.MISSION1: "npc_luna",
	#NPCType.MISSION2: "narrator",
	#NPCType.MISSION2: "narrator"
#}

var player_in_range = false

var hair_materials = {
	HairColor.BLACK: preload("res://npchairs/blackhair.tres"),
	HairColor.BLONDE: preload("res://npchairs/blondehair.tres"),
	HairColor.BROWN: preload("res://npchairs/brownhair.tres"),
	HairColor.WHITE: preload("res://npchairs/whitehair.tres"),
	HairColor.ORANGE: preload("res://npchairs/orangehair.tres")
}

var outfit_materials = {
	OutfitColor.BLUE: preload("res://npcoutfits/blue.tres"),
	OutfitColor.GREEN: preload("res://npcoutfits/green.tres"),
	OutfitColor.ORANGE: preload("res://npcoutfits/orange.tres"),
	OutfitColor.PINK: preload("res://npcoutfits/pink.tres")
}

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	dialog_npc = npc_dialogue_keys[selected_npc]
	%DialogueUI.npc_set_branch.connect(_on_npc_set_branch)
	
	update_hair_visibility()
	update_outfit_material()

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact") and not Global.inventorypaused and not Global.cookingpaused and not Global.dialoguepaused:
		show_dialog()
		
		var player_position = %Player.global_transform.origin
		self.look_at(player_position, Vector3.UP)

func _on_body_entered(body):
	if body.is_in_group("player"):  # Or use group checking
		print(body, body.is_on_floor())
		player_in_range = true
		$Label3D.visible = true  # Optional
		

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		$Label3D.visible = false  # Optional

func _on_npc_set_branch(character_id: String, new_branch: String):
	if dialog_npc == character_id:
		dialog_text = new_branch

func show_dialog():
	print(dialog_text)
	
	Global.dialoguepaused = true
	
	%DialogueUI.start_from_global(dialog_npc, dialog_text)
	
	await %DialogueUI.dialogue_finished
	
	#%DialogueUI.start_dialogue([
		#"Hello, witch!",
		#"What's up? Not much, I assume...",
		#"it works heeheehee"
	#], "Yes")
	#
	#await %DialogueUI.dialogue_finished

func update_hair_visibility():
	var hair_mat = hair_materials[hair_color]

	$NPCmaker/Armature/Skeleton3D/hairbacklong/hairbacklong.visible = show_hairbacklong
	$NPCmaker/Armature/Skeleton3D/hairbacklong/hairbacklong.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairbackshort/hairbackshort.visible = show_hairbackshort
	$NPCmaker/Armature/Skeleton3D/hairbackshort/hairbackshort.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairbackwave/hairbackwave.visible = show_hairbackwave
	$NPCmaker/Armature/Skeleton3D/hairbackwave/hairbackwave.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairbaseshort/hairbaseshort.visible = show_hairbaseshort
	$NPCmaker/Armature/Skeleton3D/hairbaseshort/hairbaseshort.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairbaseshorter/hairbaseshorter.visible = show_hairbaseshorter
	$NPCmaker/Armature/Skeleton3D/hairbaseshorter/hairbaseshorter.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairfringeemoleft/hairfringeemoleft.visible = show_hairfringeemoleft
	$NPCmaker/Armature/Skeleton3D/hairfringeemoleft/hairfringeemoleft.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairfringeemoright/hairfringeemoright.visible = show_hairfringeemoright
	$NPCmaker/Armature/Skeleton3D/hairfringeemoright/hairfringeemoright.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairfringemiddle/hairfringemiddle.visible = show_hairfringemiddle
	$NPCmaker/Armature/Skeleton3D/hairfringemiddle/hairfringemiddle.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairfringepart/hairfringepart.visible = show_hairfringepart
	$NPCmaker/Armature/Skeleton3D/hairfringepart/hairfringepart.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairfringestraight/hairfringestraight.visible = show_hairfringestraight
	$NPCmaker/Armature/Skeleton3D/hairfringestraight/hairfringestraight.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairfringetiny/hairfringetiny.visible = show_hairfringetiny
	$NPCmaker/Armature/Skeleton3D/hairfringetiny/hairfringetiny.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairsidelong/hairsidelong.visible = show_hairsidelong
	$NPCmaker/Armature/Skeleton3D/hairsidelong/hairsidelong.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairsideshort/hairsideshort.visible = show_hairsideshort
	$NPCmaker/Armature/Skeleton3D/hairsideshort/hairsideshort.material_override = hair_mat

	$NPCmaker/Armature/Skeleton3D/hairsidewave/hairsidewave.visible = show_hairsidewave
	$NPCmaker/Armature/Skeleton3D/hairsidewave/hairsidewave.material_override = hair_mat

func update_outfit_material():
	var outfit_mat = outfit_materials[outfit_color]
	$NPCmaker/Armature/Skeleton3D/Body.material_override = outfit_mat
	$NPCmaker/Armature/Skeleton3D/Cylinder.material_override = outfit_mat
	$NPCmaker/Armature/Skeleton3D/Hat.material_override = outfit_mat
	$NPCmaker/Armature/Skeleton3D/legs.material_override = outfit_mat
