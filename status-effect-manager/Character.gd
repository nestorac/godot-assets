# Character.gd
extends Node

@onready var status_manager: StatusEffectManager = $StatusEffectManager
@onready var active_effects_label: Label = $"../UI/ActiveEffectsLabel"
@onready var apply_poison_button: Button = $"../UI/ApplyPoisonButton"
@onready var apply_ice_button: Button = $"../UI/ApplyIceButton"
@onready var apply_fuzzy_button: Button = $"../UI/ApplyFuzzyButton"
@onready var timer: Timer = $"../Timer"

@onready var poison: Sprite2D = $"../UI/Poison"
@onready var ice: Sprite2D = $"../UI/Ice"
@onready var fuzzy: Sprite2D = $"../UI/Fuzzy"

@export var poison_effect: StatusEffect
@export var ice_effect: StatusEffect
@export var fuzzy_effect: StatusEffect

var health: int = 100
var max_health: int = 100

# En tiempo real
func _process(delta: float) -> void:
	status_manager.process_tick(delta)

func _ready() -> void:
	print("=== Game Started ===")
	
	# En _ready o al conectar señales
	apply_poison_button.pressed.connect(func(): apply_effect_pressed(poison_effect))
	apply_ice_button.pressed.connect(func(): apply_effect_pressed(ice_effect))
	apply_fuzzy_button.pressed.connect(func(): apply_effect_pressed(fuzzy_effect))
	
	update_ui()

#func _on_timer_timeout():
	#$"../UI/Poison".visible = false
	#print("Timer timeout!")

func apply_effect_pressed(effect: StatusEffect) -> void:
	if effect == null:
		print("ERROR: effect is not assigned")
		return
	elif effect == poison_effect:
		print("Poison effect applied!")
		poison.visible = true
		return
	elif effect == ice_effect:
		print("Ice effect applied!")
		ice.visible = true
		return
	elif effect == fuzzy_effect:
		print("Fuzzy effect applied!")
		fuzzy.visible = true
		return
	
	status_manager.apply_effect(effect)
	update_ui()

func update_ui() -> void:
	var text := "Health: %d / %d\n\nActive Effects:\n" % [health, max_health]
	
	for instance in status_manager.get_active_effects():
		var effect = instance.effect
		var duration_text = "Permanent" if effect.duration < 0 else "%.1f sec" % instance.remaining_duration
		text += "- %s (x%d) - %s\n" % [effect.effect_name, instance.stacks, duration_text]
	
	active_effects_label.text = text
