tool
extends "res://mods/Lure/classes/lure_content.gd"

var name: String = "Cosmetic Name"
var category: String = ""
var desc: String = "Cosmetic Description"
var title: String = ""
var icon: Texture = StreamTexture.new()
var main_color: Color = Color(1.0, 1.0, 1.0, 1.0)

var mesh: Mesh
var species_alt_mesh: Array
var extended_alt_mesh: Array = [
	SpeciesAltMesh.new("body"),
	SpeciesAltMesh.new("species_cat"),
	SpeciesAltMesh.new("species_dog")
] setget _set_alt_mesh_resource
var mesh_skin: Skin
var material: Material
var secondary_material: Material
var third_material: Material

var scene_replace: PackedScene

var body_pattern := [null, null, null]
var extended_body_patterns: Array = [
	BodyPattern.new("body"),
	BodyPattern.new("species_cat"),
	BodyPattern.new("species_dog")
] setget _set_pattern_resource

var mirror_face: bool = true
var flip: bool = false
var allow_blink: bool = true
var alt_eye: Texture
var alt_blink: Texture

var cos_internal_id: int = 0
var dynamic_species_id:int
var dynamic_body_pattern_id:int

var in_rotation = false
var chest_reward = false
var cost = 10


class SpeciesAltMesh extends Resource:
	export (String) var species
	export (Mesh) var mesh
	
	func _init(init_species: String = "", init_mesh: Mesh = Mesh.new()) -> void:
		resource_name = "Alt Mesh"
		species = init_species
		mesh = init_mesh


class BodyPattern extends Resource:
	export (String) var species
	export (Texture) var pattern
	
	func _init(init_species: String = "", init_pattern: Texture = ImageTexture.new()) -> void:
		resource_name = "Body Pattern"
		species = init_species
		pattern = init_pattern


func _get_property_list() -> Array:
	var export_properties = [{
		# Lure cosmetic metadata
		name = "Metadata",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "name",
		type = TYPE_STRING,
	}, {
		name = "category",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "species,primary_color,secondary_color,eye,nose,mouth,hat,undershirt,overshirt,accessory,bobber,pattern,title,tail,legs",
	}, {
		name = "title",
		type = TYPE_STRING,
	}, {
		name = "desc",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_MULTILINE_TEXT,
	}, {
		name = "icon",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Texture",
	}, {
		name = "main_color",
		type = TYPE_COLOR,
	}, {
		# Lure scene data
		name = "PackedScene",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "scene_replace",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "PackedScene"
	}, {
		# Lure cosmetic mesh data
		name = "Mesh",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "mesh",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Mesh",
	}, {
		name = "extended_alt_mesh",
		type = TYPE_ARRAY,
		hint = PROPERTY_HINT_TYPE_STRING,
		hint_string = "%s:Resource" % [TYPE_OBJECT],
	}, {
		name = "mesh_skin",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Skin",
	}, {
		name = "material",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Material",
	}, {
		name = "secondary_material",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Material",
	}, {
		name = "third_material",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Material",
	}, {
		# Lure cosmetic pattern data
		name = "Patterns",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "extended_body_patterns",
		type = TYPE_ARRAY,
		hint = PROPERTY_HINT_TYPE_STRING,
		hint_string = "%s:Resource" % [TYPE_OBJECT],
	}, {
		# Lure cosmetic face data
		name = "Face",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "mirror_face",
		type = TYPE_BOOL,
	}, {
		name = "flip",
		type = TYPE_BOOL,
	}, {
		name = "allow_blink",
		type = TYPE_BOOL,
	}, {
		name = "alt_eye",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Texture",
	}, {
		name = "alt_blink",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Texture",
	}, {
		# Lure cosmetic acquisition data
		name = "Acquisition",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "in_rotation",
		type = TYPE_BOOL,
	}, {
		name = "chest_reward",
		type = TYPE_BOOL,
	}, {
		name = "cost",
		type = TYPE_INT
	}]
	
	return export_properties


func _set_alt_mesh_resource(value) -> void:
	extended_alt_mesh = value
	
	for i in extended_alt_mesh.size():
		if not extended_alt_mesh[i]:
			extended_alt_mesh[i] = SpeciesAltMesh.new()


func _set_pattern_resource(value) -> void:
	extended_body_patterns = value
	
	for i in extended_body_patterns.size():
		if not extended_body_patterns[i]:
			extended_body_patterns[i] = BodyPattern.new()
