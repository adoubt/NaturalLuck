extends Resource
class_name DataBase

var enemy_configs = {
	0: {
		"icon": "res://src/assets/icons/poker.png" ,
		"description": "BASE CHANCE 60% PAYOUT x1.6",
		"rate": 0.6,
		"payout": 1.6,
		"abilities":[]
		},
	1: {
		"icon":  "res://src/assets/icons/roulette.png",
		"description": "BASE CHANCE 50% PAYOUT x2",
		"rate": 0.5,
		"payout": 2.0,
		"abilities":[]
		},
	2: {
		"icon": "res://src/assets/icons/slot_mashine.png",
		"description": "BASE CHANCE 30% PAYOUT x4",
		"rate": 0.3,
		"payout": 4.0,
		"abilities":[]
		},
		}
		
var animal_configs = {
	0: {
		"name": "Owl",
		"description": "Leaves behind a SIGNAL for the NEXT ROUND",
		"icon_idle":"res://src/assets/icons/owl_idle.png",
		"icon_happy":"res://src/assets/icons/owl_happy.png",
		"icon_sad":"res://src/assets/icons/owl_sad.png",
		"balance": 0.0,
		"abilities":[3]
		},
	1: {
		"name": "Hedgehog",
		"description": "Keeps 30% of its BALANCE",
		"icon_idle":"res://src/assets/icons/hedgehog_idle.png",
		"icon_happy":"res://src/assets/icons/hedgehog_happy.png",
		"icon_sad":"res://src/assets/icons/hedgehog_sad.png",
		"balance": 0.0,
		"abilities":[0]
		},
	2: {
		"name": "Fox",
		"description": "After acting, increases chance to defeat the enemy by 10% for the next ally",
		"icon_idle":"res://src/assets/icons/fox_idle.png",
		"icon_happy":"res://src/assets/icons/fox_happy.png",
		"icon_sad":"res://src/assets/icons/fox_sad.png",
		"balance": 0.0,
		"abilities":[1]
		},
	3: {
		"name": "Frog",
		"description": "Jumps back into battle",
		"icon_idle":"res://src/assets/icons/frog_idle.png",
		"icon_happy":"res://src/assets/icons/frog_happy.png",
		"icon_sad":"res://src/assets/icons/frog_sad.png",
		"balance": 0.0,
		"abilities":[2]
		},
	4: {
		"name": "Mouse",
		"description": "ON LOSE grants +20% BALANCE to the NEXT UNIT",
		"icon_idle":"res://src/assets/icons/mouse_idle.png",
		"icon_happy":"res://src/assets/icons/mouse_happy.png",
		"icon_sad":"res://src/assets/icons/mouse_sad.png",
		"balance": 0.0,
		"abilities":[4]
		},
	}
	
var hint_configs = {
	#0: {
		#"name": "name",
		#"description": "GAMES this round pay +20% if Owl is on the field",
		#"abilities":[]
		#},
	#1: {
		#"name": "name",
		#"description": "MOUSE cannot lose on Second GAME",
		#"abilities":[]
		#},
	3: {
		"name": "name",
		"description": "Units played last ROUND gain +20% DEPOSIT",
		"abilities":[0]
		},
	#4: {
		#"name": "name",
		#"description": "Solo unit gains +100% PAYOUT",
		#"abilities":[]
		#},
	#5: {
		#"name": "name",
		#"description": "DEPOSIT 90% grants +1 ROUND",
		#"abilities":[]
		#},
	6: {
		"name": "name",
		"description": "Solo unit gains +100 payout",
		"abilities":[1]
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
		"value": 0.1,
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
var hint_abilities = {
	0: {
		"name":"name",
		"trigger": AbilityTriggers.Events.DEPOSITED,
		"action": AbilityTriggers.Actions.ADD_ENEMY_BALANCE,
		"value": 0.20,
		"target": AbilityTriggers.Targets.ANIMAL
	},
	1: {
		"name":"name",
		"trigger": AbilityTriggers.Events.BATTLE_STARTED,
		"action": AbilityTriggers.Actions.INCREASE_ALL_PAYOUT,
		"value": 0.20,
		"target": AbilityTriggers.Targets.GAME
	},
}
