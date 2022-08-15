class_name Robot
extends KinematicBody2D

const GRAVITY := 15

export var power_crystals := 1
export var health := 6

var _sword := System.new(false, 0)
var _shield := System.new(false, 0)
var _ranged := System.new(false, 0)
var _drones := System.new(false, 0)
var _horizontal_speed := 200
var _max_fall_speed := 600
var _current_vertical_speed := 0
