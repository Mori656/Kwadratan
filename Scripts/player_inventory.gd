extends Node2D

var resources = {"wood":0, "brick":0, "sheep":0, "grain":0, "stone":0}

func add_resource(res: String, count: int):
	if not resources.has(res):
		resources[res] = 0
	resources[res] += count
	print("Dodano do ekwipunku: ", count, " ", res)
	print("Aktualny stan surowca ", res, " to ", resources[res])
