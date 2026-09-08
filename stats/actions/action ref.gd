extends RefCounted
class_name Action
## A class to store the data of a card in-game.
##
## A class to store the data of a card in-game.

#region FightManager Signals
# these signals are technically emitted not here, but instead mostly by FightManager
# still, it's here so that various functionalities don't have to listen in to FightManager for things that require only action-related signals
# (e.g. "On Use: 'foo'")
@warning_ignore_start("unused_signal")
signal about_to_use()
signal used()
@warning_ignore_restore("unused_signal")
#endregion
const COPY_PROPERTIES = ["play_point_cost", "speed_cost", "passive", "passive_text", "cinematics", "character_movement", "action_dice"]

var play_point_cost: int = 0
var speed_cost: int = 0

var passive: Array[ActionEffect] = []
var passive_text := ""

var cinematics = ""
var character_movement = ""

var action_dice: Array[ActionDie] = []

## Additional effects that can be applied to the action.
## You can bypass this and edit the action itself(Plain stat changes).
var buff: Array = []

# Can accept dict and Obj



func init_dict(d: Dictionary):
    var err_t := ""
    play_point_cost = d["play_point_cost"]
    speed_cost = d["speed_cost"]

    for p in d["passive"]:
        add_passive(p)
    passive_text = d[passive_text]
    for ie in d["action_dice"]:
        add_die(ie)
    
    cinematics = d["cinematics"]
    character_movement = d["character_movement"]
    if err_t:
        push_error(err_t)

func init_obj(o: Object) -> void:
    var err_p := []
    for prop in COPY_PROPERTIES:
        if (prop in o) and (prop in self):
            if prop == "passive":
                for p in o[prop]:
                    add_passive(p)
            elif prop == "action_dice":
                for d in o[prop]:
                    add_die(d)
            else:
                self[prop] = o[prop]

            self[prop] = o[prop]
        elif not (prop in self):
            assert(false, "Property '{0}' not found in script that governs the type 'Action'".format([prop]))
        else:
            err_p.append(prop)
    if not err_p.is_empty():
        push_error("Properties {0} not found in object '{1}'".format([
            err_p.reduce(_perror_init_obj), o
        ]))

func add_passive(p: ActionEffect):
    p.connect_action(self)
    passive.append(p)

func add_die(d: ActionDie):
    action_dice.append(d)

func _perror_init_obj(accum, t):
    if accum:
        return accum + ", '{0}'".format([t])
    else:
        return "'{0}'".format([t])
