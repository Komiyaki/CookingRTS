extends Container
class_name Ticket

enum TicketRequest {
    NONE,
    EXTRA,
    LESS,
    ALERGEN,
}

@export var time_limit: int = 60
@export var dish_id: int = 0
@export var dish_request: Dictionary = Dictionary()
# dish_request should follow { ingredient_id: TicketRequest } format, logic handled in TicketManager
