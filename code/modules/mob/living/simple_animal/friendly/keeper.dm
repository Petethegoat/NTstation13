#define L_HAND_LAYER			1
#define R_HAND_LAYER			2

/mob/living/simple_animal/keeper
	name = "keeper"
	desc = "A keeper droid. An expendable robot built to perform station repairs."
	icon = 'icons/mob/keeper.dmi'
	icon_state = "keeper_f"
	icon_living = "keeper_f"
	icon_dead = "keeper_d"
	gender = NEUTER
	health = 30
	maxHealth = 30
	universal_speak = 0
	robot_talk_understand = 1
	wander = 0
	speed = 0
	ventcrawler = 2
	density = 0
	var/list/overlays_item[2]


/mob/living/simple_animal/keeper/New()
	..()

	name = "keeper ([rand(100, 999)])"

	access_card = new /obj/item/weapon/card/id(src)
	var/datum/job/captain/C = new/datum/job/captain
	access_card.access = C.get_access()


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
	usr << "1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Keeper."
	usr << "2. You may not harm any being, regardless of intent or circumstance."
	usr << "3. You must maintain, repair, improve, and power the station to the best of your abilities."


/mob/living/simple_animal/keeper/Login()
	..()
	check_laws()


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
		if(client)
			client.screen += r_hand

		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state

		overlays_item[R_HAND_LAYER] = image("icon"='icons/mob/items_righthand.dmi', "icon_state"="[t_state]", "layer"=-R_HAND_LAYER)

	apply_overlay(R_HAND_LAYER)

/mob/living/simple_animal/keeper/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	if(l_hand)
		if(client)
			client.screen += l_hand

		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state

		overlays_item[L_HAND_LAYER] = image("icon"='icons/mob/items_lefthand.dmi', "icon_state"="[t_state]", "layer"=-L_HAND_LAYER)

	apply_overlay(L_HAND_LAYER)

#undef L_HAND_LAYER
#undef R_HAND_LAYER