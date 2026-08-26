# CombatAction.gd
class_name CombatAction
extends Resource

enum Category { ATTACK, SPELL, DEFENSE }

@export var id: StringName
@export var display_name: String
@export var description: String
@export var category: Category
@export var icon: Texture2D
@export var mana_cost: int = 0
@export var cooldown: float = 0.0
@export var spell_scene: PackedScene   # only for spells
