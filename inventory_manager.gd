### INVENTORY MANAGER ###
extends Node

var current_currency: int = 0
var has_frog: bool = false
var has_postage: bool = false

func increment_currency(value: int):
	pass

func reset_inventory():
	current_currency = 0
	has_frog = false
	has_postage = false
