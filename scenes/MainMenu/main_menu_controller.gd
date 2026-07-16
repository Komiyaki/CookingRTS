extends MarginContainer

@export var game_scene: String = "res://Scenes/Game/game_scene.tscn"
@export var start_button: Button
@export var exit_button: Button


func _ready() -> void:
    print("Main menu is ready")
    print("Start button: ", start_button)
    _check_dependencies()
    exit_button.pressed.connect(_exit_game)
    start_button.pressed.connect(_start_game)

func _start_game() -> void:
    print("Test")
    get_tree().change_scene_to_file(game_scene)
    print("Start game via main menu")

func _exit_game() -> void:
    print("Exited game via main menu")
    get_tree().quit()

func _check_dependencies() -> void:
    if start_button == null:
        push_error("No start_button set on main_menu_controller")
    if exit_button == null:
        push_error("No exit_button set on main_menu_controller")
    if not ResourceLoader.exists(game_scene):
        push_error("No scene exists at game_scene path on main_menu_controller")
