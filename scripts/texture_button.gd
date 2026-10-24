extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
@onready var player: CharacterBody2D = $"../../Player"
@onready var become_smol: AnimationPlayer = $"../../Player/BecomeSmol"
@onready var texture_button: TextureButton = $"."
@onready var dialouge_2: Label = $"../../Dialouges/Dialouge2"
@onready var guide_1: Label = $"../../Guide/Guide1"


func _on_pressed() -> void:
	dialouge_2.visible = true
	guide_1.visible = false
	become_smol.play("sizesmall")
	texture_button.queue_free()
