/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Glass shards - TODO: Move this into code/game/object/item/weapons
 */

/*
 * Glass sheets
 */
/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	g_amt = 3750
	origin_tech = "materials=1"
	var/created_window = /obj/structure/window/basic	//What do we grow up to be?


/obj/item/stack/sheet/glass/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user)
	..()
	add_fingerprint(user)
	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(CC.amount < 5)
			user << "\b There is not enough wire in this coil. You need 5 lengths."
			return
		CC.use(5)
		user << "\blue You attach wire to the [name]."
		var/obj/item/stack/light_w/new_tile = new(user.loc)
		new_tile.add_fingerprint(user)
		src.use(1)
	else if( istype(W, /obj/item/stack/rods) )
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/rglass/RG = new (user.loc)
		RG.add_fingerprint(user)
		RG.add_to_stacks(user)
		V.use(1)
		var/obj/item/stack/sheet/glass/G = src
		src = null
		var/replace = (user.get_inactive_hand()==G)
		G.use(1)
		if (!G && !RG && replace)
			user.put_in_hands(RG)
	else
		return ..()

/obj/item/stack/sheet/glass/proc/construct_window(mob/user as mob)
	if(!user || !src)	return 0
	if(!istype(user.loc,/turf)) return 0
	if(!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return 0
	var/title = "Sheet-[src]"
	title += " ([src.amount] sheet\s left)"
	switch(alert(title, "Would you like full tile glass or one direction?", "One Direction", "Full Window", "Cancel", null))
		if("One Direction")
			if(!src)	return 1
			if(src.loc != user)	return 1

			var/list/directions = new/list(cardinal)
			var/i = 0
			for (var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					user << "\red There are too many windows in this location."
					return 1
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					user << "\red Can't let you do that."
					return 1

			//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
			var/dir_to_set = 2
			for(var/direction in list( user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
				var/found = 0
				for(var/obj/structure/window/WT in user.loc)
					if(WT.dir == direction)
						found = 1
				if(!found)
					dir_to_set = direction
					break

			var/obj/structure/window/W
			W = new created_window( user.loc, 0 )
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.anchored = 0
			W.air_update_turf(1)
			src.use(1)
			W.add_fingerprint(user)
		if("Full Window")
			if(!src)	return 1
			if(src.loc != user)	return 1
			if(src.amount < 2)
				user << "\red You need more glass to do that."
				return 1
			if(locate(/obj/structure/window) in user.loc)
				user << "\red There is a window in the way."
				return 1
			var/obj/structure/window/W
			W = new created_window( user.loc, 0 )
			W.dir = SOUTHWEST
			W.ini_dir = SOUTHWEST
			W.anchored = 0
			W.air_update_turf(1)
			W.add_fingerprint(user)
			src.use(2)
	return 0


/*
 * Reinforced glass sheets
 */
/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	g_amt = 3750
	m_amt = 1875
	origin_tech = "materials=2"
	var/created_window = /obj/structure/window/reinforced

/obj/item/stack/sheet/rglass/cyborg
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	g_amt = 0
	m_amt = 0

/obj/item/stack/sheet/rglass/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/rglass/proc/construct_window(mob/user as mob)
	if(!user || !src)	return 0
	if(!istype(user.loc,/turf)) return 0
	if(!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return 0
	var/title = "Sheet-[src]"
	title += " ([src.amount] sheet\s left)"
	switch(input(title, "Would you like full tile glass a one direction glass pane or a windoor?") in list("One Direction", "Full Window", "Windoor", "Cancel"))
		if("One Direction")
			if(!src)	return 1
			if(src.loc != user)	return 1
			var/list/directions = new/list(cardinal)
			var/i = 0
			for (var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					user << "\red There are too many windows in this location."
					return 1
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					user << "\red Can't let you do that."
					return 1

			//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
			var/dir_to_set = 2
			for(var/direction in list( user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
				var/found = 0
				for(var/obj/structure/window/WT in user.loc)
					if(WT.dir == direction)
						found = 1
				if(!found)
					dir_to_set = direction
					break

			var/obj/structure/window/W
			W = new created_window( user.loc, 1 )
			W.state = 0
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.anchored = 0
			W.add_fingerprint(user)
			src.use(1)

		if("Full Window")
			if(!src)	return 1
			if(src.loc != user)	return 1
			if(src.amount < 2)
				user << "<span class='warning'>You need more glass to do that.</span>"
				return 1
			if(locate(/obj/structure/window) in user.loc)
				user << "<span class='warning'>There is a window in the way.</span>"
				return 1
			var/obj/structure/window/W
			W = new created_window(user.loc, 1)
			W.state = 0
			W.dir = SOUTHWEST
			W.ini_dir = SOUTHWEST
			W.anchored = 0
			W.add_fingerprint(user)
			src.use(2)

		if("Windoor")
			if(!src || src.loc != user) return 1

			if(isturf(user.loc) && locate(/obj/structure/windoor_assembly/, user.loc))
				user << "<span class='warning'>There is already a windoor assembly in that location.</span>"
				return 1

			if(isturf(user.loc) && locate(/obj/machinery/door/window/, user.loc))
				user << "<span class='warning'>There is already a windoor in that location.</span>"
				return 1

			if(src.amount < 5)
				user << "<span class='warning'>You need more glass to do that.</span>"
				return 1

			var/obj/structure/windoor_assembly/WD = new(user.loc)
			WD.state = "01"
			WD.anchored = 0
			WD.add_fingerprint(user)
			src.use(5)
			switch(user.dir)
				if(SOUTH)
					WD.dir = SOUTH
					WD.ini_dir = SOUTH
				if(EAST)
					WD.dir = EAST
					WD.ini_dir = EAST
				if(WEST)
					WD.dir = WEST
					WD.ini_dir = WEST
				else //If the user is facing northeast. northwest, southeast, southwest or north, default to north
					WD.dir = NORTH
					WD.ini_dir = NORTH
		else
			return 1


	return 0


/obj/item/weapon/shard
	name = "shard"
	desc = "A nasty looking shard of glass."
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = 1.0
	force = 5.0
	throwforce = 10.0
	item_state = "shard-glass"
	g_amt = 3750
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

	suicide_act(mob/user)
		viewers(user) << pick("<span class='suicide'>[user] is slitting \his wrists with the shard of glass! It looks like \he's trying to commit suicide.</span>", \
							"<span class='suicide'>[user] is slitting \his throat with the shard of glass! It looks like \he's trying to commit suicide.</span>")
		return (BRUTELOSS)


/obj/item/weapon/shard/New()
	icon_state = pick("glasslarge", "glassmedium", "glasssmall")
	switch(icon_state)
		if("glasssmall")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("glassmedium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("glasslarge")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)

/obj/item/weapon/shard/afterattack(atom/A as mob|obj, mob/user, proximity)
	if(!proximity || !(src in user)) return
	if(isturf(A))
		return
	if(istype(A, /obj/item/weapon/storage))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves)
			H << "<span class='warning'>[src] cuts into your hand!</span>"
			var/organ = (H.hand ? "l_" : "r_") + "arm"
			var/obj/item/organ/limb/affecting = H.get_organ(organ)
			if(affecting.take_damage(force / 2))
				H.update_damage_overlays(0)
	else if(isliving(user))
		var/mob/living/L = user
		L << "<span class='warning'>[src] cuts into your hand!</span>"
		L.adjustBruteLoss(force / 2)


/obj/item/weapon/shard/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			var/obj/item/stack/sheet/glass/NG = new (user.loc)
			for(var/obj/item/stack/sheet/glass/G in user.loc)
				if(G == NG)
					continue
				if(G.amount >= G.max_amount)
					continue
				G.attackby(NG, user)
				user << "<span class='notice'>You add the newly-formed glass to the stack. It now contains [NG.amount] sheet\s.</span>"
			qdel(src)
	..()

/obj/item/weapon/shard/Crossed(mob/AM)
	if(istype(AM))
		playsound(loc, 'sound/effects/glass_step.ogg', 50, 1)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(!H.shoes)
				H << "<span class='userdanger'>You step in the broken glass!</span>"
				H.apply_damage(5,BRUTE,(pick("l_leg", "r_leg")))
				H.Weaken(3)

/obj/item/weapon/shard/plasma
	name = "plasma shard"
	desc = "A shard of plasma. Don't step on this."
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = 1.0
	force = 8.0
	throwforce = 14.0
	item_state = "shard-glass"
	g_amt = 7500
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

	suicide_act(mob/user)
		viewers(user) << pick("<span class='suicide'>[user] is slitting \his feet with the plasma crystal! It looks like \he's trying to commit suicide.</span>", \
							"<span class='suicide'>[user] is chewing on the plasma crystal! It looks like \he's trying to commit suicide.</span>")
		return (BRUTELOSS)

/obj/item/weapon/shard/plasma/New()

	src.icon_state = pick("plasmalarge", "plasmamedium", "plasmasmall")
	switch(src.icon_state)
		if("plasmasmall")
			src.pixel_x = rand(-12, 12)
			src.pixel_y = rand(-12, 12)
		if("plasmamedium")
			src.pixel_x = rand(-8, 8)
			src.pixel_y = rand(-8, 8)
		if("plasmalarge")
			src.pixel_x = rand(-5, 5)
			src.pixel_y = rand(-5, 5)
		else
	return


/obj/item/weapon/shard/plasma/Crossed(var/mob/AM)
	if(istype(AM))
		playsound(loc, 'sound/effects/glass_step.ogg', 50, 1)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			H << "<span class='userdanger'>You step in the broken plasma shards!</span>"
			H.apply_damage(9,BRUTE,(pick("l_leg", "r_leg")))
			H.Weaken(6)

/*
 * Plasma Glass sheets
 */
/obj/item/stack/sheet/glass/plasmaglass
	name = "plasma glass"
	desc = "A very strong and very resistant sheet of a plasma-glass alloy."
	singular_name = "glass sheet"
	icon_state = "sheet-plasmaglass"
	g_amt = 7500
	origin_tech = "materials=3;plasmatech=2"
	created_window = /obj/structure/window/plasmabasic

/obj/item/stack/sheet/glass/plasmaglass/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/glass/plasmaglass/attackby(obj/item/W, mob/user)
	if( istype(W, /obj/item/stack/rods) )
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/glass/plasmarglass/RG = new (user.loc)
		RG.add_fingerprint(user)
		RG.add_to_stacks(user)
		V.use(1)
		var/obj/item/stack/sheet/glass/plasmaglass/G = src
		src = null
		var/replace = (user.get_inactive_hand()==G)
		G.use(1)
		if (!G && !RG && replace)
			user.put_in_hands(RG)
	else
		return ..()

/*
 * Reinforced plasma glass sheets
 */
/obj/item/stack/sheet/glass/plasmarglass
	name = "reinforced plasma glass"
	desc = "Plasma glass which seems to have rods or something stuck in them."
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-plasmarglass"
	g_amt = 7500
	m_amt = 1875
	origin_tech = "materials=4;plasmatech=2"
	created_window = /obj/structure/window/plasmareinforced

/obj/item/stack/sheet/glass/plasmarglass/attack_self(mob/user as mob)
	construct_window(user)
