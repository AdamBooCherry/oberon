### INVENTORY MANAGER AUTOLOAD ###
extends Node

# --- Signals ---
signal currency_changed(new_amount: int)
signal item_state_changed(item_name: StringName, owned: bool)

# --- Inventory State ---
var current_currency: int = 0:
	set(value):
		current_currency = max(0, value) # Prevents negative currency
		currency_changed.emit(current_currency)

var has_frog: bool = false:
	set(value):
		if has_frog != value:
			has_frog = value
			item_state_changed.emit(&"frog", has_frog)

var has_postage: bool = false:
	set(value):
		if has_postage != value:
			has_postage = value
			item_state_changed.emit(&"postage", has_postage)


# --- Currency Management ---

func increment_currency(value: int) -> void:
	current_currency += value # Automatically invokes setter and emits signal!

func decrease_currency(value: int) -> bool:
	if current_currency >= value:
		current_currency -= value
		return true
	return false


# --- Utility / Reset ---

func reset_inventory() -> void:
	current_currency = 0
	has_frog = false
	has_postage = false
