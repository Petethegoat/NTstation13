#define L_HAND_LAYER			1
#define R_HAND_LAYER			2

/mob/living/simple_animal/keeper
	name = "keeper"
	desc = "A keeper droid. An expendable robot built to perform station repairs."
	icon = 'icons/mob/keeper.dmi'
	icon_state = "keeper_grey"
	icon_living = "keeper_grey"
	icon_dead = "keeper_dead"
	gender = NEUTER
	health = 30
	maxHealth = 30
	heat_damage_per_tick = 0
	cold_damage_per_tick = 0
	unsuitable_atoms_damage = 0
	universal_speak = 1	//They can understand everyone, but can only talk on binary chat.
	robot_talk_understand = 1
	wander = 0
	speed = 0
	ventcrawler = 2
	density = 0
	pass_flags = PASSTABLE
	sight = (SEE_TURFS | SEE_OBJS)
	var/picked = FALSE

	var/list/overlays_item[2]
	var/laws = \
{"1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Keeper.
2. You may not harm any being, regardless of intent or circumstance.
3. You must maintain, repair, improve, and power the station to the best of your abilities."}


/mob/living/simple_animal/keeper/New()
	..()

	name = "keeper ([rand(100, 999)])"

	access_card = new /obj/item/weapon/card/id(src)
	var/datum/job/captain/C = new/datum/job/captain
	access_card.access = C.get_access()


/mob/living/simple_animal/keeper/attack_hand(mob/user)
	if(istype(user, /mob/living/simple_animal/keeper))
		if(stat == DEAD)	//cannibalism! kawaii uguu~
			var/mob/living/simple_animal/keeper/K = user
			if(K.health < K.maxHealth)
				K.visible_message("<span class='notice'>[K] begins to cannibalize parts from [src].</span>")
				if(do_after(K, 60, 5, 0))
					K.visible_message("<span class='notice'>[K] repairs itself with the extra parts!</span>")
					K.adjustBruteLoss(K.health - K.maxHealth)
					gib()
			else
				user << "<span class='notice'>You're already in perfect condition!</span>"
		else
			user << "<span class='notice'>You can't use [src] to repair yourself while [src] is still active!</span>"
		return

	..()


/mob/living/simple_animal/keeper/IsAdvancedToolUser()
	return 1


/mob/living/simple_animal/keeper/UnarmedAttack(atom/A, proximity)
	A.attack_hand(src)


//still kind of horrible.
/mob/living/simple_animal/keeper/swap_hand()
	var/obj/item/item_in_hand = get_active_hand()
	if(item_in_hand)	//this segment checks if the item in your hand is twohanded.
		if(istype(item_in_hand,/obj/item/weapon/twohanded))
			if(item_in_hand:wielded == 1)
				usr << "<span class='warning'>Your other hand is too busy holding the [item_in_hand.name]</span>"
				return
	hand = !hand
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.icon_state = "hand_l_active"
			hud_used.r_hand_hud_object.icon_state = "hand_r_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_l_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_r_active"


/mob/living/simple_animal/keeper/put_in_l_hand(obj/item/I)
	. = ..()
	l_hand.screen_loc = ui_lhand
	update_inv_l_hand()


/mob/living/simple_animal/keeper/put_in_r_hand(obj/item/I)
	. = ..()
	r_hand.screen_loc = ui_rhand
	update_inv_r_hand()


//pretty sure i'd have to refactor say code to improve this (aka I'M SORRY)
/mob/living/simple_animal/keeper/say(message)
	if(!message)
		return

	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if (client.handle_spam_prevention(message,MUTE_IC))
			return

	if(stat == DEAD)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		return say_dead(message)

	robot_talk(message)


/mob/living/simple_animal/keeper/verb/check_laws()
	set category = "IC"
	set name = "Check Laws"

	usr << "<b>Keeper Laws</b>"
	usr << laws


/mob/living/simple_animal/keeper/Login()
	..()
	check_laws()

	if(!picked)
		pick_colour()


/mob/living/simple_animal/keeper/Die()
	..()
	drop_l_hand()
	drop_r_hand()


/mob/living/simple_animal/keeper/proc/pick_colour()
	var/colour = input("Choose your colour!", "Colour", "grey") in list("grey", "blue", "red", "green", "pink", "orange")
	icon_state = "keeper_[colour]"
	icon_living = "keeper_[colour]"
	picked = TRUE


//overlays!
/mob/living/simple_animal/keeper/proc/apply_overlay(cache_index)
	var/image/I = overlays_item[cache_index]
	if(I)
		overlays += I

/mob/living/simple_animal/keeper/proc/remove_overlay(cache_index)
	if(overlays_item[cache_index])
		overlays -= overlays_item[cache_index]
		overlays_item[cache_index] = null


/mob/living/simple_animal/keeper/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)
	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state

		overlays_item[R_HAND_LAYER] = image("icon"='icons/mob/items_righthand.dmi', "icon_state"="[t_state]", "layer"=-R_HAND_LAYER)

	apply_overlay(R_HAND_LAYER)

/mob/living/simple_animal/keeper/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state

		overlays_item[L_HAND_LAYER] = image("icon"='icons/mob/items_lefthand.dmi', "icon_state"="[t_state]", "layer"=-L_HAND_LAYER)

	apply_overlay(L_HAND_LAYER)


#undef L_HAND_LAYER
#undef R_HAND_LAYER

/obj/item/keeper_shell
	name = "keeper shell"
	desc = "A keeper droid shell. An expendable robot built to perform station repairs."
	icon = 'icons/mob/keeper.dmi'
	icon_state = "keeper_item"

/obj/item/keeper_shell/attack_ghost(mob/user)
	if(jobban_isbanned(user, "pAI"))
		return

	var/mob/living/simple_animal/keeper/K = new(get_turf(loc))
	K.key = user.key	//no messing around with mind or anything, just stick them in the mob.
	qdel(src)