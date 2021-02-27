#include <YSI\y_hooks>

/* Creating a new skydive and adding a map.
   
   1. Add your map in inc/skydive_maps.pwn
   1.A - Add the SKydive ID in the enum LIke: SKYDIVE_3 etc..
   2.Add The Skydive Information int his pwn under SkydiveInfo
   3. Add the command in this pwn.

   4. To Add skydive cmd teleport.
       - Goto main.pwn Under TeleportNames Add the skydive teleport info.

*/
// Skydive
enum {

	SKYDIVE_1,
	SKYDIVE_2
};
enum SKEnum
{
    SKYDIVE_ID,
    SKYDIVE_NAME[20],
    SKYDIVE_CMD[10],
    Float:SKYDIVE_POSX,
    Float:SKYDIVE_POSY,
    Float:SKYDIVE_POSZ,
    Float:SKYDIVE_POSA,
    Float:SKYDIVE_CPX,
    Float:SKYDIVE_CPY,
    Float:SKYDIVE_CPZ,
    SKYDIVE_SCORE,
    SKYDIVE_CASH
};
static const SkydiveInfo[][SKEnum] =
{
	{SKYDIVE_1,  "Skydive 1", "skydive",  1850.0948, -134.4211,  2465.8916,  266.1203,  2003.9713, -151.0531, 706.3226,  10, 12000},
	{SKYDIVE_2,  "Skydive 2", "skydive2", -3775.1895, 1585.9076, 1642.9535,  187.7393, -3797.66675, 1473.41479, 7.68909, 25, 18000}
};

new SkydiveCP[sizeof(SkydiveInfo)];

hook OnGameModeInit()
{
    for(new sk = 0; sk < sizeof(SkydiveInfo); sk++)
	{
		SkydiveCP[sk] = CreateDynamicCP(SkydiveInfo[sk][SKYDIVE_CPX],SkydiveInfo[sk][SKYDIVE_CPY], SkydiveInfo[sk][SKYDIVE_CPZ], 15.0,  SKYDIVE_WORLD, -1, -1, 40.0);
	}
    return 1;
}

hook OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    if(PlayerInfo[playerid][Player_Mode] == MODE_SPEC) return true;
    
    switch(PlayerInfo[playerid][Player_Mode])
    {
           case MODE_SKYDIVE:
           {

	    	    new SkydivID = PlayerInfo[playerid][Player_LastSky];
                if(SkydiveCP[SkydivID] == checkpointid)
	    	 	{

		                if(GetPlayerWeapon(playerid) == 46)
		                {
		                        SendPlayerTextNotice(playerid, "~r~~h~Congrats!~n~~w~You finished the skydive challenge.", "");
		                        PlayerPlaySound(playerid, 1149,0,0,0);
		  
		                        format(MainStr, sizeof(MainStr), ""SERVER_TAG" {%06x}%s(%i) "text_green"has successfully completed /%s", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid ,SkydiveInfo[SkydivID][SKYDIVE_CMD]);
				                SCMToAll(-1, MainStr);
				                format(MainStr, sizeof(MainStr), ""text_yellow"-> You have earned score: %d and cash: %s", SkydiveInfo[SkydivID][SKYDIVE_SCORE], Currency(SkydiveInfo[SkydivID][SKYDIVE_CASH]));
				                SCMToAll(-1, MainStr);

		                        SendPlayerMoney(playerid, SkydiveInfo[SkydivID][SKYDIVE_CASH]);
		                        SendPlayerScore(playerid, SkydiveInfo[SkydivID][SKYDIVE_SCORE]);
		                        format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: ~g~+%i~n~  ~g~~h~Cash~w~: ~g~+$%s", SkydiveInfo[SkydivID][SKYDIVE_SCORE], Currency(SkydiveInfo[SkydivID][SKYDIVE_CASH]));
		                        PlayerPoints(playerid,MainStr);

		                        PlayerInfoTD(playerid, "~w~You have successfully completed the ~g~skydive ~w~challenge", 5500);

		                        //reset
		                        PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
					            SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
					            PlayerInfo[playerid][Player_LastSky] = -1;
					            SetPlayerInterior(playerid, 0);
					            WeaponReset(playerid);
					            SpawnPlayerEx(playerid, true);
                                     
                                // Give achievement
                                switch(SkydivID)
                                {
                                    case SKYDIVE_1: PlayerInfo[playerid][Player_AchSkydive][0] = 1;  // skydive 1
                                    case SKYDIVE_2: PlayerInfo[playerid][Player_AchSkydive][1] = 1;  // skydive 2
                                }
                                if(PlayerInfo[playerid][Player_AchCompleted][ACH_SKYDIVER] == 0)
                                {
                                    if(PlayerInfo[playerid][Player_AchSkydive][SKYDIVE_1] == 1 &&  PlayerInfo[playerid][Player_AchSkydive][SKYDIVE_2] == 1)
                                    {
                                          GivePlayerSkydiveAchievement(playerid); // moved to main.pwn
                                    }
                                }

		                }
		                else SCM(playerid, -1, ""text_red"INFO: Skydive Challenge failed, you must have a parachute to complete this challenge.");
		                return 1;
	    	 	}

            }

    }
    return 1;
}
CMD:skydive(playerid)
{
	if(PlayerInfo[playerid][Player_Mode] == MODE_SKYDIVE) return SendPlayerTextNotice(playerid, "Type /exit to leave", "");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "You can't use this command right now");
    if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You can't use this command while being in a gang war");

    // Clear Player 
    cmd_stopanim(playerid);
    ClosePlayerDialog(playerid);
    ResetPlayerWeapons(playerid);
    
    PlayerRequestToJoinSkydive(playerid, SKYDIVE_1);
    return  1;
}
CMD:skydive2(playerid)
{
	if(PlayerInfo[playerid][Player_Mode] == MODE_SKYDIVE) return SendPlayerTextNotice(playerid, "Type /exit to leave", "");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM || PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You can't use this command right now");

    // Clear Player 
    cmd_stopanim(playerid);
    ClosePlayerDialog(playerid);
    ResetPlayerWeapons(playerid);
    
    PlayerRequestToJoinSkydive(playerid, SKYDIVE_2);
    return  1;	
}

