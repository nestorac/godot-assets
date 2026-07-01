# status_effect_manager.gd
class_name StatusEffectManager
extends Node

## Emitted when an effect is applied or refreshed
signal effect_applied(effect_instance: Dictionary)

## Emitted when an effect is removed
signal effect_removed(effect_instance: Dictionary)

## Emitted after an effect processes an event
signal effect_event_processed(effect_instance: Dictionary, event: String)

## Dictionary storing active effects
## Key = StatusEffect resource, Value = instance data
var active_effects: Dictionary = {}

## Reference to the owner of this manager (usually the character/unit)
var owner_node: Node = null


func _ready() -> void:
	owner_node = get_parent()


## Applies an effect to the owner.
## If the effect already exists and is not stackable, it refreshes the duration.
func apply_effect(effect: StatusEffect) -> void:
	if not effect:
		return

	var instance: Dictionary

	if active_effects.has(effect):
		instance = active_effects[effect]
		if effect.stackable:
			instance.stacks = min(instance.stacks + 1, effect.max_stacks)
		instance.remaining_duration = effect.duration
	else:
		instance = {
			"effect": effect,
			"stacks": 1,
			"remaining_duration": effect.duration,
			"applier": null
		}
		active_effects[effect] = instance

	_dispatch_event(instance, "applied", {"applier": instance.applier})
	effect_applied.emit(instance)


## Removes a specific effect
func remove_effect(effect: StatusEffect) -> void:
	if active_effects.has(effect):
		var instance = active_effects[effect]
		_dispatch_event(instance, "removed", {})
		active_effects.erase(effect)
		effect_removed.emit(instance)


## Public method to send events from outside (damage, attacks, etc.)
func send_event(event: String, data: Dictionary = {}) -> void:
	for instance in active_effects.values():
		_dispatch_event(instance, event, data)


## Processes time passing (call this every frame or every second).
## Reduces duration and triggers "tick" events.
func process_tick(delta: float = 1.0) -> void:
	var effects_to_remove: Array = []

	for effect in active_effects.keys():
		var instance = active_effects[effect]

		if instance.remaining_duration > 0:
			instance.remaining_duration -= delta

		_dispatch_event(instance, "tick", {"delta": delta})

		if instance.remaining_duration <= 0 and effect.duration != -1:
			effects_to_remove.append(effect)

	for effect in effects_to_remove:
		remove_effect(effect)


## Internal method that dispatches an event only to effects listening to it
func _dispatch_event(instance: Dictionary, event: String, data: Dictionary = {}) -> void:
	var effect: StatusEffect = instance.effect

	if event in effect.listen_to_events:
		effect.on_event(event, data, self)
		effect_event_processed.emit(instance, event)


## Returns true if the owner currently has an effect with the given tag
func has_effect(tag: String) -> bool:
	for effect in active_effects.keys():
		if tag in effect.tags:
			return true
	return false


## Returns all currently active effect instances (useful for UI)
func get_active_effects() -> Array:
	return active_effects.values()
