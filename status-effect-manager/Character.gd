# Character.gd
extends Node

@onready var status_manager: StatusEffectManager = $StatusEffectManager
@onready var active_effects_label: Label = $"../UI/ActiveEffectsLabel"
@onready var apply_button: Button = $"../UI/ApplyPoisonButton"

@export var poison_effect: StatusEffect

var health: int = 100
var max_health: int = 100


func _ready() -> void:
	# Connect button from code (more reliable)
	if apply_button:
		apply_button.pressed.connect(apply_poison)
	
	# Connect status manager signals
	status_manager.effect_applied.connect(_on_effect_applied)
	status_manager.effect_removed.connect(_on_effect_removed)
	status_manager.effect_event_processed.connect(_on_effect_event)
	
	update_ui()


func apply_poison() -> void:
	if poison_effect:
		status_manager.apply_effect(poison_effect)
		print("Poison applied!")           # Debug message
	else:
		print("ERROR: poison_effect is not assigned in the Inspector!")


func _on_effect_applied(instance: Dictionary) -> void:
	print("Effect applied: ", instance.effect.effect_name)
	update_ui()


func _on_effect_removed(instance: Dictionary) -> void:
	print("Effect removed: ", instance.effect.effect_name)
	update_ui()


func _on_effect_event(instance: Dictionary, event: String) -> void:
	if event == "tick":
		if "poison" in instance.effect.tags:
			var damage = 5 * instance.stacks
			health = max(0, health - damage)
			print("Poison tick! Damage:", damage, " | Health:", health)
			update_ui()


func update_ui() -> void:
	var text := "Health: %d/%d\n\nActive Effects:\n" % [health, max_health]
	
	for instance in status_manager.get_active_effects():
		var effect = instance.effect
		var dur = "Permanent" if effect.duration < 0 else "%.1f sec" % instance.remaining_duration
		text += "- %s (x%d) - %s\n" % [effect.effect_name, instance.stacks, dur]
	
	active_effects_label.text = text
