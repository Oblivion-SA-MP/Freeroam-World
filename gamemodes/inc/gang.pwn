#include <YSI\y_hooks>

#define MAX_GANGS (500)
#define MAX_GZONES (100)
#define MAX_GANG_RANKS (6)
#define MAX_GANG_MEMBERS (30)

#define GANG_TAG ""text_white"[{FFA000}GANG"text_white"]"
#define GANG_CHAT "{00FFB4}"
#define GANG_MAX_ZONES (10)
#define ZCOLOR_INSTOCK (0xFFFFFFAA)
#define ZCOLOR_ENEMY   (0x95133499)
#define ZCOLOR_OWN     (0x33FF3399)
#define ZONE_REST_CAP  (3000) // 50 mins in seconds
#define ZONE_REST_CAPFAIL  (1800) // 30 mins in seconds
#define ZONE_ATT_TIME (120) // 2 mins
new TotalGangs = 0, TotalGangZones = 0, Iterator:InGangWar<MAX_GANGS>;

enum {

	Zone_InStock,
	Zone_InAttack,
	Zone_InLock
}
enum GangEnum
{
    Gang_ID,
	Gang_Name[20],
	Gang_Tag[5],
	Gang_Color
};
new GangInfo[MAX_GANGS][GangEnum];

enum GangZEnum
{
   Zone_ID,
   Zone_Name[30],
   Zone_Owner,
   Zone_Status,
   Zone_LockTime,
   Zone_Attacker,
   Zone_Streamer,
   Text3D:Zone_Label,
   Float:Zone_X,
   Float:Zone_Y,
   Float:Zone_Z,
   bool:Zone_Exist,
   Zone_AttackTime,
   Text:Zone_TD,
   Zone_Area
};
new GZInfo[MAX_GZONES][GangZEnum];

new Text3D:GangLabel[MAX_PLAYERS];

new GangRanks[MAX_GANG_RANKS][] =
{
  {"None"},
  {"Gang Newbie"},
  {"Gang Leader"},
  {"Gang General"},
  {"Gang Major"},
  {"Gang Founder"}
};



hook OnGamModeInit()
{
    for(new i = 0; i < MAX_GANGS; i++)
    {
       GangInfo[i][Gang_ID] = 0;
       GangInfo[i][Gang_Name][0] = '\0';
       GangInfo[i][Gang_Tag][0] = '\0';
    }
    TotalGangs = 0;
    TotalGangZones = 0;
    for(new i = 0; i < MAX_GZONES; i++) 
    {
        GZInfo[i][Zone_Exist] = false; 
    }
	return 1;
}

hook OnPlayerConnect(playerid)
{
    SetPVarInt(playerid, "GangInvitation", INVALID_PLAYER_ID);
    GangLabel[playerid] = Text3D:-1;
	return 1;
}
LoadServerGang()
{
	mysql_tquery(fwdb, "SELECT * FROM `gangs`;", "LoadServerGangData");
}
LoadServerGangZone()
{
	mysql_tquery(fwdb, "SELECT * FROM `gzones`;", "LoadServerGZoneData");
}
publicEx LoadServerGangData()
{
    new rows = cache_num_rows();
   
    if(!rows) return 1;
    
    new countgangid = 0;
    for(new i = 0; i < MAX_GANGS && i < rows; i++)
    {

        cache_get_value_name_int(i, "g_ID", countgangid);
        GangInfo[countgangid][Gang_ID] = countgangid;

        cache_get_value_name(i, "g_Name",GangInfo[countgangid][Gang_Name],20);
        cache_get_value_name(i, "g_Tag", GangInfo[countgangid][Gang_Tag], 5);
        cache_get_value_name_int(i, "g_Color", GangInfo[countgangid][Gang_Color]);
        TotalGangs++;
    }
    printf("Number of Gang Loaded: %i", TotalGangs);
	return 1;
}
publicEx LoadServerGZoneData()
{
    new rows = cache_num_rows(), gang_label[300];
   
    if(!rows) return 1;
    
    new countgzid = 0;
    for(new i = 0; i < MAX_GZONES && i < rows; i++)
    {
        cache_get_value_name_int(i, "z_ID", countgzid);
        GZInfo[countgzid][Zone_ID] = countgzid;

        cache_get_value_name(i, "z_Name",GZInfo[countgzid][Zone_Name],20);
        cache_get_value_name_int(i, "z_LockTime", GZInfo[countgzid][Zone_LockTime]);
        cache_get_value_name_int(i, "z_Owner", GZInfo[countgzid][Zone_Owner]);

        cache_get_value_name_float(i, "z_PosX", GZInfo[countgzid][Zone_X]);
        cache_get_value_name_float(i, "z_PosY", GZInfo[countgzid][Zone_Y]);
        cache_get_value_name_float(i, "z_PosZ", GZInfo[countgzid][Zone_Z]);

        if(GZInfo[countgzid][Zone_LockTime] == 0) 
        {
        	 GZInfo[countgzid][Zone_Status] = Zone_InStock;
        }
        else
        {
           GZInfo[countgzid][Zone_Status] = Zone_InLock;
        }

        GZInfo[countgzid][Zone_Area] = GangZoneCreate(GZInfo[countgzid][Zone_X] - 70 , GZInfo[countgzid][Zone_Y] - 70, GZInfo[countgzid][Zone_X] + 70 , GZInfo[countgzid][Zone_Y] + 70 );

        GZInfo[countgzid][Zone_Streamer] = CreateDynamicSphere(GZInfo[countgzid][Zone_X],GZInfo[countgzid][Zone_Y],GZInfo[countgzid][Zone_Z], 70, .worldid = FREEROAM_WORLD);
        
        if(GZInfo[countgzid][Zone_Owner] == 0)
        {
        	  format(gang_label, sizeof(gang_label), ""text_white"["text_red"Gang Zone"text_white"]\n\nZone ID: "text_yellow"%i\n"text_white"Zone Name: "text_yellow"%s\n"text_white"Zone Owner: "text_yellow"None\n"text_white"Zone Status: "text_green"Capturable",countgzid,GZInfo[countgzid][Zone_Name]);
              GZInfo[countgzid][Zone_Label] = CreateDynamic3DTextLabel(gang_label, msg_white,GZInfo[countgzid][Zone_X],GZInfo[countgzid][Zone_Y],GZInfo[countgzid][Zone_Z]+0.40, 100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, FREEROAM_WORLD);
        }
        else 
        {
             format(gang_label, sizeof(gang_label), ""text_white"["text_red"Gang Zone"text_white"]\n\nZone ID: "text_yellow"%i\n"text_white"Zone Name: "text_yellow"%s\n"text_white"Zone Owner: "text_yellow"%s\n"text_white"Zone Status: %s",countgzid, GZInfo[countgzid][Zone_Name], GangInfo[GZInfo[countgzid][Zone_Owner]][Gang_Name], GZInfo[countgzid][Zone_Status] == Zone_InStock ? (text_green"Capturable") : (text_red"Locked") );
             GZInfo[countgzid][Zone_Label] = CreateDynamic3DTextLabel(gang_label, msg_white,GZInfo[countgzid][Zone_X],GZInfo[countgzid][Zone_Y],GZInfo[countgzid][Zone_Z]+0.40, 100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, FREEROAM_WORLD);
        }     
        GZInfo[countgzid][Zone_Exist] = true;
        TotalGangZones++;
    }
    printf("Number of Gang Zones Loaded: %i", TotalGangZones);
	return 1;
}
CMD:gcreate(playerid, params[])
{
	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");

	if(PlayerInfo[playerid][Player_GangID] != 0) return SCM(playerid, msg_red, "ERROR: You are already in a gang");
    
    if(TotalGangs >= MAX_GANGS) return SCM(playerid, msg_red, "ERROR: Maximum gangs have been reached");

    if(PlayerInfo[playerid][Player_Score] < 150)
        return SCM(playerid, msg_red,"ERROR: You must have 150 score to create a gang in our server");
    if(PlayerInfo[playerid][Player_Cash] < 200000)
        return SCM(playerid, msg_red,"ERROR: You must have $2,00,000 cash to create a gang in our server");
    
	new gcName[20], gcTag[5], escapeName[20], escapeTag[5];
    if(sscanf(params, "s[20]s[5]", gcName, gcTag)) return SCM(playerid, msg_yellow, "Usage: /gcreate <gang-name> <gang-tag>");
    if(strlen(gcName) < 5 || strlen(gcName) > 20) return SCM(playerid, msg_red,"ERROR: Gang Nmae Length: 5 - 20");
    if(strlen(gcTag) < 2 || strlen(gcTag) > 5) return SCM(playerid, msg_red,"ERROR: Gang Tag Length: 2 - 5");
    
    mysql_escape_string(gcName, escapeName,20);
    mysql_escape_string(gcTag, escapeTag, 5);
    
    mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT `g_Name` FROM `gangs` WHERE `g_Name` = '%s' LIMIT 1;", gcName);
    new Cache:result = mysql_query(fwdb, MainStr);

    if(cache_num_rows())
    {
         SCM(playerid, msg_red, "ERROR: Gang Name already exists in database");
    } 
    else 
    {
      mysql_format(fwdb, MainStr, sizeof(MainStr), "INSERT INTO `gangs`(`g_Name`,`g_Tag`,`g_Founder`,`creation`) VALUES ( '%s', '%s', '%s', UNIX_TIMESTAMP() )", escapeName, escapeTag, PlayerInfo[playerid][Player_Name]);
      mysql_tquery(fwdb, MainStr, "OnPlayerGangCreate", "iss", playerid,gcName,gcTag);
    }
    cache_delete(result);
	return 1;
}

