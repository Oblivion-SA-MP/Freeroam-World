/* Creating a new DM.
   
   Define a new DM ID in the enum like: DM_3, DM_4...
   Add DM ID, DM Name, and Dm cmd in DMInfo .
   Add the weapons that are needed for the DM.(can be any weapon but be careful with the slot)
   Add DMPositions
   Add the command and change: PlayerRequestToJoinDM(playerid, your dm id); 
   Everything id done.

   Death , Respawn and Dialog Responses are in main.pwn 
*/

// DM Vars
enum {
   
     DM_None, // 0 ignore.
     DM_1, // 1
     DM_2 // 2
};

enum DMEnum {

	DM_ID,
	DM_Name[20],
	DM_Cmd[10]
};

enum DMWeap {

	DM_ID,
	DM_Weap,
	DM_Ammo
};

static const DMInfo[][DMEnum] =
{ 
    {DM_None, "None", "None"}, // ignore
	  {DM_1, "Deathmatch 1", "dm"},
	  {DM_2, "Deathmatch 2", "dm2"} 
	// futher adding? make sure that the last line one should not have a ' , '
};
static const DMWeapons[][DMWeap] =
{
	{DM_None, 0, 0}, // ignore

	{DM_1,26, 9999},
	{DM_1,4, 1},
	{DM_1, 24, 9999},

	{DM_2, 34, 9999},
	{DM_2, 28, 9999},
	{DM_2, 24, 9999} 
	// futher adding? make sure that the last line one should not have a ' , '
};
enum DMPosEnum {

	DM_ID,
	Float:DM_POSX,
	Float:DM_POSY,
	Float:DM_POSZ,
	Float:DM_POSA,
	Interior
};

static const DMPositions[][DMPosEnum] =
{
  {DM_None, 0.0, 0.0,0.0,0.0, 0}, // ignore
  
  {DM_1, 1304.6666,-63.0556,1002.4957,24.1503, 18},
  {DM_1, 1252.6544,-36.7338,1001.0333,265.7091, 18},
  {DM_1, 1290.4911,2.0734,1001.0200,169.2015, 18},

  {DM_2,-973.1328,1061.5443,1345.6681,89.5907,  10},
  {DM_2,-1054.8959,1095.7388,1343.0774,174.8181,  10},
  {DM_2,-1132.2743,1057.3405,1346.4092,272.8924,  10} 

  // futher adding? make sure that the last line  should not have a ' , '
};


CMD:dms(playerid)
{
     if(PlayerInfo[playerid][Player_Mode] == MODE_DM) return SendPlayerTextNotice(playerid, "Type /exit to leave", "");
     if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "You can't use this command right now");
     if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You can't use this command while being in a gang war");
    
     new StoreDMS[500];
     for(new i = 1; i < sizeof(DMInfo); i++)
     {
    	   format(MainStr, sizeof(MainStr), ""text_white"%s [/%s]\n", DMInfo[i][DM_Name], DMInfo[i][DM_Cmd] );
    	   strcat(StoreDMS, MainStr);

     }
     ShowPlayerDialog(playerid, DIALOG_DM_MENU, DIALOG_STYLE_LIST, ""DIALOG_TAG" Deathmatchs List", StoreDMS, "Join", "Close");
	 return 1;
}

CMD:dm1(playerid) return cmd_dm(playerid);
CMD:dm(playerid)
{
	if(PlayerInfo[playerid][Player_Mode] == MODE_DM) return SendPlayerTextNotice(playerid, "Type /exit to leave", "");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "You can't use this command right now");
    if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You are can't use this command while being in a gang war");

    // Clear Player 
    cmd_stopanim(playerid);
    ClosePlayerDialog(playerid);
    ResetPlayerWeapons(playerid);


    // Set Player To DM
    PlayerRequestToJoinDM(playerid, DM_1);

    return 1;
}

CMD:dm2(playerid)
{
  	if(PlayerInfo[playerid][Player_Mode] == MODE_DM) return SendPlayerTextNotice(playerid, "Type /exit to leave", "");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "You can't use this command right now");
    if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You are can't use this command while being in a gang war");
    // Clear Player 
    cmd_stopanim(playerid);
    ClosePlayerDialog(playerid);
    ResetPlayerWeapons(playerid);


    // Set Player To DM
    PlayerRequestToJoinDM(playerid, DM_2);
	return 1;
}

stock PlayerRequestToJoinDM(playerid, dm)
{
	  // just clear game text
	SendPlayerTextNotice(playerid, "", "");

    SavePlayerPos(playerid);
    PlayerInfo[playerid][Player_Mode] = MODE_DM;
    PlayerInfo[playerid][Player_LastDM] = dm;
    SetPlayerVirtualWorld(playerid, DM_WORLD+dm);

    if(PlayerInfo[playerid][Player_God])
    { 
        ResetPlayerGod(playerid);
    }
    
    SetPlayerHealth(playerid, 100.0);

	new pos = GetRandomDMPosition(dm);
	SetPlayerInterior(playerid, DMPositions[pos][Interior]);
	SetPlayerPos(playerid, DMPositions[pos][DM_POSX], DMPositions[pos][DM_POSY], DMPositions[pos][DM_POSZ]);
	SetPlayerFacingAngle(playerid, DMPositions[pos][DM_POSA]);
    SetCameraBehindPlayer(playerid);


    for(new i = 1; i < sizeof(DMWeapons); i++)
    {
    	if(DMWeapons[i][DM_ID] == dm)
    	{
    		GivePlayerWeapon(playerid, DMWeapons[i][DM_Weap], DMWeapons[i][DM_Ammo]);
    	}
    }

    format(MainStr, sizeof(MainStr), ""text_yellow"[Notice] {%06x}%s(%i)"text_white" has joined "text_blue"%s [/%s]", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid, DMInfo[dm][DM_Name], DMInfo[dm][DM_Cmd]);
    SCMToAll(-1, MainStr);
 
    DMTextDraw(playerid, true);
	return 1;
}
GetRandomDMPosition(dm)
{
    new dmpositionrandom[sizeof(DMPositions)], dmpcount;
    for(new i,j=sizeof(DMPositions); i < j; i++)
    {
        if(DMPositions[i][DM_ID]== dm)
        {
            dmpositionrandom[dmpcount++]=i;
        }
    }
    return dmpositionrandom[random(dmpcount)];
}