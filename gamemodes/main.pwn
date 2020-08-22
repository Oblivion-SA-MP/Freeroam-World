/* =====================================================================
                        Freeroam World @ 2020
                        Scripted By: Oblivion
                        Script Version :  v1
========================================================================*/

/* 
    Script Information

SA-MP Server 0.3.7 R4
MySQL Version: r41-4
sscanf2 version 2.8.2
Streamer version 2.9.4
ZCMD 
Foreach 

Compiler Note: -d3

*/

#include <a_samp>
#include <a_mysql41>                        
#include <sscanf2>
#include <foreach>
#include <streamer>                    
#include <zcmd>  

// Server Defines
#undef MAX_PLAYERS
#define MAX_PLAYERS  100  
#undef MAX_VEHICLES
#define MAX_VEHICLES 1999 

#define SERVER_HOST     "Freerom World"
#define SERVER_MODE     "Stunt/Minigames/Fun"                        
#define SERVER_VERSION  "Version: v1"
#define SERVER_MAP      "FW v1"                        
#define SERVER_TAG      "{F0F0F0}:: {F2F853}FW {F0F0F0}::"
#define SERVER_LANG     "English"
#define SERVER_WEB      "www.freeroamworld.com"                        
// Server Defines Ends


// MySQL Connection
new MySQL:fwdb;
#define	MySQLHost  "localhost" 
#define MySQLUser  "root"
#define MySQLPass  ""
#define MySQLDB    "fwdb"
// End of MySQL Connection

// Defines Colors
#define text_red      "{FF000F}"
#define msg_red       (0xFF000FFF)
#define text_yellow   "{F2F853}"
#define msg_yellow    (0xF2F853FF)
#define text_green    "{0BDDC4}"
#define msg_green     (0x0BDDC4FF)
#define text_blue     "{0087FF}"
#define msg_blue      (0x3793FAFF)
#define text_white    "{F0F0F0}"
#define msg_white     (0xFEFEFEFF) 

#define SCM                        SendClientMessage        
#define SCMToAll                   SendClientMessageToAll   
#define DIALOG_TAG                 ""text_white"["text_yellow"FW"text_white"] ::" 
#define ADMIN_LEVELS               (5)
#define None_LEVEL                 (0)
#define Junior_LEVEL               (1)
#define Lead_LEVEL                 (2)   
#define Head_LEVEL                 (3)
#define CEA_LEVEL                  (4)
#define Founder_LEVEL              (5)
// Animinations
#define PreloadAnimLib(%1,%2)	   ApplyAnimation(%1,%2,"NULL",0.0,0,0,0,0,0)

#define publicEx%0(%1) forward %0(%1); public %0(%1)
// Server Includes
#include "inc\convertunix.inc"

enum timers
{
	Server_Timer,
}
new ServerTime[timers];
// Player Information
enum pinfo 
{
     Player_ID,
     Player_Name[MAX_PLAYER_NAME],
     Player_Pass[65],
     Player_Salts[11],
     Player_IP[16],
     Player_Color,
     Player_LastOnline,
     Player_Joined,
     Player_PlayTime,
     Player_JoinTick,
     Player_LoginError,
     Player_Skin,
     Player_Cash,
     Player_Score,
     Player_Kills,
     Player_Deaths,
     Player_Admin,

     // bool
     bool:Player_Logged,
     bool:Player_FirstSpawn,
     bool:Player_Spawned
};
new PlayerInfo[MAX_PLAYERS][pinfo];
// Player Information Ends

// Dialogs
enum 
{
    DIALOG_NONE,
    DIALOG_REGISTER,
    DIALOG_LOGIN
};


static const AdminLevels[ADMIN_LEVELS + 1 ][] =
{
	{"Member"},
	{"Junior Administrator"},
	{"Lead Administrator"},
	{"Head Administrator"},
	{"Chief Executive Administrator"},
	{"Founder"}
};