publicEx OnPlayerGangCreate(playerid, name[], tag[])
{

    new g_id = cache_insert_id();

    GangInfo[g_id][Gang_ID] = g_id;
    strmid(GangInfo[g_id][Gang_Name], name, 0, 20, 20);
    strmid(GangInfo[g_id][Gang_Tag], tag, 0, 5,5);
    
    GangInfo[g_id][Gang_Color] = -1329275137;

    format(MainStr, sizeof(MainStr), ""SERVER_TAG" {%06x}%s(%i) "text_white"has created a gang: "text_green"[%s]%s", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid, tag, name);
    SCMToAll(-1, MainStr);
    SCM(playerid, msg_yellow, " -> You have successfully created a gang");

    PlayerPoints(playerid,"~y~Points~w~:~n~  ~b~Score~w~: ~w~-~n~  ~g~~h~Cash~w~: ~r~-$2,00,000");
    SendPlayerMoney(playerid, -200000);
    TotalGangs++;
    
    // Set Player Gang Info
    PlayerInfo[playerid][Player_GangID] = g_id;
    PlayerInfo[playerid][Player_GangRank] = 5;
    
    SendPlayerGangScore(g_id, 10);

    mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `gang_rank`= 5 , `gang_id` = %d WHERE `ID` = %d", PlayerInfo[playerid][Player_GangID], PlayerInfo[playerid][Player_ID]);
    mysql_query(fwdb, MainStr);
    
    SetPlayerGangLabel(playerid);

    SyncGangZoneForPlayer(playerid);
    printf("[Gang Creation] Player Name: %s Has created gang: [%s]%s", PlayerInfo[playerid][Player_Name],GangInfo[g_id][Gang_Tag], GangInfo[g_id][Gang_Name]);
	return 1;
}

CMD:grename(playerid, params[])
{
	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
  	if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");
	if(PlayerInfo[playerid][Player_GangRank] != 5) return SCM(playerid, msg_red, "ERROR: You need to be founder to rename gang");

    if( Iter_Contains(InGangWar,PlayerInfo[playerid][Player_GangID]) ) 
    {
         return  ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" Your gang is currently involved in a gang war. Please Try again later", "OK", "");
    }

    if(PlayerInfo[playerid][Player_Score] < 500)
        return SCM(playerid, msg_red,"ERROR: You must have 500 score to rename your gang");
    if(PlayerInfo[playerid][Player_Cash] < 800000)
        return SCM(playerid, msg_red,"ERROR: You must have $8,00,000 cash to create a gang in our server");

   	new grcName[20], grcTag[5], rescapeName[20], rescapeTag[5];
    if(sscanf(params, "s[20]s[5]", grcName, grcTag)) return SCM(playerid, msg_yellow, "Usage: /grename <gang-name> <gang-tag>");
    if(strlen(grcName) < 5 || strlen(grcName) > 20) return SCM(playerid, msg_red,"ERROR: Gang Nmae Length: 5 - 20");
    if(strlen(grcTag) < 2 || strlen(grcTag) > 5) return SCM(playerid, msg_red,"ERROR: Gang Tag Length: 2 - 5");


    mysql_escape_string(grcName, rescapeName,20);
    mysql_escape_string(grcTag, rescapeTag, 5);
    
    mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT `g_Name` FROM `gangs` WHERE `g_Name` = '%s' LIMIT 1;", grcName);
    new Cache:rresult = mysql_query(fwdb, MainStr);

    if(cache_num_rows())
    {
         SCM(playerid, msg_red, "ERROR: Gang Name already exists in database");
    } 
    else 
    {
	      strmid(GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Name], grcName, 0, 20, 20);
	      strmid(GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Tag], grcTag, 0, 5,5);
	      mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `gangs` SET `g_Name`='%s', `g_Tag`='%s' WHERE `g_ID` = %d LIMIT 1;", rescapeName, rescapeTag, GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_ID]);
	      mysql_query(fwdb, MainStr);
	      format(MainStr, sizeof MainStr, ""GANG_TAG" Gang Founder %s(%i) has changed the gang name to [%s]%s", PlayerInfo[playerid][Player_Name],playerid, grcTag, grcName );
          SendGangNotice( PlayerInfo[playerid][Player_GangID] , MainStr);
          PlayerPoints(playerid,"~y~Points~w~:~n~  ~b~Score~w~: ~w~-~n~  ~g~~h~Cash~w~: ~r~-$8,00,000");
          SendPlayerMoney(playerid, -800000);
    }
    cache_delete(rresult);
    Delete3DTextLabel(GangLabel[playerid]);
    SetPlayerGangLabel(playerid);
	return 1;
}

CMD:gmembers(playerid)
{

    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
  
    mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT `name`, `gang_rank` FROM `users` WHERE `gang_id` = %d ORDER BY `gang_rank` DESC LIMIT %d;", PlayerInfo[playerid][Player_GangID], MAX_GANG_MEMBERS);
    mysql_tquery(fwdb, MainStr, "OnPlayerRequestForGangMembers", "i", playerid);
	return 1;
}

publicEx OnPlayerRequestForGangMembers(playerid)
{
    if(!cache_num_rows()) return SCM(playerid, msg_red, "ERROR: Something went wrong, Please contact founders and report this.");
    
    new StoreMembers[400], uName[MAX_PLAYER_NAME], gang_rank;
    for(new i = 0; i < cache_num_rows(); i++)
    {
          
          cache_get_value_index(i, 0, uName, sizeof(uName));
          cache_get_value_index_int(i, 1, gang_rank);

          format(MainStr,sizeof(MainStr), ""text_white"%s "text_yellow"(%s)\n", uName, GangRanks[gang_rank]);
          strcat(StoreMembers, MainStr);
    }
    format(MainStr, sizeof MainStr, ""DIALOG_TAG" {%06x}%s's "text_white"Gang Members",GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Color] >>> 8,GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Name] );                  
    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_LIST, MainStr, StoreMembers, "OK", "Close");
	return 1;
}

