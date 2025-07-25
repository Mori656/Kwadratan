extends Node2D

var resources = {"wood":0, "brick":0, "sheep":0, "grain":0, "stone":0}

func add_resource(res,count):
	if res in resources:
		resources[res] += count
		print("Dodano " + res)
