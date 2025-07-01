# global.gd (singleton, mainly for UI purposes)

extends Node

var inventorypaused := false
var cookingpaused := false
var dialoguepaused := false
var inventory_ref := Inventory.new()
