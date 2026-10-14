extends RefCounted
## Dados das experiências José no Egito, A travessia do mar, Rute em Belém e
## Os pastores de Belém: disponíveis, encadeadas, com cenas válidas e alvos
## existentes. Chamado por tests/test_runner.gd, que fornece check().
## Checagens marcadas "[região]" dependem de data/regions (mapas da etapa de arte).

const CHAIN := {
	"joseph_egypt": "joseph_dothan_road",
	"exodus_sea": "joseph_potiphar_house",
	"ruth_bethlehem": "exodus_sea_crossing",
	"shepherds_bethlehem": "ruth_gleaning",
}
const QUESTS := {
	"joseph_egypt": ["joseph_caravan_watch", "joseph_potiphar_house", "egypt_granary_sacks", "egypt_house_life"],
	"exodus_sea": ["exodus_sea_crossing", "sea_camp_flock", "sea_camp_water"],
	"ruth_bethlehem": ["ruth_gleaning", "tova_gleaning", "bethlehem_harvest_signs"],
	"shepherds_bethlehem": ["shepherds_night", "bn_fold_round", "bethlehem_night_signs"],
}
const SCENES := ["joseph_caravan_departs", "exodus_sea_crossing", "ruth_gleaning_meal", "shepherds_announcement", "shepherds_at_the_house"]

var r: Node


func _init(runner: Node) -> void:
	r = runner


func check(cond: bool, label: String) -> void:
	r.check(cond, label)


func test_experiences_available_and_chained() -> void:
	GameState.new_game()
	for xid in CHAIN:
		var x := WorldManager.experience(xid)
		check(String(x.get("status", "")) == "available", "%s: status available" % xid)
		check(x.get("requires") == {"quest_completed": CHAIN[xid]}, "%s: requer %s" % [xid, CHAIN[xid]])
		check(QuestManager.db.quests.has(String(CHAIN[xid])), "%s: missão exigida %s existe" % [xid, CHAIN[xid]])
		var done := String(x.get("completed_by", ""))
		check(done in QUESTS[xid] and QuestManager.db.quests.has(done), "%s: concluída por %s" % [xid, done])
		check(x.get("passage") is Dictionary and WorldSchema.validate_passage(xid, x.passage).is_empty(), "%s: cartão de passagem válido" % xid)
		check(WorldManager.experience_state(xid) == "locked", "%s: bloqueada num jogo novo" % xid)
		check(WorldManager.start_experience(xid) != "", "%s: bloqueada não inicia" % xid)
	var x9 := WorldManager.experience("joseph_egypt")
	check(x9.get("stages", []).size() == 2 and String(x9.stages[1].get("travel", {}).get("region", "")) == "egypt_house", "José no Egito: segunda etapa leva à casa egípcia")
	var x16 := WorldManager.experience("exodus_sea")
	check(String(x16.travel.entry_if[0].entry) == "far_shore_dawn", "Travessia do mar: depois da cena, volta pela outra margem")
	var labels := []
	for era in WorldManager.eras_order:
		labels.append(String(era.label))
	check(not labels.has("Século I") and labels.has("Nos dias de Herodes"), "época do Novo Testamento sem rótulo \"Século I\" %s" % [labels])
	GameState.new_game()


func test_quests_and_links() -> void:
	var catalog: BibleCatalog = Bible.catalog
	for xid in QUESTS:
		for qid in QUESTS[xid]:
			check(QuestManager.db.quests.has(qid), "missão %s carregada" % qid)
			var q := QuestManager.db.get_quest(qid)
			if q.is_empty():
				continue
			check(String(q.get("verification", {}).get("status", "")) == "pending_review", "%s: verificação pending_review" % qid)
			for o in q.objectives:
				for t in o.targets:
					match String(t.type):
						"npc":
							check(GameData.characters.has(String(t.id)), "%s/%s: alvo npc '%s' é um personagem" % [qid, o.id, t.id])
						"scene":
							check(SceneDatabase.ids_in().has(String(t.id)), "%s/%s: alvo de cena '%s' existe" % [qid, o.id, t.id])
				var ev: Dictionary = o.complete_on
				if String(ev.event) == "scene_finished":
					check(SceneDatabase.ids_in().has(String(ev.id)), "%s/%s: cena %s existe" % [qid, o.id, ev.id])
				if String(ev.event) == "presentation_finished":
					check(catalog.presentations.has(String(ev.id)), "%s/%s: apresentação %s existe" % [qid, o.id, ev.id])
				if String(ev.event) in ["inventory", "item_delivered", "item_received"]:
					check(not Inventory.item(String(ev.id)).is_empty(), "%s/%s: item %s existe" % [qid, o.id, ev.id])
			for d in q.get("discoveries", []):
				check(catalog.discoveries.has(d), "%s: descoberta %s existe" % [qid, d])
	for sid in ["gen_039_joseph_potiphar", "ruth_002_gleaning", "luke_002_shepherds"]:
		check(catalog.stories.has(sid), "história %s existe" % sid)


func test_scenes() -> void:
	var db := SceneDatabase.new()
	db.load_dir()
	var catalog: BibleCatalog = Bible.catalog
	var sounds := SceneDatabase.manifest_sounds()
	for sid in SCENES:
		check(db.has_scene(sid), "cena %s carregada" % sid)
		if not db.has_scene(sid):
			continue
		var s: Dictionary = db.get_scene(sid)
		check(SceneDatabase.validate(s).is_empty(), "cena %s: formato válido %s" % [sid, SceneDatabase.validate(s)])
		check(String(s.verification.get("status", "")) == "pending_review", "cena %s: verificação pending_review" % sid)
		var links := SceneDatabase.validate_links(s, catalog, GameData.characters, {String(s.region): {}}, sounds)
		check(links.is_empty(), "cena %s: legendas, figurantes, sons e descobertas válidos %s" % [sid, links])
		check(GameData.regions.has(String(s.region)), "[região] cena %s: região %s existe" % [sid, s.region])


## Examináveis, áreas e pickups citados nos objetivos precisam estar declarados em data/regions.
func test_region_targets() -> void:
	for xid in QUESTS:
		for qid in QUESTS[xid]:
			var q := QuestManager.db.get_quest(qid)
			if q.is_empty():
				continue
			for o in q.objectives:
				for t in o.targets:
					var kind := String(t.type)
					if not (kind in ["examinable", "area", "pickup"]):
						continue
					var rid := String(t.get("region", o.get("region", q.region)))
					if rid == "":
						rid = String(q.region)
					var list_key: String = {"examinable": "examinables", "area": "areas", "pickup": "pickups"}[kind]
					var ok := false
					for e in GameData.get_region(rid).get(list_key, []):
						if String(e.get("id", "")) == String(t.id):
							ok = true
					check(ok, "[região] %s/%s: %s '%s' declarado em %s" % [qid, o.id, kind, t.id, rid])
