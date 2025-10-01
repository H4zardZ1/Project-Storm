extends Range

@export var background_color: Color
@export var lune_color: Color = Color.WHITE

var center: Vector2:
    get:
        return size / 2
var r: float:
    get:
        return minf(center.x, center.y)

func _init() -> void:
    changed.connect(queue_redraw)
    value_changed.connect(queue_redraw)


func _draw() -> void:

    draw_circle(center, r, background_color, true, -1.0, true)
    if value <= min_value:
        return
    var curve := Curve2D.new()
    # Good news: the approx for a circle for beziers is way good enough https://spencermortensen.com/articles/bezier-circle/
    # Bad news: i want lunar phases, not *just* circles
    # const BEZIER_CIRCLE_APPROX_A = 1.00005519
    # const BEZIER_CIRCLE_APPROX_B = 0.55342686
    # const BEZIER_CIRCLE_APPROX_C = 0.99873585
    curve.add_point(Vector2(r, 0), Vector2.ZERO, Vector2(r * 0.55342686 / 1.00005519, r * 0.00131934)) 
    curve.add_point(Vector2(0, r), )
    # Another way of dealing with this is instead of 
    pass
