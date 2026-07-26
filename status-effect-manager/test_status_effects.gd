extends Node2D

@onready var poison_img = $UI/Poison
@onready var ice_img = $UI/Ice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	poison_img.visible = false
	ice_img.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