CMD:gcolor(playerid, params[])
{
    if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");
    if(PlayerInfo[playerid][Player_GangRank] != 5) return SCM(playerid, msg_red, "ERROR: You need to be  founder to set a gang color");
    if( Iter_Contains(InGangWar,PlayerInfo[playerid][Player_GangID]) ) 
    {
         return  ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" Your gang is currently involved in a gang war. Please Try again later", "OK", "");
    }
    new rgb[4];
    if(sscanf(params, "iii", rgb[0] , rgb[1], rgb[2]) || !(0 <= rgb[0] <= 255) || !(0 <= rgb[1] <= 255) || !(0 <= rgb[2] <= 255))
    return SCM(playerid, msg_yellow, "Usage: /gcolor <R> <G> <B>");
   

    if(rgb[0] < 30 && rgb[1] < 30 && rgb[2] < 30)
    {
        SCM(playerid, msg_red ,"ERROR: RGB values under 30 are not allowed!");
        return true;
    }

    rgb[3] = ConvertRGB(rgb[0], rgb[1], rgb[2], 99);
    GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Color] = rgb[3];

    format(MainStr, sizeof(MainStr), ""GANG_TAG" "text_white"Gang Founder %s(%i) has changed the gang color to: {%06x}COLOR",PlayerInfo[playerid][Player_Name], playerid, rgb[3] >>> 8);
    SendGangNotice(PlayerInfo[playerid][Player_GangID], MainStr);
    

    mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `gangs` SET `g_Color`=%d WHERE `g_ID`= %d", GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Color], GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_ID]);    
    mysql_query(fwdb, MainStr);
    return true;
}
CMD:grank(playerid, params[])
{
    if(!PlayerInfo[playerid][Player_Logged])  return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
	if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");
	if(PlayerInfo[playerid][Player_GangRank] < 4) return SCM(playerid, msg_red, "ERROR: You need to be  co-founder or founder to set a gang member rank");
    if( Iter_Contains(InGangWar,PlayerInfo[playerid][Player_GangID]) ) 
    {
         return  ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" Your gang is currently involved in a gang war. Please Try again later", "OK", "");
    }
    new gang_rank = 0;
    if(sscanf(params, "ui", getotherid,gang_rank)) return SCM(playerid, msg_yellow, "Usage: /gset <id/name> <rank>");
    if(gang_rank > 4 || gang_rank < 1) return SCM(playerid, msg_red, "ERRIR: Gang Ranks: 1 - 4");
    if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid player id");
    if(!PlayerInfo[getotherid][Player_Logged])  return SCM(playerid, msg_red, "ERROR: The player is not logged in");

    if(PlayerInfo[getotherid][Player_GangID] != PlayerInfo[playerid][Player_GangID]) return SCM(playerid, msg_red, "ERROR: The Player is not your gang member");

    if(PlayerInfo[getotherid][Player_GangRank] == gang_rank) return SCM(playerid, msg_red, "ERROR: The player is already in that rank");
    
    if(PlayerInfo[playerid][Player_GangRank] != 5)
	{
		if(gang_rank == 4) return SCM(playerid, msg_red, "ERROR: Only gang founders can promote others to co-founders.");
		if(PlayerInfo[getotherid][Player_GangRank] == 5)
		{
			SCM(playerid, msg_red, "ERROR: You can't set levels on the gang founder!");

			format(MainStr, sizeof(MainStr), ""text_red"*** "text_white"%s(%d) has just tried to set your gang level!",PlayerInfo[playerid][Player_Name], playerid);
			SCM(getotherid, -1, MainStr);
			return 1;
		}
	}
    new new_level[12];
	if(gang_rank > PlayerInfo[getotherid][Player_GangRank]) 
	{ 
		 strmid(new_level, "promoted", 0, 12, 12);
    }
    else strmid(new_level, "demoted", 0, 12, 12);
    
    PlayerInfo[playerid][Player_GangRank] = gang_rank;

    mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `gang_rank`=%d WHERE `ID` = %d LIMIT 1;", PlayerInfo[playerid][Player_GangRank], PlayerInfo[playerid][Player_ID]);
    mysql_query(fwdb, MainStr);


    format(MainStr, sizeof MainStr, ""GANG_TAG" %s %s(%i) has %s our gang member %s(%i) to %s(%i)", GangRanks[PlayerInfo[playerid][Player_GangRank]], PlayerInfo[playerid][Player_Name], playerid, new_level, PlayerInfo[getotherid][Player_Name], getotherid, GangRanks[gang_rank]);
    SendGangNotice( PlayerInfo[playerid][Player_GangID] , MainStr);
	return 1;
}

CMD:gclose(playerid)
{
	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
   
    if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");
	if(PlayerInfo[playerid][Player_GangRank] != 5) return SCM(playerid, msg_red, "ERROR: You need to gang founder to close this gang");

    if( Iter_Contains(InGangWar,PlayerInfo[playerid][Player_GangID]) ) 
    {
         return  ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" Your gang is currently involved in a gang war. Please Try again later", "OK", "");
    }

    format(MainStr, sizeof(MainStr), ""GANG_TAG" Founder %s(%i) has closed the gang!", PlayerInfo[playerid][Player_Name], playerid);
    SendGangNotice( PlayerInfo[playerid][Player_GangID] , MainStr);
     
    mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `gang_rank`= 0 , `gang_id` = 0 WHERE `gang_id` = %d", PlayerInfo[playerid][Player_GangID]);
    mysql_query(fwdb, MainStr);

    mysql_format(fwdb, MainStr, sizeof(MainStr), "DELETE FROM `gangs` WHERE `g_ID` = %d", GangInfo[ PlayerInfo[playerid][Player_GangID] ] [Gang_ID] );
    mysql_query(fwdb, MainStr);

    mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `gzones` SET `z_Owner` = 0 WHERE `z_Owner` = %d", PlayerInfo[playerid][Player_GangID] );
    mysql_query(fwdb, MainStr);

    foreach(new i : Player)
    {
          if(PlayerInfo[i][Player_GangID] == PlayerInfo[playerid][Player_GangID])
          {
          	 PlayerInfo[i][Player_GangID] = 0;
          	 PlayerInfo[i][Player_GangRank] = 0;
             Delete3DTextLabel(GangLabel[i]);
          }
    }
    for(new i = 0; i < MAX_GZONES; i++)
    {
         if(PlayerInfo[playerid][Player_GangID] == GZInfo[i][Zone_Owner])
         {
         	GZInfo[i][Zone_Owner] = 0;
         	GZInfo[i][Zone_Status] = Zone_InStock;
         	GZInfo[i][Zone_LockTime] = 0;
         	UpdateGangZoneLabel(i);
         }
    }
    foreach(new i : Player) SyncGangZoneForPlayer(i);
    TotalGangs--;
	return 1;
}