stock PlayerRequestToJoinSkydive(playerid, skydive)
{
	// just clear game text
	SendPlayerTextNotice(playerid, "", "");

    if(GetPVarInt(playerid, "SkydiveAchInfo") == 0)
    {
        SetPVarInt(playerid, "SkydiveAchInfo", 1);
        SCM(playerid, msg_red,"INFO: Complete 1st and 2nd skydives without disconnect to achieve 'God of Skydive'");
    }
    SavePlayerPos(playerid);

    PlayerInfo[playerid][Player_Mode] = MODE_SKYDIVE;
    PlayerInfo[playerid][Player_LastSky] = skydive;
    SetPlayerVirtualWorld(playerid, SKYDIVE_WORLD);
    

    if(PlayerInfo[playerid][Player_God])
    { 
        ResetPlayerGod(playerid);
    }

    Streamer_Update(playerid);
    if(!PlayerInfo[playerid][Player_LoadMap])
    {
    	    TogglePlayerControllable(playerid, false);
			PlayerInfo[playerid][Player_LoadMap] = true;
			TextDrawShowForPlayer(playerid, TDInfo[ObjectsLoad]);
			PlayerInfo[playerid][Player_tLoadMap] = SetTimerEx("UpdatePlayerSpawn", 3500, false, "i", playerid);
    }
    
    SetPlayerHealth(playerid, 100.0);

	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, SkydiveInfo[skydive][SKYDIVE_POSX], SkydiveInfo[skydive][SKYDIVE_POSY], floatadd(SkydiveInfo[skydive][SKYDIVE_POSZ], 3.5));
	SetPlayerFacingAngle(playerid, SkydiveInfo[skydive][SKYDIVE_POSA]);
    SetCameraBehindPlayer(playerid);

    GivePlayerWeapon(playerid, 46, 1);
    
    new cmd[10];
    strcat(cmd, "/");
    strcat(cmd, SkydiveInfo[skydive][SKYDIVE_CMD]);
    SendPlayerTextNotice(playerid, SkydiveInfo[skydive][SKYDIVE_NAME], cmd);

    format(MainStr, sizeof(MainStr), ""text_yellow"[Notice] {%06x}%s(%i)"text_white" has joined challenge "text_green"%s [/%s]", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid, SkydiveInfo[skydive][SKYDIVE_NAME], SkydiveInfo[skydive][SKYDIVE_CMD]);
    SCMToAll(-1, MainStr);
	return 1;
}
