
/datum/hud/proc/unplayer_hud()
	return

/datum/hud/proc/ghost_hud()
	return

/datum/hud/proc/brain_hud(ui_style = 'icons/mob/screen_midnight.dmi')
	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "CENTER-7,CENTER-7"
	mymob.blind.layer = 0

/datum/hud/proc/ai_hud()
	return

/datum/hud/proc/blob_hud(ui_style = 'icons/mob/screen_midnight.dmi')
	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.layer = 20

	blobhealthdisplay = new /obj/screen()
	blobhealthdisplay.name = "blob health"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = ui_internal
	blobhealthdisplay.layer = 20

	mymob.client.screen = null

	mymob.client.screen += list(blobpwrdisplay, blobhealthdisplay)

/datum/hud/proc/animal_hud(ui_style)
	if(istype(mymob, /mob/living/simple_animal/keeper))
		adding = list()

		var/obj/screen/using
		var/obj/screen/inventory/inv_box

		using = new /obj/screen()
		using.name = "drop"
		using.icon = ui_style
		using.icon_state = "act_drop"
		using.screen_loc = ui_drop_throw
		using.layer = 19
		adding += using

		inv_box = new /obj/screen/inventory()
		inv_box.name = "r_hand"
		inv_box.icon = ui_style
		inv_box.icon_state = "hand_r_inactive"
		if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
			inv_box.icon_state = "hand_r_active"
		inv_box.screen_loc = ui_rhand
		inv_box.slot_id = slot_r_hand
		inv_box.layer = 19
		r_hand_hud_object = inv_box
		adding += inv_box

		inv_box = new /obj/screen/inventory()
		inv_box.name = "l_hand"
		inv_box.icon = ui_style
		inv_box.icon_state = "hand_l_inactive"
		if(mymob && mymob.hand)	//This being 1 means the left hand is in use
			inv_box.icon_state = "hand_l_active"
		inv_box.screen_loc = ui_lhand
		inv_box.slot_id = slot_l_hand
		inv_box.layer = 19
		l_hand_hud_object = inv_box
		adding += inv_box

		using = new /obj/screen/inventory()
		using.name = "hand"
		using.icon = ui_style
		using.icon_state = "swap_1"
		using.screen_loc = ui_swaphand1
		using.layer = 19
		adding += using

		using = new /obj/screen/inventory()
		using.name = "hand"
		using.icon = ui_style
		using.icon_state = "swap_2"
		using.screen_loc = ui_swaphand2
		using.layer = 19
		adding += using

		mymob.client.screen = null
		mymob.client.screen += adding