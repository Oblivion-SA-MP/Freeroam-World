#include <YSI\y_hooks>


enum {

	PARKOUR_1
};

enum PARKENUM {

	Park_ID,
    Park_Name[30],
    Park_Cmd[10],
    Float:POSX,
    Float:POSY,
    Float:POSZ,
    Float:POSA,
    Float:CPOSX,
    Float:CPOSY,
    Float:CPOSZ,
    Park_Score,
    Park_Cash
};

static const ParkourInfo[][PARKENUM] =
{
   {PARKOUR_1, "Parkour 1", "parkour", 1116.6528,-2048.5420,74.4297,183.3526,976.5490,-2348.6780,91.7266, 10, 14000}
};

new ParkourCP[sizeof(ParkourInfo)];


hook OnGameModeInit()
{
    for(new pk = 0; pk < sizeof(ParkourInfo); pk++)
	{
		ParkourCP[pk] = CreateDynamicCP(ParkourInfo[pk][CPOSX],ParkourInfo[pk][CPOSY], ParkourInfo[pk][CPOSZ], 15.0,  PARKOUR_WORLD, -1, -1, 40.0);
	}
    return 1;
}

CMD:parkour(playerid)
{
	if(PlayerInfo[playerid][Player_Mode] == MODE_PARKOUR) return SendPlayerTextNotice(playerid, "Type /exit to leave", "");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "You can't use this command right now");
    if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You can't use this command while being in a gang war");

    // Clear Player 
    cmd_stopanim(playerid);
    ClosePlayerDialog(playerid);
    ResetPlayerWeapons(playerid);
    
    PlayerRequestToJoinParkour(playerid, PARKOUR_1);
    return  1;
}

stock PlayerRequestToJoinParkour(playerid, parkourid)
{
	// just clear game text
	SendPlayerTextNotice(playerid, "", "");

    SavePlayerPos(playerid);

    PlayerInfo[playerid][Player_Mode] = MODE_PARKOUR;
    PlayerInfo[playerid][Player_LastPark] = parkourid;
    SetPlayerVirtualWorld(playerid, PARKOUR_WORLD);
    

    if(PlayerInfo[playerid][Player_God])
    { 
        ResetPlayerGod(playerid);
    }

    SetPlayerHealth(playerid, 100.0);

	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, ParkourInfo[parkourid][POSX], ParkourInfo[parkourid][POSY], floatadd(ParkourInfo[parkourid][POSZ], 3.5));
	SetPlayerFacingAngle(playerid, ParkourInfo[parkourid][POSA]);
    SetCameraBehindPlayer(playerid);
  
    new cmd[10];
    strcat(cmd, "/");
    strcat(cmd, ParkourInfo[parkourid][Park_Cmd]);
    SendPlayerTextNotice(playerid, ParkourInfo[parkourid][Park_Name], cmd);

    format(MainStr, sizeof(MainStr), ""text_yellow"[Notice] {%06x}%s(%i)"text_white" has joined challenge "text_red"%s [/%s]", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid, ParkourInfo[parkourid][Park_Name], ParkourInfo[parkourid][Park_Cmd]);
    SCMToAll(-1, MainStr);
	return 1;
}

hook OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    if(PlayerInfo[playerid][Player_Mode] == MODE_SPEC) return true;
    
    switch(PlayerInfo[playerid][Player_Mode])
    {
           case MODE_PARKOUR:
           {

	    	    new ParkourID = PlayerInfo[playerid][Player_LastPark];
                if(ParkourCP[ParkourID] == checkpointid)
	    	 	{
                        SendPlayerTextNotice(playerid, "~r~~h~Congrats!~n~~w~You finished the parkour challenge.", "");
                        PlayerPlaySound(playerid, 1149,0,0,0);

                        format(MainStr, sizeof(MainStr), ""SERVER_TAG" {%06x}%s(%i) "text_green"has successfully completed /%s", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid ,ParkourInfo[ParkourID][Park_Cmd]);
		                SCMToAll(-1, MainStr);
		                format(MainStr, sizeof(MainStr), ""text_yellow"-> You have earned score: %d and cash: %s", ParkourInfo[ParkourID][Park_Score], Currency(ParkourInfo[ParkourID][Park_Cash]));
		                SCMToAll(-1, MainStr);

                        SendPlayerMoney(playerid, ParkourInfo[ParkourID][Park_Cash]);
                        SendPlayerScore(playerid, ParkourInfo[ParkourID][Park_Score]);
                        format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: ~g~+%i~n~  ~g~~h~Cash~w~: ~g~+$%s", ParkourInfo[ParkourID][Park_Score], Currency(ParkourInfo[ParkourID][Park_Cash]));
                        PlayerPoints(playerid,MainStr);

                        PlayerInfoTD(playerid, "~w~You have successfully completed the ~g~parkour ~w~challenge", 5500);

                        //reset parkour
                        PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
			            SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
			            PlayerInfo[playerid][Player_LastPark] = -1;
			            SetPlayerInterior(playerid, 0);
			            WeaponReset(playerid);
			            SpawnPlayerEx(playerid, true);
		                return 1;
	    	 	}

            }

    }
    return 1;
}