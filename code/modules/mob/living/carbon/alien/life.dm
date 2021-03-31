/mob/living/carbon/alien/Life(delta_time = SSMOBS_DT, times_fired)
	findQueen()
	return..()

/mob/living/carbon/alien/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return 0

	var/toxins_used = 0
	var/tox_detect_threshold = 0.02
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.return_temperature())/BREATH_VOLUME

	breath.assert_gases(/datum/gas/plasma, /datum/gas/oxygen)

	//Partial pressure of the toxins in our breath
	var/Toxins_pp = (breath.get_moles(/datum/gas/plasma)/breath.total_moles())*breath_pressure

	if(Toxins_pp > tox_detect_threshold) // Detect toxins in air
		adjustPlasma(breath.get_moles(/datum/gas/plasma)*250)
		throw_alert("alien_tox", /atom/movable/screen/alert/alien_tox)

		toxins_used = breath.get_moles(/datum/gas/plasma)

	else
		clear_alert("alien_tox")

	//Breathe in toxins and out oxygen
	breath.adjust_moles(/datum/gas/plasma, -toxins_used)
	breath.adjust_moles(/datum/gas/oxygen, toxins_used)

	breath.garbage_collect()

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

/mob/living/carbon/alien/handle_status_effects(delta_time, times_fired)
	..()
	//natural reduction of movement delay due to stun.
	if(move_delay_add > 0)
		move_delay_add = max(0, move_delay_add - (0.5 * rand(1, 2) * delta_time))

/mob/living/carbon/alien/handle_changeling()
	return

/mob/living/carbon/alien/handle_fire(delta_time, times_fired)//Aliens on fire code
	. = ..()
	if(.) //if the mob isn't on fire anymore
		return
	adjust_bodytemperature(BODYTEMP_HEATING_MAX * 0.5 * delta_time) //If you're on fire, you heat up!