CMD:ginvite(playerid, params[])
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
   
    if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");
    if(PlayerInfo[playerid][Player_GangRank] < 3) return SCM(playerid, msg_red, "ERROR: You need to gang general to use this gang");
    if( Iter_Contains(InGangWar,PlayerInfo[playerid][Player_GangID]) ) 
    {
         return  ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" Your gang is currently involved in a gang war. Please Try again later", "OK", "");
    }
    if(sscanf(params, "u", getotherid)) return SCM(playerid, msg_yellow, "Usage: /ginvite <id/name>");

    if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid player id");
    if(!PlayerInfo[getotherid][Player_Logged])  return SCM(playerid, msg_red, "ERROR: The player is not logged in");
    
    if(PlayerInfo[getotherid][Player_GangID] != 0) return SCM(playerid, msg_red, "ERROR: The Player is already in a gang");
    if(PlayerInfo[getotherid][Player_Score] < 150) return SCM(playerid, msg_red, "ERROR: The Player needs 150 score to join a gang");
    if(GetPVarInt(getotherid, "GangInvitation") == playerid) return SCM(playerid, msg_red, "ERROR: You have already sent a gang invite to this player!");

    new Float:POS[3];
    GetPlayerPos(getotherid, POS[0], POS[1], POS[2]);
	if(!IsPlayerInRangeOfPoint(playerid, 8.0, POS[0], POS[1], POS[2]))  return SCM(playerid, msg_red, "ERROR: You must be near the player to whom you are inviting!");
    
    mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT `gang_id` FROM `users` WHERE `gang_id` = %d", PlayerInfo[playerid][Player_GangID]);
    new Cache:mResult = mysql_query(fwdb, MainStr);

    if(cache_num_rows() > MAX_GANG_MEMBERS)
    {
          SCM(playerid, msg_red, "ERROR: Your gang reached maximum number of gang memvers");
    }
    else 
    {
           SCM(playerid, msg_green, " -> Gang Invitation has been sent to that player");
           format(MainStr, sizeof(MainStr),""GANG_TAG" %s(%i) has invited you to his gang: %s",PlayerInfo[playerid][Player_Name], playerid, GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Name]);
           SCM(getotherid, -1, MainStr);
           SetPVarInt(getotherid, "GangInvitation", playerid);
    }
    cache_delete(mResult);
	return 1;
}
CMD:gjoin(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    
	new inv_id = GetPVarInt(playerid, "GangInvitation");

	if(GetPVarInt(playerid, "GangInvitation") == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: You have not been invited to any gang.");

	if(inv_id == INVALID_PLAYER_ID)
		return SCM(playerid, msg_red, "ERROR: The player that has invited you has left the server! Invite has been cancelled."), DeletePVar(playerid, "GangInvitation");


	PlayerInfo[playerid][Player_GangID] = PlayerInfo[inv_id][Player_GangID];
    PlayerInfo[playerid][Player_GangRank] = 1;

	mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `gang_id`=%d,`gang_rank`=1 WHERE `ID`=%d", GangInfo[ PlayerInfo[playerid][Player_GangID] ] [Gang_ID],PlayerInfo[playerid][Player_ID]);
	mysql_query(fwdb, MainStr);

	format(MainStr, sizeof(MainStr), ""GANG_TAG" %s(%i) has joined the gang! Invited by: %s(%d)", PlayerInfo[playerid][Player_Name], playerid, PlayerInfo[inv_id][Player_Name], inv_id);
	SendGangNotice( PlayerInfo[playerid][Player_GangID] , MainStr);

	SetPVarInt(playerid, "GangInvitation", INVALID_PLAYER_ID);
    SetPlayerGangLabel(playerid);
    SyncGangZoneForPlayer(playerid);
	return true;
}

CMD:gdeny(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");

	new inv_id = GetPVarInt(playerid, "GangInvitation");

	if(GetPVarInt(playerid, "GangInvitation") == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: You have not been invited to any gang.");

	if(inv_id == INVALID_PLAYER_ID)
		return SCM(playerid, msg_red, "ERROR: The player that has invited you has left the server! Invite has been cancelled."), DeletePVar(playerid, "GangInvitation");

	format(MainStr, sizeof(MainStr), ""GANG_TAG" You have denied the gang request from %s(%d)", PlayerInfo[inv_id][Player_Name], inv_id);
	SCM(playerid, -1, MainStr);

	format(MainStr, sizeof(MainStr), ""GANG_TAG" %s(%d) has denied the gang request.", PlayerInfo[playerid][Player_Name], playerid);
	SCM(inv_id, -1, MainStr);

	SetPVarInt(playerid, "GangInvitation", INVALID_PLAYER_ID);
	return true;
}
CMD:gleave(playerid, params[])
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");
    if( Iter_Contains(InGangWar,PlayerInfo[playerid][Player_GangID]) ) 
    {
         return  ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" Your gang is currently involved in a gang war. Please Try again later", "OK", "");
    }
    if(PlayerInfo[playerid][Player_GangRank] == 5) return SCM(playerid, msg_red, "ERROR: You can't leave the gang as the gang founder, type /gclose to close the gang.");
    
    format(MainStr, sizeof(MainStr), ""GANG_TAG" %s(%i) has left the gang.",PlayerInfo[playerid][Player_Name], playerid);
    SendGangNotice(PlayerInfo[playerid][Player_GangID], MainStr);

    format(MainStr, sizeof(MainStr), ""SERVER_TAG" You have left your gang '%s'.", GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Name]);
    SCM(playerid, -1, MainStr);
     
    PlayerInfo[playerid][Player_GangID] = 0;
    PlayerInfo[playerid][Player_GangRank] = 0;
    Delete3DTextLabel(GangLabel[playerid]);

    format(MainStr, sizeof(MainStr), "UPDATE users SET gang_id=0,gang_rank=0 WHERE ID = %d", PlayerInfo[playerid][Player_ID]);
    mysql_query(fwdb, MainStr);
    SyncGangZoneForPlayer(playerid);
    return 1;
}
CMD:gkick(playerid, params[])
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");
    if( Iter_Contains(InGangWar,PlayerInfo[playerid][Player_GangID]) ) 
    {
         return  ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" Your gang is currently involved in a gang war. Please Try again later", "OK", "");
    }
    if(PlayerInfo[playerid][Player_GangRank] < 4) return SCM(playerid, msg_red, "ERROR: You need to gang co founder to use this gang");
   
    new kickName[24];
    if(sscanf(params, "s[24]", kickName)) return SCM(playerid, msg_yellow, "Usage: /gkick <id/name>");

    new escaped_tmp[24];
    mysql_escape_string(kickName, escaped_tmp, 24);

    mysql_format(fwdb , MainStr, sizeof(MainStr), "SELECT * FROM `users` WHERE `name` = '%s'", escaped_tmp);
    mysql_tquery(fwdb , MainStr, "KickPlayerFromGroup", "is", playerid, escaped_tmp);
    return 1;
}
forward KickPlayerFromGroup(playerid, kickedPlayer[]);
public KickPlayerFromGroup(playerid, kickedPlayer[])
{
    if(!cache_num_rows())
    {
       return  SCM(playerid, msg_red, "ERROR: Invalid User name specified");
    }
    
    new pg_ID , pg_Rank;

    cache_get_value_name_int(0, "gang_id", pg_ID);
    cache_get_value_name_int(0, "gang_rank", pg_Rank);

    if(pg_ID != GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_ID]) return  SCM(playerid, msg_red, "ERROR: This player is not in your gang!");
    if(pg_Rank >= PlayerInfo[playerid][Player_GangRank])  return  SCM(playerid, msg_red, "ERROR: You cannot kick this player from the gang.");

    format(MainStr, sizeof(MainStr), ""GANG_TAG" %s(%i) has kicked out %s from the gang.", PlayerInfo[playerid][Player_Name], playerid, kickedPlayer);
    SendGangNotice(PlayerInfo[playerid][Player_GangID], MainStr);

    format(MainStr, sizeof(MainStr), "UPDATE users SET gang_id=0,gang_rank=0 WHERE name = '%s'", kickedPlayer);
    mysql_query(fwdb, MainStr);

    //==== Setting Player ingame
    foreach(new i : Player) if(strcmp(PlayerInfo[i][Player_Name], kickedPlayer, true, strlen(kickedPlayer)) == 0)
    {
        PlayerInfo[i][Player_GangID] = 0;
        PlayerInfo[i][Player_GangRank] = 0;
        Delete3DTextLabel(GangLabel[i]);
        SyncGangZoneForPlayer(i);
    }
    
    return 1;
}

