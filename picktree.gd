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
	TreeType.TREE1: $Tree1,
	TreeType.TREE2: $Tree2,
	TreeType.TREE3: $Tree3,
	TreeType.TREE4: $Tree4,
	TreeType.TREE5: $Tree5,
	TreeType.TREE6: $Tree6,
	TreeType.TREE7: $Tree7,
	TreeType.TREE8: $Tree8,
	TreeType.TREE9: $Tree9,
	TreeType.TREE10: $Tree10,
	TreeType.TREE11: $Tree11,
	TreeType.TREE12: $Tree12,
	TreeType.TREE13: $Tree13,
	TreeType.TREE14: $Tree14
}

@export var tree_type: TreeType = TreeType.TREE1

func _ready():

	for t in tree_models:
		var tree = tree_models[t]
		if tree:
			tree.visible = false

	if tree_type in tree_models and tree_models[tree_type]:
		tree_models[tree_type].visible = true
