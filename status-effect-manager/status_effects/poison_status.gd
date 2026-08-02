class_name PoisonStatus
extends StatusEffect

## Damage per tick.
@export var damage_per_tick: int = 5

func on_event(event: String, data: Dictionary, manager: StatusEffectManager) -> void:
	match event:
		"applied":
			print("%s applied" % effect_name)
		"tick":
			# Here, real damage.
			if manager.owner_node.has_method("take_damage"):
				manager.owner_node.take_damage(damage_per_tick * data.get("stacks", 1))
		"removed":
			print("%s ficnished" % effect_name)
