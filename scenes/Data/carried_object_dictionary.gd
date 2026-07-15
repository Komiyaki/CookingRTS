class_name CarriedObjectDictionary

const NAME: String = "name"

const id_dict: Dictionary = {
    # Plate
    0b000000: { # 0
        "name": "Plate",
        "carry_value": 4,
        "timer_value": 0,
        "sprite_name": "default",
    },
    # Carbs
    0b001000: { # 8
        "name": "Rice",
        "carry_value": 3,
        "timer_value": 0,
        "sprite_name": "Rice",
    },
    0b001001: { # 9
        "name": "Noodle",
        "carry_value": 3,
        "timer_value": 0,
        "sprite_name": "Noodle",
    },
    # Protein
    0b010000: { # 16
        "name": "Chicken",
        "carry_value": 3,
        "timer_value": 0,
        "sprite_name": "Chicken",
    },
    0b010001: { # 17
        "name": "Beef",
        "carry_value": 3,
        "timer_value": 0,
        "sprite_name": "Beef Cube",
    },
    0b010010: { # 18
        "name": "Pork",
        "carry_value": 3,
        "timer_value": 0,
        "sprite_name": "Pork Cube",
    },
    0b010011: { # 19
        "name": "Shrimp",
        "carry_value": 2,
        "timer_value": 0,
        "sprite_name": "Shrimp",
    },
    # Vegetable
    0b011000: { # 24
        "name": "Cabbage",
        "carry_value": 3,
        "timer_value": 0,
        "sprite_name": "Cabbage",
    },
    0b011001: { # 25
        "name": "Chives",
        "carry_value": 1,
        "timer_value": 0,
        "sprite_name": "Chive",
    },
    0b011010: { # 26
        "name": "Carrot",
        "carry_value": 2,
        "timer_value": 0,
        "sprite_name": "Carrot",
    },
    0b011011: { # 27
        "name": "Bok Choy",
        "carry_value": 2,
        "timer_value": 0,
        "sprite_name": "Bok Choy",
    },
    0b011100: { # 28
        "name": "Bean Sprout",
        "carry_value": 1,
        "timer_value": 0,
        "sprite_name": "Bean Sprout",
    },
    0b011101: { # 29
        "name": "Bell Pepper",
        "carry_value": 2,
        "timer_value": 0,
        "sprite_name": "Bell Pepper",
    },
    # Sauce
    0b100000: { # 32
        "name": "Soy",
        "carry_value": 2,
        "timer_value": 0,
        "sprite_name": "Soy",
    },
    0b100001: { # 33
        "name": "Oyster",
        "carry_value": 2,
        "timer_value": 0,
        "sprite_name": "Oyster",
    },
    0b100010: { # 34
        "name": "Worchestershire",
        "carry_value": 2,
        "timer_value": 0,
        "sprite_name": "Worchestershire",
    },
    # Seasoning
    0b101000: { # 40
        "name": "Salt",
        "carry_value": 1,
        "timer_value": 0,
        "sprite_name": "Salt",
    },
    0b101001: { # 41
        "name": "Pepper",
        "carry_value": 1,
        "timer_value": 0,
        "sprite_name": "Pepper",
    },
    0b101010: { # 42
        "name": "MSG",
        "carry_value": 1,
        "timer_value": 0,
        "sprite_name": "MSG",
    },
}

static func has_id(id: int) -> bool:
    return id_dict.has(id)

static func get_data(id: int) -> Dictionary:
    return id_dict.get(id, {})

static func get_item_name(id: int) -> String:
    return id_dict.get(id, {}).get("name", "Unknown")


static func get_sprite_name(id: int) -> String:
    return id_dict.get(id, {}).get("sprite_name", "default")


static func get_carry_value(id: int) -> int:
    return id_dict.get(id, {}).get("carry_value", 0)


static func get_timer_value(id: int) -> float:
    return id_dict.get(id, {}).get("timer_value", 0.0)
