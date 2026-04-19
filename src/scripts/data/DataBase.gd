extends Resource
class_name DataBase

var enemy_configs = {
	0: {
		"icon": "res://icon.svg",
		"rate": 50.0,
		"payout": 1.0,
		"abilities":[]
		},
		}
		
var animal_configs = {
	0: {
		"name": "cat",
		"description": "description",
		"icon_idle":"res://src/assets/icons/cat_idle.png",
		"icon_happy":"res://src/assets/icons/cat_idle.png",
		"icon_sad":"res://src/assets/icons/cat_idle.png",
		"balance": 0.0,
		"abilities":[]
		},
	1: {
		"name": "hedgehod",
		"description": "description",
		"icon_idle":"res://src/assets/icons/hedgehog_idle.png",
		"icon_happy":"res://src/assets/icons/hedgehog_happy.png",
		"icon_sad":"res://src/assets/icons/hedgehog_sad.png",
		"balance": 0.0,
		"abilities":[]
		},
	2: {
		"name": "fox",
		"description": "description",
		"icon_idle":"res://src/assets/icons/fox_idle.png",
		"icon_happy":"res://src/assets/icons/fox_idle.png",
		"icon_sad":"res://src/assets/icons/fox_idle.png",
		"balance": 0.0,
		"abilities":[]
		},
	}
var hint_configs = {
	0: {
		"name": "name",
		"description": "Second Enemy x2 Profit",
		"abilities":[]
		},
	1: {
	"name": "name",
	"description": "Second Enemy x2 Profit",
	"abilities":[]
	},
		
}
var relic_configs = {
	0: {
		"name": "name",
		"description": "description",
		"icon":"res://icon.svg",
		"abilities":[]
		},
		}
var consumable_configs = {
	0: {
		"name": "name",
		"description": "description",
		"icon":"res://icon.svg",
		"abilities":[]
		},
	}

var relic_abilities = {
	0: {
		"trigger_type": AbilityTriggers.Events.ANIMAL_WIN,
		"action": AbilityTriggers.Actions.ADD_BALANCE
	},
	1: {
		"trigger_type": AbilityTriggers.Events.ANIMAL_WIN,
		"action": AbilityTriggers.Actions.ADD_BALANCE
	}
}
var animal_abilities = {
	0: {
		"trigger_type": AbilityTriggers.Events.ANIMAL_WIN,
		"action": AbilityTriggers.Actions.ADD_BALANCE
	},
	1: {
		"trigger_type": AbilityTriggers.Events.ANIMAL_WIN,
		"action": AbilityTriggers.Actions.ADD_BALANCE
	}
}

var consumable_abilities = {
	0: {
		"trigger_type": AbilityTriggers.Events.CONSUMABLE_USED,
		"action": AbilityTriggers.Actions.ADD_BALANCE,
		"target": AbilityTriggers.Targets.GAME
	},
	1: {
		"trigger_type": AbilityTriggers.Events.CONSUMABLE_USED,
		"action": AbilityTriggers.Actions.DISABLE_ENEMY
	}
}