CMD:gpanel(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");

    new StoreGangInfo[300];
    StoreGangInfo[0] = EOS;

    switch( PlayerInfo[playerid][Player_GangRank] )
    {
         case 1,2,3: strcat(StoreGangInfo, ""text_white"Show Gang Information\nShow Gang Members\nShow Top gangs\n");
         case 4: strcat(StoreGangInfo, ""text_white"Show Gang Information\nShow Gang Members\nShow Top gangs\nKick Player From Gang");
         case 5: strcat(StoreGangInfo, ""text_white"Show Gang Information\nShow Gang Members\nShow Top gangs\nKick Player From Gang\nClose Gang");
    }
    format(MainStr, sizeof MainStr, ""DIALOG_TAG" {%06x}%s's "text_white"Gang Panel",GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Color] >>> 8,GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Name] );
    ShowPlayerDialog(playerid, DIALOG_GANG_PANEL, DIALOG_STYLE_LIST, MainStr, StoreGangInfo, "Select", "Cancel");
 	return 1;
}
SendGangNotice(gangid, const msg[])
{

	foreach(new i : Player)
	{
		if(PlayerInfo[i][Player_GangID] == gangid)
		{
            SCM(i, -1, msg);
		}
	}
}


SendPlayerGangScore(gangid, score)
{
      mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `gangs` SET `g_Score` = `g_Score` + %d WHERE `g_ID` = %d LIMIT 1;", score,  gangid);
      mysql_query(fwdb, MainStr);
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{

    switch(dialogid)
    {
    	case DIALOG_GANG_PANEL: 
    	{
    		switch(listitem)
    		{
    			case 0: ShowPlayerGangInfo(playerid);
    			case 1: cmd_gmembers(playerid);
                case 2: ShowTopGangs(playerid);
    			case 3: cmd_gkick(playerid, "");
    			case 4: cmd_gclose(playerid);
    		}
    	}
    }
	return 1;
}

stock ShowPlayerGangInfo(playerid)
{

	mysql_format(fwdb, MainStr, sizeof MainStr, "SELECT * FROM `gangs` WHERE `g_ID` = %d LIMIT 1;", GangInfo[ PlayerInfo[playerid][Player_GangID]][Gang_ID] );
	mysql_tquery(fwdb, MainStr, "ShowGangInfo", "i", playerid);
	return 1;
}

publicEx ShowGangInfo(playerid)
{
   
    if(!cache_num_rows())  return SCM(playerid, msg_red, "ERROR: Something went wrong, Please contact founders and report this.");

    new StoreGangInfo[500], StoreGangInfo2[500]; 
  
    new g_ID, g_Name[20], g_Color, g_Tag[5], g_Founder[MAX_PLAYER_NAME], g_Score, g_Creation;
    cache_get_value_name_int(0, "g_ID", g_ID);
    cache_get_value_name(0, "g_Name", g_Name);
    cache_get_value_name_int(0, "g_Color", g_Color);
    cache_get_value_name(0 ,"g_Tag" , g_Tag);
    cache_get_value_name(0, "g_Founder", g_Founder);
    cache_get_value_name_int(0, "g_Score", g_Score);
    cache_get_value_name_int(0, "creation", g_Creation);

    format(StoreGangInfo, sizeof(StoreGangInfo), "\n\n"text_yellow"Gang ID: "text_white"%i\n"text_yellow"Gang Name: "text_white"%s\n"text_yellow"Gang Tag: "text_white"%s\n"text_yellow"Gang Score: "text_white"%i\n"text_yellow"Gang Color: {%06x}COLOR\n"text_yellow"Gang Founder: "text_white"%s\n"text_yellow"Gang Creation: "text_white"%s\n",
    g_ID, g_Name, g_Tag, g_Score, g_Color >>> 8, g_Founder, ConvertUnix( g_Creation ) );
    strcat(StoreGangInfo2, StoreGangInfo);
    
	mysql_format(fwdb, MainStr, sizeof MainStr, "SELECT `gang_id`,`gang_rank` FROM `users` WHERE `gang_id` = %d", PlayerInfo[playerid][Player_GangID] );
	new Cache:mgang = mysql_query(fwdb, MainStr);
    
    if(cache_num_rows())
    {
       format(MainStr, sizeof MainStr, "\n"text_yellow"Total Gang Members: "text_white"%i/%i\n",cache_num_rows(), MAX_GANG_MEMBERS );
       strcat(StoreGangInfo2,MainStr);
    }
    cache_delete(mgang);

    foreach(new i : Player)
    {
    	if(PlayerInfo[i][Player_GangID] == PlayerInfo[playerid][Player_GangID])
    	{
    		if(PlayerInfo[i][Player_Afk]) format(MainStr, sizeof MainStr, "{%06x}%s(%i)"text_red"[AFK]\n", PlayerColor(i), PlayerInfo[i][Player_Name], i);
            else format(MainStr, sizeof MainStr, "{%06x}%s(%i)\n", PlayerColor(i), PlayerInfo[i][Player_Name], i);

    		strcat(StoreGangInfo2,MainStr);
    	}
    }
 
    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Info", StoreGangInfo2, "OK", "");
	return 1;
}

CMD:gtop(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    ShowTopGangs(playerid);
    return 1;
}
stock ShowTopGangs(playerid)
{

     new Cache:topgresult=mysql_query(fwdb, "SELECT * FROM `gangs` WHERE `g_ID` ORDER BY `g_Score` DESC LIMIT 20;");
 
     if(cache_num_rows())
     {
    
        new g_ID, g_Name[20], g_Color, g_Tag[5], g_Founder[MAX_PLAYER_NAME], g_Score, StoreTopString[500],StoreTopString2[500];
        strcat(StoreTopString2, "\n");
        for(new i = 0; i <  MAX_GANGS && i < cache_num_rows(); i++)
        {
             cache_get_value_name(i, "g_Name", g_Name, sizeof(g_Name) );
             cache_get_value_name(i, "g_Tag", g_Tag, sizeof(g_Tag) );
             cache_get_value_name(i, "g_Founder", g_Founder, sizeof(g_Founder) );
             cache_get_value_name_int(i, "g_Color", g_Color);
             cache_get_value_name_int(i, "g_Score", g_Score);
             cache_get_value_name_int(i, "g_ID", g_ID);
           
             format(StoreTopString, sizeof(StoreTopString), ""text_white"#%i. {%06x}[%s]%s - %s - %i\n",g_ID, g_Color>>> 8, g_Tag,g_Name,g_Founder,g_Score);
             strcat(StoreTopString2, StoreTopString);
        }
        ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Top Gangs", StoreTopString2, "OK", "");
     }
     else  SCM(playerid, msg_red, "ERROR: There are not gangs created in the server");
     cache_delete(topgresult);
     return 1;
}

stock SetPlayerGangLabel(playerid)
{
    new stringGangName[200];
    format(stringGangName,sizeof(stringGangName),""text_blue"GANG:"text_white" %s", GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Name]);
    GangLabel[playerid] = Create3DTextLabel(stringGangName, -1, 0.0, 0.0, 50.0, 30.0, 0, 1);
    Attach3DTextLabelToPlayer(GangLabel[playerid], playerid, 0.0, 0.0, 0.64);
}
CMD:gangs(playerid)
{

    new Iterator:OnlineGangs[2]<MAX_PLAYERS>;
    new StoreGagsOnline[800];

    Iter_Init(OnlineGangs);

    foreach(new i : Player)
    {
        if(PlayerInfo[i][Player_GangID]> 0 && !Iter_Contains(OnlineGangs[0], PlayerInfo[i][Player_GangID]))
        {
            Iter_Add(OnlineGangs[0], PlayerInfo[i][Player_GangID]);
            Iter_Add(OnlineGangs[1], i);
        }
    }
    if(Iter_Count(OnlineGangs[1]) == 0) return SendClientMessage(playerid, msg_red, "INFO: There are no gangs online!");
    
    format(MainStr, sizeof(MainStr), ""text_white"%i gangs online:\n", Iter_Count(OnlineGangs[1]));
    strcat(StoreGagsOnline, MainStr);

    for(new i = Iter_First(OnlineGangs[1]), count = 0; i != Iter_End(OnlineGangs[1]); i = Iter_Next(OnlineGangs[1], i), ++count)
    {
        if(count <= 40)
        {
            format(MainStr, sizeof(MainStr), "\n"text_white"%i - %s", count + 1, GangInfo[PlayerInfo[i][Player_GangID]][Gang_Name]);
            strcat(StoreGagsOnline, MainStr);
        }
        else
        {
            format(MainStr, sizeof(MainStr), "\n"text_white"[... too many online]");
            strcat(StoreGagsOnline, MainStr);
            break;
        }
    }
    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX,  ""DIALOG_TAG" Gangs Online", StoreGagsOnline, "OK", "");
    return 1;
}


