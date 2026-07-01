# status_effect.gd
class_name StatusEffect
extends Resource

## Display name of the effect
@export var effect_name: String = "Effect"

## Description shown in tooltips or UI
@export_multiline var description: String = ""

## Icon for the effect (optional)
@export var icon: Texture2D

## Duration in seconds (real-time) or turns.
## Use -1 for permanent effects until manually removed.
@export var duration: float = 5.0

## Can this effect stack?
@export var stackable: bool = false

## Maximum number of stacks allowed
@export var max_stacks: int = 3

## Tags used to identify and query effects easily
## Examples: "poison", "buff", "debuff", "dot", "control"
@export var tags: Array[String] = []

## List of events this effect listens to.
## Example: ["applied", "tick", "damage_taken"]
@export var listen_to_events: Array[String] = ["applied", "removed", "tick"]


## Called when an event this effect is listening to occurs.
## Override this method in specific effect resources.
func on_event(event: String, data: Dictionary, manager: StatusEffectManager) -> void:
	pass
