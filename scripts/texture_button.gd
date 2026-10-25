extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
@onready var player: CharacterBody2D = $"../../Player"
@onready var become_smol: AnimationPlayer = $"../../Player/BecomeSmol"
@onready var potion_man: TextureButton = $"."
@onready var dialouge_2: Label = $"../potionman"
@onready var guide_1: Label = $"../Guide1"
@onready var teleporter_button: Button = $"../TeleporterButton"
@onready var camera_2d: Camera2D = $"../../Player/Camera2D"


func _on_pressed() -> void:
	dialouge_2.visible = true
	guide_1.visible = false
	become_smol.play("sizesmall")
	teleporter_button.visible = true
	potion_man.queue_free()
	