static const PlayerColors[511] =
{
	0x000022FF, 0x000044FF, 0x000066FF, 0x000088FF, 0x0000AAFF, 0x0000CCFF, 0x0000EEFF,
	0x002200FF, 0x002222FF, 0x002244FF, 0x002266FF, 0x002288FF, 0x0022AAFF, 0x0022CCFF, 0x0022EEFF,
	0x004400FF, 0x004422FF, 0x004444FF, 0x004466FF, 0x004488FF, 0x0044AAFF, 0x0044CCFF, 0x0044EEFF,
	0x006600FF, 0x006622FF, 0x006644FF, 0x006666FF, 0x006688FF, 0x0066AAFF, 0x0066CCFF, 0x0066EEFF,
	0x008800FF, 0x008822FF, 0x008844FF, 0x008866FF, 0x008888FF, 0x0088AAFF, 0x0088CCFF, 0x0088EEFF,
	0x00AA00FF, 0x00AA22FF, 0x00AA44FF, 0x00AA66FF, 0x00AA88FF, 0x00AAAAFF, 0x00AACCFF, 0x00AAEEFF,
	0x00CC00FF, 0x00CC22FF, 0x00CC44FF, 0x00CC66FF, 0x00CC88FF, 0x00CCAAFF, 0x00CCCCFF, 0x00CCEEFF,
	0x00EE00FF, 0x00EE22FF, 0x00EE44FF, 0x00EE66FF, 0x00EE88FF, 0x00EEAAFF, 0x00EECCFF, 0x00EEEEFF,
	0x220000FF, 0x220022FF, 0x220044FF, 0x220066FF, 0x220088FF, 0x2200AAFF, 0x2200CCFF, 0x2200FFFF,
	0x222200FF, 0x222222FF, 0x222244FF, 0x222266FF, 0x222288FF, 0x2222AAFF, 0x2222CCFF, 0x2222EEFF,
	0x224400FF, 0x224422FF, 0x224444FF, 0x224466FF, 0x224488FF, 0x2244AAFF, 0x2244CCFF, 0x2244EEFF,
	0x226600FF, 0x226622FF, 0x226644FF, 0x226666FF, 0x226688FF, 0x2266AAFF, 0x2266CCFF, 0x2266EEFF,
	0x228800FF, 0x228822FF, 0x228844FF, 0x228866FF, 0x228888FF, 0x2288AAFF, 0x2288CCFF, 0x2288EEFF,
	0x22AA00FF, 0x22AA22FF, 0x22AA44FF, 0x22AA66FF, 0x22AA88FF, 0x22AAAAFF, 0x22AACCFF, 0x22AAEEFF,
	0x22CC00FF, 0x22CC22FF, 0x22CC44FF, 0x22CC66FF, 0x22CC88FF, 0x22CCAAFF, 0x22CCCCFF, 0x22CCEEFF,
	0x22EE00FF, 0x22EE22FF, 0x22EE44FF, 0x22EE66FF, 0x22EE88FF, 0x22EEAAFF, 0x22EECCFF, 0x22EEEEFF,
	0x440000FF, 0x440022FF, 0x440044FF, 0x440066FF, 0x440088FF, 0x4400AAFF, 0x4400CCFF, 0x4400FFFF,
	0x442200FF, 0x442222FF, 0x442244FF, 0x442266FF, 0x442288FF, 0x4422AAFF, 0x4422CCFF, 0x4422EEFF,
	0x444400FF, 0x444422FF, 0x444444FF, 0x444466FF, 0x444488FF, 0x4444AAFF, 0x4444CCFF, 0x4444EEFF,
	0x446600FF, 0x446622FF, 0x446644FF, 0x446666FF, 0x446688FF, 0x4466AAFF, 0x4466CCFF, 0x4466EEFF,
	0x448800FF, 0x448822FF, 0x448844FF, 0x448866FF, 0x448888FF, 0x4488AAFF, 0x4488CCFF, 0x4488EEFF,
	0x44AA00FF, 0x44AA22FF, 0x44AA44FF, 0x44AA66FF, 0x44AA88FF, 0x44AAAAFF, 0x44AACCFF, 0x44AAEEFF,
	0x44CC00FF, 0x44CC22FF, 0x44CC44FF, 0x44CC66FF, 0x44CC88FF, 0x44CCAAFF, 0x44CCCCFF, 0x44CCEEFF,
	0x44EE00FF, 0x44EE22FF, 0x44EE44FF, 0x44EE66FF, 0x44EE88FF, 0x44EEAAFF, 0x44EECCFF, 0x44EEEEFF,
	0x660000FF, 0x660022FF, 0x660044FF, 0x660066FF, 0x660088FF, 0x6600AAFF, 0x6600CCFF, 0x6600FFFF,
	0x662200FF, 0x662222FF, 0x662244FF, 0x662266FF, 0x662288FF, 0x6622AAFF, 0x6622CCFF, 0x6622EEFF,
	0x664400FF, 0x664422FF, 0x664444FF, 0x664466FF, 0x664488FF, 0x6644AAFF, 0x6644CCFF, 0x6644EEFF,
	0x666600FF, 0x666622FF, 0x666644FF, 0x666666FF, 0x666688FF, 0x6666AAFF, 0x6666CCFF, 0x6666EEFF,
	0x668800FF, 0x668822FF, 0x668844FF, 0x668866FF, 0x668888FF, 0x6688AAFF, 0x6688CCFF, 0x6688EEFF,
	0x66AA00FF, 0x66AA22FF, 0x66AA44FF, 0x66AA66FF, 0x66AA88FF, 0x66AAAAFF, 0x66AACCFF, 0x66AAEEFF,
	0x66CC00FF, 0x66CC22FF, 0x66CC44FF, 0x66CC66FF, 0x66CC88FF, 0x66CCAAFF, 0x66CCCCFF, 0x66CCEEFF,
	0x66EE00FF, 0x66EE22FF, 0x66EE44FF, 0x66EE66FF, 0x66EE88FF, 0x66EEAAFF, 0x66EECCFF, 0x66EEEEFF,
	0x880000FF, 0x880022FF, 0x880044FF, 0x880066FF, 0x880088FF, 0x8800AAFF, 0x8800CCFF, 0x8800FFFF,
	0x882200FF, 0x882222FF, 0x882244FF, 0x882266FF, 0x882288FF, 0x8822AAFF, 0x8822CCFF, 0x8822EEFF,
	0x884400FF, 0x884422FF, 0x884444FF, 0x884466FF, 0x884488FF, 0x8844AAFF, 0x8844CCFF, 0x8844EEFF,
	0x886600FF, 0x886622FF, 0x886644FF, 0x886666FF, 0x886688FF, 0x8866AAFF, 0x8866CCFF, 0x8866EEFF,
	0x888800FF, 0x888822FF, 0x888844FF, 0x888866FF, 0x888888FF, 0x8888AAFF, 0x8888CCFF, 0x8888EEFF,
	0x88AA00FF, 0x88AA22FF, 0x88AA44FF, 0x88AA66FF, 0x88AA88FF, 0x88AAAAFF, 0x88AACCFF, 0x88AAEEFF,
	0x88CC00FF, 0x88CC22FF, 0x88CC44FF, 0x88CC66FF, 0x88CC88FF, 0x88CCAAFF, 0x88CCCCFF, 0x88CCEEFF,
	0x88EE00FF, 0x88EE22FF, 0x88EE44FF, 0x88EE66FF, 0x88EE88FF, 0x88EEAAFF, 0x88EECCFF, 0x88EEEEFF,
	0xAA0000FF, 0xAA0022FF, 0xAA0044FF, 0xAA0066FF, 0xAA0088FF, 0xAA00AAFF, 0xAA00CCFF, 0xAA00FFFF,
	0xAA2200FF, 0xAA2222FF, 0xAA2244FF, 0xAA2266FF, 0xAA2288FF, 0xAA22AAFF, 0xAA22CCFF, 0xAA22EEFF,
	0xAA4400FF, 0xAA4422FF, 0xAA4444FF, 0xAA4466FF, 0xAA4488FF, 0xAA44AAFF, 0xAA44CCFF, 0xAA44EEFF,
	0xAA6600FF, 0xAA6622FF, 0xAA6644FF, 0xAA6666FF, 0xAA6688FF, 0xAA66AAFF, 0xAA66CCFF, 0xAA66EEFF,
	0xAA8800FF, 0xAA8822FF, 0xAA8844FF, 0xAA8866FF, 0xAA8888FF, 0xAA88AAFF, 0xAA88CCFF, 0xAA88EEFF,
	0xAAAA00FF, 0xAAAA22FF, 0xAAAA44FF, 0xAAAA66FF, 0xAAAA88FF, 0xAAAAAAFF, 0xAAAACCFF, 0xAAAAEEFF,
	0xAACC00FF, 0xAACC22FF, 0xAACC44FF, 0xAACC66FF, 0xAACC88FF, 0xAACCAAFF, 0xAACCCCFF, 0xAACCEEFF,
	0xAAEE00FF, 0xAAEE22FF, 0xAAEE44FF, 0xAAEE66FF, 0xAAEE88FF, 0xAAEEAAFF, 0xAAEECCFF, 0xAAEEEEFF,
	0xCC0000FF, 0xCC0022FF, 0xCC0044FF, 0xCC0066FF, 0xCC0088FF, 0xCC00AAFF, 0xCC00CCFF, 0xCC00FFFF,
	0xCC2200FF, 0xCC2222FF, 0xCC2244FF, 0xCC2266FF, 0xCC2288FF, 0xCC22AAFF, 0xCC22CCFF, 0xCC22EEFF,
	0xCC4400FF, 0xCC4422FF, 0xCC4444FF, 0xCC4466FF, 0xCC4488FF, 0xCC44AAFF, 0xCC44CCFF, 0xCC44EEFF,
	0xCC6600FF, 0xCC6622FF, 0xCC6644FF, 0xCC6666FF, 0xCC6688FF, 0xCC66AAFF, 0xCC66CCFF, 0xCC66EEFF,
	0xCC8800FF, 0xCC8822FF, 0xCC8844FF, 0xCC8866FF, 0xCC8888FF, 0xCC88AAFF, 0xCC88CCFF, 0xCC88EEFF,
	0xCCAA00FF, 0xCCAA22FF, 0xCCAA44FF, 0xCCAA66FF, 0xCCAA88FF, 0xCCAAAAFF, 0xCCAACCFF, 0xCCAAEEFF,
	0xCCCC00FF, 0xCCCC22FF, 0xCCCC44FF, 0xCCCC66FF, 0xCCCC88FF, 0xCCCCAAFF, 0xCCCCCCFF, 0xCCCCEEFF,
	0xCCEE00FF, 0xCCEE22FF, 0xCCEE44FF, 0xCCEE66FF, 0xCCEE88FF, 0xCCEEAAFF, 0xCCEECCFF, 0xCCEEEEFF,
	0xEE0000FF, 0xEE0022FF, 0xEE0044FF, 0xEE0066FF, 0xEE0088FF, 0xEE00AAFF, 0xEE00CCFF, 0xEE00FFFF,
	0xEE2200FF, 0xEE2222FF, 0xEE2244FF, 0xEE2266FF, 0xEE2288FF, 0xEE22AAFF, 0xEE22CCFF, 0xEE22EEFF,
	0xEE4400FF, 0xEE4422FF, 0xEE4444FF, 0xEE4466FF, 0xEE4488FF, 0xEE44AAFF, 0xEE44CCFF, 0xEE44EEFF,
	0xEE6600FF, 0xEE6622FF, 0xEE6644FF, 0xEE6666FF, 0xEE6688FF, 0xEE66AAFF, 0xEE66CCFF, 0xEE66EEFF,
	0xEE8800FF, 0xEE8822FF, 0xEE8844FF, 0xEE8866FF, 0xEE8888FF, 0xEE88AAFF, 0xEE88CCFF, 0xEE88EEFF,
	0xEEAA00FF, 0xEEAA22FF, 0xEEAA44FF, 0xEEAA66FF, 0xEEAA88FF, 0xEEAAAAFF, 0xEEAACCFF, 0xEEAAEEFF,
	0xEECC00FF, 0xEECC22FF, 0xEECC44FF, 0xEECC66FF, 0xEECC88FF, 0xEECCAAFF, 0xEECCCCFF, 0xEECCEEFF,
	0xEEEE00FF, 0xEEEE22FF, 0xEEEE44FF, 0xEEEE66FF, 0xEEEE88FF, 0xEEEEAAFF, 0xEEEECCFF, 0xEEEEEEFF
};

