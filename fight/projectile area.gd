extends Area3D

var enemies: Array[FightClashable] = []
var friends: Array[FightClashable] = []

var user: FightCombatant = null

func _ready() -> void:
    body_entered.connect(clash_body)

func clash_body(body: Node3D):
    if "combatant" in body:
        if user.team != body.combatant.team:
            enemies.append(body.combatant)
        else:
            friends.append(body.combatant)
        
