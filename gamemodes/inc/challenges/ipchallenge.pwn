#include <YSI\y_hooks>

enum {

	IP_1
};

enum IPEnum
{
   IP_ID,
   IP_Name[20],
   IP_Cmd[10],
   Float:POSX,
   Float:POSY,
   Float:POSZ,
   Float:POSA,
   Float:CPOSX,
   Float:CPOSY,
   Float:CPOSZ,
   IP_Score,
   IP_Cash
};

static const IPInfo[][IPEnum] =
{
   {IP_1, "Infernus Paradise 1", "ip", -2710.2043, 2921.9412, 9.6277, -7.0000, -3992.63916, 4806.34375, 63.28321, 20, 15000}
};

new PInfernesCP[sizeof(IPInfo)];


hook OnGameModeInit()
{
    for(new ipcp = 0; ipcp < sizeof(IPInfo); ipcp++)
	{
		PInfernesCP[ipcp] = CreateDynamicCP(IPInfo[ipcp][CPOSX],IPInfo[ipcp][CPOSY], IPInfo[ipcp][CPOSZ], 20.0, IP_WORLD, -1, -1, 40.0);
	}
    return 1;
}

CMD:ip(playerid)
{
	if(PlayerInfo[playerid][Player_Mode] == MODE_IP) return SendPlayerTextNotice(playerid, "Type /exit to leave", "");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "You can't use this command right now");
    if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You can't use this command while being in a gang war");

    // Clear Player 
    cmd_stopanim(playerid);
    ClosePlayerDialog(playerid);
    ResetPlayerWeapons(playerid);
    
    PlayerRequestToJoinIP(playerid, IP_1);
    return  1;
}

stock PlayerRequestToJoinIP(playerid, ip_id)
{
	// just clear game text
	SendPlayerTextNotice(playerid, "", "");

    SavePlayerPos(playerid);

    PlayerInfo[playerid][Player_Mode] = MODE_IP;
    PlayerInfo[playerid][Player_LastIP] = ip_id;
    SetPlayerVirtualWorld(playerid, IP_WORLD);
    

    if(PlayerInfo[playerid][Player_God])
    { 
        ResetPlayerGod(playerid);
    }

    SetPlayerHealth(playerid, 100.0);

	SetPlayerInterior(playerid, 0);

	PlayerVehicleSpawn(playerid, 411, false);
    
    SetVehiclePos(GetPlayerVehicleID(playerid),IPInfo[ip_id][POSX], IPInfo[ip_id][POSY],floatadd(IPInfo[ip_id][POSZ], 3.5));
	SetVehicleZAngle(GetPlayerVehicleID(playerid), IPInfo[ip_id][POSA]);

	PlayerTextDrawShow(playerid, PlayerTD[ChallengeVehInfo][playerid]);
    new cmd[10];
    strcat(cmd, "/");
    strcat(cmd, IPInfo[ip_id][IP_Cmd]);
    SendPlayerTextNotice(playerid, IPInfo[ip_id][IP_Name], cmd);

    format(MainStr, sizeof(MainStr), ""text_yellow"[Notice] {%06x}%s(%i)"text_white" has joined challenge "text_red"%s [/%s]", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid, IPInfo[ip_id][IP_Name], IPInfo[ip_id][IP_Cmd]);
    SCMToAll(-1, MainStr);
	return 1;
}

hook OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    if(PlayerInfo[playerid][Player_Mode] == MODE_SPEC) return true;
    
    switch(PlayerInfo[playerid][Player_Mode])
    {
           case MODE_IP:
           {

	    	    new IP_LastID = PlayerInfo[playerid][Player_LastIP];
                if(PInfernesCP[IP_LastID] == checkpointid)
	    	 	{
                        SendPlayerTextNotice(playerid, "~r~~h~Congrats!~n~~w~You finished the infernus paradise challenge.", "");
                        PlayerPlaySound(playerid, 1149,0,0,0);

                        format(MainStr, sizeof(MainStr), ""SERVER_TAG" {%06x}%s(%i) "text_green"has successfully completed /%s", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid ,IPInfo[IP_LastID][IP_Cmd]);
		                SCMToAll(-1, MainStr);
		                format(MainStr, sizeof(MainStr), ""text_yellow"-> You have earned score: %d and cash: %s", IPInfo[IP_LastID][IP_Score], Currency(IPInfo[IP_LastID][IP_Cash]));
		                SCMToAll(-1, MainStr);

                        SendPlayerMoney(playerid, IPInfo[IP_LastID][IP_Cash]);
                        SendPlayerScore(playerid, IPInfo[IP_LastID][IP_Score]);
                        format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: ~g~+%i~n~  ~g~~h~Cash~w~: ~g~+$%s", IPInfo[IP_LastID][IP_Score], Currency(IPInfo[IP_LastID][IP_Cash]));
                        PlayerPoints(playerid,MainStr);

                        PlayerInfoTD(playerid, "~w~You have successfully completed the ~g~infernus paradise ~w~challenge", 5500);

                        //reset
                        PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
			            SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
			            PlayerTextDrawHide(playerid, PlayerTD[ChallengeVehInfo][playerid]);
			            PlayerInfo[playerid][Player_LastIP] = -1;
                        PlayerInfo[playerid][Player_ResetFix] = 0;
                        PlayerInfo[playerid][Player_ResetNos] = 0;
			            SetPlayerInterior(playerid, 0);
			            WeaponReset(playerid);
			            DestroyPlayerVehicles(playerid);
			            SpawnPlayerEx(playerid, true);
		                return 1;
	    	 	}

            }

    }
    return 1;
}
