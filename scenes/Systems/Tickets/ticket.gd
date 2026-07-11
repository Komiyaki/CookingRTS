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
@export var dish_request: TicketRequest = TicketRequest.NONE
