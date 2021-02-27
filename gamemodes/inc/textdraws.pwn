#include <YSI\y_hooks>

/* Textdraw.psn

  This Pwn holds all the textdraws which are used in the server.

  This is script hold the funtions which textdraws are shown and hidden

*/
enum STDEnum {
 
     Text:ServerText[2], // Server name and Mode
     Text:ServerTele,
     Text:ServerRandomMSG,
     Text:PlayerGod,
     Text:ObjectsLoad,
     Text:AchTextFetch
 };
new TDInfo[STDEnum];

enum PTDEnum {

	PlayerText:Speedo[MAX_PLAYERS],
	PlayerText:Points[MAX_PLAYERS],
	PlayerText:InfoTD[MAX_PLAYERS],
	PlayerText:AchTextTD[MAX_PLAYERS],
	PlayerText:AchNameTD[MAX_PLAYERS],
	PlayerText:ChallengeVehInfo[MAX_PLAYERS]
};

new PlayerTD[PTDEnum];
hook OnGameModeInit()
{

    TDInfo[ServerText][0]= TextDrawCreate(19.000000, 317.000000, ""#SERVER_TDHOST"");
	TextDrawFont(TDInfo[ServerText][0], 0);
	TextDrawLetterSize(TDInfo[ServerText][0], 0.412500, 1.900000);
	TextDrawTextSize(TDInfo[ServerText][0], 400.000000, 17.000000);
	TextDrawSetOutline(TDInfo[ServerText][0], 2);
	TextDrawSetShadow(TDInfo[ServerText][0], 0);
	TextDrawAlignment(TDInfo[ServerText][0], 1);
	TextDrawColor(TDInfo[ServerText][0], -1);
	TextDrawBackgroundColor(TDInfo[ServerText][0], 255);
	TextDrawBoxColor(TDInfo[ServerText][0], 50);
	TextDrawUseBox(TDInfo[ServerText][0], 0);
	TextDrawSetProportional(TDInfo[ServerText][0], 1);
	TextDrawSetSelectable(TDInfo[ServerText][0], 0);

	TDInfo[ServerText][1] = TextDrawCreate(10.000000, 430.000000, ""#SERVER_TDMODE"");
	TextDrawFont(TDInfo[ServerText][1], 2);
	TextDrawLetterSize(TDInfo[ServerText][1], 0.237500, 1.700000);
	TextDrawTextSize(TDInfo[ServerText][1], 400.000000, 17.000000);
	TextDrawSetOutline(TDInfo[ServerText][1], 1);
	TextDrawSetShadow(TDInfo[ServerText][1], 0);
	TextDrawAlignment(TDInfo[ServerText][1], 1);
	TextDrawColor(TDInfo[ServerText][1], -1);
	TextDrawBackgroundColor(TDInfo[ServerText][1], 255);
	TextDrawBoxColor(TDInfo[ServerText][1], 50);
	TextDrawUseBox(TDInfo[ServerText][1], 0);
	TextDrawSetProportional(TDInfo[ServerText][1], 1);
	TextDrawSetSelectable(TDInfo[ServerText][1], 0);

	TDInfo[ServerTele] = TextDrawCreate(274.000000, 415.000000, "~y~[~y~Oblivion_~w~gone_to_~p~/ls");
	TextDrawFont(TDInfo[ServerTele], 2);
	TextDrawLetterSize(TDInfo[ServerTele], 0.141665, 1.149997);
	TextDrawTextSize(TDInfo[ServerTele], 400.000000, 17.000000);
	TextDrawSetOutline(TDInfo[ServerTele], 1);
	TextDrawSetShadow(TDInfo[ServerTele], 0);
	TextDrawAlignment(TDInfo[ServerTele], 1);
	TextDrawColor(TDInfo[ServerTele], -1);
	TextDrawBackgroundColor(TDInfo[ServerTele], 255);
	TextDrawBoxColor(TDInfo[ServerTele], 50);
	TextDrawUseBox(TDInfo[ServerTele], 0);
	TextDrawSetProportional(TDInfo[ServerTele], 1);
	TextDrawSetSelectable(TDInfo[ServerTele], 0);

	TDInfo[ServerRandomMSG] = TextDrawCreate(260.000000, 427.000000, "~w~Use ~p~/t ~w~to see all teleports");
	TextDrawFont(TDInfo[ServerRandomMSG], 2);
	TextDrawLetterSize(TDInfo[ServerRandomMSG], 0.162498, 1.500000);
	TextDrawTextSize(TDInfo[ServerRandomMSG], 400.000000, 17.000000);
	TextDrawSetOutline(TDInfo[ServerRandomMSG], 1);
	TextDrawSetShadow(TDInfo[ServerRandomMSG], 0);
	TextDrawAlignment(TDInfo[ServerRandomMSG], 1);
	TextDrawColor(TDInfo[ServerRandomMSG], 35839);
	TextDrawBackgroundColor(TDInfo[ServerRandomMSG], 255);
	TextDrawBoxColor(TDInfo[ServerRandomMSG], 50);
	TextDrawUseBox(TDInfo[ServerRandomMSG], 0);
	TextDrawSetProportional(TDInfo[ServerRandomMSG], 1);
	TextDrawSetSelectable(TDInfo[ServerRandomMSG], 0);

	TDInfo[PlayerGod] = TextDrawCreate(542.000000, 80.000000, "~g~GODMODE");
	TextDrawFont(TDInfo[PlayerGod], 2);
	TextDrawLetterSize(TDInfo[PlayerGod], 0.416666, 1.800000);
	TextDrawTextSize(TDInfo[PlayerGod], 321.500000, 20.500000);
	TextDrawSetOutline(TDInfo[PlayerGod], 2);
	TextDrawSetShadow(TDInfo[PlayerGod], 3);
	TextDrawAlignment(TDInfo[PlayerGod], 1);
	TextDrawColor(TDInfo[PlayerGod], -1);
	TextDrawBackgroundColor(TDInfo[PlayerGod], 255);
	TextDrawBoxColor(TDInfo[PlayerGod], 99);
	TextDrawUseBox(TDInfo[PlayerGod], 0);
	TextDrawSetProportional(TDInfo[PlayerGod], 1);
	TextDrawSetSelectable(TDInfo[PlayerGod], 0);

	TDInfo[ObjectsLoad] = TextDrawCreate(239.000000, 368.000000, "~y~Objects_Loading...");
	TextDrawFont(TDInfo[ObjectsLoad], 2);
	TextDrawLetterSize(TDInfo[ObjectsLoad], 0.391666, 2.000000);
	TextDrawTextSize(TDInfo[ObjectsLoad], 400.000000, 17.000000);
	TextDrawSetOutline(TDInfo[ObjectsLoad], 1);
	TextDrawSetShadow(TDInfo[ObjectsLoad], 0);
	TextDrawAlignment(TDInfo[ObjectsLoad], 1);
	TextDrawColor(TDInfo[ObjectsLoad], -16776961);
	TextDrawBackgroundColor(TDInfo[ObjectsLoad], 255);
	TextDrawBoxColor(TDInfo[ObjectsLoad], 202);
	TextDrawUseBox(TDInfo[ObjectsLoad], 1);
	TextDrawSetProportional(TDInfo[ObjectsLoad], 1);
	TextDrawSetSelectable(TDInfo[ObjectsLoad], 0);

	TDInfo[AchTextFetch] = TextDrawCreate(245.000000, 111.000000, "~y~Fetching_Achievement_Data...");
	TextDrawFont(TDInfo[AchTextFetch], 3);
	TextDrawLetterSize(TDInfo[AchTextFetch], 0.295833, 1.700000);
	TextDrawTextSize(TDInfo[AchTextFetch], 400.000000, 17.000000);
	TextDrawSetOutline(TDInfo[AchTextFetch], 1);
	TextDrawSetShadow(TDInfo[AchTextFetch], 0);
	TextDrawAlignment(TDInfo[AchTextFetch], 1);
	TextDrawColor(TDInfo[AchTextFetch], -1);
	TextDrawBackgroundColor(TDInfo[AchTextFetch], 255);
	TextDrawBoxColor(TDInfo[AchTextFetch], 50);
	TextDrawUseBox(TDInfo[AchTextFetch], 0);
	TextDrawSetProportional(TDInfo[AchTextFetch], 1);
	TextDrawSetSelectable(TDInfo[AchTextFetch], 0);
	return 1;
}

hook OnGameModeExit()
{
    for(new ii = 0; ii < sizeof(TDInfo[ServerText]); ii++)
    {
    	TextDrawDestroy(TDInfo[ServerText][ii]);
    }
    TextDrawDestroy(TDInfo[ServerTele]);
    TextDrawDestroy(TDInfo[ServerRandomMSG]);
    TextDrawDestroy(TDInfo[PlayerGod]);
    TextDrawDestroy(TDInfo[ObjectsLoad]);
    TextDrawDestroy(TDInfo[AchTextFetch]);

    foreach(new ii : Player)
    {
    	PlayerTextDrawDestroy(ii, PlayerTD[Points][ii]);
    	PlayerTextDrawDestroy(ii, PlayerTD[Speedo][ii]);
    	PlayerTextDrawDestroy(ii, PlayerTD[InfoTD][ii]);
    	PlayerTextDrawDestroy(ii,PlayerTD[AchTextTD][ii]);
    	PlayerTextDrawDestroy(ii,PlayerTD[AchNameTD][ii]);
    	PlayerTextDrawDestroy(ii, PlayerTD[ChallengeVehInfo][ii]);
    }
	return 1;
}
hook OnPlayerConnect(playerid)
{

	PlayerTD[Points][playerid] = CreatePlayerTextDraw(playerid, 17.000000, 249.000000, " ");
	PlayerTextDrawFont(playerid,PlayerTD[Points][playerid], 3);
	PlayerTextDrawLetterSize(playerid,PlayerTD[Points][playerid], 0.304162, 1.499999);
	PlayerTextDrawTextSize(playerid,PlayerTD[Points][playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid,PlayerTD[Points][playerid], 1);
	PlayerTextDrawSetShadow(playerid,PlayerTD[Points][playerid], 0);
	PlayerTextDrawAlignment(playerid,PlayerTD[Points][playerid], 1);
	PlayerTextDrawColor(playerid,PlayerTD[Points][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid,PlayerTD[Points][playerid], 255);
	PlayerTextDrawBoxColor(playerid,PlayerTD[Points][playerid], 50);
	PlayerTextDrawUseBox(playerid,PlayerTD[Points][playerid], 0);
	PlayerTextDrawSetProportional(playerid,PlayerTD[Points][playerid], 1);
	PlayerTextDrawSetSelectable(playerid,PlayerTD[Points][playerid], 0);


	PlayerTD[Speedo][playerid] = CreatePlayerTextDraw(playerid, 99.000000, 403.000000, "0 KM/H");
	PlayerTextDrawFont(playerid,PlayerTD[Speedo][playerid], 2);
	PlayerTextDrawLetterSize(playerid,PlayerTD[Speedo][playerid], 0.283333, 1.950000);
	PlayerTextDrawTextSize(playerid,PlayerTD[Speedo][playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid,PlayerTD[Speedo][playerid], 2);
	PlayerTextDrawSetShadow(playerid,PlayerTD[Speedo][playerid], 0);
	PlayerTextDrawAlignment(playerid,PlayerTD[Speedo][playerid], 1);
	PlayerTextDrawColor(playerid,PlayerTD[Speedo][playerid], 16777215);
	PlayerTextDrawBackgroundColor(playerid,PlayerTD[Speedo][playerid], 255);
	PlayerTextDrawBoxColor(playerid,PlayerTD[Speedo][playerid], 50);
	PlayerTextDrawUseBox(playerid,PlayerTD[Speedo][playerid], 0);
	PlayerTextDrawSetProportional(playerid,PlayerTD[Speedo][playerid], 1);
	PlayerTextDrawSetSelectable(playerid,PlayerTD[Speedo][playerid], 0);

	PlayerTD[InfoTD][playerid] = CreatePlayerTextDraw(playerid, 90.000000, 350.000000, " ");
	PlayerTextDrawFont(playerid, PlayerTD[InfoTD][playerid], 1);
	PlayerTextDrawLetterSize(playerid, PlayerTD[InfoTD][playerid], 0.175000, 1.250000);
	PlayerTextDrawTextSize(playerid, PlayerTD[InfoTD][playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, PlayerTD[InfoTD][playerid], 1);
	PlayerTextDrawSetShadow(playerid, PlayerTD[InfoTD][playerid], 0);
	PlayerTextDrawAlignment(playerid, PlayerTD[InfoTD][playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD[InfoTD][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD[InfoTD][playerid], 255);
	PlayerTextDrawBoxColor(playerid, PlayerTD[InfoTD][playerid], 50);
	PlayerTextDrawUseBox(playerid, PlayerTD[InfoTD][playerid], 0);
	PlayerTextDrawSetProportional(playerid, PlayerTD[InfoTD][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTD[InfoTD][playerid], 0);

	PlayerTD[AchTextTD][playerid] = CreatePlayerTextDraw(playerid, 183.000000, 157.000000, "~y~Achievement_Completed");
	PlayerTextDrawFont(playerid, PlayerTD[AchTextTD][playerid], 2);
	PlayerTextDrawLetterSize(playerid, PlayerTD[AchTextTD][playerid], 0.529166, 2.000000);
	PlayerTextDrawTextSize(playerid, PlayerTD[AchTextTD][playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, PlayerTD[AchTextTD][playerid], 1);
	PlayerTextDrawSetShadow(playerid, PlayerTD[AchTextTD][playerid], 0);
	PlayerTextDrawAlignment(playerid, PlayerTD[AchTextTD][playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD[AchTextTD][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD[AchTextTD][playerid], 255);
	PlayerTextDrawBoxColor(playerid, PlayerTD[AchTextTD][playerid], 50);
	PlayerTextDrawUseBox(playerid, PlayerTD[AchTextTD][playerid], 0);
	PlayerTextDrawSetProportional(playerid, PlayerTD[AchTextTD][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTD[AchTextTD][playerid], 0);

	PlayerTD[AchNameTD][playerid] = CreatePlayerTextDraw(playerid,265.000000, 204.000000, " ");
	PlayerTextDrawFont(playerid, PlayerTD[AchNameTD][playerid], 0);
	PlayerTextDrawLetterSize(playerid, PlayerTD[AchNameTD][playerid], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, PlayerTD[AchNameTD][playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, PlayerTD[AchNameTD][playerid], 2);
	PlayerTextDrawSetShadow(playerid, PlayerTD[AchNameTD][playerid], 0);
	PlayerTextDrawAlignment(playerid, PlayerTD[AchNameTD][playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD[AchNameTD][playerid], -65281);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD[AchNameTD][playerid], 255);
	PlayerTextDrawBoxColor(playerid, PlayerTD[AchNameTD][playerid], 88);
	PlayerTextDrawUseBox(playerid, PlayerTD[AchNameTD][playerid], 0);
	PlayerTextDrawSetProportional(playerid, PlayerTD[AchNameTD][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTD[AchNameTD][playerid], 0);

	PlayerTD[ChallengeVehInfo][playerid] = CreatePlayerTextDraw(playerid, 3.000000, 281.000000, " ");
	PlayerTextDrawFont(playerid, PlayerTD[ChallengeVehInfo][playerid], 1);
	PlayerTextDrawLetterSize(playerid, PlayerTD[ChallengeVehInfo][playerid], 0.379166, 1.300000);
	PlayerTextDrawTextSize(playerid, PlayerTD[ChallengeVehInfo][playerid], 160.000000, 14.000000);
	PlayerTextDrawSetOutline(playerid, PlayerTD[ChallengeVehInfo][playerid], 1);
	PlayerTextDrawSetShadow(playerid, PlayerTD[ChallengeVehInfo][playerid], 0);
	PlayerTextDrawAlignment(playerid, PlayerTD[ChallengeVehInfo][playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD[ChallengeVehInfo][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD[ChallengeVehInfo][playerid], 255);
	PlayerTextDrawBoxColor(playerid, PlayerTD[ChallengeVehInfo][playerid], 50);
	PlayerTextDrawUseBox(playerid, PlayerTD[ChallengeVehInfo][playerid], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD[ChallengeVehInfo][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTD[ChallengeVehInfo][playerid], 0);
	return 1;
}
hook OnPlayerDisconnect(playerid, reason)
{
    ServerGlobalTD(playerid, true); // hide
    HideServerPlayerTD(playerid);
	return 1;
}

// Function to show/hide Global TDs when player connected
ServerGlobalTD(playerid, bool:hide = false)
{
	if(hide)
	{
	    for(new ii = 0; ii < sizeof(TDInfo[ServerText]); ii++)
	    {
	    	TextDrawHideForPlayer(playerid, TDInfo[ServerText][ii]);
	    }
	    TextDrawHideForPlayer(playerid, TDInfo[ServerTele]);
	    TextDrawHideForPlayer(playerid, TDInfo[ServerRandomMSG]);
	    TextDrawHideForPlayer(playerid, TDInfo[PlayerGod]);
	    TextDrawHideForPlayer(playerid, TDInfo[ObjectsLoad]);
	    TextDrawHideForPlayer(playerid, TDInfo[AchTextFetch]);
	    return 1;
	}

    for(new ii = 0; ii < sizeof(TDInfo[ServerText]); ii++)
    {
    	TextDrawShowForPlayer(playerid, TDInfo[ServerText][ii]);
    }
    TextDrawShowForPlayer(playerid, TDInfo[ServerTele]);
    TextDrawShowForPlayer(playerid, TDInfo[ServerRandomMSG]);
	return 1;
}

// Hides all Player TD when player disconnect.
HideServerPlayerTD(playerid)
{
    if(PlayerInfo[playerid][Player_Vehicle] != INVALID_VEHICLE_ID)
    {
    	PlayerTextDrawHide(playerid, PlayerTD[Speedo][playerid]);
    }
    PlayerTextDrawHide(playerid, PlayerTD[Points][playerid]);
    PlayerTextDrawHide(playerid,PlayerTD[InfoTD][playerid]);
    PlayerTextDrawHide(playerid, PlayerTD[AchTextTD][playerid]);
    PlayerTextDrawHide(playerid, PlayerTD[AchNameTD][playerid]);
    PlayerTextDrawHide(playerid, PlayerTD[ChallengeVehInfo][playerid]);
	return 1;
}

// Show Player Points earned when losing/earning cash or score.
PlayerPoints(playerid, text[])
{
	PlayerTextDrawSetString(playerid, PlayerTD[Points][playerid], text);

    PlayerTextDrawShow(playerid, PlayerTD[Points][playerid]);
    SetTimerEx("HidePointsTD", 3500, false, "i", playerid);
	return 1;
}

publicEx HidePointsTD(playerid)
{
	if(PlayerInfo[playerid][Player_Logged])
	{
         PlayerTextDrawHide(playerid, PlayerTD[Points][playerid]);
	}
	return 1;
}

PlayerInfoTD(playerid, text[], interval)
{
	PlayerTextDrawSetString(playerid, PlayerTD[InfoTD][playerid], text);

    PlayerTextDrawShow(playerid, PlayerTD[InfoTD][playerid]);
    SetTimerEx("HideInfoTD", interval, false, "i", playerid);
	return 1;
}

publicEx HideInfoTD(playerid)
{
	if(PlayerInfo[playerid][Player_Logged])
	{
         PlayerTextDrawHide(playerid, PlayerTD[InfoTD][playerid]);
	}
	return 1;
}


publicEx StopAchDataFetch(playerid, getachname[], getachid)
{ 
	if(!IsPlayerConnected(playerid)) return 1;
    TextDrawHideForPlayer(playerid, TDInfo[AchTextFetch]);
	PlayerAchievement(playerid, getachname, getachid);
	return 1;
}

PlayerAchievement(playerid, achname[], achid)
{
    PlayerTextDrawShow(playerid, PlayerTD[AchTextTD][playerid]);

    PlayerTextDrawSetString(playerid, PlayerTD[AchNameTD][playerid], achname);
    PlayerTextDrawShow(playerid, PlayerTD[AchNameTD][playerid]);
    SetTimerEx("HidePlayerAchTD", 5500, false, "i", playerid);
    
 
    PlayerPoints(playerid,"~y~Points~w~:~n~  ~b~Score~w~: ~g~+100~n~  ~g~~h~Cash~w~: ~g~$20,500");
    format(MainStr, sizeof(MainStr), "~w~You have completed achievement: ~g~%s", achname);
    PlayerInfoTD(playerid, MainStr, 4500);
    SendPlayerScore(playerid, 100);
    SendPlayerMoney(playerid, 20500);

    format(MainStr, sizeof(MainStr),  "INSERT INTO `playerachs`(`ach_id`, `ach_status`, `reg_id`) VALUES (%d,%d,%d)", achid,PlayerInfo[playerid][Player_AchCompleted][achid],PlayerInfo[playerid][Player_ID]);
    mysql_query(fwdb, MainStr);
	return 1;
}

publicEx HidePlayerAchTD(playerid)
{
	if(PlayerInfo[playerid][Player_Logged])
	{
         PlayerTextDrawHide(playerid, PlayerTD[AchTextTD][playerid]);
         PlayerTextDrawHide(playerid, PlayerTD[AchNameTD][playerid]);
	}
	return 1;
}
// hide/show tele in dms
DMTextDraw(playerid, bool:hide=false)
{
    if(hide) return TextDrawHideForPlayer(playerid, TDInfo[ServerTele]);
    TextDrawShowForPlayer(playerid, TDInfo[ServerTele]);
	return 1;
}