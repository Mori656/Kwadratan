extends Node2D

@export var neighbors: Array:
	set(value): #setter dla active
		neighbors = value
		
var row: int = 0
var column: int = 0 
var value: int = 0
