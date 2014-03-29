/mob/living/simple_animal/keeper
	name = "keeper"
	desc = "A keeper droid. They're kawaii as fuck and they'll repair up your shit."
	icon = 'icons/mob/keeper.dmi'
	icon_state = "keeper"
	icon_living = "keeper"
	icon_dead = "keeper_dead"
	gender = NEUTER
	health = 30
	maxHealth = 30
	universal_speak = 0
	robot_talk_understand = 1
	wander = 0
	speed = 0
	ventcrawler = 2


/mob/living/simple_animal/keeper/New()
	..()

	name = "keeper ([rand(100, 999)])"

	access_card = new /obj/item/weapon/card/id(src)
	var/datum/job/captain/C = new/datum/job/captain
	access_card.access = C.get_access()


/mob/living/simple_animal/keeper/UnarmedAttack(atom/A, proximity)
	A.attack_hand(src)


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
	return


/mob/living/simple_animal/keeper/put_in_l_hand(obj/item/I)
	if(lying && !(I.flags & ABSTRACT))
		return 0
	if(!istype(I))
		return 0

	if(!l_hand)
		I.loc = src
		l_hand = I
		I.layer = 20
		l_hand.screen_loc = ui_lhand
		I.equipped(src, slot_l_hand)

		if(client)
			client.screen |= I
		if(pulling == I)
			stop_pulling()

		update_inv_l_hand(0)
		return 1
	return 0


/mob/living/simple_animal/keeper/put_in_r_hand(obj/item/I)
	if(lying && !(I.flags & ABSTRACT))
		return 0
	if(!istype(I))
		return 0

	if(!r_hand)
		I.loc = src
		r_hand = I
		I.layer = 20
		r_hand.screen_loc = ui_rhand
		I.equipped(src, slot_r_hand)

		if(client)
			client.screen |= I
		if(pulling == I)
			stop_pulling()

		update_inv_r_hand(0)
		return 1
	return 0


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