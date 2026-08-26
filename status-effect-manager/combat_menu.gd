# CombatMenu.gd
extends CanvasLayer

signal action_selected(action: CombatAction)

@export var actions: Array[CombatAction] = []

@onready var attacks_list: ItemList = $Panel/TabContainer/Attacks
@onready var spells_list: ItemList = $Panel/TabContainer/Spells
@onready var defenses_list: ItemList = $Panel/TabContainer/Defenses
@onready var description: Label = $Panel/DescriptionLabel

var _by_list := {}  # ItemList -> array of actions in that list

func _ready() -> void:
	visible = false
	_populate()
	attacks_list.item_selected.connect(_on_item_selected.bind(attacks_list))
	spells_list.item_selected.connect(_on_item_selected.bind(spells_list))
	defenses_list.item_selected.connect(_on_item_selected.bind(defenses_list))
	attacks_list.item_activated.connect(_on_item_activated.bind(attacks_list))
	spells_list.item_activated.connect(_on_item_activated.bind(defenses_list))  # fix if needed
	# same for defenses_list.item_activated

func open_menu() -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_menu() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _populate() -> void:
	attacks_list.clear()
	spells_list.clear()
	defenses_list.clear()
	_by_list = {attacks_list: [], spells_list: [], defenses_list: []}

	for action in actions:
		var list: ItemList
		match action.category:
			CombatAction.Category.ATTACK:
				list = attacks_list
			CombatAction.Category.SPELL:
				list = spells_list
			CombatAction.Category.DEFENSE:
				list = defenses_list
		var idx := list.add_item(action.display_name, action.icon)
		list.set_item_metadata(idx, action)
		_by_list[list].append(action)

func _on_item_selected(index: int, list: ItemList) -> void:
	var action: CombatAction = list.get_item_metadata(index)
	description.text = "%s\n%s\nCost: %d" % [action.display_name, action.description, action.mana_cost]

func _on_item_activated(index: int, list: ItemList) -> void:
	var action: CombatAction = list.get_item_metadata(index)
	action_selected.emit(action)
	close_menu()
