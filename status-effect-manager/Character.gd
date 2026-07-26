# Character.gd
extends Node

@onready var status_manager: StatusEffectManager = $StatusEffectManager
@onready var active_effects_label: Label = $"../UI/ActiveEffectsLabel"
@onready var apply_button: Button = $"../UI/ApplyPoisonButton"
@onready var ice_apply_button: Button = $"../UI/ApplyIceButton"

@export var poison_effect: StatusEffect
@export var ice_effect: StatusEffect

var health: int = 100
var max_health: int = 100

signal poisoned
signal iced

func _ready() -> void:
	print("=== Game Started ===")
	
	if apply_button:
		apply_button.mouse_filter = Control.MOUSE_FILTER_STOP
		apply_button.pressed.connect(apply_poison_pressed)
		print("Button connected successfully from code")
	else:
		print("ERROR: ApplyPoisonButton not found!")
		
	if ice_apply_button:
		ice_apply_button.mouse_filter = Control.MOUSE_FILTER_STOP
		ice_apply_button.pressed.connect(apply_ice_pressed)
		print("Button connected successfully from code")
	else:
		print("ERROR: ApplyPoisonButton not found!")
#	apply_ice_pressed
#	apply_poison_pressed
	update_ui()

func _on_timer_timeout():
	$"../UI/Poison".visible = false
	print("Timer timeout!")

func apply_poison_pressed() -> void:
	print(">>> BUTTON PRESSED <<<")
	
	if poison_effect == null:
		print("ERROR: poison_effect is not assigned in the Inspector!")
		return
#	apply_ice_pressed
#	apply_poison_pressed
	status_manager.apply_effect(poison_effect)
	poisoned.connect($"../UI/Poison"._on_poisoned)
	poisoned.emit()
	print("Poison applied successfully!")
	update_ui()

func apply_ice_pressed() -> void:
	print(">>> BUTTON PRESSED <<<")
	
	if ice_effect == null:
		print("ERROR: ice_effect is not assigned in the Inspector!")
		return
	
	status_manager.apply_effect(ice_effect)
	poisoned.connect($"../UI/Ice"._on_iced)
	poisoned.emit()
	print("Ice applied successfully!")
	update_ui()

func update_ui() -> void:
	var text := "Health: %d / %d\n\nActive Effects:\n" % [health, max_health]
	
	for instance in status_manager.get_active_effects():
		var effect = instance.effect
		var duration_text = "Permanent" if effect.duration < 0 else "%.1f sec" % instance.remaining_duration
		text += "- %s (x%d) - %s\n" % [effect.effect_name, instance.stacks, duration_text]
	
	active_effects_label.text = text
