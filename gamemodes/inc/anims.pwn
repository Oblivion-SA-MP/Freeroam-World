CMD:anims(playerid, params[])
{
	
    new animstring[800];
    strcat(animstring, ""text_yellow"All animations are listed below:\n");
    strcat(animstring, ""text_white"/piss - /wank - /dance - /vomit\n/drunk - /sit - /wave - /lay - /smoke - /crossarms\n/rob - /cigar - /laugh - /handsup - /fucku - /carry\n\n");
	strcat(animstring, ""text_yellow"To stop an animation:");
	strcat(animstring, "\n"text_white"Type: /stopanim or Press F");

	ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""SERVER_TAG" Animations", animstring, "OK", "");
	return 1;
}


CMD:handsup(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
	SetPVarInt(playerid, "PlayerUseAnim", 1);
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_HANDSUP);
	return 1;
}

CMD:cigar(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    SetPVarInt(playerid, "PlayerUseAnim", 1);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
	return 1;
}

CMD:carry(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    SetPVarInt(playerid, "PlayerUseAnim", 1);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	return 1;
}

CMD:piss(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    SetPVarInt(playerid, "PlayerUseAnim", 1);
    ApplyAnimation(playerid, "PAULNMAC", "Piss_loop", 4.1, 1, 0, 0, 0, 0);
    SetPlayerSpecialAction(playerid, 68);
	return 1;
}

CMD:wank(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    SetPVarInt(playerid, "PlayerUseAnim", 1);
    ApplyAnimation(playerid, "PAULNMAC", "wank_loop", 4.1, 1, 0, 0, 0, 0);
	return 1;
}

CMD:crossarms(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    new crossarms;
	if(sscanf(params, "i", crossarms))
	{
	    return SCM(playerid, msg_yellow, "Usage: /crossarms <1-2>");
	}

    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    SetPVarInt(playerid, "PlayerUseAnim", 1);

	switch(crossarms)
	{
		case 1: ApplyAnimation(playerid, "CRACK", "Bbalbat_Idle_01", 4.0, 1, 0, 0, 0, 0);
		case 2: ApplyAnimation(playerid, "CRACK", "Bbalbat_Idle_02", 4.0, 1, 0, 0, 0, 0);
		default: SCM(playerid, msg_yellow, "Usage: /crossarms <1-2>");
 	}
	return 1;
}

CMD:sit(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    new sit;
    if(sscanf(params, "i", sit))
    {
        return SCM(playerid, msg_yellow, "Usage: /sit <1-6>");
    }

    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    SetPVarInt(playerid, "PlayerUseAnim", 1);

	switch(sit)
	{
  		case 1: ApplyAnimation(playerid, "BEACH", "bather", 4.0, 1, 0, 0, 0, 0);
  		case 2: ApplyAnimation(playerid, "BEACH", "Lay_Bac_Loop", 4.0, 1, 0, 0, 0, 0);
  		case 3: ApplyAnimation(playerid, "BEACH", "ParkSit_W_loop", 4.0, 1, 0, 0, 0, 0);
		case 4: ApplyAnimation(playerid, "BEACH", "SitnWait_loop_W", 4.0, 1, 0, 0, 0, 0);
  		case 5: ApplyAnimation(playerid, "BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0);
  		case 6: ApplyAnimation(playerid, "PED", "SEAT_down", 4.0, 0, 1, 1, 1, 0);
  		default: SCM(playerid, msg_yellow, "Usage: /sit <1-6>");
 	}
	return 1;
}

CMD:dance(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    new dance;
    if(sscanf(params, "i", dance))
    {
        return SCM(playerid, msg_yellow, "Usage: /dance <1-5>");
    }

    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    
  	if(dance == 1)
  	{
  	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE1);
  	}
  	else if(dance == 2)
  	{
  	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE2);
  	}
  	else if(dance == 3)
  	{
  	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE3);
  	}
  	else if(dance == 4)
  	{
  	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE4);
  	}
  	else if(dance == 5)
  	{
		ApplyAnimation(playerid, "DANCING", "DNCE_M_A", 4.1, 1, 0, 0, 0, 0);
  	}
  	else
  	{
  	    SCM(playerid, msg_yellow, "Usage: /dance <1-5>");
  	}
  	SetPVarInt(playerid, "PlayerUseAnim", 1);
	return 1;
}

CMD:vomit(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    
    ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 4.1, 1, 0, 0, 0, 0);
    SetPVarInt(playerid, "PlayerUseAnim", 1);
	return 1;
}

CMD:drunk(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");

    ApplyAnimation(playerid, "PED", "WALK_DRUNK", 4.1, 1, 0, 0, 0, 0);
    SetPVarInt(playerid, "PlayerUseAnim", 1);
	return 1;
}

CMD:wave(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    
    ApplyAnimation(playerid, "ON_LOOKERS", "wave_loop", 4.1, 1, 0, 0, 0, 0);
    SetPVarInt(playerid, "PlayerUseAnim", 1);
	return 1;
}

CMD:lay(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    
    ApplyAnimation(playerid, "BEACH", "Lay_Bac_Loop", 4.1, 1, 0, 0, 0, 0);
    SetPVarInt(playerid, "PlayerUseAnim", 1);
	return 1;
}

CMD:smoke(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");
    
    ApplyAnimation(playerid, "SHOP", "Smoke_RYD", 4.1, 1, 0, 0, 0, 0);
    SetPVarInt(playerid, "PlayerUseAnim", 1);
	return 1;
}

CMD:laugh(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");

    ApplyAnimation(playerid, "RAPPING", "Laugh_01", 4.1, 1, 0, 0, 0, 0);
    SetPVarInt(playerid, "PlayerUseAnim", 1);
	return 1;
}

CMD:fucku(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    if(IsPlayerInAnyVehicle(playerid))
    {
      SCM(playerid, msg_red, "ERROR: You can't perform animations in your vehicle.");
      return true;
    }
    cmd_stopanims(playerid);
    SendPlayerTextNotice(playerid, "~w~Type ~y~/stopanim ~w~to quit", "");

    ApplyAnimation(playerid, "PED", "fucku", 4.1, 1, 0, 0, 0, 0);
    SetPVarInt(playerid, "PlayerUseAnim", 1);
	return 1;
}
CMD:stopanim(playerid) return cmd_stopanims(playerid);
CMD:stopanims(playerid)
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
    
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    ClearAnimations(playerid);
    DeletePVar(playerid, "PlayerUseAnim");
	return 1;
}
