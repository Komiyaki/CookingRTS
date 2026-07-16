extends Node
class_name GameManager

const debug: bool = true


@export var main_menu_scene: String = "res://scenes/MainMenu/main_menu.tscn"

@onready var tree_root: SceneTree = self.get_tree()

@export var carried_object_pool: CarriedObjectPooler
@export var ui_manager: GameUIManager
@export var ticket_manager: TicketManager
@export var pan: PanObjective

@export var gm_round_timer: Timer
@export var gm_interround_timer: Timer
@export var gm_ticket_spawn_timer: Timer

@export var high_score: int:
    set(value):
        SaveData.high_score = value
    get:
        return SaveData.high_score


signal points_change_event(previous_amount: int, new_amount: int)
@export var current_points: int = 0:
    set(value):
        points_change_event.emit(current_points, value)
        current_points = value

signal game_state_event(previous_state: GameData.GameState, new_state: GameData.GameState)
@export var game_state: GameData.GameState = GameData.GameState.FIRST_LOAD:
    set(value):
        game_state_event.emit(game_state, value)
        game_state = value

signal round_event(round_number: int)
var round_number: int = 0:
    set(value):
        round_number = value
        round_event.emit(round_number)

signal pause_event(is_paused: bool)
var is_paused: bool = false:
    set(value):
        is_paused = value
        tree_root.paused = value
        pause_event.emit(is_paused)
        print("%sPAUSED GAME" % ("" if is_paused else "UN"))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state = GameData.GameState.FIRST_LOAD
    _check_dependencies()

    _call_first_setup()

    gm_round_timer.wait_time = GameData.ROUND_TIMER_SECONDS
    gm_round_timer.one_shot = true
    gm_round_timer.timeout.connect(_round_timer_end)

    gm_interround_timer.wait_time = GameData.INTERROUND_TIMER_SECONDS
    gm_interround_timer.one_shot = true
    gm_interround_timer.timeout.connect(_interround_timer_end)

    gm_ticket_spawn_timer.timeout.connect(_spawn_ticket_timer_end)

    ticket_manager.point_event.connect(_process_point_event)

    ui_manager.restart_button.pressed.connect(_process_game_restart)
    ui_manager.exit_button.pressed.connect(_process_return_to_menu)

    # carried_object_pool.spawn_carried_object(Vector2.ONE * 200, 0)

func _check_dependencies() -> void:
    if carried_object_pool == null:
        push_error("No carried_object_pool set on %s" % name)
    if ui_manager == null:
        push_error("No ui_manager set on %s" % name)
    if pan == null:
        push_error("No pan set on %s" % name)
    if gm_round_timer == null:
        push_error("No gm_round_timer set on %s" % name)
    if gm_interround_timer == null:
        push_error("No gm_interround_timer set on %s" % name)


func _call_first_setup() -> void:
    ui_manager.first_setup(self)
    ticket_manager.first_setup(ui_manager, pan.cooking_manager)
    pan.carried_object_pooler = carried_object_pool

# process pause inputs
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        if not is_paused:
            is_paused = true
        else:
            is_paused = false
    if event.is_action_pressed("pause_menu"):

        pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:


    match game_state:
        GameData.GameState.FIRST_LOAD:
            print("%s performing first load" % name)
            # for now dont do much, just start spawning
            # might play some intro animation or something idk
            game_state = GameData.GameState.ROUND_SWITCH

        GameData.GameState.PAUSED:
            # send signal to all subscribers that game is paused (on pause and unpause)
            pass

        GameData.GameState.INTERROUND:
            gm_ticket_spawn_timer.stop()
            # allow shopping for new guys??? idk
            pass

        GameData.GameState.ROUND_SWITCH:
            # increment round counter, load recipe data for next round, start round timer
            round_number += 1
            game_state = GameData.GameState.SPAWNING

            gm_round_timer.start()
            gm_ticket_spawn_timer.start()
            ticket_manager.spawn_ticket()
            pass

        GameData.GameState.SPAWNING:
            pass

        GameData.GameState.GAME_OVER:
            # show stats
            # allow restart, or exit to menu
            pass

        GameData.GameState.RESTART:
            tree_root.reload_current_scene()
            pass

        _:
            push_error("Unexpected GameState value on %s" % name)

    pass

func _round_timer_end() -> void:
    game_state = GameData.GameState.GAME_OVER
    if current_points > high_score:
        high_score = current_points
    is_paused = true
    ui_manager.do_gameover(high_score, current_points)
    # gm_interround_timer.start()

func _interround_timer_end() -> void:
    game_state = GameData.GameState.ROUND_SWITCH

func _spawn_ticket_timer_end() -> void:
    ticket_manager.spawn_ticket()

func _process_point_event(amount: int) -> void:
    print("POINTS INCREASED %d" % amount)
    current_points += amount

func _process_game_restart():
    is_paused = false
    tree_root.reload_current_scene()

func _process_return_to_menu():
    tree_root.change_scene_to_file(main_menu_scene)
