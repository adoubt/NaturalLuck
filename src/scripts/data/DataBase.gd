extends Resource
class_name DataBase

var enemy_configs = {
	0: {
		"icon": "res://icon.svg",
		"rate": 0.4,
		"payout": 1.0,
		"abilities":[]
		},
		}
		
var animal_configs = {
	0: {
		"name": "Owl",
		"description": "description",
		"icon_idle":"res://src/assets/icons/owl_idle.png",
		"icon_happy":"res://src/assets/icons/owl_happy.png",
		"icon_sad":"res://src/assets/icons/owl_sad.png",
		"balance": 0.0,
		"abilities":[3]
		},
	1: {
		"name": "Hedgehog",
		"description": "description",
		"icon_idle":"res://src/assets/icons/hedgehog_idle.png",
		"icon_happy":"res://src/assets/icons/hedgehog_happy.png",
		"icon_sad":"res://src/assets/icons/hedgehog_sad.png",
		"balance": 0.0,
		"abilities":[0]
		},
	2: {
		"name": "Fox",
		"description": "description",
		"icon_idle":"res://src/assets/icons/fox_idle.png",
		"icon_happy":"res://src/assets/icons/fox_happy.png",
		"icon_sad":"res://src/assets/icons/fox_sad.png",
		"balance": 0.0,
		"abilities":[1]
		},
	3: {
		"name": "Frog",
		"description": "description",
		"icon_idle":"res://src/assets/icons/frog_idle.png",
		"icon_happy":"res://src/assets/icons/frog_happy.png",
		"icon_sad":"res://src/assets/icons/frog_sad.png",
		"balance": 0.0,
		"abilities":[2]
		},
	4: {
		"name": "Mouse",
		"description": "description",
		"icon_idle":"res://src/assets/icons/mouse_idle.png",
		"icon_happy":"res://src/assets/icons/mouse_happy.png",
		"icon_sad":"res://src/assets/icons/mouse_sad.png",
		"balance": 0.0,
		"abilities":[4]
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
		"description": "weqfewqfwwef Enemy x2 Profit",
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
		"name":"hedgehog_ability",
		"trigger": AbilityTriggers.Events.BEFORE_ANIMAL_CASHOUT,
		"action": AbilityTriggers.Actions.KEEP_PERCENT,
		"value": 0.20,
		"target": AbilityTriggers.Targets.SELF
	},
	1: {
		"name":"fox_ability",
		"trigger": AbilityTriggers.Events.ENEMY_PASSED,
		"action": AbilityTriggers.Actions.INCREASE_RATE,
		"value": 1,
		"target": AbilityTriggers.Targets.ENEMY
	},
	2: {
		"name":"frog_ability",
		"trigger": AbilityTriggers.Events.BATTLE_STARTED,
		"action": AbilityTriggers.Actions.ADD_REQUEUE,
		"value": 1,
		"target": AbilityTriggers.Targets.SELF
	},
	3: {
		"name":"owl_ability",
		"trigger": AbilityTriggers.Events.BATTLE_STARTED,
		"action": AbilityTriggers.Actions.SHOW_LAST_SIGNAL,
		"value": 1,
		"target": AbilityTriggers.Targets.GAME
	},
	4: {
		"name":"mouse_ability",
		"trigger": AbilityTriggers.Events.ANIMAL_LOSS,
		"action": AbilityTriggers.Actions.SHARE_PERCENT,
		"value": 0.20,
		"target": AbilityTriggers.Targets.NEXT_ANIMAL
	}
}