// gang zone 
CMD:makegzone(playerid, params[])
{
	
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    
    if(PlayerInfo[playerid][Player_Admin] != Founder_Level) return SCM(playerid, msg_red, "ERROR: haha, Ez guy!");
    
    if(TotalGangZones >= MAX_GZONES) return SCM(playerid, msg_red, "ERROR: Maximum gang zones have been reached");

    new zonename[30], escpzonename[30];

    if(sscanf(params, "s[30]", zonename)) return SCM(playerid, msg_yellow, "Usage: /makegzone <zone name>");

    if(strlen(zonename) < 5 || strlen(zonename) > 30 ) return SCM(playerid, msg_red, "ERROR: Zone Name Length: 5 - 30");

    mysql_escape_string(zonename, escpzonename, sizeof(escpzonename));

    mysql_format(fwdb, MainStr,sizeof(MainStr), "INSERT INTO `gzones` (`z_Name`) VALUES ('%e')", escpzonename);
    mysql_tquery(fwdb, MainStr, "OnPlayerCreateGangZone", "is", playerid, zonename);
	return 1;
}

publicEx OnPlayerCreateGangZone(playerid, zname[])
{
    new z_ID = cache_insert_id(), cgang_label[300];
    
    GZInfo[z_ID][Zone_ID] = z_ID;

    GetPlayerPos(playerid, GZInfo[z_ID][Zone_X],GZInfo[z_ID][Zone_Y],GZInfo[z_ID][Zone_Z] );
    
    GZInfo[z_ID][Zone_Area] = GangZoneCreate(GZInfo[z_ID][Zone_X] - 70.0 , GZInfo[z_ID][Zone_Y] - 70.0, GZInfo[z_ID][Zone_X] + 70.0, GZInfo[z_ID][Zone_Y] + 70.0);

    GZInfo[z_ID][Zone_Streamer] = CreateDynamicSphere(GZInfo[z_ID][Zone_X],GZInfo[z_ID][Zone_Y],GZInfo[z_ID][Zone_Z], 70, .worldid = FREEROAM_WORLD);
    
    strmid(GZInfo[z_ID][Zone_Name], zname, 0, 30,30);

    format(cgang_label, sizeof(cgang_label), ""text_white"["text_red"Gang Zone"text_white"]\n\nZone ID: "text_yellow"%i\n"text_white"Zone Name: "text_yellow"%s\n"text_white"Zone Owner: "text_yellow"None\n"text_white"Zone Status: "text_green"Capturable",z_ID,GZInfo[z_ID][Zone_Name]);
    GZInfo[z_ID][Zone_Label] = CreateDynamic3DTextLabel(cgang_label, msg_white,GZInfo[z_ID][Zone_X],GZInfo[z_ID][Zone_Y],GZInfo[z_ID][Zone_Z]+0.40, 100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, FREEROAM_WORLD);

    

    GangZoneShowForAll(GZInfo[z_ID][Zone_Area], ZCOLOR_INSTOCK);

	GZInfo[z_ID][Zone_Status] = Zone_InStock;
	GZInfo[z_ID][Zone_LockTime] = 0;
	GZInfo[z_ID][Zone_Owner] = 0;
    GZInfo[z_ID][Zone_Exist] = true;
    mysql_format(fwdb, MainStr,sizeof(MainStr), "UPDATE `gzones` SET `z_PosX` = %f, `z_PosY` = %f, `z_PosZ` = %f WHERE `z_ID` = %d", GZInfo[z_ID][Zone_X],GZInfo[z_ID][Zone_Y],GZInfo[z_ID][Zone_Z], z_ID);
    mysql_query(fwdb, MainStr);
    TotalGangZones++;
	return 1;
}

SyncGangZoneForPlayer(playerid)
{ 
	  for(new gzloop = 0; gzloop < MAX_GZONES; gzloop++) 
	  {
	  	     if(!GZInfo[gzloop][Zone_Exist]) continue;

		     if(PlayerInfo[playerid][Player_GangID] == 0)
		     {
		          GangZoneShowForPlayer(playerid, GZInfo[gzloop][Zone_Area] , ZCOLOR_INSTOCK);
		       
		     }
		     else 
		     {
		     	if(GZInfo[gzloop][Zone_Owner] == PlayerInfo[playerid][Player_GangID])
		     	{
		               GangZoneShowForPlayer(playerid, GZInfo[gzloop][Zone_Area] , ZCOLOR_OWN);
		     	}
		     	else 
		     	{
		     	      GangZoneShowForPlayer(playerid, GZInfo[gzloop][Zone_Area] , ZCOLOR_ENEMY);
		     	}
		     }
	 }
}


CMD:destroygzone(playerid, params[])
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    
    if(PlayerInfo[playerid][Player_Admin] != Founder_Level) return SCM(playerid, msg_red, "ERROR: haha, Ez guy!");
    if( Iter_Contains(InGangWar,PlayerInfo[playerid][Player_GangID]) ) 
    {
         return  ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" Your gang is currently involved in a gang war", "OK", "");
    }
    
    new getzoneid;
    if(sscanf(params, "i", getzoneid)) return SCM(playerid, msg_yellow, "Usage: /destroygzone <id>");
    
    if(!GZInfo[getzoneid][Zone_Exist]) return SCM(playerid, msg_red, "ERROR: You have specified a wrong id");
    if(GZInfo[getzoneid][Zone_Status] == Zone_InAttack) return SCM(playerid, msg_yellow, "ERROR: Gang Zone is currently under attack! Please try again later");
    
    GZInfo[getzoneid][Zone_Owner] = 0;
    GZInfo[getzoneid][Zone_LockTime] = 0;
    GZInfo[getzoneid][Zone_Status] = Zone_InStock;
    GZInfo[getzoneid][Zone_ID] = 0;
    
    mysql_format(fwdb, MainStr, sizeof(MainStr), "DELETE FROM `gzones` WHERE `z_ID` = %d", getzoneid );
    mysql_query(fwdb, MainStr);

    DestroyDynamicArea(GZInfo[getzoneid][Zone_Streamer]);
    DestroyDynamic3DTextLabel(GZInfo[getzoneid][Zone_Label]);
    GangZoneDestroy(GZInfo[getzoneid][Zone_Area]);
    TotalGangZones--;
    GZInfo[getzoneid][Zone_Exist] = false;
   	return 1;
}

