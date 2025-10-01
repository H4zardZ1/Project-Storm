extends Container
# Custom container for the UI half of the hand

## in pixels
@export var maximum_spacing : float

func _notification(what: int) -> void:
    if what == NOTIFICATION_SORT_CHILDREN:
        var child_count := get_child_count()
        var space_needed: float = 0
        for i in range(child_count):
            var child = get_child(i)
            space_needed += child.size.x
            if (i < (child_count - 1)) and (maximum_spacing < 0):
                space_needed += maximum_spacing
        var x_offset := (size.x - space_needed) / 2
        var spacing := maximum_spacing
        if maximum_spacing > 0:
            if space_needed + maximum_spacing * (child_count - 1) > size.x:
                spacing = (size.x - space_needed) / (child_count - 1)
            space_needed = minf(size.x, space_needed)
        
        
        for child in get_children():
            child.position = Vector2(x_offset, 0)
            x_offset += child.size.x + spacing


            