extends Resource
class_name Stats

signal hp_changed(new_hp, max_hp)
signal mana_changed(new_mana, max_mana)
signal xp_changed(new_xp, xp_to_next)
signal level_changed(new_level)
signal died

# Primary stats (allocated on level up)
@export var strength: int = 3
@export var agility: int = 3
@export var intelligence: int = 3
@export var vitality: int = 3

# Item base values (set by equipment)
var _item_dmg_min: float = 1.0
var _item_dmg_max: float = 2.0
var _item_str_scale_min: float = 0.15
var _item_str_scale_max: float = 0.3

# Derived stats (computed)
var _max_hp: float = 0.0
var _max_mana: float = 0.0
var _dmg_min: float = 0.0
var _dmg_max: float = 0.0
var _spell_damage: float = 0.0
var _mana_regen: float = 0.0
var _hp_regen: float = 0.0
var _speed: float = 0.0
var _crit_chance: float = 0.0
var _defense: float = 0.0
var _attack_speed: float = 0.0
var _attack_speed_mod: float = 0.0
var _hp_regen_add: float = 0.0

func _update_derived() -> void:
	_max_hp = 80.0 + vitality * 10.0
	_max_mana = 20.0 + intelligence * 5.0
	_dmg_min = _item_dmg_min + strength * _item_str_scale_min
	_dmg_max = _item_dmg_max + strength * _item_str_scale_max
	_spell_damage = 8.0 + intelligence * 1.5
	_mana_regen = 2.0 + intelligence * 0.5
	_hp_regen = vitality * 0.02 + _hp_regen_add
	_speed = 2.75 + agility * 0.05
	_crit_chance = 0.05 + agility * 0.005
	_defense = vitality * 1.5
	_attack_speed = 3.0 + agility * 0.015 + _attack_speed_mod
	if hp > _max_hp: hp = _max_hp
	if mana > _max_mana: mana = _max_mana
	hp_changed.emit(hp, _max_hp)
	mana_changed.emit(mana, _max_mana)

@export var hp: float = 110.0:
	set(value):
		hp = clampf(value, 0.0, _max_hp if _max_hp > 0 else 110.0)
		hp_changed.emit(hp, _max_hp if _max_hp > 0 else 110.0)
		if hp <= 0.0:
			died.emit()

@export var mana: float = 30.0:
	set(value):
		mana = clampf(value, 0.0, _max_mana if _max_mana > 0 else 30.0)
		mana_changed.emit(mana, _max_mana if _max_mana > 0 else 30.0)

@export var level: int = 1:
	set(value):
		level = value
		level_changed.emit(level)

@export var xp: float = 0.0
@export var xp_to_next: float = 50.0
@export var points_per_level: int = 3
@export var unspent_points: int = 0

func get_max_hp() -> float: _update_derived() if _max_hp == 0.0 else null; return _max_hp
func get_max_mana() -> float: _update_derived() if _max_mana == 0.0 else null; return _max_mana
func get_melee_damage() -> float: _update_derived() if _dmg_min == 0.0 else null; return (_dmg_min + _dmg_max) / 2.0
func get_melee_damage_min() -> float: _update_derived() if _dmg_min == 0.0 else null; return _dmg_min
func get_melee_damage_max() -> float: _update_derived() if _dmg_max == 0.0 else null; return _dmg_max
func get_spell_damage() -> float: _update_derived() if _spell_damage == 0.0 else null; return _spell_damage
func get_mana_regen() -> float: _update_derived() if _mana_regen == 0.0 else null; return _mana_regen
func get_hp_regen() -> float: _update_derived() if _hp_regen == 0.0 and _hp_regen_add == 0.0 else null; return _hp_regen
func get_speed() -> float: _update_derived() if _speed == 0.0 else null; return _speed
func get_crit_chance() -> float: _update_derived() if _crit_chance == 0.0 else null; return _crit_chance
func get_defense() -> float: _update_derived() if _defense == 0.0 else null; return _defense
func get_attack_speed() -> float: return _attack_speed if _attack_speed > 0 else 1.0

func set_item_melee_damage(min_val: float, max_val: float, s_min: float = 0.15, s_max: float = 0.3) -> void:
	_item_dmg_min = min_val
	_item_dmg_max = max_val
	_item_str_scale_min = s_min
	_item_str_scale_max = s_max
	_update_derived()

func set_attack_speed_mod(val: float) -> void:
	_attack_speed_mod = val
	_update_derived()

func set_hp_regen_add(val: float) -> void:
	_hp_regen_add = val
	_update_derived()

func get_max_hp_cached() -> float: return _max_hp if _max_hp > 0 else 80.0
func get_max_mana_cached() -> float: return _max_mana if _max_mana > 0 else 30.0

func take_damage(amount: float) -> void:
	var reduced := maxf(amount - get_defense(), 1.0)
	hp -= reduced

func heal(amount: float) -> void:
	hp += amount

func spend_mana(amount: float) -> bool:
	if mana >= amount:
		mana -= amount
		return true
	return false

func regen_mana(delta: float) -> void:
	if mana < get_max_mana():
		mana += get_mana_regen() * delta

func regen_hp(delta: float) -> void:
	if hp < get_max_hp():
		hp += get_hp_regen() * delta

func add_xp(amount: float) -> bool:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		unspent_points += points_per_level
		xp_to_next = 50.0 * level
		hp = get_max_hp()
		mana = get_max_mana()
		xp_changed.emit(xp, xp_to_next)
		AudioManager.play_sfx("levelup")
		return true
	xp_changed.emit(xp, xp_to_next)
	return false

func allocate_point(stat: String) -> bool:
	if unspent_points <= 0: return false
	match stat:
		"str": strength += 1
		"agi": agility += 1
		"int": intelligence += 1
		"vit": vitality += 1
		_: return false
	unspent_points -= 1
	_update_derived()
	return true

func reset() -> void:
	strength = 3; agility = 3; intelligence = 3; vitality = 3
	hp = 110.0; mana = 35.0
	xp = 0.0; level = 1; xp_to_next = 50.0; unspent_points = 0
	_update_derived()