CMD:gwar(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");
    if(PlayerInfo[playerid][Player_GangRank] < 2) return SCM(playerid, msg_red, "ERROR: You need to be Leader+ to start a gang war");
    
    if( Iter_Contains(InGangWar,PlayerInfo[playerid][Player_GangID]) ) 
    {
         return  ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" Your gang is currently involved in a gang war", "OK", "");
    }
    if(GetGangOwnedZones(PlayerInfo[playerid][Player_GangID]) >= GANG_MAX_ZONES)
    {
        ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" Your gang has owned maximum number of gang zones", "OK", "");
        return 1;
    }
    new gzone, bool:inArea = false, gpcount = 0;
    for(gzone = 0; gzone < MAX_GZONES; gzone++) if(GZInfo[gzone][Zone_Exist])
    {
        if(IsPlayerInRangeOfPoint(playerid, 7.0, GZInfo[gzone][Zone_X],GZInfo[gzone][Zone_Y],GZInfo[gzone][Zone_Z]))
        {
            inArea = true;
            break;
        } 
    }
    if(!inArea) return SCM(playerid, msg_red, "ERROR: You need in a gang zone to use this command");
    if(GZInfo[gzone][Zone_LockTime])
    {
         new mint = floatround(GZInfo[gzone][Zone_LockTime] / 60);
         if(mint == 0) format(MainStr, sizeof(MainStr), ""text_yellow"Gang Zone will be unlocked in few seconds");
         else format(MainStr, sizeof(MainStr), ""text_yellow"Gang Zone is locked for %d minutes.",mint);

         ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", MainStr, "OK", "");
         return 1;
    }
    if(GZInfo[gzone][Zone_Owner] == PlayerInfo[playerid][Player_GangID]) return SCM(playerid, msg_red, "INFO: Your gang already owns this zone");
    if(GZInfo[gzone][Zone_Status] == Zone_InAttack) return SCM(playerid, msg_red, "INFO: Gang Zone is currently being attacked");

    if(GZInfo[gzone][Zone_Owner] != 0)
    {
          if(Iter_Contains(InGangWar, GZInfo[gzone][Zone_Owner]))
          {
             return  ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Zone", ""text_white" The zone owner is currently involved in a gang war", "OK", "");
          }
    }

    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 7.0, GZInfo[gzone][Zone_X],GZInfo[gzone][Zone_Y],GZInfo[gzone][Zone_Z]))
        {
            if(PlayerInfo[i][Player_GangID] == PlayerInfo[playerid][Player_GangID] && PlayerInfo[i][Player_Mode] == MODE_FREEROAM && !PlayerInfo[i][Player_InGWAR] && PlayerInfo[i][Player_Afk] == 0)
            {  
                PlayerInfo[i][Player_InGWAR] = true;
                ResetPlayerGod(i);
                WeaponReset(i);
                SCM(i, -1, ""text_green"You are now in Gang War mode, type /lgwar to leave Gang War!");
                TextDrawShowForPlayer(i, GZInfo[gzone][Zone_TD]);
                
                GangZoneFlashForPlayer(i, GZInfo[gzone][Zone_Area], ZCOLOR_OWN);
                gpcount++;
            }
        }
    }
    GZInfo[gzone][Zone_Status] = Zone_InAttack;
    GZInfo[gzone][Zone_AttackTime] = ZONE_ATT_TIME;
    GZInfo[gzone][Zone_Attacker] = PlayerInfo[playerid][Player_GangID];
    Iter_Add(InGangWar, PlayerInfo[playerid][Player_GangID]);

    if(gpcount == 1)
    {
        format(MainStr, sizeof(MainStr),""GANG_TAG" "GANG_CHAT"%s %s(%i) has started to capture the gang zone: %s with 1 tied member.", GangRanks[PlayerInfo[playerid][Player_GangRank]], PlayerInfo[playerid][Player_Name], playerid, GZInfo[gzone][Zone_Name]);
    }
    else 
    {
        format(MainStr, sizeof(MainStr),""GANG_TAG" "GANG_CHAT"%s %s(%i) has started to capture the gang zone: %s with %i tied members.", GangRanks[PlayerInfo[playerid][Player_GangRank]], PlayerInfo[playerid][Player_Name], playerid,GZInfo[gzone][Zone_Name], gpcount);
    }
    SendGangNotice(PlayerInfo[playerid][Player_GangID], MainStr);

    if(GZInfo[gzone][Zone_Owner] != 0)
    {
       format(MainStr, sizeof(MainStr),""GANG_TAG" "GANG_CHAT"Gang %s has started to capture your gang zone: %s", GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Name], GZInfo[gzone][Zone_Name]);
       SendGangNotice(GZInfo[gzone][Zone_Owner], MainStr);
       Iter_Add(InGangWar, GZInfo[gzone][Zone_Owner]);
    }
    
    format(MainStr, sizeof(MainStr), ""text_white"** FW {D2691E} Gang %s has started to capture the gang zone: %s with %i tied member(s)", GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Name], GZInfo[gzone][Zone_Name], gpcount);
    SCMToAll(msg_white, MainStr);
    if(GZInfo[gzone][Zone_Owner] != 0)
    {
        format(MainStr, sizeof(MainStr), ""text_white"** FW {D2691E} Current Gang Zone Owner: %s", GangInfo[GZInfo[gzone][Zone_Owner]][Gang_Name]);
        SCMToAll(-1, MainStr);
    }
    return 1;
}

CMD:gwars(playerid)
{
  new count = 0, finstring[700];
  for(new i = 0; i < MAX_GZONES; i++)  if(GZInfo[i][Zone_Exist])
  {
         if(GZInfo[i][Zone_Status] == Zone_InAttack)
         {
                format(MainStr, sizeof(MainStr), "\n%s gang is attacking the zone %s", GangInfo[GZInfo[i][Zone_Attacker]][Gang_Name], GZInfo[i][Zone_Name]);
                strcat(finstring, MainStr);
                count++;
         }
  }
  if(count > 0) ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Gang Info", finstring, "OK", "");
  else  SCM(playerid, msg_red ,"INFO: There are no gang wars currently going on.");
  return 1;
}
CMD:leavegwar(playerid) return cmd_lgwar(playerid);
CMD:lgwar(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");
    if(!PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "ERROR: You are not involved in any gang war");

    PlayerInfo[playerid][Player_InGWAR] = false;
    for(new i = 0; i < MAX_GZONES; i++)
	{
	  TextDrawHideForPlayer(i, GZInfo[i][Zone_TD]);
      GangZoneStopFlashForPlayer(playerid, GZInfo[i][Zone_Area]);
	}
    SCM(playerid, -1, ""text_green"You are no longer invloved in Gang War mode!");
    
    return 1;
}