new ClassModels[28] = 
{
	23, 270, 170, 3, 304,81,1,299,0,199,5,264,26,289,
	28,72,100,115,272,127,138,149,249,
	162,271,285,310,307
};
static const Float:PlayerSpawns[3][4] =
{
	{-2027.3507,145.1084,28.8359,273.7815}, // SF
	{2492.9268,-1668.9504,13.3359,93.6851}, // LS
	{2039.5809,1553.6820,10.6719,178.8951} // LV
};

new MainStr[350];

main(){}
public OnGameModeInit()
{

    fwdb = mysql_connect(""MySQLHost"", ""MySQLUser"",""MySQLPass"",""MySQLDB"");
    mysql_log(ERROR | WARNING); 
  
    if(fwdb == MYSQL_INVALID_HANDLE || mysql_errno(fwdb) != 0) 
    {    
    	 new error[30];
         if(mysql_error(error, sizeof(error), fwdb))
         {
                printf("==========="#SERVER_HOST"===========\n");
                printf("Connection could not be established!\n");
                printf("Error: %s\n", error);
                printf("Server Unloaded!\n");
                printf("====================================\n");
                SendRconCommand("exit");
         }
         return 1;
    }
    printf("==========="#SERVER_HOST"===========\n");
    printf("Connection has been established to "#MySQLHost"");
    printf("Server "#SERVER_VERSION"");
    printf("Started at %s", ConvertUnix(gettime()));
    printf("Server Loaded Successfully.!\n");
    printf("====================================");

    // Server Rcon Info
	SetGameModeText(""SERVER_MODE"");
	SendRconCommand("hostname "SERVER_HOST"");
	SendRconCommand("mapname "SERVER_MAP"");
	SendRconCommand("weburl "SERVER_WEB"");
	SendRconCommand("language "SERVER_LANG"");
    
	// Server Enables/Disables
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
    SetWeather(1);
    SetWorldTime(12);
	EnableVehicleFriendlyFire();
	AllowInteriorWeapons(0);
	DisableInteriorEnterExits();
	DisableNameTagLOS();

    //Player Class Selection
    for(new cmodelid; cmodelid < sizeof(ClassModels); cmodelid++)
    { 
       AddPlayerClass(ClassModels[cmodelid], -1430.8273, 1581.1094, 1055.7191,103.7086,0, 0, 0, 0, 0, 0);
	}

	ServerTime[Server_Timer] = SetTimer("ServerTimer", 1000, true);
    return 1;
}

public OnGameModeExit()
{
    foreach(new i : Player)
	{
		if(PlayerInfo[i][Player_Logged]) PlayerRequestSaveStats(i);
	}

	KillTimer(ServerTime[Server_Timer]);
    mysql_close(fwdb);
	return 1;
}


public OnPlayerConnect(playerid)
{
    ResetPlayerVar(playerid);

    GetPlayerIp(playerid, PlayerInfo[playerid][Player_IP], 16);
    GetPlayerName(playerid, PlayerInfo[playerid][Player_Name], MAX_PLAYER_NAME);
    SetPlayerColor(playerid, PlayerColors[random(sizeof(PlayerColors))]);

    
    format(MainStr, sizeof(MainStr), ""text_green"* %s has connected to the server!", PlayerInfo[playerid][Player_Name]);
    SendClientMessageToAll(msg_green, MainStr);
 
    for(new i = 0; i < 30; i ++) SendClientMessage(playerid,msg_white, "\n");
    SendClientMessage(playerid, msg_white, "=========================="text_red""SERVER_HOST""text_white"==========================");
	SendClientMessage(playerid, msg_white, "Welcome to "text_red"Freeroam World "text_yellow""SERVER_VERSION"");
	SendClientMessage(playerid, msg_white, "Scripted by "text_green"Oblivion");
	SendClientMessage(playerid, msg_white, "Visit our webite at "text_blue""SERVER_WEB"");
	SendClientMessage(playerid, msg_white, "Copyright (c)2020 Freeroam World");
	SendClientMessage(playerid, msg_white, "==============================================================");
    


    // Load Aminimations for Player
	PreloadAnimLib(playerid, "BOMBER");
	PreloadAnimLib(playerid, "RAPPING");
	PreloadAnimLib(playerid, "SHOP");
	PreloadAnimLib(playerid, "BEACH");
	PreloadAnimLib(playerid, "SMOKING");
	PreloadAnimLib(playerid, "FOOD");
	PreloadAnimLib(playerid, "STRIP");
	PreloadAnimLib(playerid, "ON_LOOKERS");
	PreloadAnimLib(playerid, "DEALER");
	PreloadAnimLib(playerid, "CRACK");
	PreloadAnimLib(playerid, "CARRY");
	PreloadAnimLib(playerid, "COP_AMBIENT");
	PreloadAnimLib(playerid, "PARK");
	PreloadAnimLib(playerid, "INT_HOUSE");
	PreloadAnimLib(playerid, "FOOD");
	PreloadAnimLib(playerid, "PED");
    ApplyAnimation(playerid, "DANCING", "DNCE_M_B", 4.0, 1, 0, 0, 0, -1);

    PlayAudioStreamForPlayer(playerid, "https://iil.fjrifj.frl/94c536896829728937d6cc9005e6fbf2/9NRRCX9QCUc/carxcscxcrrxcis");

    PlayerInfo[playerid][Player_JoinTick] = gettime();

    // Ban Check
    mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT `password`,`salts` FROM `users` WHERE `name` ='%e' LIMIT 1;", PlayerInfo[playerid][Player_Name]);
    mysql_tquery(fwdb, MainStr, "OnPlayerAccountCheck", "i", playerid);


    SendDeathMessage(INVALID_PLAYER_ID, playerid, 200);
    return 1;
}
publicEx OnPlayerAccountCheck(playerid)
{
    new rows = cache_num_rows();

    if(rows)
    {
    	cache_get_value_name(0, "password", PlayerInfo[playerid][Player_Pass],65);
        cache_get_value_name(0, "salts", PlayerInfo[playerid][Player_Salts], 11);

        // Ban Check
        mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT `ban_id`,`ban_user`, `ban_admin`, `ban_time`,`ban_lift` ,`ban_reason` FROM `bans` WHERE `ban_user`='%e' OR `ban_ip` = '%s'", PlayerInfo[playerid][Player_Name], PlayerInfo[playerid][Player_IP]);
    	new Cache:bancheck = mysql_query(fwdb, MainStr);

    	new banrows = cache_num_rows();

    	if(banrows)
    	{

                new ban_id, ban_user[MAX_PLAYER_NAME], ban_time, ban_lift, ban_admin[MAX_PLAYER_NAME], ban_msg[600], ban_reason[40];  
                cache_get_value_int(0, 0, ban_id);
                cache_get_value(0, 1, ban_user);
                cache_get_value(0, 2, ban_admin);
                cache_get_value_int(0, 3, ban_time);
                cache_get_value_int(0, 4, ban_lift);
                cache_get_value(0, 5, ban_reason);
                if(ban_lift != 0) // temp ban
                {
                
                    if(gettime() > ban_lift)
                    {
                          mysql_format(fwdb, MainStr, sizeof(MainStr), "DELETE FROM `bans` WHERE `ban_user` = '%e' LIMIT 1;", ban_user);
                          mysql_tquery(fwdb, MainStr);
                          SCM(playerid, msg_white, ""SERVER_TAG" "text_green"Good News: You account ban has been expired! Good Luck!");
                  
                    }
                    else
                    {
                         GameTextForPlayer(playerid, "~r~You are Banned!", 2500, 3);
                         format(ban_msg, sizeof(ban_msg), ""text_white"Hello %s,\nBan ID: %d\nBanned by: %s\nBan Date: %s\nBan Lift: %s\nReason: %s\nWrongly Banned? Do a ban appeal in forum!",
                         	ban_user, ban_id, ban_admin, ConvertUnix(ban_time), ConvertUnix(ban_lift), ban_reason);
                         ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG"  Ban Notice", ban_msg, "OK", "");
                         DelayKick(playerid);
                         cache_delete(bancheck);  
                         return 1;
                    }
                }
                else
                { // Permanent Ban
                	     GameTextForPlayer(playerid, "~r~You are Banned!", 2500, 3);
                         format(ban_msg, sizeof(ban_msg), ""text_white"Hello %s,\nBan ID: %d\nBanned by: %s\nBan Date: %s\nBan Lift: Permanent\nReason: %s\nWrongly Banned? Do a ban appeal in forum!",
                         	ban_user, ban_id, ban_admin, ConvertUnix(ban_time),  ban_reason);
                         ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG"  Ban Notice", ban_msg, "OK", "");
                         DelayKick(playerid);
                         cache_delete(bancheck);  
                         return 1;
                }
	    }
	    else RequestLoginDialog(playerid);
        cache_delete(bancheck);           
    }
    else  RequestRegisterDialog(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(PlayerInfo[playerid][Player_Logged]) PlayerRequestSaveStats(playerid);


    SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);

    // Remove
    if(GetPVarInt(playerid, "PlayerKicked")) DeletePVar(playerid, "PlayerKicked");
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{

    PlayerInfo[playerid][Player_FirstSpawn] = true;
    new spawnrand = random(sizeof(PlayerSpawns));

   
    SetSpawnInfo(playerid, NO_TEAM, PlayerInfo[playerid][Player_Skin] != 999 ? PlayerInfo[playerid][Player_Skin] : GetPlayerSkin(playerid), PlayerSpawns[spawnrand][0], PlayerSpawns[spawnrand][1], 
    	                     PlayerSpawns[spawnrand][2], PlayerSpawns[spawnrand][3], 0, 0, 0, 0, 0, 0);

    if(PlayerInfo[playerid][Player_Skin] != 999)
	{
		 TogglePlayerSpectating(playerid, true);
		 SetTimerEx("ForcePlayerToSpawn", 20, false, "i", playerid);
		 TogglePlayerSpectating(playerid, false);

		 return 1;
	}
	else
	{
		Streamer_UpdateEx(playerid, -1430.8273, 1581.1094, 1055.7191, -1, -1);
		SetPlayerPos(playerid, -1430.8273, 1581.1094, 1055.7191);
		SetPlayerFacingAngle(playerid, 103.7086);
		SetPlayerInterior(playerid, 14);
        SetPlayerCameraPos(playerid, -1435.3335, 1578.2095, 1056.1750);
	    SetPlayerCameraLookAt(playerid, -1434.4907, 1578.7393, 1056.0746);
	    ApplyAnimation(playerid, "DANCING", "DNCE_M_B", 4.1, 1, 1, 1, 1, 1);
	}
    return 1;
}


public OnPlayerRequestSpawn(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return 0; 
    return 1;
}


public OnPlayerSpawn(playerid)
{
	
    PlayerInfo[playerid][Player_Spawned] = true;
    if(PlayerInfo[playerid][Player_FirstSpawn])
    {
        PlayerInfo[playerid][Player_FirstSpawn] = false;
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        StopAudioStreamForPlayer(playerid);
        SetPlayerWorldBounds(playerid, 20000, -20000, 20000, -20000);
        return 1;

    }
	SetCameraBehindPlayer(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetCameraBehindPlayer(playerid);
    SetPlayerWorldBounds(playerid, 20000, -20000, 20000, -20000);

	return 1;
}
CMD:kms(pid) return SetPlayerHealth(pid, 0.0);
public OnPlayerDeath(playerid, killerid, reason)
{
	
	 // To avoid  exploits 
	ShowPlayerDialog(playerid, -1, DIALOG_STYLE_LIST, "Close", "Close", "Close", "Close");

    PlayerInfo[playerid][Player_Spawned] = false;
    

    SendPlayerMoney(playerid, -500);
    PlayerInfo[playerid][Player_Deaths]++;

    if(killerid != INVALID_PLAYER_ID)
    {
    	PlayerInfo[playerid][Player_Kills]++;
    	SendPlayerScore(playerid, 2);
    	SendPlayerMoney(playerid, 5000);
    }

    new spawnrand = random(sizeof(PlayerSpawns));
    SetSpawnInfo(playerid, NO_TEAM, GetPlayerSkin(playerid), PlayerSpawns[spawnrand][0], PlayerSpawns[spawnrand][1], PlayerSpawns[spawnrand][2], PlayerSpawns[spawnrand][3], 0, 0, 0, 0, 0, 0);
    SendDeathMessage(killerid, playerid, reason);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
   
    switch(dialogid)
    {
    	case DIALOG_REGISTER:
    	{
    		if(!response)
			{
				GameTextForPlayer(playerid, "~r~You are Kicked", 2500, 3);
				format(MainStr, sizeof(MainStr), "You have been successfully kicked from the server, %s Have a nice day", PlayerInfo[playerid][Player_Name]);
				SCM(playerid,msg_red, MainStr);
				DelayKick(playerid);
				return true;
			}
            if(strlen(inputtext) < 4 || strlen(inputtext) > 65) 
            	       return RequestRegisterDialog(playerid);

            if(!IsValidChar(inputtext))
			{
				SCM(playerid,msg_red, "ERROR: Password can contain only A-Z, a-z, 0-9, _, [ ], ( )");
				RequestRegisterDialog(playerid);
				return true;
			}

			new samplesalt[11];
			for(new i; i < 10; i++)
			{
				samplesalt[i]= random(79) + 47;
			}
            samplesalt[10] = 0;
            SHA256_PassHash(inputtext, samplesalt, PlayerInfo[playerid][Player_Pass], 65);

            mysql_format(fwdb, MainStr, sizeof(MainStr), "INSERT INTO `users` (`name`, `password`, `salts`,`ip`) VALUES ('%e','%e','%e','%e')", 
            	 PlayerInfo[playerid][Player_Name], PlayerInfo[playerid][Player_Pass],samplesalt, PlayerInfo[playerid][Player_IP]);
            mysql_tquery(fwdb, MainStr, "PlayerRequestRegister", "i", playerid);

    	}
    	case DIALOG_LOGIN:
    	{
            if(!response)
			{
				GameTextForPlayer(playerid, "~r~You are Kicked", 2500, 3);
				format(MainStr, sizeof(MainStr), "You have been successfully kicked from the server, %s Have a nice day", PlayerInfo[playerid][Player_Name]);
				SCM(playerid,msg_red, MainStr);
				DelayKick(playerid);
				return true;
			}
            if(strlen(inputtext) < 4 || strlen(inputtext) > 65) 
            	       return RequestLoginDialog(playerid);
            
            if(!IsValidChar(inputtext))
			{
				SCM(playerid,msg_red, "ERROR: Password can contain only A-Z, a-z, 0-9, _, [ ], ( )");
				RequestLoginDialog(playerid);
				return true;
			}
              
            new hashcheck[65];
            SHA256_PassHash(inputtext, PlayerInfo[playerid][Player_Salts], hashcheck, 65);
            if(!strcmp(hashcheck, PlayerInfo[playerid][Player_Pass]))
            {
                  mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT * FROM `users` WHERE `name` = '%e' LIMIT 1;", PlayerInfo[playerid][Player_Name] );
                  mysql_tquery(fwdb, MainStr, "PlayerRequestLogin", "i",playerid);
                  PlayerInfo[playerid][Player_LoginError] = 0; //reset
            }
            else 
            {
				RequestLoginDialog(playerid);
				PlayerInfo[playerid][Player_LoginError]++;
				switch(PlayerInfo[playerid][Player_LoginError])
				{
					case 1: SCM(playerid,msg_red, "ERROR: Please Enter the correct Password! (Attempts: 1/3)");
					case 2:SCM(playerid,msg_red, "ERROR: Please Enter the correct Password! (Attempts: 2/3)");
					case 3:
					{
						// Close the login dialog!
						ShowPlayerDialog(playerid, -1, DIALOG_STYLE_LIST, "Close", "Close", "Close", "Close");
						GameTextForPlayer(playerid, "~r~You are Kicked", 2500, 3);
						SCM(playerid,msg_red, "ERROR: You have failed to enter your account password (Attempts: 3/3)");
						format(MainStr, sizeof(MainStr), "You have been successfully kicked from the server, %s Have a nice day", PlayerInfo[playerid][Player_Name]);
						SCM(playerid,msg_red, MainStr);
						DelayKick(playerid);
					}
				}
            }

    	}
    }

	return true;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if (!success)
    {
       GameTextForPlayer(playerid, "~y~~h~Unknown Command!", 3400, 3);
    }
    return 1;
} 

publicEx PlayerRequestRegister(playerid)
{

    PlayerInfo[playerid][Player_ID] = cache_insert_id();
    PlayerInfo[playerid][Player_Logged] = true;
    PlayerInfo[playerid][Player_LastOnline] = gettime();
    PlayerInfo[playerid][Player_Joined] = gettime();
    GameTextForPlayer(playerid, "+$20,000~n~startcash", 3500, 1);
    GivePlayerMoney(playerid, 2000);
    format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_white"%s(%i) "text_green"has registered, making the server have a total of "text_blue"%s "text_green"players registered.",PlayerInfo[playerid][Player_Name], playerid, Currency(PlayerInfo[playerid][Player_ID]));
	SCMToAll(msg_green, MainStr);
	SCM(playerid, msg_white,""SERVER_TAG" "text_white"You are now registered, and have been logged in!");
	
	// update join time once.
	mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `joined` = %d, `lastonline` = %d WHERE `ID` = %d LIMIT 1;",PlayerInfo[playerid][Player_Joined],PlayerInfo[playerid][Player_LastOnline],PlayerInfo[playerid][Player_ID] );
	mysql_tquery(fwdb, MainStr);
	return 1;
}

publicEx PlayerRequestLogin(playerid)
{
    if(cache_num_rows() > 0)
    {
        // Load Player Data
       	cache_get_value_name_int(0, "ID", PlayerInfo[playerid][Player_ID]);
       	cache_get_value_name_int(0, "color", PlayerInfo[playerid][Player_Color]);
        cache_get_value_name_int(0, "lastonline",  PlayerInfo[playerid][Player_LastOnline]);
        cache_get_value_name_int(0, "joined",  PlayerInfo[playerid][Player_Joined]);
        cache_get_value_name_int(0, "playtime",PlayerInfo[playerid][Player_PlayTime]);
        cache_get_value_name_int(0, "score",PlayerInfo[playerid][Player_Score]);
        cache_get_value_name_int(0, "skin",PlayerInfo[playerid][Player_Skin]);
        cache_get_value_name_int(0, "cash",PlayerInfo[playerid][Player_Cash]);
        cache_get_value_name_int(0, "kills",PlayerInfo[playerid][Player_Kills]);
        cache_get_value_name_int(0, "deaths",PlayerInfo[playerid][Player_Deaths]);
        cache_get_value_name_int(0, "admin",PlayerInfo[playerid][Player_Admin]);

        SetPlayerScore(playerid, PlayerInfo[playerid][Player_Score]);
        GivePlayerMoney(playerid, PlayerInfo[playerid][Player_Cash]);

        PlayerInfo[playerid][Player_Logged] = true;
        format(MainStr, sizeof(MainStr),""SERVER_TAG" You were last online at %s and registered on %s\n", 
        	 ConvertUnix(PlayerInfo[playerid][Player_LastOnline]), ConvertUnix(PlayerInfo[playerid][Player_Joined]));
        SCM(playerid, msg_white, MainStr);
         

        format(MainStr, sizeof(MainStr),""SERVER_TAG" Your playtime is %s\n", FormatPlayTime(playerid));
        SCM(playerid, msg_white, MainStr);
        
       	if(PlayerInfo[playerid][Player_Color] != 0)
       	{
       		SetPlayerColor(playerid, PlayerInfo[playerid][Player_Color]);
       		SCM(playerid, -1, ""SERVER_TAG" "text_blue"Custom Name Color is set!\n");
       	}

       	if(PlayerInfo[playerid][Player_Skin] != 999)
       	{
       		SCM(playerid, -1, ""SERVER_TAG" "text_blue"Saved Skin is set!\n");
       	}

        SCM(playerid, -1, ""SERVER_TAG" "text_green"Successfully logged in.");
    }
    else DelayKick(playerid); // Just kick the player from the server
	return 1;
}
CMD:savecolor(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command!");
    if(PlayerInfo[playerid][Player_Color] == 0)
	{
	    SCM(playerid, -1, ""SERVER_TAG" "text_green"Color saved! It will be loaded on next login, use /deletecolor to remove it.");
	}
	else
	{
	    SCM(playerid, -1, ""SERVER_TAG" "text_green"Saved color overwritten! It will be loaded on next login, use /deletecolor to remove it.");
	}
    PlayerInfo[playerid][Player_Color] = GetPlayerColor(playerid);
	return 1;
}

public OnPlayerUpdate(playerid)
{

    if(GetPlayerMoney(playerid) > PlayerInfo[playerid][Player_Cash])
	{
		ResetPlayerMoney(playerid);
		GivePlayerMoney(playerid, PlayerInfo[playerid][Player_Cash]);
	}

	return 1;
}
CMD:deletecolor(playerid)
{
	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command!");

	if(PlayerInfo[playerid][Player_Color] == 0)
	{
	    SCM(playerid, -1, ""SERVER_TAG" "text_green"You have no saved color yet!");
	}
	else
	{
	    SCM(playerid, -1, ""SERVER_TAG" "text_red"Color has been deleted!");
	}
    PlayerInfo[playerid][Player_Color]  = 0;
	return 1;
}
CMD:saveskin(playerid, params[])
{
	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command!");

	if(PlayerInfo[playerid][Player_Skin] == 999)
	{
	    
	    SCM(playerid, -1, ""SERVER_TAG" "text_green"Skin saved! Skipping class selection next login. Use /deleteskin to remove it");
	}
	else
	{
	    SCM(playerid, -1, ""SERVER_TAG" "text_green"Saved skin overwritten! Skipping class selection next login. Use /deleteskin to remove it");
	}
	new skin = GetPlayerSkin(playerid);
	
	if(IsValidSkin(skin)) PlayerInfo[playerid][Player_Skin] = skin;
    else SCM(playerid, msg_red, "ERROR: Invalid Skin ID!");
    return 1;
}

CMD:deleteskin(playerid, params[])
{
	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command!");

	if(PlayerInfo[playerid][Player_Skin] == 999)
	{
	    SCM(playerid, msg_red, "ERROR:You have no saved skin");
	}
	else
	{
	    SCM(playerid, -1, ""SERVER_TAG" "text_green"Saved skin has been deleted");
	}
    PlayerInfo[playerid][Player_Skin] = 999;
	return 1;
}

CMD:random(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command!");
	
	new rand = random(sizeof(PlayerColors));
	SetPlayerColor(playerid, PlayerColors[rand]);
	format(MainStr, sizeof(MainStr), "Color set! Your new color: {%06x}Color", GetPlayerColor(playerid) >>> 8);
	SCM(playerid, msg_blue, MainStr);
	return 1;
}

CMD:statistics(playerid, params[]) return cmd_stats(playerid, params); 
CMD:stats(playerid, params[])
{

    new getotherid, otherid, StatsString[400], StoreStatsString[400];
    if(sscanf(params,"u", getotherid))
    {
         otherid = playerid;
    }
    else 
    {
    	if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid player!");
		if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected!");
		otherid = getotherid;
    }
  
    format(StatsString, sizeof(StatsString), ""text_white"%s's Statistics: #%d\n\nScore: %d\nMoney: %s\nKills: %d\nDeaths: %d\nKDR: %0.2f",
    	 PlayerInfo[otherid][Player_Name], PlayerInfo[otherid][Player_ID], PlayerInfo[otherid][Player_Score],Currency(PlayerInfo[otherid][Player_Cash]),
    	 PlayerInfo[otherid][Player_Kills],PlayerInfo[otherid][Player_Deaths],Float:PlayerInfo[otherid][Player_Kills]/Float:PlayerInfo[otherid][Player_Deaths]);
    strcat(StoreStatsString,StatsString);

  
    format(StatsString, sizeof(StatsString), "\nPlay Time: %s\nLast Login: %s\nRegistration Date: %s",
    	 FormatPlayTime(otherid), ConvertUnix(PlayerInfo[otherid][Player_LastOnline]),ConvertUnix(PlayerInfo[otherid][Player_Joined]));
    strcat(StoreStatsString,StatsString);

    ShowPlayerDialog(otherid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Player Statistics", StoreStatsString, "OK", "");
	return 1;
}

CMD:tban(playerid, params[]) return cmd_tempban(playerid, params);
CMD:tempban(playerid, params[])
{
   if(PlayerInfo[playerid][Player_Admin] < Lead_LEVEL) return SCM(playerid, msg_red, "ERROR: You are not a higher level administrator!");

   new getotherid, ban_reason[40], ban_days, ban_lift;
   if(sscanf(params, "uds[40]", getotherid, ban_days, ban_reason))
   	             return SCM(playerid, msg_yellow, "Usage: /tban <id/name> <days> <reason>");
   if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid player!");
   if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected!");
   if(getotherid == playerid) return SCM(playerid, msg_red, "ERROR: You are not able to ban yourself!");
   if(ban_days < 0) return SCM(playerid, msg_red, "ERROR: Please input a valid ban time.");
   if(GetPVarInt(playerid, "PlayerKicked")) return SCM(playerid, msg_red, "ERROR: Player has been kicked from the server.");
   if( strlen(ban_reason) > 40) return SCM(playerid, msg_red, "ERROR: Ban reason cannot be highter than 40 characters.");

   ban_lift = gettime() + (ban_days * 86400);

   SetPVarInt(getotherid, "PlayerKicked", 1);
	   
   //insert into the db
   mysql_format(fwdb, MainStr, sizeof(MainStr), "INSERT INTO `bans` (`ban_user`, `ban_admin`, `ban_time`,`ban_lift` ,`ban_reason`,`ban_ip`) VALUES ('%s','%s',UNIX_TIMESTAMP(),%d,'%s','%s')",
   	PlayerInfo[getotherid][Player_Name],PlayerInfo[playerid][Player_Name],ban_lift,ban_reason,PlayerInfo[getotherid][Player_IP]);
   mysql_tquery(fwdb, MainStr, "OnPlayerTempBan", "iisi", playerid, getotherid, ban_reason, ban_lift);
   return 1;
}
publicEx OnPlayerTempBan(admin,ban_player,reason[],days)
{
	 format(MainStr, sizeof(MainStr), "Ban Notice #%d: %s has been banned by Administrator %s (Reason: %s)", cache_insert_id(), PlayerInfo[ban_player][Player_Name],
	 	PlayerInfo[admin][Player_Name], reason);
	 SCMToAll(msg_red, MainStr);

	 new ban_msg[600];

	 GameTextForPlayer(ban_player, "~r~You are Banned!", 2500, 3);

	 format(ban_msg, sizeof(ban_msg), ""text_white"Hello %s,\nBan ID: %d\nBanned by: %s\nBan Date: %s\nBan Lift: %s\nReason: %s\nWrongly Banned? Do a ban appeal in forum!",
	 	PlayerInfo[ban_player][Player_Name], cache_insert_id(), PlayerInfo[admin][Player_Name], ConvertUnix(gettime()), ConvertUnix(days), reason);
	 ShowPlayerDialog(ban_player, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Ban Notice", ban_msg, "OK", "");

	 DelayKick(ban_player);
     return 1;
}


CMD:ban(playerid, params[])
{
   if(PlayerInfo[playerid][Player_Admin] < Lead_LEVEL) return SCM(playerid, msg_red, "ERROR: You are not a higher level administrator!");

   new getotherid, ban_reason[40];
   if(sscanf(params, "us[40]", getotherid, ban_reason))
   	             return SCM(playerid, msg_yellow, "Usage: /ban <id/name> <reason>");
   if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid player!");
   if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected!");

   if(getotherid == playerid) return SCM(playerid, msg_red, "ERROR: You are not able to ban yourself!");

   if(GetPVarInt(playerid, "PlayerKicked")) return SCM(playerid, msg_red, "ERROR: Player has been kicked from the server.");
   if( strlen(ban_reason) > 40) return SCM(playerid, msg_red, "ERROR: Ban reason cannot be highter than 40 characters.");
   
   SetPVarInt(getotherid, "PlayerKicked", 1);
   //insert into the db
   mysql_format(fwdb, MainStr, sizeof(MainStr), "INSERT INTO `bans` (`ban_user`, `ban_admin`, `ban_time`,`ban_lift` ,`ban_reason`,`ban_ip`) VALUES ('%s','%s',UNIX_TIMESTAMP(),0,'%s','%s')",
   	PlayerInfo[getotherid][Player_Name],PlayerInfo[playerid][Player_Name],ban_reason,PlayerInfo[getotherid][Player_IP]);
   mysql_tquery(fwdb, MainStr, "OnPlayerGetBanned", "iisi", playerid, getotherid, ban_reason);
   return 1;
}

publicEx OnPlayerGetBanned(admin,ban_player,reason[])
{

	 format(MainStr, sizeof(MainStr), "Ban Notice #%d: %s has been banned by Administrator %s (Reason: %s)", cache_insert_id(), PlayerInfo[ban_player][Player_Name],
	 	PlayerInfo[admin][Player_Name], reason);
	 SCMToAll(msg_red, MainStr);

	 new ban_msg[600];
	 GameTextForPlayer(ban_player, "~r~You are Banned!", 2500, 3);

	 format(ban_msg, sizeof(ban_msg), ""text_white"Hello %s,\nBan ID: %d\nBanned by: %s\nBan Date: %s\nBan Lift: Permanent\nReason: %s\nWrongly Banned? Do a ban appeal in forum!",
	 	PlayerInfo[ban_player][Player_Name], cache_insert_id(), PlayerInfo[admin][Player_Name], ConvertUnix(gettime()), reason);
	 ShowPlayerDialog(ban_player, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Ban Notice", ban_msg, "OK", "");

	 DelayKick(ban_player);
     return 1;
}


CMD:setlevel(playerid, params[]) return cmd_setadmin(playerid, params);
CMD:setadmin(playerid, params[])
{

    if(PlayerInfo[playerid][Player_Admin] < CEA_LEVEL)
		if(!IsPlayerAdmin(playerid))
			 return SCM(playerid, msg_red, "ERROR: You are not a higher level administrator!");
    
    new getotherid, getalevel;
    if(sscanf(params, "ui", getotherid, getalevel)) return SCM(playerid, msg_yellow, "Usage: /setadmin <id/name> <level>");

    if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid player!");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected!");

    if(getalevel < None_LEVEL || getalevel > Founder_LEVEL) return SCM(playerid, msg_red, "ERROR: Level Range ( 0 - 5 )");

    if(PlayerInfo[playerid][Player_Admin] == CEA_LEVEL)
	{
		if(getalevel > CEA_LEVEL)
			return SCM(playerid, msg_red, "ERROR: You can't promote yourself or other players to founder as an Chief Executive Administrator");
	}

	if(PlayerInfo[getotherid][Player_Admin] == getalevel)
	{
		return SCM(playerid, msg_red, "ERROR: Player is already in that level.");
	}

	new getlevel[50];
	getlevel = (getalevel > PlayerInfo[getotherid][Player_Admin]) ? ("promoted") : ("demoted");

    PlayerInfo[getotherid][Player_Admin] = getalevel;

    format(MainStr, sizeof(MainStr), "%s %s has %s %s's level to %s", AdminLevels[PlayerInfo[playerid][Player_Admin]], PlayerInfo[playerid][Player_Name],
    	getlevel,  PlayerInfo[getotherid][Player_Name],  AdminLevels[ PlayerInfo[getotherid][Player_Admin] ] );
    SCMToAll(msg_blue, MainStr);

    mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `admin` = %d WHERE `ID` = %d", PlayerInfo[playerid][Player_Admin], PlayerInfo[playerid][Player_ID]);
    mysql_query(fwdb, MainStr);
	return 1;
}

ResetPlayerVar(playerid)
{
    PlayerInfo[playerid][Player_ID] = 0;
    PlayerInfo[playerid][Player_Logged] = false;
    PlayerInfo[playerid][Player_FirstSpawn] = false;
    PlayerInfo[playerid][Player_Spawned] = false;
    PlayerInfo[playerid][Player_Color] = 0;
    PlayerInfo[playerid][Player_LastOnline] = 0;
    PlayerInfo[playerid][Player_Joined] = 0;
    PlayerInfo[playerid][Player_PlayTime] = 0;
    PlayerInfo[playerid][Player_LoginError] = 0;
    PlayerInfo[playerid][Player_Skin] = 999;
    PlayerInfo[playerid][Player_Score] = 0;
    PlayerInfo[playerid][Player_Cash] = 0;
    PlayerInfo[playerid][Player_Kills] = 0;
    PlayerInfo[playerid][Player_Deaths] = 0;
    PlayerInfo[playerid][Player_Admin] = 0;
}

publicEx ServerTimer()
{
  foreach(new i : Player) if(PlayerInfo[i][Player_Spawned])
  {
    if(GetPlayerMoney(i) > PlayerInfo[i][Player_Cash])
	{
		ResetPlayerMoney(i);
		GivePlayerMoney(i, PlayerInfo[i][Player_Cash]);
	}
  }
  return 1;
}
stock DelayKick(playerid)
{
    SetTimerEx("KickEx", 100, 0, "i", playerid);
}
publicEx KickEx(playerid) return Kick(playerid);

publicEx ForcePlayerToSpawn(playerid) return SpawnPlayer(playerid);

SendPlayerMoney(playerid, sendcash)
{
	if(playerid == INVALID_PLAYER_ID) return 1;

	if(PlayerInfo[playerid][Player_Cash] >= 1000000000) return 1;

    PlayerInfo[playerid][Player_Cash] += sendcash;
    GivePlayerMoney(playerid, sendcash);
    return 1;
}
SendPlayerScore(playerid, sendscore)
{
	if(playerid == INVALID_PLAYER_ID) return 1;

    PlayerInfo[playerid][Player_Score] += sendscore;
    
    SetPlayerScore(playerid, PlayerInfo[playerid][Player_Cash]);
    return 1;

}

stock RequestRegisterDialog(playerid)
{
    format(MainStr, sizeof(MainStr), ""text_white"Welcome to "text_yellow""SERVER_HOST""text_white", %s\n\nPlease enter your password below to register!",PlayerInfo[playerid][Player_Name]);
    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, ""DIALOG_TAG" "SERVER_HOST"  Register", MainStr, "Register", "Quit");
    return true;
}

stock RequestLoginDialog(playerid)
{
    format(MainStr, sizeof(MainStr), ""text_white"Welcome back to "text_yellow""SERVER_HOST""text_white", %s\n\nPlease enter your password below to login!",PlayerInfo[playerid][Player_Name]);
    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""DIALOG_TAG"  "SERVER_HOST" Login", MainStr, "Login", "Quit");
    return true;
}

stock PlayerRequestSaveStats(playerid)
{
	mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `color` = %d, `lastonline` = %d, `playtime`= %d,`skin`=%d,`kills`=%d,`deaths`=%d,`cash`=%d WHERE `ID` = %d LIMIT 1;",
	PlayerInfo[playerid][Player_Color],gettime(),CalculatePlayTime(playerid),PlayerInfo[playerid][Player_Skin],PlayerInfo[playerid][Player_Kills],PlayerInfo[playerid][Player_Deaths],
	PlayerInfo[playerid][Player_Cash],PlayerInfo[playerid][Player_ID]);
	mysql_tquery(fwdb, MainStr);
}

CalculatePlayTime(playerid)
{
    PlayerInfo[playerid][Player_PlayTime] = PlayerInfo[playerid][Player_PlayTime] + (gettime() - PlayerInfo[playerid][Player_JoinTick]);
    PlayerInfo[playerid][Player_JoinTick] = gettime();
    return PlayerInfo[playerid][Player_PlayTime];
}

stock FormatPlayTime(playerid)
{
    new ptime[3], ptimestr[40], pchectime = CalculatePlayTime(playerid);
    ptime[0] = floatround(pchectime / 3600, floatround_floor);
    ptime[1] = floatround(pchectime / 60, floatround_floor) % 60;
    ptime[2] = floatround(pchectime % 60, floatround_floor);
    format(ptimestr, sizeof(ptimestr), "%ih %02im %02is", ptime[0], ptime[1], ptime[2]);
	return ptimestr;
}

Currency(num)
{
    new szStr[16];
    format(szStr, sizeof(szStr), "%i", num);

    for(new iLen = strlen(szStr) - (num < 0 ? 4 : 3); iLen > 0; iLen -= 3)
    {
        strins(szStr, ",", iLen);
    }
    return szStr;
}

stock IsValidSkin(skin)
{
	return (0 <= skin <= 311 && skin != 74);
}


stock IsValidChar(const name[])
{
	new len = strlen(name);

	for(new ch = 0; ch != len; ch++)
	{
		switch(name[ch])
		{
			case 'A' .. 'Z', 'a' .. 'z', '0' .. '9', ']', '[', '(', ')', '_', '.', '@', '#', ' ': continue;
			default: return false;
		}
	}
	return true;
}
