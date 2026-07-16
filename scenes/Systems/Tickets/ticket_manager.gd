extends Node
class_name TicketManager


@export var ticket_ui_manager: TicketUIManager

@export var tickets: Dictionary # Tickets are stored as (ticketid, Ticket)
@export var ticket_count: int = 0
@export var inactive_timers: Array[Timer]
@export var timer_scene: PackedScene
@export var ticket_capacity: int

const DISH_DICTIONARY_LEN: int = len(RecipeDictionary.recipe_dict) - 1

@export var plate_process_queue: Array

signal point_event(amount: int)

# TODO: implement plate/ticket scoring
# @export var plate_zone:
# Object to detect completed dishes, pick them up and grade
# Reference to ui manager to handle ticket display

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

    # Initialize ticket timers
    for i in range(ticket_capacity):
        var new_timer = timer_scene.instantiate()
        add_child(new_timer)
        new_timer.name = "%s %d" % ["Timer", i]
        inactive_timers.append(new_timer)


func first_setup(game_ui_manager: GameUIManager, cooking_manager: CookingManager):
    ticket_ui_manager = game_ui_manager.ticket_ui_manager
    cooking_manager.cooking_finished.connect(grade_completed_plate)


func spawn_ticket() -> void:
    if len(inactive_timers) <= 0:
        return # We have too many tickets to make a new one

    var new_ticket: Ticket = Ticket.new()

    new_ticket.id = ticket_count
    ticket_count += 1

    # TODO: expand ticket dish selection
    new_ticket.dish_id = randi_range(1, DISH_DICTIONARY_LEN)

    # TODO: add dish special requests
    new_ticket.time_limit += len(new_ticket.dish_request) * 10

    var new_timer = inactive_timers.pop_front()

    new_timer.wait_time = new_ticket.time_limit
    new_ticket.timer = new_timer

    new_timer.timeout.connect(new_ticket._timout_ticket, ConnectFlags.CONNECT_ONE_SHOT)
    new_ticket.ticket_expired.connect(_ticket_expired, ConnectFlags.CONNECT_ONE_SHOT)

    tickets.set(new_ticket.id, new_ticket)
    print("TicketManager - Created ticket id: %d" % new_ticket.id)

    # Add ticket to the UI and start timer
    ticket_ui_manager.add_ticket_ui(new_ticket)
    new_timer.start()


func _ticket_expired(ticket: Ticket) -> void:
    # reset and replace timer from ticket
    inactive_timers.append(ticket.timer)
    ticket.timer = null

    # remove ticket from active tickets
    tickets.erase(ticket.id)
    # TODO: save tickets to show at end?


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("solve_ticket"):
        grade_completed_plate(RecipeDictionary.recipe_dict.get(tickets[tickets.keys()[0]].dish_id).get(RecipeDictionary.INGREDIENTS).duplicate(true))

# plate_ingredients should be in form (carriable_id: int, count: int)
func grade_completed_plate(plate_ingredients: Dictionary) -> bool:
    print("TicketManager - Grading the following plate:")
    print(plate_ingredients)

    var ticket_id_to_complete: int = -1

    # for each ticket
    for ticket_id in tickets.keys():
        var dish_id: int = tickets.get(ticket_id).dish_id
        var recipe_ingredients: Dictionary = RecipeDictionary.recipe_dict[dish_id].get(RecipeDictionary.INGREDIENTS).duplicate(true)
        # TODO: add special request modifiers here

        print("Checking plate against recipe: ")
        print(recipe_ingredients)

        # for each ingredient in the recipe
        for ingredient_key in recipe_ingredients.keys():
            # check if it exists in the plate, break to next ticket if not
            var plate_ingredient_count = plate_ingredients.get(ingredient_key)
            if plate_ingredient_count == null:
                break
            # else, check if the amount is correct
            recipe_ingredients[ingredient_key] -= plate_ingredient_count
            if recipe_ingredients[ingredient_key] != 0:
                break

            recipe_ingredients.erase(ingredient_key)

        if len(recipe_ingredients) > 0:
            continue

        ticket_id_to_complete = ticket_id
        break

    # if we did not find a matching ticket, return false
    if ticket_id_to_complete < 0:
        return false

    # remove ticket_to_complete from tickets
    tickets.get(ticket_id_to_complete).timer.stop()
    tickets.get(ticket_id_to_complete).timer.timeout.emit()
    tickets.erase(ticket_id_to_complete)

    print("Successful Plate!")
    point_event.emit(GameData.PLATE_SUCESS_POINTS)

    return true