CMD:capture(playerid)
{
     if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
     if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
     if(PlayerInfo[playerid][Player_GangID] == 0) return SCM(playerid, msg_red, "ERROR: You are not in a gang");
    
     new gzone, bool:InArea = false;
     for(gzone = 0; gzone < MAX_GZONES; gzone++) if(GZInfo[gzone][Zone_Exist])
     {
         if(IsPlayerInRangeOfPoint(playerid, 7.0, GZInfo[gzone][Zone_X],GZInfo[gzone][Zone_Y],GZInfo[gzone][Zone_Z]))
         { 
              InArea = true;
              break;
         }
     }
     if(!InArea) return SCM(playerid, msg_red, "ERROR: You need in a gang zone to use this command");
     if(GZInfo[gzone][Zone_Status] != Zone_InAttack) return SCM(playerid, msg_red, "INFO: This zone is not being under attacked");
     if(GZInfo[gzone][Zone_Owner] != PlayerInfo[playerid][Player_GangID]) return SCM(playerid, msg_red, "INFO: This zone does not belong to your gang");


     new gcpcount = 0, Float:gPOs[3];
     foreach(new i : Player)
     {
        GetPlayerPos(i, gPOs[0], gPOs[1], gPOs[2]);

        if(IsPointInDynamicArea(GZInfo[gzone][Zone_Area], gPOs[0], gPOs[1], gPOs[2]))
        {
            if(PlayerInfo[i][Player_GangID] == PlayerInfo[playerid][Player_GangID] && PlayerInfo[i][Player_Mode] == MODE_FREEROAM && PlayerInfo[i][Player_InGWAR] && PlayerInfo[i][Player_Afk] == 0)
            {  
                    gcpcount++;
            }
        }
     }

        
     if(gcpcount != 0)
     {
        SCM(playerid, -1, ""text_red"You cannot re-capture this zone as there is still the attacking gang around");
     }
     else
     {
        
        format(MainStr, sizeof(MainStr), ""GANG_TAG" "GANG_CHAT" Your gang failed to capture zone: %s. %s(%i) re-captured it!", GZInfo[gzone][Zone_Name], PlayerInfo[playerid][Player_Name], playerid);
        SendGangNotice(GZInfo[gzone][Zone_Attacker], MainStr);

        format(MainStr, sizeof(MainStr), ""GANG_TAG" "GANG_CHAT"%s %s(%i) re-captured zone: %s which was under attack.", GangRanks[PlayerInfo[playerid][Player_GangRank]], PlayerInfo[playerid][Player_Name], playerid, GZInfo[gzone][Zone_Name]);
        SendGangNotice(PlayerInfo[playerid][Player_GangID], MainStr);

        format(MainStr, sizeof(MainStr),  ""text_white"** FW {D2691E}Gang %s failed to capture zone: %s. Zone remains %s territory and will be locked for %d minutes!", GangInfo[ GZInfo[gzone][Zone_Attacker] ][Gang_Name], GZInfo[gzone][Zone_Name], GangInfo[ PlayerInfo[playerid][Player_GangID] ][Gang_Name], ZONE_REST_CAPFAIL);
        SCMToAll(-1, MainStr);
        
        foreach(new p : Player)
        {
            if(PlayerInfo[p][Player_InGWAR])
            {
                if(PlayerInfo[p][Player_GangID] == GZInfo[gzone][Zone_Attacker])
                {
                    PlayerInfo[p][Player_GangID] = false;
                    TextDrawHideForPlayer(p, GZInfo[gzone][Zone_TD]);
                    GangZoneStopFlashForPlayer(p, GZInfo[gzone][Zone_Area]);
                }
                if(GZInfo[gzone][Zone_Owner] != 0 && PlayerInfo[p][Player_GangID] == GZInfo[gzone][Zone_Owner])
                {
                    PlayerInfo[p][Player_GangID] = false;
                    SendPlayerMoney(p, 20000);
                    SendPlayerScore(p, 15);
                    PlayerPoints(p,"~y~Points~w~:~n~  ~b~Score~w~: ~g~+15~n~  ~g~~h~Cash~w~: ~g~+$20,000");
                }
            }
        }
        Iter_Remove(InGangWar, PlayerInfo[playerid][Player_GangID]);
        Iter_Remove(InGangWar, GZInfo[gzone][Zone_Attacker]);
        GZInfo[gzone][Zone_LockTime] = ZONE_REST_CAPFAIL;
        GZInfo[gzone][Zone_Status] = Zone_InLock;
        GZInfo[gzone][Zone_Attacker] = 0;
        UpdateGangZoneLabel(gzone);
     }
     return 1;
}


stock UpdateGangZoneLabel(zoneid)
{
      new gang_label[300];
      if(GZInfo[zoneid][Zone_Owner] == 0)
      {
              format(gang_label, sizeof(gang_label), ""text_white"["text_red"Gang Zone"text_white"]\n\nZone ID: "text_yellow"%i\n"text_white"Zone Name: "text_yellow"%s\n"text_white"Zone Owner: "text_yellow"None\n"text_white"Zone Status: "text_green"Capturable",zoneid,GZInfo[zoneid][Zone_Name]);
      }
      else 
      {
              format(gang_label, sizeof(gang_label), ""text_white"["text_red"Gang Zone"text_white"]\n\nZone ID: "text_yellow"%i\n"text_white"Zone Name: "text_yellow"%s\n"text_white"Zone Owner: "text_yellow"%s\n"text_white"Zone Status: %s",zoneid,GZInfo[zoneid][Zone_Name], GangInfo[GZInfo[zoneid][Zone_Owner]][Gang_Name], GZInfo[zoneid][Zone_Status] == Zone_InStock ? (text_green"Capturable") : (text_red"Locked") );
      }
      Update3DTextLabelText(GZInfo[zoneid][Zone_Label], msg_white, gang_label);
}

SecToMin(secs)
{
    new etmp[80];
    new mint = floatround(secs / 60);
    secs -= mint * 60;
    format(etmp, sizeof(etmp), "%i minutes %02i seconds", mint, secs);
    return etmp;
}
ChangeSecToMin(secs)
{
    new etmp[80];
    new mint = floatround(secs / 60);
    secs -= mint * 60;
    format(etmp, sizeof(etmp), "%i:%02i", mint, secs);
    return etmp;
}
SaveGangZones()
{
   for(new i = 0; i < MAX_GZONES; i++)
   {
      if(!GZInfo[i][Zone_Exist]) continue;
      mysql_format(fwdb, MainStr, sizeof MainStr, "UPDATE `gzones` SET `z_LockTime` = %d WHERE `z_ID` = %d", GZInfo[i][Zone_LockTime], GZInfo[i][Zone_ID]);
      mysql_query(fwdb, MainStr);
   }
}
GetGangOwnedZones(gangid)
{
    new gzocount = 0;
    for(new i = 0; i < MAX_GZONES; i++)
    {
       if(!GZInfo[i][Zone_Exist]) continue;
       if(GZInfo[i][Zone_Owner] == gangid)
       {
          gzocount++;
       }
    }
    return gzocount; 
}
hook OnPlayerEnterDynamicArea(playerid, areaid)
{
    for(new i = 0; i < MAX_GZONES; i++) if(GZInfo[i][Zone_Exist])
    {
        if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) continue;

        if(areaid == GZInfo[i][Zone_Streamer] && GZInfo[i][Zone_Owner] != 0 && GZInfo[i][Zone_Owner] == PlayerInfo[playerid][Player_GangID] && GZInfo[i][Zone_Status] == Zone_InAttack)
        {
                PlayerInfo[playerid][Player_InGWAR] = true;
                ResetPlayerGod(playerid);
                WeaponReset(playerid);

                SCM(playerid, -1, ""text_green"You are now in Gang War mode, type /lgwar to leave Gang War!");
                SendPlayerTextNotice(playerid, "~y~~h~Gang War entered~n~~r~/capture to re-capture", "");
                break;
        }

        if(areaid == GZInfo[i][Zone_Streamer] && GZInfo[i][Zone_Status] == Zone_InAttack && PlayerInfo[playerid][Player_GangID] != GZInfo[i][Zone_Owner] && PlayerInfo[playerid][Player_GangID] != GZInfo[i][Zone_Attacker])
        {
            if(IsPlayerInAnyVehicle(playerid))
            {
                new Float:vPOS[4];
                new vID = GetPlayerVehicleID(playerid);
                GetVehicleVelocity(vID , vPOS[0], vPOS[1], vPOS[2]);
                GetVehicleZAngle(vID , vPOS[3]);

                vPOS[0] += (-1.1 * floatsin(-vPOS[3], degrees));
                vPOS[1] += (-1.1 * floatcos(-vPOS[3], degrees));

                SetVehicleVelocity(vID , vPOS[0], vPOS[1], vPOS[2] * 1.2);
                SendPlayerTextNotice(playerid, "~y~~h~Gang War~n~~w~ongoing","");
            }
            else if(!IsPlayerInAnyVehicle(playerid))
            {
                new Float:POS[3];
                GetPlayerPos(playerid, POS[0],POS[1],POS[2]);
                SetPlayerPos(playerid, POS[0],POS[1]-5,POS[2]);
                SendPlayerTextNotice(playerid, "~y~~h~Gangwar is ongoing!", "");
            }
            break;
        }
    }
    return 1;
}

hook OnPlayerLeaveDynamicArea(playerid, areaid)
{
    if(PlayerInfo[playerid][Player_InGWAR])
    {
        for(new i = 0; i < MAX_GZONES; i++) if(GZInfo[i][Zone_Exist])
        {
            
            if(GZInfo[i][Zone_Owner] != 0 && GZInfo[i][Zone_Owner] == PlayerInfo[playerid][Player_GangID]  && GZInfo[i][Zone_Status] == Zone_InAttack && areaid ==  GZInfo[i][Zone_Streamer] )
            {
                // Player left GWAR
                PlayerInfo[playerid][Player_InGWAR] = false;
                SCM(playerid, -1, ""text_green"You have left the gang zone, get back fast and defend it!");
                break;
            }
        }
    }
    return 1;
}
