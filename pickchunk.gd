extends Node3D

enum ChunkType {
	GRASS,
	GROUND,
	SAKURA,
	SNOW,
	ROCK
}

var chunk_materials = {
	ChunkType.GRASS: preload("res://Ground/Grass/GrassMaterial.tres"),
	ChunkType.GROUND: preload("res://Ground/Grass/GroundMaterial.tres"),
	ChunkType.SAKURA: preload("res://Ground/Grass/SakuraMaterial.tres"),
	ChunkType.SNOW: preload("res://Ground/Grass/SnowMaterial.tres"),
	ChunkType.ROCK: preload("res://Ground/Grass/RockMaterial.tres"),
}

@export var chunk_type: ChunkType = ChunkType.GRASS

func _ready():
	var chunk_mat = chunk_materials[chunk_type]
	$StaticBody3D/chunk.material_override = chunk_mat
