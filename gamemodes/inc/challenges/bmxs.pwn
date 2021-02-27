#include <YSI\y_hooks>
enum {

	BMX_1
};

enum bmxEnum {

	bmx_id,
	bmx_name[20],
	bmx_cmd[10],
	Float:bmx_posx,
	Float:bmx_posy,
	Float:bmx_posz,
	Float:bmx_posa,
	Float:bmx_cpx,
	Float:bmx_cpy,
	Float:bmx_cpz,
	bmx_score,
	bmx_cash
};

static const BmxInfo[][bmxEnum] = 
{
	{BMX_1, "BMX Parkour", "bmx",198.5472,3274.2612,16.0692,0.0704,192.3451,3340.3376,120.5544, 15, 10000}
};
new bmxCP[sizeof(BmxInfo)];

hook OnGameModeInit()
{
    for(new i = 0; i < sizeof(BmxInfo); i++)
    {
       bmxCP[i] = CreateDynamicCP(BmxInfo[i][bmx_cpx],BmxInfo[i][bmx_cpy], BmxInfo[i][bmx_cpz], 3.0, BMX_WORLD, -1, -1, 40.0);
	}
	return 1;
}

CMD:bmx(playerid)
{
    if(PlayerInfo[playerid][Player_Mode] == MODE_BMX) return SendPlayerTextNotice(playerid, "Type /exit to leave", "");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "You can't use this command right now");
    if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You can't use this command while being in a gang war");
    // Clear Player 
    cmd_stopanim(playerid);
    ClosePlayerDialog(playerid);
    ResetPlayerWeapons(playerid);
    
    PlayerRequestToJoinBMX(playerid, BMX_1);
	return 1;
}

stock PlayerRequestToJoinBMX(playerid, bmxid)
{
	// just clear game text
	SendPlayerTextNotice(playerid, "", "");

    SavePlayerPos(playerid);

    PlayerInfo[playerid][Player_Mode] = MODE_BMX;
    PlayerInfo[playerid][Player_LastBMX] = bmxid;
    SetPlayerVirtualWorld(playerid, BMX_WORLD);
    

    if(PlayerInfo[playerid][Player_God])
    { 
        ResetPlayerGod(playerid);
    }

    SetPlayerHealth(playerid, 100.0);

	SetPlayerInterior(playerid, 0);

	SetPlayerPos(playerid, BmxInfo[bmxid][bmx_posx],BmxInfo[bmxid][bmx_posy], floatadd(BmxInfo[bmxid][bmx_posz], 3.5));
	SetPlayerFacingAngle(playerid, BmxInfo[bmxid][bmx_posa]);
    SetCameraBehindPlayer(playerid);
  
    new cmd[10];
    strcat(cmd, "/");
    strcat(cmd, BmxInfo[bmxid][bmx_cmd]);
    SendPlayerTextNotice(playerid, BmxInfo[bmxid][bmx_name], cmd);

    format(MainStr, sizeof(MainStr), ""text_yellow"[Notice] {%06x}%s(%i)"text_white" has joined challenge "text_red"%s [/%s]", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid, BmxInfo[bmxid][bmx_name], BmxInfo[bmxid][bmx_cmd]);
    SCMToAll(-1, MainStr);
	return 1;
}

hook OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    if(PlayerInfo[playerid][Player_Mode] == MODE_SPEC) return true;
    
    switch(PlayerInfo[playerid][Player_Mode])
    {

          case MODE_BMX:
          {

                     if(IsPlayerInAnyVehicle(playerid) && GetVehicleModel(GetPlayerVehicleID(playerid)) == 481)
                     {
                             new bmx_last_id = PlayerInfo[playerid][Player_LastBMX];

                             if(bmxCP[bmx_last_id] == checkpointid)
				    	 	 {
			                        SendPlayerTextNotice(playerid, "~r~~h~Congrats!~n~~w~You finished the bmx parkour challenge.", "");
			                        PlayerPlaySound(playerid, 1149,0,0,0);
			                        

			                        format(MainStr, sizeof(MainStr), ""SERVER_TAG" {%06x}%s(%i) "text_green"has successfully completed /%s", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid ,BmxInfo[bmx_last_id][bmx_cmd]);
					                SCMToAll(-1, MainStr);
					                format(MainStr, sizeof(MainStr), ""text_yellow"-> You have earned score: %d and cash: %s", BmxInfo[bmx_last_id][bmx_score], Currency(BmxInfo[bmx_last_id][bmx_cash]));
					                SCMToAll(-1, MainStr);

			                        SendPlayerMoney(playerid, BmxInfo[bmx_last_id][bmx_cash]);
			                        SendPlayerScore(playerid, BmxInfo[bmx_last_id][bmx_score]);
			                        format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: ~g~+%i~n~  ~g~~h~Cash~w~: ~g~+$%s", BmxInfo[bmx_last_id][bmx_score], Currency(BmxInfo[bmx_last_id][bmx_cash]));
			                        PlayerPoints(playerid,MainStr);

			                        PlayerInfoTD(playerid, "~w~You have successfully completed the ~g~bmx parkour ~w~challenge", 5500);

			                        //reset 
			                        PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
						            SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
						            PlayerInfo[playerid][Player_LastBMX] = -1;
						            SetPlayerInterior(playerid, 0);
						            WeaponReset(playerid);
						            SpawnPlayerEx(playerid, true);
					                return 1;
				    	 	 }
                      }



          }

    }
    return 1;
}