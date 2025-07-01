extends Node3D

enum TreeType {
	TREE1,
	TREE2,
	TREE3,
	TREE4,
	TREE5,
	TREE6,
	TREE7,
	TREE8,
	TREE9,
	TREE10,
	TREE11,
	TREE12,
	TREE13,
	TREE14
}

# Diccionario para asociar cada tipo de árbol con su nodo correspondiente
@onready var tree_models = {
	TreeType.TREE1: $StaticBody3D/Tree1,
	TreeType.TREE2: $StaticBody3D/Tree2,
	TreeType.TREE3: $StaticBody3D/Tree3,
	TreeType.TREE4: $StaticBody3D/Tree4,
	TreeType.TREE5: $StaticBody3D/Tree5,
	TreeType.TREE6: $StaticBody3D/Tree6,
	TreeType.TREE7: $StaticBody3D/Tree7,
	TreeType.TREE8: $StaticBody3D/Tree8,
	TreeType.TREE9: $StaticBody3D/Tree9,
	TreeType.TREE10: $StaticBody3D/Tree10,
	TreeType.TREE11: $StaticBody3D/Tree11,
	TreeType.TREE12: $StaticBody3D/Tree12,
	TreeType.TREE13: $StaticBody3D/Tree13,
	TreeType.TREE14: $StaticBody3D/Tree14
}

@export var tree_type: TreeType = TreeType.TREE1

func _ready():

	for t in tree_models:
		var tree = tree_models[t]
		if tree:
			tree.visible = false

	if tree_type in tree_models and tree_models[tree_type]:
		tree_models[tree_type].visible = true
