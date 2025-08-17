extends Node2D

var resources = {"wood":0, "iron":0, "oil":0, "coal":0, "uran":0}

func add_resource(res: String, count: int):
	if not resources.has(res):
		resources[res] = 0
	resources[res] += count
	print("Dodano do ekwipunku: ", count, " ", res)
	print("Aktualny stan surowca ", res, " to ", resources[res])
