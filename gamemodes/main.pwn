<<<<<<< HEAD
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
Preview  Dialog Plugin Version.
Compiler Note: -d3

*/

#include <a_samp>
#include <a_mysql41>
#include <sscanf2>
#include <foreach>
#include <streamer>
#include <zcmd>  
#include <preview-dialog>

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
     Player_Mode,
     Player_TeleCat,
     Player_WeapCat,

     // bool
     bool:Player_Logged,
     bool:Player_FirstSpawn,
     bool:Player_Spawned
};
new PlayerInfo[MAX_PLAYERS][pinfo];

enum {

	MODE_FREEROAM,
}
// Player Information Ends

// Dialogs
enum 
{
    DIALOG_NONE,
    DIALOG_REGISTER,
    DIALOG_LOGIN,
    DIALOG_TELEPORT_MENU,
    DIALOG_TELEPORT_SELECT,
    DIALOG_WEAPON_MENU,
    DIALOG_WEAPON_SELECT
};

// Teleport 
enum {

	Tele_Hotspots,
	Tele_Cities
};

enum TDEnum {

	CatID,
	CatName[20]
};

static const TeleportDialog[][TDEnum] =
{
	{Tele_Hotspots,"Hotspots"},
	{Tele_Cities,"Cities"}
};

enum TNEnum {
	TeleID,
	TeleName[30],
	TeleCmd[10]
}

static const TeleportNames[][TNEnum] =
{

   {Tele_Hotspots, "Los Santos", "ls"},
   {Tele_Hotspots, "San Fierro", "sf"},
   {Tele_Hotspots, "Las Venturas", "lv"},

   {Tele_Cities, "Los Santos Hospital", "lsh"},
   {Tele_Cities, "San Fierro Hospital", "sfh"},
   {Tele_Cities, "Las Venturas Hospital", "lvh"},
   {Tele_Cities, "Los Santos", "ls"},
   {Tele_Cities, "San Fierro", "sf"},
   {Tele_Cities, "Las Venturas", "lv"}

};
//


// Weapon Dialog
enum {
  
    WEAPON_RIFLES,
    WEAPON_SUBMACHINES,
    WEAPON_SHOTGUNS,
    WEAPON_HANDGUNS,
    WEAPON_MELEE,
    WEAPON_SPECIAL
};

enum WDEnum
{
   WeapCatID,
   WeapName[20],
   WeapModel,
   WeapModelID,
   WeapAmmo
};

enum WMDEnum {

	WeapMCatID,
	WeapMCatName[20]
};
static const WeaponMenuDialog[][WMDEnum] =
{
	{WEAPON_RIFLES,"Rifles"},
	{WEAPON_SUBMACHINES,"Submachine Guns"},
	{WEAPON_SHOTGUNS,"Shot Guns"},
	{WEAPON_HANDGUNS,"Hand Guns"},
	{WEAPON_MELEE,"Melee Guns"},
	{WEAPON_SPECIAL,"Special Weapons"}
};


static const WeaponDialog[][WDEnum] =
{
   // Rifles
  {WEAPON_RIFLES, "AK-47", 30, 355, 99999},
  {WEAPON_RIFLES, "Country Rifle",33,357, 99999},
  {WEAPON_RIFLES, "M4", 31, 356, 99999},
  {WEAPON_RIFLES, "Sniper Rifle", 34,358, 99999},

  // Submachine
  {WEAPON_SUBMACHINES, "MP 5",29,353, 99999},
  {WEAPON_SUBMACHINES, "UZI", 28,352 , 99999},
  {WEAPON_SUBMACHINES, "TEC-9", 32, 372 ,99999},

  // Shotguns
  {WEAPON_SHOTGUNS, "Pump Gun",25, 349 ,99999},
  {WEAPON_SHOTGUNS, "Sawn-Off", 26, 350 ,99999},
  {WEAPON_SHOTGUNS, "Combat Shotgun", 27,351 , 99999},

  // hand guns
  {WEAPON_HANDGUNS, "9mm",22, 346 ,99999},
  {WEAPON_HANDGUNS, "Silenced 9mm", 23, 347 ,99999},
  {WEAPON_HANDGUNS, "Desert Eagle", 24,348 , 99999},

  //melee
  {WEAPON_MELEE, "Golf Club", 2,333 , 1},
  {WEAPON_MELEE, "Nightstick",3,334 , 1},
  {WEAPON_MELEE, "Knife", 4,335 , 1},
  {WEAPON_MELEE, "Shovel", 6, 337 ,1},
  {WEAPON_MELEE, "Katana", 8, 339 ,1},
  {WEAPON_MELEE, "Chainsaw",9, 341 ,1},
  {WEAPON_MELEE, "Double-ended Dildo", 10, 321 ,1},
  {WEAPON_MELEE, "Silver Vibrator", 13, 324 ,1},
  {WEAPON_MELEE, "Flowers", 14, 325 ,1},

  //specials
  {WEAPON_SPECIAL, "Tear Gas", 17,343, 99999},
  {WEAPON_SPECIAL, "Molotov Cocktail",18, 344,4},
  {WEAPON_SPECIAL, "Flamethrower", 37,361, 50},
  {WEAPON_SPECIAL, "Spraycan", 41, 365, 50},
  {WEAPON_SPECIAL, "Fire Extinguisher", 42, 366, 50}
};
static const AdminLevels[Founder_LEVEL + 1 ][] =
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

    // Reset Player Data.
    ResetPlayerVar(playerid);
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
    	PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
        PlayerInfo[playerid][Player_FirstSpawn] = false;
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        StopAudioStreamForPlayer(playerid);
        SetPlayerWorldBounds(playerid, 20000, -20000, 20000, -20000);
        return 1;
    }

    switch(PlayerInfo[playerid][Player_Mode])
    {
	       case MODE_FREEROAM:
	       {
		  		SetCameraBehindPlayer(playerid);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			    SetPlayerInterior(playerid, 0);
			    SetPlayerVirtualWorld(playerid, 0);
			    SetCameraBehindPlayer(playerid);
			    SetPlayerWorldBounds(playerid, 20000, -20000, 20000, -20000);
		   }
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	
	 // To avoid  exploits 
	ShowPlayerDialog(playerid, -1, DIALOG_STYLE_LIST, "Close", "Close", "Close", "Close");

    PlayerInfo[playerid][Player_Spawned] = false;
    
    SendDeathMessage(killerid, playerid, reason);

    SendPlayerMoney(playerid, -500);
    PlayerInfo[playerid][Player_Deaths]++;

    if(killerid != INVALID_PLAYER_ID)
    {
    	PlayerInfo[killerid][Player_Kills]++;
    }

    switch(PlayerInfo[playerid][Player_Mode])
    {
      case MODE_FREEROAM: 
      {
	   	    new spawnrand = random(sizeof(PlayerSpawns));
		    SetSpawnInfo(playerid, NO_TEAM, GetPlayerSkin(playerid), PlayerSpawns[spawnrand][0], PlayerSpawns[spawnrand][1], PlayerSpawns[spawnrand][2], PlayerSpawns[spawnrand][3], 0, 0, 0, 0, 0, 0);
		   

		    if(killerid != INVALID_PLAYER_ID && PlayerInfo[killerid][Player_Mode] == MODE_FREEROAM)
		    {
		    	SendPlayerScore(killerid, 2);
		    	SendPlayerMoney(killerid, 5000);
		    	return 1;
		    }
	  }

	}
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
    	 case DIALOG_TELEPORT_MENU:
    	 {
    	 	  if(!response) return 1;
              if(listitem < 0 || listitem > sizeof(TeleportDialog)) return 1;
              RequestPlayerTeleList(playerid, TeleportDialog[listitem][CatID]);
    	 }
    	 case DIALOG_TELEPORT_SELECT:
    	 {
    	 	  if(!response) return 1;
              new count = 0;
              for(new i = 0; i < sizeof(TeleportNames);i++)
              {

                    if(PlayerInfo[playerid][Player_TeleCat] == TeleportNames[i][TeleID])
                    {
 
                    	  if(count == listitem)
                    	  {
                    	  	 PlayerInfo[playerid][Player_TeleCat] = -1;
                             format(MainStr, sizeof(MainStr), "cmd_%s", TeleportNames[i][TeleCmd]);
                             CallLocalFunction(MainStr, "i", playerid);

                             return 1;
                    	  }
                          count++;
                    }
               }
    	  }
    	  case DIALOG_WEAPON_MENU:
    	  {
    	 	  if(!response) return 1;
              if(listitem < 0 || listitem > sizeof(WeaponMenuDialog)) return 1;
              RequestPlayerWeaponsList(playerid, WeaponMenuDialog[listitem][WeapMCatID]);
    	 }
    	 case DIALOG_WEAPON_SELECT:
    	 {

    	 	  if(!response) return 1;
              new count = 0;
              for(new i = 0; i < sizeof(WeaponDialog);i++)
              {

                    if(PlayerInfo[playerid][Player_WeapCat] == WeaponDialog[i][WeapCatID])
                    {
 
                    	  if(count == listitem)
                    	  {
                    	  	 PlayerInfo[playerid][Player_WeapCat] = -1;
                             return GivePlayerWeapon(playerid, WeaponDialog[i][WeapModel], WeaponDialog[i][WeapAmmo]);
                    	  }
                          count++;
                    }
               }
    	 }

    }

	return true;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(!PlayerInfo[playerid][Player_Spawned])
	{
        SCM(playerid, msg_red, "ERROR: You need to spawn to use commands!");
		return 0;
	} 

	ShowPlayerDialog(playerid, -1, DIALOG_STYLE_LIST, "Close", "Close", "Close", "Close");
	return 1;
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
	mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `joined` = %d, `lastonline` = %d , `online` = 1 WHERE `ID` = %d LIMIT 1;",PlayerInfo[playerid][Player_Joined],PlayerInfo[playerid][Player_LastOnline],PlayerInfo[playerid][Player_ID] );
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

        mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `online` = 1 WHERE `ID` = %d LIMIT 1;",PlayerInfo[playerid][Player_ID] );
	    mysql_tquery(fwdb, MainStr);

        SCM(playerid, -1, ""SERVER_TAG" "text_green"Successfully logged in.");
    }
    else DelayKick(playerid); // Just kick the player from the server
	return 1;
}


CMD:w(playerid) return cmd_weapons(playerid);
CMD:weap(playerid) return cmd_weapons(playerid);
CMD:weapons(playerid) 
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command!");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe!");
    RequestPlayerWeaponDialog(playerid);
	return 1;
}

CMD:t(playerid) return cmd_tele(playerid);
CMD:teles(playerid) return cmd_tele(playerid);
CMD:teleport(playerid) return cmd_tele(playerid);
CMD:tele(playerid) 
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command!");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe!");
    RequestPlayerTeleDialog(playerid);
	return 1;
}


CMD:ls(playerid) return  SendPlayerToPosition(playerid,  2494.7476, -1666.6097, 13.3438, 88.1632 , 2494.7476, -1666.6097, 13.3438, 88.1632, "Los Santos", "/ls", true, true, false);
CMD:lv(playerid) return   SendPlayerToPosition(playerid,  2039.8860,1546.1112,10.4450,180.4970,2039.8860,1546.1112,10.4450,180.4970, "Las Venturas", "/lv", true, true, false);
CMD:sf(playerid) return   SendPlayerToPosition(playerid, -1990.6650, 136.9297, 27.3110, 0.6588, -1990.6650, 136.9297, 27.3110, 0.6588, "San Fierro", "/sf", true, true, false);
CMD:lsh(playerid) return  SendPlayerToPosition(playerid, 2031.6591,-1415.4594,16.9922,136.5410 , 2031.6591,-1415.4594,16.9922,136.5410, "Los Santos Hospital", "/lsh",true, true, false);
CMD:sfh(playerid) return  SendPlayerToPosition(playerid,  -2663.7432,593.5697,14.2507,181.0684 , -2663.7432,593.5697,14.2507,181.0684, "San Fierro Hospital", "/sfh",true, true, false);
CMD:lvh(playerid) return  SendPlayerToPosition(playerid, 1608.1807,1833.2031,10.8203,174.4132 , 1625.1787,1824.4666,10.8203,352.3649, "Las Venturas Hospital", "/lvh",true, true, false);

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
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe!");
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
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe!");
	
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
	if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe!");

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

    if(getalevel < 0 || getalevel > Founder_LEVEL) return SCM(playerid, msg_red, "ERROR: Level Range ( 0 - 5 )");

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
    PlayerInfo[playerid][Player_WeapCat] = -1;
    PlayerInfo[playerid][Player_TeleCat] = -1;
    SetPVarInt(playerid, "PlayerKicked", 0);
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

stock RequestPlayerWeaponDialog(playerid)
{
	new StoreStre[200];
	for(new i = 0; i < sizeof(WeaponMenuDialog); i++)
	{
		format(MainStr, sizeof(MainStr), ""text_white"%s\n", WeaponMenuDialog[i][WeapMCatName]);
		strcat(StoreStre, MainStr);
	}
    ShowPlayerDialog(playerid, DIALOG_WEAPON_MENU, DIALOG_STYLE_LIST, ""DIALOG_TAG" Weapons Menu", StoreStre, "Choose", "Close");
	return true;
}

stock RequestPlayerTeleDialog(playerid)
{ 
	new StoreStre[200];
	for(new i = 0; i < sizeof(TeleportDialog); i++)
	{
		format(MainStr, sizeof(MainStr), ""text_white"%s\n", TeleportDialog[i][CatName]);
		strcat(StoreStre, MainStr);
	}
    ShowPlayerDialog(playerid, DIALOG_TELEPORT_MENU, DIALOG_STYLE_LIST, ""DIALOG_TAG" Teleport Menu", StoreStre, "Choose", "Close");
	return true;
}
stock RequestPlayerWeaponsList(playerid, category)
{
    new catgStr[500], StorecatgStr[500];
    PlayerInfo[playerid][Player_WeapCat] = category;
    for(new i = 0; i < sizeof(WeaponDialog); i++)
    {
    	if(WeaponDialog[i][WeapCatID] == category)
    	{
	    	format(catgStr, sizeof(catgStr), "%i(0.0, 0.0, -50.0, 1.5)\t%s\n",WeaponDialog[i][WeapModelID], WeaponDialog[i][WeapName]);
	    	strcat(StorecatgStr, catgStr);
	    }
    } 
    ShowPlayerDialog(playerid, DIALOG_WEAPON_SELECT, DIALOG_STYLE_PREVIEW_MODEL, "~h~~y~FW~w~ :: Weapons", StorecatgStr, "Select", "Close");
	return true;
}
stock RequestPlayerTeleList(playerid, category)
{
    new catgStr[500], StorecatgStr[500];
    PlayerInfo[playerid][Player_TeleCat] = category;
    for(new i = 0; i < sizeof(TeleportNames); i++)
    {
    	if(TeleportNames[i][TeleID] == category)
    	{
	    	format(catgStr, sizeof(catgStr), ""text_white"%s [/%s]\n", TeleportNames[i][TeleName], TeleportNames[i][TeleCmd]);
	    	strcat(StorecatgStr, catgStr);
	    }
    } 
    ShowPlayerDialog(playerid, DIALOG_TELEPORT_SELECT, DIALOG_STYLE_LIST, ""DIALOG_TAG" Teleports", StorecatgStr, "Select", "Close");
	return true;
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
	mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `color` = %d, `lastonline` = %d, `playtime`= %d,`skin`=%d,`kills`=%d,`deaths`=%d,`cash`=%d, `online` = 0 WHERE `ID` = %d LIMIT 1;",
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

SendPlayerToPosition(playerid, Float:X, Float:Y, Float:Z, Float:Angle, Float:XVeh, Float:YVeh, Float:ZVeh, Float:AngleVeh, const map[], const cmd[], bool:vehspawn, bool:cmdtext = true, bool:updatepos = true)
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		SCM(playerid, msg_red, "ERROR: You can't use this command right now!");
		return 1; 
	}
	
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);

    if(vehspawn)
    {
        new vID = GetPlayerVehicleID(playerid);
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
		    if(updatepos) Streamer_UpdateEx(playerid, XVeh, YVeh, ZVeh);

			SetVehiclePos(vID, XVeh, YVeh, floatadd(ZVeh, 4.5));
		    SetVehicleVirtualWorld(vID, 0);
	   		SetVehicleZAngle(vID, AngleVeh);
	   		LinkVehicleToInterior(vID, 0);
			PutPlayerInVehicle(playerid, vID, 0);
		}
        else 
	    {
	    	if(updatepos) Streamer_UpdateEx(playerid, X, Y, Z);

			SetPlayerPos(playerid, X, Y, floatadd(Z, 2.5));
			SetPlayerFacingAngle(playerid, Angle);

	    }
	}
	else
	{
	    	if(updatepos) Streamer_UpdateEx(playerid, X, Y, Z);

			SetPlayerPos(playerid, X, Y, floatadd(Z, 2.5));
			SetPlayerFacingAngle(playerid, Angle);
	}
    SetCameraBehindPlayer(playerid);
    
    if(cmdtext) SendPlayerTextNotice(playerid, map, cmd);
    return 1;
}

SendPlayerTextNotice(playerid, const map[], const cmd[])
{
    format(MainStr, sizeof(MainStr), "~y~~h~%s~n~~w~%s", map, cmd);
    GameTextForPlayer(playerid, MainStr, 3500, 3);
	return 1;
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
=======
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
Preview  Dialog Plugin Version.
Compiler Note: -d3


Pending: Gang War Capture CMD  Coding.
*/

#include <a_samp>
#include <a_mysql41>
#include <sscanf2>
#include <foreach>
#include <streamer>
#include <zcmd>  
#include <preview-dialog>
#include <YSI\y_iterate>


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

#define SERVER_TDHOST        "~y~~h~Freeroam ~b~~h~World"   
#define SERVER_TDMODE        "~y~Stunt~w~/~r~Minigames~w~/~g~Fun"                     
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
#define Junior_Level               (1)
#define Lead_Level                 (2)   
#define Head_Level                 (3)
#define CEA_Level                  (4)
#define Founder_Level              (5)
#define MAX_WARNS                  (5) 
#define UnCapsText(%1)             for( new ToLowerChar; ToLowerChar < strlen( %1 ); ToLowerChar ++ ) if ( %1[ ToLowerChar ]> 64 && %1[ ToLowerChar ] < 91 ) %1[ ToLowerChar ] += 32
#define ClosePlayerDialog(%0)       ShowPlayerDialog(%0, -1, DIALOG_STYLE_LIST, "Close", "Close", "Close", "Close")
#define ConvertRGB(%1,%2,%3,%4)    (((((%1) & 0xff) << 24) | (((%2) & 0xff) << 16) | (((%3) & 0xff) << 8) | ((%4) & 0xff)))
#define PlayerColor(%0)            GetPlayerColor(%0) >>> 8
#define MAX_REPORTS                (10)
#define MAX_ACHS                   (5)
#define MAX_SKYDIVE_ACH            (2)
// Animinations
#define PreloadAnimLib(%1,%2)	   ApplyAnimation(%1,%2,"NULL",0.0,0,0,0,0,0)

#define publicEx%0(%1) forward %0(%1); public %0(%1)


Float:GetDistance3D(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2);
Float:GetDistance3D(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
	return VectorSize(x1 - x2, y1 - y2, z1 - z2);
}

native IsValidVehicle(vehicleid);
enum Vars
{
	Server_Timer,
	Server_RandMSG,
	Server_ReactionTimer,
	Server_ReactionTimerEnd,
	Server_MathsTimer
};
new ServerVars[Vars];
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
     Player_Mode,
     Player_TeleCat,
     Player_WeapCat,
     Player_Warns,
     Player_MuteTime,
     Player_JailTime,
     Player_Vehicle,
     Player_VehCat,
     Player_LastDM,
     Player_LastSky,
     Player_LastPark,
     Player_LastIP,
     Player_LastBMX,
     Player_Spec,
     Player_Ignore[MAX_PLAYERS],
     Player_Afk,
     Player_FS,
     Player_tLoadMap,
     Player_Email[40],
     Player_AchCompleted[MAX_ACHS],
     Player_AchSkydive[MAX_SKYDIVE_ACH],
     Player_ResetNos,
     Player_ResetFix,
     Player_AutoLogin,
     Player_TempName[MAX_PLAYER_NAME],
     Player_TempIP[16],
     Player_GangID,
     Player_GangRank,

     // bool
     bool:Player_Logged,
     bool:Player_FirstSpawn,
     bool:Player_Spawned,
     bool:Player_Muted,
     bool:Player_Caps,
     bool:Player_Freeze,
     bool:Player_Speedo,
     bool:Player_God,
     bool:Player_SB,
     bool:Player_Bounce,
     bool:Player_SJ,
     bool:Player_AllowPM,
     bool:Player_AllowTP,
     bool:Player_LoadMap,
     bool:Player_SavedPos,
     bool:Player_InGWAR,
     //Float
     Float:Player_OldPos[4]
};
new PlayerInfo[MAX_PLAYERS][pinfo];

enum {

	MODE_FREEROAM,
	MODE_JAILED,
	MODE_DM,
	MODE_SPEC,
	MODE_SKYDIVE,
	MODE_PARKOUR,
	MODE_IP,
	MODE_BMX
};
// Player Information Ends

// Dialogs
enum 
{
    DIALOG_NONE,
    DIALOG_REGISTER,
    DIALOG_LOGIN,
    DIALOG_TELEPORT_MENU,
    DIALOG_TELEPORT_SELECT,
    DIALOG_WEAPON_MENU,
    DIALOG_WEAPON_SELECT,
    DIALOG_SKIN_MENU,
    DIALOG_DM_MENU,
    DIALOG_VEHICLE_MENU,
    DIALOG_VEHICLE_SELECT,
    DIALOG_FIGHTSTYLE,
    DIALOG_PLAYER_COLOR,
    DIALOG_PLAYER_SETTINGS,
    DIALOG_GANG_PANEL
};
enum (+= 5) // 0 , 5, 10, ....
{
	FREEROAM_WORLD, // 0
	JAIL_WORLD,
	SKYDIVE_WORLD,
	PARKOUR_WORLD,
	IP_WORLD,
	BMX_WORLD,
	DM_WORLD  
};

// Teleport 
enum {

	Tele_Hotspots,
	Tele_Cities,
	Tele_Challenges,
	Tele_Minigames
};

enum TDEnum {

	CatID,
	CatName[20]
};

static const TeleportDialog[][TDEnum] =
{
	{Tele_Hotspots,"Hotspots"},
	{Tele_Cities,"Cities"},
	{Tele_Challenges,"Challenges"},
	{Tele_Minigames,"Minigames"}
};

enum TNEnum {
	TeleID,
	TeleName[30],
	TeleCmd[10],
	Float:LabelPosX,
	Float:LabelPosY,
	Float:LabelPosZ,
	LabelWorld,
	bool:LabelCreate
}

static const TeleportNames[][TNEnum] =
{
   
   {Tele_Hotspots, "Los Santos", "ls",2494.7476, -1666.6097, 13.3438, FREEROAM_WORLD,true},
   {Tele_Hotspots, "San Fierro", "sf",-1990.6650, 136.9297, 27.3110,FREEROAM_WORLD,true},
   {Tele_Hotspots, "Las Venturas", "lv",2039.8860,1546.1112,10.4450,FREEROAM_WORLD,true},
   {Tele_Hotspots, "Abandoned Airport", "aa",376.6015,2540.4746,19.5100,FREEROAM_WORLD,true},
   {Tele_Hotspots, "Mount Chiliad", "mc",-2340.2388,-1624.9121,487.7368,FREEROAM_WORLD,true},
   {Tele_Hotspots, "San Fierro Airport", "sfa",-1173.9863,36.9642,15.7011,FREEROAM_WORLD,true},
   

   {Tele_Cities, "Los Santos Hospital", "lsh",2031.6591,-1415.4594,16.9922,FREEROAM_WORLD,true},
   {Tele_Cities, "San Fierro Hospital", "sfh",-2663.7432,593.5697,14.2507,FREEROAM_WORLD,true},
   {Tele_Cities, "Las Venturas Hospital", "lvh",1608.1807,1833.2031,10.8203 ,FREEROAM_WORLD,true},
   {Tele_Cities, "Los Santos", "ls",2494.7476, -1666.6097, 13.3438, FREEROAM_WORLD,true},
   {Tele_Cities, "San Fierro", "sf",-1990.6650, 136.9297, 27.3110,FREEROAM_WORLD,true},
   {Tele_Cities, "Las Venturas", "lv",2039.8860,1546.1112,10.4450,FREEROAM_WORLD,true},
   {Tele_Cities, "Los Santos Airport", "lsa",1918.7611,-2393.4937,18.5000, FREEROAM_WORLD,true},
   {Tele_Cities, "San Fierro Airport", "sfa",-1173.9863,36.9642,15.7011,FREEROAM_WORLD,true},
   {Tele_Cities, "Las Venturas Airport", "lva",1319.0911,1263.2156,12.2010,FREEROAM_WORLD,true},
   {Tele_Cities, "LS Police Department", "lspd",1536.1853,-1671.6768,13.1804, FREEROAM_WORLD,true},
   {Tele_Cities, "LV Police Department", "lvpd",2291.2131,2426.4822,10.8203,FREEROAM_WORLD,true},
   {Tele_Cities, "SF Police Department", "sfpd",-1627.0214,679.1722,7.1901,FREEROAM_WORLD,true},
   {Tele_Cities, "Glen", "glen", 1897.0003,-1172.1928,24.2482,FREEROAM_WORLD,true},


   {Tele_Challenges, "Skydive 1", "skydive", 1850.0948,-134.4211,2465.8916,SKYDIVE_WORLD,true},
   {Tele_Challenges, "Skydive 2", "skydive2",-3775.1895,1585.9076,1642.9535,SKYDIVE_WORLD,true},
   {Tele_Challenges, "Parkour 1", "parkour",1116.6528,-2048.5420,74.4297,PARKOUR_WORLD,true},
   {Tele_Challenges, "Infernus Paradise", "ip",-2710.2043, 2921.9412, 9.6277,IP_WORLD,true},
   {Tele_Challenges, "BMX Parkour", "bmx",198.5472,3274.2612,16.0692,BMX_WORLD,true},
   
   {Tele_Minigames, "Deathmatches", "dms", 0.0, 0.0 , 0.0 ,  -1,false}

};

// Achievements
enum {

	ACH_SCORE,
	ACH_CASH,
	ACH_KIllER,
	ACH_RIP,
	ACH_SKYDIVER
};
enum ACHEnum {
    Ach_ID,
	Ach_Name[30],
	Ach_Req,
	Ach_ReqText[30]
};
/* 
  if you are going to edit an achievement, please use the ach_od to search and edit.
*/
static const AchInfo[MAX_ACHS][ACHEnum] =
{
   {ACH_SCORE, "Score Gainer", 2500, "Get 2500 Score"}, // in Main.Pwn
   {ACH_CASH, "Rich Player", 10000000, "Earn $10,000,000"}, // In Main.pwn 
   {ACH_KIllER, "Assassinator", 5000, "Get 5000 Kills"}, //in Main.pwn
   {ACH_RIP, "Rest In Peace", 1000, "Die 1000 Times"}, // In Main.pwn 
   {ACH_SKYDIVER, "God of Skydiving", MAX_SKYDIVE_ACH, "Win First 2 Skydives"} // In Main.pwn and Skydives.pwn
};

// Vehicle Dialog
enum {

	Vehicle_Airplanes,
	Vehicle_Helicopters,
	Vehicle_Bikes,
	Vehicle_Convertibles,
	Vehicle_Industrial,
	Vehicle_Lowriders,
	Vehicle_OffRoad,
	Vehicle_PSV,
	Vehicle_Saloons,
	Vehicle_Sport,
	Vehicle_Wagons,
	Vehicle_Boats,
	Vehicle_RC,
	Vehicle_Unique
};

enum VDEnum {

	CatID,
	CatName[50]
};

enum VEnum {

	V_ID,
	V_Model,
	V_Price
};

static const VehicleDialog[][VDEnum] =
{
	{Vehicle_Airplanes,"Airplanes"},
	{Vehicle_Helicopters,"Helicopters"},
	{Vehicle_Bikes,"Bikes"},
	{Vehicle_Convertibles,"Convertibles"},
	{Vehicle_Industrial,"Industrials"},
	{Vehicle_Lowriders,"Lowriders"},
	{Vehicle_OffRoad,"Off Road"},
	{Vehicle_PSV,"Public Service Vehicles"},
	{Vehicle_Saloons,"Saloons"},
	{Vehicle_Sport,"Sports Vehicles"},
	{Vehicle_Wagons,"Station Wagons"},
	{Vehicle_Boats,"Boats"},
	{Vehicle_RC,"RC Vehicles"},
	{Vehicle_Unique,"Unique Vehicles"}
};
/* Price List are added for Private Vehicle system */
static const VehicleMenu[][VEnum] =
{
	{Vehicle_Airplanes, 460, 2000000},
	{Vehicle_Airplanes, 476, 2000000},
	{Vehicle_Airplanes, 511, 2000000},
	{Vehicle_Airplanes, 512, 2000000},
	{Vehicle_Airplanes, 519, 2000000},
	{Vehicle_Airplanes, 513, 2000000},
	{Vehicle_Airplanes, 553, 2000000},
	{Vehicle_Airplanes, 577, 2000000},
	{Vehicle_Airplanes, 592, 2000000},
	{Vehicle_Airplanes, 593, 2000000},

	{Vehicle_Helicopters, 548, 1400000},
	{Vehicle_Helicopters, 417, 1500000},
	{Vehicle_Helicopters, 487, 1300000},
	{Vehicle_Helicopters, 488, 1100000},
	{Vehicle_Helicopters, 497, 1700000},
	{Vehicle_Helicopters, 563, 1800000},
	{Vehicle_Helicopters, 469, 1900000},

	{Vehicle_Bikes, 581, 800000},
	{Vehicle_Bikes, 509, 700000},
	{Vehicle_Bikes, 481, 500000},
	{Vehicle_Bikes, 462, 230000},
	{Vehicle_Bikes, 521, 500000},
	{Vehicle_Bikes, 463, 500000},
	{Vehicle_Bikes, 510, 500000},
	{Vehicle_Bikes, 522, 500000},
	{Vehicle_Bikes, 461, 500000},
	{Vehicle_Bikes, 448, 500000},
	{Vehicle_Bikes, 471, 500000},
	{Vehicle_Bikes, 468, 500000},
	{Vehicle_Bikes, 586, 500000},

	{Vehicle_Convertibles, 480, 80000},
	{Vehicle_Convertibles, 533, 50000},
	{Vehicle_Convertibles, 439, 70000},
	{Vehicle_Convertibles, 555, 40000},

	{Vehicle_Industrial, 422, 200000},
	{Vehicle_Industrial, 482, 200000},
	{Vehicle_Industrial, 498, 200000},
	{Vehicle_Industrial, 609, 200000},
	{Vehicle_Industrial, 524, 200000},
	{Vehicle_Industrial, 578, 200000},
	{Vehicle_Industrial, 455, 200000},
	{Vehicle_Industrial, 403, 200000},
	{Vehicle_Industrial, 414, 200000},
	{Vehicle_Industrial, 582, 200000},
	{Vehicle_Industrial, 443, 200000},
	{Vehicle_Industrial, 514, 200000},
	{Vehicle_Industrial, 515, 200000},
	{Vehicle_Industrial, 440, 200000},
	{Vehicle_Industrial, 543, 200000},
	{Vehicle_Industrial, 605, 200000},
	{Vehicle_Industrial, 459, 200000},
	{Vehicle_Industrial, 531, 200000},
	{Vehicle_Industrial, 408, 200000},
	{Vehicle_Industrial, 552, 200000},
	{Vehicle_Industrial, 478, 200000},
	{Vehicle_Industrial, 456, 200000},
	{Vehicle_Industrial, 554, 200000},

	{Vehicle_Lowriders, 536, 800000},
	{Vehicle_Lowriders, 575, 700000},
	{Vehicle_Lowriders, 534, 500000},
	{Vehicle_Lowriders, 567, 230000},
	{Vehicle_Lowriders, 535, 500000},
	{Vehicle_Lowriders, 566, 500000},
	{Vehicle_Lowriders, 576, 500000},
	{Vehicle_Lowriders, 412, 500000},


   	{Vehicle_OffRoad, 568, 100000},
	{Vehicle_OffRoad, 424, 200000},
	{Vehicle_OffRoad, 573, 300000},
	{Vehicle_OffRoad, 579, 400000},
	{Vehicle_OffRoad, 400, 500000},
	{Vehicle_OffRoad, 500, 600000},
	{Vehicle_OffRoad, 444, 700000},
	{Vehicle_OffRoad, 556, 800000},
	{Vehicle_OffRoad, 557, 900000},
	{Vehicle_OffRoad, 470, 995555},
	{Vehicle_OffRoad, 505, 750000},
	{Vehicle_OffRoad, 495, 850000},

	{Vehicle_PSV, 416, 800000},
	{Vehicle_PSV, 433, 700000},
	{Vehicle_PSV, 431, 500000},
	{Vehicle_PSV, 438, 230000},
	{Vehicle_PSV, 437, 500000},
	{Vehicle_PSV, 523, 500000},
	{Vehicle_PSV, 490, 500000},
	{Vehicle_PSV, 528, 500000},
	{Vehicle_PSV, 407, 500000},
	{Vehicle_PSV, 544, 500000},
	{Vehicle_PSV, 544, 500000},
	{Vehicle_PSV, 598, 500000},
	{Vehicle_PSV, 597, 500000},
	{Vehicle_PSV, 599, 300000},
	{Vehicle_PSV, 601, 300000},
	{Vehicle_PSV, 420, 300000},

	{Vehicle_Saloons, 445, 200000},
	{Vehicle_Saloons, 504, 200000},
	{Vehicle_Saloons, 401, 200000},
	{Vehicle_Saloons, 518, 200000},
	{Vehicle_Saloons, 527, 200000},
	{Vehicle_Saloons, 542, 200000},
	{Vehicle_Saloons, 507, 200000},
	{Vehicle_Saloons, 585, 200000},
	{Vehicle_Saloons, 419, 200000},
	{Vehicle_Saloons, 526, 200000},
	{Vehicle_Saloons, 604, 200000},
	{Vehicle_Saloons, 466, 200000},
	{Vehicle_Saloons, 492, 200000},
	{Vehicle_Saloons, 474, 200000},
	{Vehicle_Saloons, 546, 200000},
	{Vehicle_Saloons, 517, 200000},
	{Vehicle_Saloons, 410, 200000},
	{Vehicle_Saloons, 551, 200000},
	{Vehicle_Saloons, 516, 200000},
	{Vehicle_Saloons, 467, 200000},
	{Vehicle_Saloons, 600, 200000},
	{Vehicle_Saloons, 426, 200000},
	{Vehicle_Saloons, 436, 200000},
	{Vehicle_Saloons, 547, 200000},
	{Vehicle_Saloons, 405, 200000},
	{Vehicle_Saloons, 580, 200000},
	{Vehicle_Saloons, 560, 200000},
	{Vehicle_Saloons, 550, 200000},
	{Vehicle_Saloons, 549, 200000},
	{Vehicle_Saloons, 540, 200000},
	{Vehicle_Saloons, 491, 200000},
	{Vehicle_Saloons, 529, 200000},
	{Vehicle_Saloons, 421, 200000},

	{Vehicle_Sport, 602, 200000},
	{Vehicle_Sport, 429, 200000},
	{Vehicle_Sport, 496, 200000},
	{Vehicle_Sport, 402, 200000},
	{Vehicle_Sport, 541, 200000},
	{Vehicle_Sport, 415, 200000},
	{Vehicle_Sport, 589, 200000},
	{Vehicle_Sport, 587, 200000},
	{Vehicle_Sport, 565, 200000},
	{Vehicle_Sport, 494, 200000},
	{Vehicle_Sport, 502, 200000},
	{Vehicle_Sport, 503, 200000},
	{Vehicle_Sport, 411, 200000},
	{Vehicle_Sport, 559, 200000},
	{Vehicle_Sport, 603, 200000},
	{Vehicle_Sport, 475, 200000},
	{Vehicle_Sport, 506, 200000},
	{Vehicle_Sport, 451, 200000},
	{Vehicle_Sport, 558, 200000},
	{Vehicle_Sport, 477, 200000},
	{Vehicle_Sport, 562, 200000},

	{Vehicle_Wagons, 418, 800000},
	{Vehicle_Wagons, 404, 700000},
	{Vehicle_Wagons, 479, 500000},
	{Vehicle_Wagons, 458, 230000},
	{Vehicle_Wagons, 561, 500000},


	{Vehicle_Boats, 472, 800000},
	{Vehicle_Boats, 473, 700000},
	{Vehicle_Boats, 493, 500000},
	{Vehicle_Boats, 595, 230000},
	{Vehicle_Boats, 484, 500000},
	{Vehicle_Boats, 430, 500000},
	{Vehicle_Boats, 453, 500000},
	{Vehicle_Boats, 452, 500000},
	{Vehicle_Boats, 446, 500000},
	{Vehicle_Boats, 454, 500000},

	{Vehicle_RC, 441, 800000},
	{Vehicle_RC, 465, 700000},
	{Vehicle_RC, 501, 500000},
	{Vehicle_RC, 564, 230000},
	{Vehicle_RC, 594, 500000},

	{Vehicle_Unique, 485, 200000},
	{Vehicle_Unique, 457, 200000},
	{Vehicle_Unique, 483, 200000},
	{Vehicle_Unique, 508, 200000},
	{Vehicle_Unique, 532, 200000},
	{Vehicle_Unique, 486, 200000},
	{Vehicle_Unique, 406, 200000},
	{Vehicle_Unique, 530, 200000},
	{Vehicle_Unique, 434, 200000},
	{Vehicle_Unique, 545, 200000},
	{Vehicle_Unique, 588, 200000},
	{Vehicle_Unique, 571, 200000},
	{Vehicle_Unique, 572, 200000},
	{Vehicle_Unique, 423, 200000},
	{Vehicle_Unique, 442, 200000},
	{Vehicle_Unique, 428, 200000},
	{Vehicle_Unique, 409, 200000},
	{Vehicle_Unique, 574, 200000},
	{Vehicle_Unique, 525, 200000},
	{Vehicle_Unique, 583, 200000},
	{Vehicle_Unique, 539, 200000}
};



// Weapon Dialog
enum {
  
    WEAPON_RIFLES,
    WEAPON_SUBMACHINES,
    WEAPON_SHOTGUNS,
    WEAPON_HANDGUNS,
    WEAPON_MELEE,
    WEAPON_SPECIAL
};

enum WDEnum
{
   WeapCatID,
   WeapName[20],
   WeapModel,
   WeapModelID,
   WeapAmmo
};

enum WMDEnum {

	WeapMCatID,
	WeapMCatName[20]
};
static const WeaponMenuDialog[][WMDEnum] =
{
	{WEAPON_RIFLES,"Rifles"},
	{WEAPON_SUBMACHINES,"Submachine Guns"},
	{WEAPON_SHOTGUNS,"Shot Guns"},
	{WEAPON_HANDGUNS,"Hand Guns"},
	{WEAPON_MELEE,"Melee Guns"},
	{WEAPON_SPECIAL,"Special Weapons"}
};


static const WeaponDialog[][WDEnum] =
{
   // Rifles
  {WEAPON_RIFLES, "AK-47", 30, 355, 9999999},
  {WEAPON_RIFLES, "Country Rifle",33,357, 9999999},
  {WEAPON_RIFLES, "M4", 31, 356, 9999999},
  {WEAPON_RIFLES, "Sniper Rifle", 34,358, 9999999},

  // Submachine
  {WEAPON_SUBMACHINES, "MP 5",29,353, 9999999},
  {WEAPON_SUBMACHINES, "UZI", 28,352 , 9999999},
  {WEAPON_SUBMACHINES, "TEC-9", 32, 372 ,9999999},

  // Shotguns
  {WEAPON_SHOTGUNS, "Pump Gun",25, 349 ,9999999},
  {WEAPON_SHOTGUNS, "Sawn-Off", 26, 350 ,9999999},
  {WEAPON_SHOTGUNS, "Combat Shotgun", 27,351 , 9999999},

  // hand guns
  {WEAPON_HANDGUNS, "9mm",22, 346 ,9999999},
  {WEAPON_HANDGUNS, "Silenced 9mm", 23, 347 ,9999999},
  {WEAPON_HANDGUNS, "Desert Eagle", 24,348 , 9999999},

  //melee
  {WEAPON_MELEE, "Golf Club", 2,333 , 1},
  {WEAPON_MELEE, "Nightstick",3,334 , 1},
  {WEAPON_MELEE, "Knife", 4,335 , 1},
  {WEAPON_MELEE, "Shovel", 6, 337 ,1},
  {WEAPON_MELEE, "Katana", 8, 339 ,1},
  {WEAPON_MELEE, "Chainsaw",9, 341 ,1},
  {WEAPON_MELEE, "Double-ended Dildo", 10, 321 ,1},
  {WEAPON_MELEE, "Silver Vibrator", 13, 324 ,1},
  {WEAPON_MELEE, "Flowers", 14, 325 ,1},

  //specials
  {WEAPON_SPECIAL, "Tear Gas", 17,343, 9999999},
  {WEAPON_SPECIAL, "Molotov Cocktail",18, 344,4},
  {WEAPON_SPECIAL, "Flamethrower", 37,361, 50},
  {WEAPON_SPECIAL, "Spraycan", 41, 365, 50},
  {WEAPON_SPECIAL, "Fire Extinguisher", 42, 366, 50}
};


static const AdminLevels[Founder_Level + 1 ][] =
{
	{"Member"},
	{"Junior Administrator"},
	{"Lead Administrator"},
	{"Head Administrator"},
	{"Chief Executive Administrator"},
	{"Founder"}
};

enum TPEnum {

	Float:Posx,
	Float:Posy,
	Float:Posz
};
enum VPEnum {
    
	Float:Posx,
	Float:Posy,
	Float:Posz
};

static const TelePickups[3][TPEnum] =
{

	{-1184.2761,38.5494,15.6831},
	{368.6183,2530.8616,19.5100},
	{-2332.5659,-1631.2749,487.7318}
};
static const VehiclePickups[3][VPEnum] =
{
	{-2326.1672,-1677.3083,485.4201},
	{352.3308,2540.4004,16.7284},
	{-1187.9993,6.0414,14.1484}
};
new TeleportPickup[sizeof(TelePickups)], VehiclePickup[sizeof(VehiclePickups)];


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

static const GetVehicleName[212][] =
{
	{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},{"Firetruck"},{"Trashmaster"},{"Stretch"},
	{"Manana"},{"Infernus"},{"Voodoo"},{"Pony"},{"Mule"},{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},
	{"Washington"},{"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Ohdude"},{"Premier"},{"Enforcer"},{"Securicar"},{"Banshee"},{"Predator"},{"Bus"},
	{"faggot"},{"Barracks"},{"Hotknife"},{"Trailer 1"},{"Previon"},{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},
	{"Monster"},{"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},{"Speeder"},{"Reefer"},{"Tropic"},{"Flatbed"},
	{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},{"Skimmer"},{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},
	{"Sanchez"},{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},{"Rustler"},{"ZR-350"},{"Walton"},{"Regina"},{"Comet"},
	{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},{"Baggage"},{"Dozer"},{"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},
	{"Jetmax"},{"Hotring"},{"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},{"Mesa"},{"RC Goblin"},{"Hotring Racer A"},
	{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},{"Super GT"},{"Elegant"},{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},
	{"Tanker"},{"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Jumpjet"},{"FCR-900"},{"NRG-500"},{"HPV1000"},{"Cement Truck"},{"Tow Truck"},
	{"Fortune"},{"Cadrona"},{"FBI Truck"},{"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},{"Blade"},{"Freight"},
	{"Brownstreak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},{"Firetruck LA"},{"Hustler"},{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},
	{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},{"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},{"RC Tiger"},
	{"Flash"},{"Tahoma"},{"Savanna"},{"Bandito"},{"Freight Flat"},{"Streak Carriage"},{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},{"Broadway"},{"Tornado"},{"AT-400"},
	{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"Newsvan"},{"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},{"Club"},{"Freight Carriage"},
	{"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},{"Police Car (SFPD)"},{"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T. Van"},
	{"Alpha"},{"Phoenix"},{"Glendale"},{"Sadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},{"Boxville"},{"Farm Plow"},{"Utility Trailer"}
};

new ClassModels[28] = 
{
	23, 270, 170, 3, 304,81,1,299,0,199,5,264,26,289,
	28,72,100,115,272,127,138,149,249,
	162,271,285,310,307
};
static const Float:PlayerSpawns[3][4] =
{
	{376.6015,2540.4746,19.5100,182.1743}, //aa
	{-2340.2388,-1624.9121,487.7368,270.7733}, //mc
	{-1173.9863,36.9642,15.7011,133.4367} //sfa
};

new MainStr[350], getotherid, PlayerReports[MAX_REPORTS][500];

// Server Includes
  // Includes#endinput
#include "inc\convertunix.inc"
#include "inc\callbacks.inc"
#include "inc\anims.pwn"
  //textdraws
#include "inc\textdraws.pwn"

  //maps
#include "inc\maps\freeroam_maps.pwn"
#include "inc\maps\skydive_maps.pwn"
#include "inc\maps\parkour_maps.pwn"
#include "inc\maps\infernus_paradise_maps.pwn"
#include "inc\maps\bmx_maps.pwn"
   // minigames
#include "inc\minigames\dm_system.pwn"

   // challenges
#include "inc\challenges\skydives.pwn"
#include "inc\challenges\parkours.pwn"
#include "inc\challenges\ipchallenge.pwn"
#include "inc\challenges\bmxs.pwn"

   // system tests
#include "inc\server_tests\reaction.pwn"
#include "inc\server_tests\maths.pwn"

  // Scripts
#include "inc\gang.pwn"
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

    // Maps
     // Freeroamss
    CreateFreeroamMaps();
    CreateFreeroamVehicles();
    
     //Skydive
    CreateSkydiveObjects();

     //Parkour
    CreateParkourObjects();

     //Infernus Paradise
    CreateInfernusParadiseMaps();
    
    // BMX Parkour
    CreateBMXParkourMaps();
    CreateBMXVehicles();

    // Load Gangs
    LoadServerGang();

    LoadServerGangZone();

    //Player Class Selection
    for(new cmodelid; cmodelid < sizeof(ClassModels); cmodelid++)
    { 
       AddPlayerClass(ClassModels[cmodelid], -1430.8273, 1581.1094, 1055.7191,103.7086,0, 0, 0, 0, 0, 0);
	}

	ServerVars[Server_Timer] = SetTimer("ServerTimer", 1000, true);
	ServerVars[Server_RandMSG] = SetTimer("ServerRandMSG", 120000, true); // 2 min
    
	for(new i = 1; i < MAX_REPORTS; i++)
		PlayerReports[i] = "_";

	// Teleport Label Names
    for(new i =0; i < sizeof(TeleportNames); i++)
    {
   	    if(TeleportNames[i][LabelCreate])
   	    {
		    format(MainStr, sizeof(MainStr), ""text_yellow"%s\n  "text_white"(/%s)", TeleportNames[i][TeleName], TeleportNames[i][TeleCmd]);
			CreateDynamic3DTextLabel(MainStr, -1,  TeleportNames[i][LabelPosX], TeleportNames[i][LabelPosY], TeleportNames[i][LabelPosZ] + 0.40, 40.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0,TeleportNames[i][LabelWorld], -1, -1);
		}
    }
    // Teleport Pickts Hotspots
    for(new vp = 0; vp < sizeof(VehiclePickups); vp++)
    {
    	VehiclePickup[vp] = CreateDynamicPickup(19132, 2, VehiclePickups[vp][Posx],VehiclePickups[vp][Posy], VehiclePickups[vp][Posz], FREEROAM_WORLD);
    	CreateDynamic3DTextLabel(""text_red"Vehicles\n   "text_white"(/v)", -1,  VehiclePickups[vp][Posx],VehiclePickups[vp][Posy], VehiclePickups[vp][Posz], 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0,FREEROAM_WORLD, -1, -1);
    }

    for(new tp = 0; tp < sizeof(TelePickups); tp++)
    {
    	TeleportPickup[tp] = CreateDynamicPickup(19130, 2, TelePickups[tp][Posx],TelePickups[tp][Posy], TelePickups[tp][Posz] , FREEROAM_WORLD);
    	CreateDynamic3DTextLabel(""text_blue"Teleports\n   "text_white"(/t)", -1,  TelePickups[tp][Posx],TelePickups[tp][Posy], TelePickups[tp][Posz], 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0,FREEROAM_WORLD, -1, -1);
    }

	for(new serverveh = 0; serverveh != MAX_VEHICLES; ++serverveh)
	{
		SetVehicleNumberPlate(serverveh, ""text_blue"FW");
	}
    
	for(new i = 0; i < MAX_GZONES; i++)
    {
        GZInfo[i][Zone_TD] =  TextDrawCreate(503.000000, 298.000000, "Gang War: Nones~n~Defend the Gang Zone!~n~~n~~n~Timeleft: --:--");
        TextDrawBackgroundColor(GZInfo[i][Zone_TD], 255);
        TextDrawFont(GZInfo[i][Zone_TD], 1);
        TextDrawLetterSize(GZInfo[i][Zone_TD], 0.240000, 1.100000);
        TextDrawColor(GZInfo[i][Zone_TD], -1);
        TextDrawSetOutline(GZInfo[i][Zone_TD], 1);
        TextDrawSetProportional(GZInfo[i][Zone_TD], 1);
        TextDrawSetSelectable(GZInfo[i][Zone_TD], 0);
    }
    return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
   if(PlayerInfo[playerid][Player_Mode] == MODE_SPEC) return true;
   
   switch(PlayerInfo[playerid][Player_Mode])
   {

   	     case MODE_FREEROAM:
   	     {       
   	     	     if(IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return 1;

   	     	     // Vehicle Pickups
     	    	 for(new vp = 0; vp < sizeof(VehiclePickups); vp++)
     	    	 {
     	    	 	 if(VehiclePickup[vp] == pickupid)
     	    	 	 {
                        ClosePlayerDialog(playerid);
                        RequestPlayerVehicleDialog(playerid);
     	    	 	 	return 1;
     	    	 	 }
     	    	 }

     	    	 // Teleport Pickups
     	    	 for(new tp = 0; tp < sizeof(TelePickups); tp++)
     	    	 {
     	    	 	 if(TeleportPickup[tp] == pickupid)
     	    	 	 {
                        ClosePlayerDialog(playerid);
                        RequestPlayerTeleDialog(playerid);
     	    	 	 	return 1;
     	    	 	 }
     	    	 }
   	      }
   }

   return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(PlayerInfo[playerid][Player_Mode] == MODE_SPEC) return true;
	return 1;
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(PlayerInfo[playerid][Player_Mode] == MODE_SPEC) return true;
	return 1;
}
public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    if(PlayerInfo[playerid][Player_Mode] == MODE_SPEC) return true;
    return 1;
}

public OnGameModeExit()
{
    foreach(new i : Player)
	{
		if(PlayerInfo[i][Player_Logged]) PlayerRequestSaveStats(i);
	}
	SaveGangZones();
    DestroyAllDynamic3DTextLabels();
    DestroyAllDynamicObjects();
    DestroyAllDynamicAreas();
    
    for(new i = 0; i < MAX_GZONES; i ++)
    {
      GangZoneDestroy(GZInfo[i][Zone_Area]);
      TextDrawDestroy(GZInfo[i][Zone_TD]);
    }
	KillTimer(ServerVars[Server_Timer]);
	KillTimer(ServerVars[Server_RandMSG]);
    mysql_close(fwdb);
	return 1;
}

public OnPlayerConnect(playerid)
{
    ResetPlayerVar(playerid);

    RemovePlayerFreroamObjects(playerid); // freeroam
    RemovePlayerParkourObjects(playerid); // parkour


    GetPlayerIp(playerid, PlayerInfo[playerid][Player_TempIP], 16);
    GetPlayerName(playerid, PlayerInfo[playerid][Player_TempName], MAX_PLAYER_NAME);
    SetPlayerColor(playerid, PlayerColors[random(sizeof(PlayerColors))]);

    
    format(MainStr, sizeof(MainStr), ""text_green"** -> %s has connected to the server!", PlayerInfo[playerid][Player_Name]);
    SCMToAll(msg_green, MainStr);
 
    for(new i = 0; i < 30; i ++) SCM(playerid,msg_white, "\n");
    SCM(playerid, msg_white, "=========================="text_red""SERVER_HOST""text_white"==========================");
	SCM(playerid, msg_white, "Welcome to "text_red"Freeroam World "text_yellow""SERVER_VERSION"");
	SCM(playerid, msg_white, "Scripted by "text_green"Oblivion");
	SCM(playerid, msg_white, "Visit our webite at "text_blue""SERVER_WEB"");
	SCM(playerid, msg_white, "Copyright (c)2020 Freeroam World");
	SCM(playerid, msg_white, "==============================================================");
    


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
    mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT * FROM `users` WHERE `name` ='%e' LIMIT 1;", PlayerInfo[playerid][Player_TempName]);
    mysql_tquery(fwdb, MainStr, "OnPlayerAccountCheck", "i", playerid);


    SendDeathMessage(INVALID_PLAYER_ID, playerid, 200);
    return 1;
}
publicEx OnPlayerAccountCheck(playerid)
{

    if(!cache_num_rows()) return RequestRegisterDialog(playerid);
    
	cache_get_value_name(0, "password", PlayerInfo[playerid][Player_Pass],65);
    cache_get_value_name(0, "salts", PlayerInfo[playerid][Player_Salts], 11);
    cache_get_value_name_int(0, "autologin", PlayerInfo[playerid][Player_AutoLogin]);
    cache_get_value_name(0, "name", PlayerInfo[playerid][Player_Name], MAX_PLAYER_NAME);
    cache_get_value_name(0, "ip", PlayerInfo[playerid][Player_IP], 16);

    // Ban Check
    mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT `ban_id`,`ban_user`, `ban_admin`, `ban_time`,`ban_lift` ,`ban_reason` FROM `bans` WHERE `ban_user`='%e' OR `ban_ip` = '%s'", PlayerInfo[playerid][Player_Name], PlayerInfo[playerid][Player_IP]);
	new Cache:bancheck = mysql_query(fwdb, MainStr);

	if(cache_num_rows())
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
                      SCM(playerid, msg_white, ""SERVER_TAG" "text_green"Good News: You account ban has been expired! Good Luck");
              
                }
                else
                {
                     SendPlayerTextNotice(playerid, "~r~You are Banned!", "");
                     format(ban_msg, sizeof(ban_msg), ""text_white"Hello %s,\nBan ID: %d\nBanned by: %s\nBan Date: %s\nBan Lift: %s\nReason: %s\nWrongly Banned? Do a ban appeal in forum!",
                     	ban_user, ban_id, ban_admin, ConvertUnix(ban_time), ConvertUnix(ban_lift), ban_reason);
                     ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG"  Ban Notice", ban_msg, "OK", "");
                     DelayKick(playerid);
                     cache_delete(bancheck);  
                     return 1;
                }
            }
            else
            {       // Permanent Ban
            	     SendPlayerTextNotice(playerid, "~r~You are Banned!","");
                     format(ban_msg, sizeof(ban_msg), ""text_white"Hello %s,\nBan ID: %d\nBanned by: %s\nBan Date: %s\nBan Lift: Permanent\nReason: %s\nWrongly Banned? Do a ban appeal in forum!",
                     	ban_user, ban_id, ban_admin, ConvertUnix(ban_time),  ban_reason);
                     ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG"  Ban Notice", ban_msg, "OK", "");
                     DelayKick(playerid);
                     cache_delete(bancheck);  
                     return 1;
            }
    }
    else 
    {
    	 // auto login comes here
    	 cache_delete(bancheck);  
         if(PlayerInfo[playerid][Player_AutoLogin] == 1 &&  !strcmp(PlayerInfo[playerid][Player_IP],PlayerInfo[playerid][Player_TempIP]))
         {
                  mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT * FROM `users` WHERE `name` = '%e' LIMIT 1;", PlayerInfo[playerid][Player_Name] );
                  mysql_tquery(fwdb, MainStr, "PlayerRequestLogin", "i",playerid);
         } 
         else RequestLoginDialog(playerid);
    }       
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(PlayerInfo[playerid][Player_Logged]) PlayerRequestSaveStats(playerid);

    PlayerInfo[playerid][Player_LoadMap] = false;
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);
    
    DestroyPlayerVehicles(playerid);

    //Spec 
    foreach(new i : Player)
    {

    	if(PlayerInfo[i][Player_Mode] == MODE_SPEC && PlayerInfo[i][Player_Spec] == playerid)
    	{
    	    cmd_unspec(i);
    	    SCM(i, msg_red, ""SERVER_TAG" You have been put back yout old position. Reason: Player disconnected!");
		}
		if(PlayerInfo[i][Player_Ignore][playerid] == 1)
		{
                PlayerInfo[i][Player_Ignore][playerid] = 0;
		}
    }
    
    if(PlayerInfo[playerid][Player_InGWAR])
    {
       PlayerInfo[playerid][Player_InGWAR] = false;
       for(new ix = 0; ix < MAX_GZONES; ix++)  
       {
        	TextDrawHideForPlayer(playerid, GZInfo[ix][Zone_TD]);
     	    GangZoneStopFlashForPlayer(playerid, GZInfo[ix][Zone_Area]);
       }
    }

    if(PlayerInfo[playerid][Player_GangID] != 0) Delete3DTextLabel(GangLabel[playerid]);
    // Reset Player Data.
    ResetPlayerVar(playerid);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{

    PlayerInfo[playerid][Player_FirstSpawn] = true;
    new spawnrand = random(sizeof(PlayerSpawns));


    SetSpawnInfo(playerid, NO_TEAM, PlayerInfo[playerid][Player_Skin] != 999 ? PlayerInfo[playerid][Player_Skin] : GetPlayerSkin(playerid), PlayerSpawns[spawnrand][0], PlayerSpawns[spawnrand][1], 
    	                     PlayerSpawns[spawnrand][2], PlayerSpawns[spawnrand][3], 0, 0, 0, 0, 0, 0);
    
    ServerGlobalTD(playerid); 
    if(PlayerInfo[playerid][Player_Skin] != 999)
	{
		 TogglePlayerSpectating(playerid, true);
		 SetTimerEx("ForcePlayerToSpawn", 20, false, "i", playerid);
		 TogglePlayerSpectating(playerid, false);

		 return 1;
	}
	else
	{
		Streamer_UpdateEx(playerid, -1430.8273, 1581.1094, 1055.7191);
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
	// reset cash to avoid some bugs.
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerInfo[playerid][Player_Cash]);

    PlayerInfo[playerid][Player_Spawned] = true;
    if(PlayerInfo[playerid][Player_FirstSpawn])
    {
    	PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
        PlayerInfo[playerid][Player_FirstSpawn] = false;
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
        StopAudioStreamForPlayer(playerid);
        if(PlayerInfo[playerid][Player_God])
	    {
		    PlayerInfoTD(playerid, "~w~Your ~y~GODMODE ~w~has been ~g~enabled", 5000);
		    TextDrawShowForPlayer(playerid, TDInfo[PlayerGod]);
	    }
	    else WeaponReset(playerid);

	    if(PlayerInfo[playerid][Player_GangID] != 0)
	    {
	    	SetPlayerGangLabel(playerid);
	    }
	    SyncGangZoneForPlayer(playerid);
        SetPlayerWorldBounds(playerid, 20000, -20000, 20000, -20000);

        // gang war notice
        if(PlayerInfo[playerid][Player_GangID] != 0 && Iter_Contains(InGangWar, PlayerInfo[playerid][Player_GangID]))
        {
             for(new i = 0; i < MAX_GZONES; i++)
             {
             	if(!GZInfo[i][Zone_Exist])  continue;
             	if(GZInfo[i][Zone_Status] != Zone_InAttack) continue;
                
                if(GZInfo[i][Zone_Owner] == PlayerInfo[playerid][Player_GangID])
                {
                	SCM(playerid, msg_red, "Gang War Notice: Defend the Zone");
                	format(MainStr, sizeof(MainStr), ""GANG_TAG" "GANG_CHAT"%s is attacking your gang zone: '%s'. ReCapture the zone using /capture",GangInfo[GZInfo[i][Zone_Attacker]][Gang_Name], GZInfo[i][Zone_Name]);
                	SCM(playerid, -1, MainStr);
                	SCM(playerid, msg_red, "Gang War Notice: Defend the Zone");
                	return 1;
                }
                if(GZInfo[i][Zone_Attacker] == PlayerInfo[playerid][Player_GangID])
                {
                	SCM(playerid, msg_red, "Gang War Notice: Capture the Zone");
                	format(MainStr, sizeof(MainStr), ""GANG_TAG" "GANG_CHAT"Your gang is capturing the gang zone: '%s'. Help your gang mates to capture the zone",GZInfo[i][Zone_Name]);
                	SCM(playerid, -1, MainStr);
                	SCM(playerid, msg_red, "Gang War Notice: Capture the Zone");
                	return 1;
                }
             }

        }
        return 1;
    }

    switch(PlayerInfo[playerid][Player_Mode])
    {
	       case MODE_FREEROAM:
	       {
		  		SetCameraBehindPlayer(playerid);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			    SetPlayerInterior(playerid, 0);
			    SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
			    SetCameraBehindPlayer(playerid);
			    if(PlayerInfo[playerid][Player_God])
			    {
				    SetPlayerHealth(playerid, 99999.0);
				    ResetPlayerWeapons(playerid);
			    }
			    else WeaponReset(playerid);
			    SavePlayerPos(playerid);
			    SetPlayerWorldBounds(playerid, 20000, -20000, 20000, -20000);
		   }
		   case MODE_DM:
		   {
			    ResetPlayerWeapons(playerid);
			    // Set Player To DM
			    PlayerRequestToJoinDM(playerid, PlayerInfo[playerid][Player_LastDM]);
		   }
		   case MODE_SKYDIVE:
		   {
			   PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
	           SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	           PlayerInfo[playerid][Player_LastSky] = -1;
	           SetPlayerInterior(playerid, 0);
	           SpawnPlayerEx(playerid, true);
               WeaponReset(playerid);
		   }
		   case MODE_PARKOUR:
		   {
			   PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
	           SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	           PlayerInfo[playerid][Player_LastPark] = -1;
	           SetPlayerInterior(playerid, 0);
	           SpawnPlayerEx(playerid, true);
               WeaponReset(playerid);
		   }
		   case MODE_IP:
		   {
			   PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
	           SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	           PlayerInfo[playerid][Player_LastIP] = -1;
	           SetPlayerInterior(playerid, 0);
	           DestroyPlayerVehicles(playerid);
	           SpawnPlayerEx(playerid, true);
               WeaponReset(playerid);
		   }
		   case MODE_BMX:
		   {
			   PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
	           SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	           PlayerInfo[playerid][Player_LastBMX] = -1;
	           SetPlayerInterior(playerid, 0);
	           SpawnPlayerEx(playerid, true);
               WeaponReset(playerid);
		   }
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	
	 // To avoid  exploits 
	ClosePlayerDialog(playerid);

    PlayerInfo[playerid][Player_Spawned] = false;
    
    SendDeathMessage(killerid, playerid, reason);

    if(PlayerInfo[playerid][Player_Mode] != MODE_SKYDIVE)
    {
       PlayerInfo[playerid][Player_Deaths]++;
       if(PlayerInfo[playerid][Player_Deaths] >= AchInfo[ACH_RIP][Ach_Req] && PlayerInfo[playerid][Player_AchCompleted][ACH_RIP] == 0)
	   {
	    	SCM(playerid, msg_green, ""SERVER_TAG" "text_green"You have achieved the Rest In Peace");
	    	PlayerInfo[playerid][Player_AchCompleted][ACH_RIP] = 1;
	    	TextDrawShowForPlayer(playerid, TDInfo[AchTextFetch]);
    	    SetTimerEx("StopAchDataFetch", 3500, false, "isi"  ,playerid,  AchInfo[ACH_RIP][Ach_Name], ACH_RIP);
	   }
    }

    if(killerid != INVALID_PLAYER_ID)
    {
    	PlayerInfo[killerid][Player_Kills]++;
    	if(PlayerInfo[killerid][Player_Kills] >= AchInfo[ACH_KIllER][Ach_Req] && PlayerInfo[killerid][Player_AchCompleted][ACH_KIllER] == 0)
	    {
	    	SCM(killerid, msg_green, ""SERVER_TAG" "text_green"You have achieved the Assassinator");
	    	PlayerInfo[killerid][Player_AchCompleted][ACH_KIllER] = 1;
	    	TextDrawShowForPlayer(killerid, TDInfo[AchTextFetch]);
    	    SetTimerEx("StopAchDataFetch", 3500, false, "isi" ,killerid,  AchInfo[ACH_KIllER][Ach_Name],ACH_KIllER);
	    	
	    }
	    if(PlayerInfo[killerid][Player_GangID] != PlayerInfo[playerid][Player_GangID]) SendPlayerGangScore(PlayerInfo[killerid][Player_GangID], 3);
    }
    if(PlayerInfo[playerid][Player_Freeze])
	{
		PlayerInfo[playerid][Player_Freeze] = false;
        TogglePlayerControllable(playerid, true);
	}

    if(PlayerInfo[playerid][Player_LoadMap])
    {
	    TogglePlayerControllable(playerid, true);
	    TextDrawHideForPlayer(playerid, TDInfo[ObjectsLoad]);
	    PlayerInfo[playerid][Player_LoadMap] = false;
	    KillTimer(PlayerInfo[playerid][Player_tLoadMap]);
	}
    foreach(new i : Player)
    {
    	if(PlayerInfo[i][Player_Mode] == MODE_SPEC && PlayerInfo[i][Player_Spec] == playerid)
    	{
                 cmd_unspec(i);
                 SCM(i, msg_red, ""SERVER_TAG" You have been put back yout old position. Reason: Player Died!");
    	}
    }

    switch(PlayerInfo[playerid][Player_Mode])
    {
	    case MODE_FREEROAM: 
	    {
		   	    new spawnrand = random(sizeof(PlayerSpawns));
			    SetSpawnInfo(playerid, NO_TEAM, GetPlayerSkin(playerid), PlayerSpawns[spawnrand][0], PlayerSpawns[spawnrand][1], PlayerSpawns[spawnrand][2], PlayerSpawns[spawnrand][3], 0, 0, 0, 0, 0, 0);
			   

			    if(killerid != INVALID_PLAYER_ID && PlayerInfo[killerid][Player_Mode] == MODE_FREEROAM)
			    {
		    	    format(MainStr,sizeof(MainStr), ""text_red"** "text_white"You have been killed by {%60x}%s(%i) "text_white"and you lost", GetPlayerColor(killerid) >>> 8, PlayerInfo[killerid][Player_Name], killerid);
	             	SCM(playerid, -1, MainStr);
	                 
	                format(MainStr,sizeof(MainStr), ""text_red"** "text_white"You have been killed {%60x}%s(%i) "text_white"and earned score: "text_yellow"2 "text_white"and cash: "text_yellow"$5,000", 
	                 	GetPlayerColor(playerid) >>> 8, PlayerInfo[playerid][Player_Name], playerid);
	                SCM(killerid, -1, MainStr);
                    
                    PlayerPoints(killerid,"~y~Points~w~:~n~  ~b~Score~w~: ~g~+2~n~  ~g~~h~Cash~w~: ~g~+$5,000");
	             	SendPlayerScore(killerid, 2);
		    	    SendPlayerMoney(killerid, 5000);
			    }
                PlayerPoints(playerid,"~y~Points~w~:~n~  ~b~Score~w~: -~n~  ~g~~h~Cash~w~: ~r~-$500");
			    SendPlayerMoney(playerid, -500); // take 500 in Freeroam
		}
		case MODE_DM:
		{
             if(killerid != INVALID_PLAYER_ID && PlayerInfo[killerid][Player_Mode] == MODE_DM)
             {
             	 format(MainStr,sizeof(MainStr), ""text_yellow"[DM] "text_white"You have been killed by {%60x}%s(%i)", GetPlayerColor(killerid) >>> 8, PlayerInfo[killerid][Player_Name], killerid);
             	 SCM(playerid, -1, MainStr);
                 
                 new randscore = random(10)+1, randcash = random(5000)+900;
                 format(MainStr,sizeof(MainStr), ""text_yellow"[DM] "text_white"You have been killed {%60x}%s(%i) "text_white"and earned score: "text_yellow"%d "text_white"and cash: "text_yellow"%s", 
                 	GetPlayerColor(playerid) >>> 8, PlayerInfo[playerid][Player_Name], playerid, randscore, Currency(randcash));
             	 SCM(killerid, -1, MainStr);

             	 format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: ~g~+%d~n~  ~g~~h~Cash~w~: ~g~+$%s",randscore, Currency(randcash) );
                 PlayerPoints(killerid,MainStr);
             	 SendPlayerScore(killerid, randscore);
	    	     SendPlayerMoney(killerid, randcash);

             }
             PlayerPoints(playerid,"~y~Points~w~:~n~  ~b~Score~w~: -~n~  ~g~~h~Cash~w~: ~r~-$200");
             SendPlayerMoney(playerid, -200); // take 200 in DM
		}
		case MODE_SKYDIVE, MODE_PARKOUR, MODE_IP, MODE_BMX:
		{
             PlayerPoints(playerid,"~y~Points~w~:~n~  ~b~Score~w~: -~n~  ~g~~h~Cash~w~: ~r~-$300");
             SendPlayerMoney(playerid, -300); // take 300 
			 return 1;
		}
	}
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
				SendPlayerTextNotice(playerid, "~r~You are Kicked","");
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
            
            GetPlayerName(playerid, PlayerInfo[playerid][Player_Name], MAX_PLAYER_NAME);
            GetPlayerIp(playerid, PlayerInfo[playerid][Player_IP], 16);

            mysql_format(fwdb, MainStr, sizeof(MainStr), "INSERT INTO `users` (`name`, `password`, `salts`,`ip`) VALUES ('%e','%e','%e','%e')", 
            	 PlayerInfo[playerid][Player_Name], PlayerInfo[playerid][Player_Pass],samplesalt, PlayerInfo[playerid][Player_IP]);
            mysql_tquery(fwdb, MainStr, "PlayerRequestRegister", "i", playerid);

    	}
    	case DIALOG_LOGIN:
    	{
            if(!response)
			{
				SendPlayerTextNotice(playerid, "~r~You are Kicked","");
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
						ClosePlayerDialog(playerid);
						SendPlayerTextNotice(playerid, "~r~You are Kicked", "");
						SCM(playerid,msg_red, "ERROR: You have failed to enter your account password (Attempts: 3/3)");
						format(MainStr, sizeof(MainStr), "You have been successfully kicked from the server, %s Have a nice day", PlayerInfo[playerid][Player_Name]);
						SCM(playerid,msg_red, MainStr);
						DelayKick(playerid);
					}
				 }
              }
    	 }
    	 case DIALOG_TELEPORT_MENU:
    	 {
    	 	  if(!response) return 1;
              if(listitem < 0 || listitem > sizeof(TeleportDialog)) return 1;
              
              RequestPlayerTeleList(playerid, TeleportDialog[listitem][CatID]);
    	 }
    	 case DIALOG_TELEPORT_SELECT:
    	 {
    	 	  if(!response) return 1;
              new count = 0;
              for(new i = 0; i < sizeof(TeleportNames);i++)
              {

                    if(PlayerInfo[playerid][Player_TeleCat] == TeleportNames[i][TeleID])
                    {
 
                    	  if(count == listitem)
                    	  {
                    	  	 PlayerInfo[playerid][Player_TeleCat] = -1;
                             format(MainStr, sizeof(MainStr), "cmd_%s", TeleportNames[i][TeleCmd]);
                             CallLocalFunction(MainStr, "i", playerid);

                             return 1;
                    	  }
                          count++;
                    }
               }
    	  }
    	  case DIALOG_WEAPON_MENU:
    	  {
    	 	  if(!response) return 1;
              if(listitem < 0 || listitem > sizeof(WeaponMenuDialog)) return 1;
              RequestPlayerWeaponsList(playerid, WeaponMenuDialog[listitem][WeapMCatID]);
    	 }
    	 case DIALOG_WEAPON_SELECT:
    	 {

    	 	  if(!response) return 1;
              new count = 0;
              for(new i = 0; i < sizeof(WeaponDialog);i++)
              {

                    if(PlayerInfo[playerid][Player_WeapCat] == WeaponDialog[i][WeapCatID])
                    {
 
                    	  if(count == listitem)
                    	  {
                    	  	 PlayerInfo[playerid][Player_WeapCat] = -1;
                             return GivePlayerWeapon(playerid, WeaponDialog[i][WeapModel], WeaponDialog[i][WeapAmmo]);
                    	  }
                          count++;
                    }
               }
    	 }
    	 case DIALOG_SKIN_MENU:
    	 {
                 if(!response) return 1;
                 if(listitem >= 74)
                 {
                 	new selectskin =  listitem+1;
                 	format(MainStr, sizeof(MainStr), ""SERVER_TAG" You have changed your skin to %d", selectskin);
                 	SCM(playerid, -1, MainStr);
                 	SetPlayerSkin(playerid, selectskin);

                 }
                 else 
                 {
	                 SetPlayerSkin(playerid, listitem);
	                 format(MainStr, sizeof(MainStr), ""SERVER_TAG" You have changed your skin to %d", listitem);
		             SCM(playerid, -1, MainStr);
	            }
    	 }
    	 case DIALOG_DM_MENU:
    	 {
    	 	    if(!response) return 1;
		    	cmd_stopanim(playerid);
			    ClosePlayerDialog(playerid);
			    ResetPlayerWeapons(playerid);

			    // Set Player To DM
			    PlayerRequestToJoinDM(playerid, listitem+1);

    	 }
    	 case DIALOG_VEHICLE_MENU:
    	 {
              if(!response) return 1;
              if(listitem < 0 || listitem > sizeof(VehicleDialog)) return 1;
              RequestPlayerVehiclesList(playerid, VehicleDialog[listitem][CatID]);
    	 }
    	 case DIALOG_VEHICLE_SELECT:
    	 {

    	 	  if(!response) return 1;
              new count = 0;
              for(new i = 0; i < sizeof(VehicleMenu);i++)
              {

                    if(PlayerInfo[playerid][Player_VehCat] == VehicleMenu[i][V_ID])
                    {
                    	  if(count == listitem)
                    	  {
                    	  	 PlayerInfo[playerid][Player_VehCat] = -1;
                             return PlayerVehicleSpawn(playerid, VehicleMenu[i][V_Model], true);
                    	  }
                          count++;
                    }
               }
    	 }
    	 case DIALOG_FIGHTSTYLE:
    	 {
    	 	if(response)
			{
				switch(listitem)
				{
					case 0: //Normal
					{
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_NORMAL);
						SendPlayerTextNotice(playerid, "Fight Style:", "Normal");
	                    PlayerInfoTD(playerid, "~w~Your new ~y~Fight Style~w~: ~b~Normal", 3500);
	                    PlayerInfo[playerid][Player_FS] = 4;
					}
					case 1: //Boxing
					{
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_BOXING);
	                    SendPlayerTextNotice(playerid, "Fight Style:", "Boxing");
	                    PlayerInfoTD(playerid, "~w~Your new ~y~Fight Style~w~: ~b~Boxing", 3500);
	                    PlayerInfo[playerid][Player_FS] = 5;
					}
					case 2: //KungFu
					{
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_KUNGFU);
	                    SendPlayerTextNotice(playerid, "Fight Style:", "KungFU");
	                    PlayerInfoTD(playerid, "~w~Your new ~y~Fight Style~w~: ~b~KungFU", 3500);
	                    PlayerInfo[playerid][Player_FS] = 6;
					}
					case 3: //KneeHead
					{
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_KNEEHEAD);
                        SendPlayerTextNotice(playerid, "Fight Style:", "Knee-Head");
	                    PlayerInfoTD(playerid, "~w~Your new ~y~Fight Style~w~: ~b~Knee-Head", 3500);
	                    PlayerInfo[playerid][Player_FS] = 7;
					}
					case 4: //Grabkick
					{
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_GRABKICK);
						SendPlayerTextNotice(playerid, "Fight Style:", "Grab Kick");
	                    PlayerInfoTD(playerid, "~w~Your new ~y~Fight Style~w~: ~b~Grab Kick", 3500);
	                    PlayerInfo[playerid][Player_FS] =15;
					}
					case 5: //Elbow
					{
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_ELBOW);
						SendPlayerTextNotice(playerid, "Fight Style:", "Elbow");
	                    PlayerInfoTD(playerid, "~w~Your new ~y~Fight Style~w~: ~b~Elbow", 3500);
	                    PlayerInfo[playerid][Player_FS] =16;
					}
				}
			}
    	 }
    	 case DIALOG_PLAYER_COLOR:
    	 {
                if(response)
			    {
			    	switch(listitem)
		    		{
		    			case 0:
		    	    	{
		    	    		SetPlayerColor(playerid, msg_red);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Red");
		    	    	}
	    	    		case 1:
		    	    	{
							SetPlayerColor(playerid, msg_blue);
							SendPlayerTextNotice(playerid, "Color Changed:", "blue");
							
		    	    	}
	    	    		case 2:
		    	    	{
		    	    		SetPlayerColor(playerid, msg_white);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "White");
		    	    	}
						case 3:
		    	    	{
		    	    		SetPlayerColor(playerid, 0xFFFF82FF);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Ivory");
		    	    		
						}
						case 4:
		    	    	{
		    	    		SetPlayerColor(playerid, 0xEE82EEFF);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Pink");
		    	    		
						}
						case 5:
		    	    	{
		    	    		SetPlayerColor(playerid, 0xFFFF00FF);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Yellow");
						}
						case 6:
		    	    	{
		    	    		SetPlayerColor(playerid, 0x3BBD44FF);
                            SendPlayerTextNotice(playerid, "Color Changed:", "Green");
						}
						case 7:
		    	    	{
		    	    		SetPlayerColor(playerid, 0x15D4EDFF);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Lightblue");
						}
						case 8:
		    	    	{
		    	    		SetPlayerColor(playerid, 0xBABABAFF);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Grey");
		    	    		
						}
						case 9:
		    	    	{
		    	    		SetPlayerColor(playerid, 0xFF5000FF);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Orange");
		    	    
		    	    		
						}
						case 10:
		    	    	{
		    	    		SetPlayerColor(playerid, 0x5A00FFFF);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Purple");
		    	    		
		    	    		
						}
						case 11:
		    	    	{
		    	    		SetPlayerColor(playerid, 0x00FF00FF);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Light Green");
		    	 
		    	    		
						}
						case 12:
		    	    	{
		    	    		SetPlayerColor(playerid, 0xB0C4DEFF);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Steelblue");
		    	    		
		    	    		
						}
						case 13:
		    	    	{
		    	    		SetPlayerColor(playerid, 0xFFD700FF);
		    	    		SendPlayerTextNotice(playerid, "Color Changed:", "Gold");
		    	    		
						}
					}
					SCM(playerid, msg_green, ""text_red"INFO: "text_green"Use /savecolor to save your color");
			    }
    	  }
    	  case DIALOG_PLAYER_SETTINGS:
    	  {

    	  	      if(!response) return 1;
    	  	      switch(listitem)
    	  	      {
                        case 0: cmd_speedo(playerid);
						case 1: cmd_sb(playerid);
						case 2: cmd_sj(playerid);
						case 3: cmd_bounce(playerid);
						case 4: cmd_god(playerid);
						case 5: cmd_autologin(playerid);
						case 6: cmd_fightstyle(playerid);
						case 7: cmd_toggletp(playerid);
						case 8: cmd_togglepm(playerid);
    	  	      }
    	  }

    }

	return true;
}

public OnPlayerText(playerid, text[])
{

   if(PlayerInfo[playerid][Player_Admin] == 0)
   {
	   if(PlayerInfo[playerid][Player_Muted])
	   {
	   	   if(PlayerInfo[playerid][Player_MuteTime] > 0)
	   	   {
	   	   	   SCM(playerid, msg_red, "You are muted!");
	   	   	   return 0;
	   	   }
	   }
	   if(PlayerInfo[getotherid][Player_Caps]) UnCapsText(text);
   }

   // admin
   if(text[0] == '#' &&  PlayerInfo[playerid][Player_Admin] != 0)
   {
   	    cmd_a(playerid, text[1]);
		return 0;
   }
   else if(text[0] == '!'  &&  PlayerInfo[playerid][Player_GangID] != 0)
   { 
   	    format(MainStr, sizeof(MainStr), ""GANG_TAG" {%06x}%s(%i): "GANG_CHAT"%s", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid, text[1]);
   	    SendGangNotice(PlayerInfo[playerid][Player_GangID], MainStr);
		return 0;
   }
  
   if(ReactionInfo[Started])
   {
         if(!strcmp(ReactionInfo[ReactChars], text, false))
         {
         	     KillTimer(ServerVars[Server_ReactionTimerEnd]);

         	     ReactionInfo[Started] = false;
         	     new reactiontime = GetTickCount() - ReactionInfo[TickCount],
         	         reactsecond = reactiontime / 1000;

                 reactiontime = reactiontime - reactsecond * 1000;

                 format(MainStr, sizeof(MainStr), ""text_white"["text_blue"REACTION"text_white"] {%06x}%s(%i) "text_white"has won the reaction test in %2d.%03d seconds!", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid ,reactsecond,reactiontime);
                 SCMToAll(-1, MainStr);
                 
                 format(MainStr, sizeof(MainStr), " -> You earned score: %d and cash: $%s",ReactionInfo[RewardScore], Currency(ReactionInfo[RewardCash]) );
                 SCM(playerid, msg_yellow, MainStr);

                 
                 ReactionInfo[TickCount] = 0;
                 SendPlayerMoney(playerid, ReactionInfo[RewardCash]);
                 SendPlayerScore(playerid, ReactionInfo[RewardScore]);

                 format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: ~g~+%i~n~  ~g~~h~Cash~w~: ~g~+$%s", ReactionInfo[RewardScore], Currency(ReactionInfo[RewardCash]));
                 PlayerPoints(playerid,MainStr);

                 PlayerInfoTD(playerid, "~w~You won the ~r~reaction test", 3500);

                 format(MainStr, sizeof(MainStr), "Won the Reaction Test in %02d.%03d seconds!", reactsecond,reactiontime);
                 SetPlayerChatBubble(playerid, MainStr, msg_green, 40.0, 4000);
                 return 0;
         }
   }
  
   if(strlen(text) > 80)
   {
   	        // Slpit the lines in chat.
            new textpos = strfind(text, " ", true, 60), StoreText[144];
			
			if(textpos == -1 || textpos > 80)
			{
				textpos = 70;
			}

			StoreText[0] = EOS;
			if(PlayerInfo[playerid][Player_Admin] != 0)
			{
				strcat(StoreText, "{4098BD}");
			}				

			strcat(StoreText, text[textpos]);
			text[textpos] = EOS;
			//

		    if(PlayerInfo[playerid][Player_Admin] != 0)
		    {

		        format(MainStr, sizeof(MainStr), "%s"text_white"(%i) {4098BD}%s", ChatName(playerid), playerid, text);
			    SCMToAll(-1, MainStr);
			    SCMToAll(-1, StoreText);
		    }
		    else{

			   	format(MainStr, sizeof(MainStr), "%s"text_white"(%i) "text_white"%s", ChatName(playerid), playerid, text);
				SCMToAll(-1, MainStr);
				SCMToAll(-1, StoreText);
		    }
   }
   else {

		   if(PlayerInfo[playerid][Player_Admin] != 0)
		   {

		        format(MainStr, sizeof(MainStr), "%s"text_white"(%i) {4098BD}%s", ChatName(playerid), playerid, text);
			    SCMToAll(-1, MainStr);
		   }
		   else{

			   	format(MainStr, sizeof(MainStr), "%s"text_white"(%i) "text_white"%s", ChatName(playerid), playerid, text);
				SCMToAll(-1, MainStr);
		   }
   }
   SetPlayerChatBubble(playerid, text, msg_white, 20.0, 4000);
   return 0;
}

stock ChatName(playerid)
{
    new string3[36+MAX_PLAYER_NAME];
    if(PlayerInfo[playerid][Player_GangID] != 0)
    {
        format(string3,sizeof(string3),"{%06x}[%s] %s",PlayerColor(playerid), GangInfo[PlayerInfo[playerid][Player_GangID]][Gang_Tag], PlayerInfo[playerid][Player_Name]);
	}
    else
    {
        format(string3,sizeof(string3),"{%06x}%s",PlayerColor(playerid),PlayerInfo[playerid][Player_Name]);
    }
    return string3;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
   if(PlayerInfo[playerid][Player_Mode] == MODE_FREEROAM && !PlayerInfo[playerid][Player_InGWAR])
   {
		RepairVehicle(vehicleid);
		return 1;
   }
   return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(hittype != BULLET_HIT_TYPE_NONE) // Fix Bullet Crash
    {
	    if( !( -1000.0 <= fX <= 1000.0 ) || !( -1000.0 <= fY <= 1000.0 ) || !( -1000.0 <= fZ <= 1000.0 ) ) 
	    {
		    return 0;
  		}
	}

    if(hittype == BULLET_HIT_TYPE_PLAYER)
    {
	    if(hitid != INVALID_PLAYER_ID && PlayerInfo[hitid][Player_God]) 
	    {
	            SendPlayerTextNotice(playerid, "Player has /god enabled", "");
	    }
	}
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(!PlayerInfo[playerid][Player_Spawned])
	{
        SCM(playerid, msg_red, "ERROR: You need to spawn to use commands");
		return 0;
	} 
	if(PlayerInfo[playerid][Player_LoadMap])
	{
        SendPlayerTextNotice(playerid, "Please Wait:", "Map Loading");
		return 0;
	} 
    if(PlayerInfo[playerid][Player_Freeze])
	{
	    SCM(playerid, msg_red, "ERROR: You can't use this command while you are frozen!");
		return 0;
	}
	ClosePlayerDialog(playerid);
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if (!success)
    {
        return SendPlayerTextNotice(playerid, "~y~~h~Unknown Command!","");
    }
    return 1;
} 
public OnPlayerResume(playerid, time)
{
	if(!PlayerInfo[playerid][Player_Afk]) return 1;
	if(GetPVarInt(playerid, "PlayerRecivedPM"))
    {
            DeletePVar(playerid, "PlayerRecivedPM");
            PlayerInfoTD(playerid, "~y~You have received a PMs!~n~~w~Type ~r~/checkpms", 4000);
    }
    PlayerInfo[playerid][Player_Afk] = 0;
    return 1;
}
public OnPlayerPause(playerid)
{
	if(PlayerInfo[playerid][Player_Afk] == 0) PlayerInfo[playerid][Player_Afk] = 1;
    return 1;
}
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	 // spec
	foreach(new i : Player)
    {
    	if(PlayerInfo[i][Player_Mode] == MODE_SPEC && PlayerInfo[i][Player_Spec] == playerid)
    	{
    		switch(newstate)
    		{
    			case PLAYER_STATE_DRIVER , PLAYER_STATE_PASSENGER:
    			{
    				PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
    			}
    			case PLAYER_STATE_ONFOOT:
    		    {
    		    	PlayerSpectatePlayer(i, playerid);
    		    }
    		    case PLAYER_STATE_SPECTATING:
    		    {
    		    	cmd_unspec(i);
                    SCM(i, msg_red, ""SERVER_TAG" You have been put back yout old position. Reason: Player Spectating someone else!");
    		    }
    		}
    	}
    }

	switch(newstate)
	{

		 case PLAYER_STATE_ONFOOT:
		 {
             if(PlayerInfo[playerid][Player_Speedo])  ToggleSpeedo(playerid, true);
		 }
		 case PLAYER_STATE_DRIVER:
		 {
              if(PlayerInfo[playerid][Player_Speedo]) ToggleSpeedo(playerid);

              format(MainStr, sizeof(MainStr), "~w~Vehicle Name: ~b~%s", GetVehicleName[GetVehicleModel(GetPlayerVehicleID(playerid)) - 400]);
              PlayerInfoTD(playerid, MainStr, 3500);
		 }
	}
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	  if(newkeys & KEY_SECONDARY_ATTACK)
	  { 
			if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && GetPVarType(playerid, "PlayerUseAnim") == 1)
			{
				cmd_stopanim(playerid);
			}
	  }
	  switch(PlayerInfo[playerid][Player_Mode])
	  {
	  	   case MODE_FREEROAM:
	  	   {

			  	switch(GetPlayerState(playerid)) 
			  	{
	                    case  PLAYER_STATE_DRIVER:
	                    {
		                   if( (newkeys & KEY_FIRE || newkeys & KEY_ACTION) && PlayerInfo[playerid][Player_SB] && !PlayerInfo[playerid][Player_InGWAR])  // Speed boost
						   {
		                        new Float:vPOS[3];
								GetVehicleVelocity(GetPlayerVehicleID(playerid), vPOS[0], vPOS[1], vPOS[2]);
								SetVehicleVelocity(GetPlayerVehicleID(playerid), vPOS[0] * 1.5, vPOS[1] * 1.5, vPOS[2] * 1.5);
								if(IsNosVehicleModel(GetVehicleModel(GetPlayerVehicleID(playerid)))) AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
		                        return true;
		                   }
		                   if(newkeys & KEY_LOOK_BEHIND  &&  !PlayerInfo[playerid][Player_InGWAR]) // flip
						   {
						 		new Float:angle;
							    GetVehicleZAngle(GetPlayerVehicleID(playerid), angle);
							    SetVehicleZAngle(GetPlayerVehicleID(playerid), angle);
							    return true;
						   }
						   if(newkeys & KEY_NO &&  PlayerInfo[playerid][Player_InGWAR]) //speed break
						   {
								new Float:POS[3], vid = GetPlayerVehicleID(playerid);
								GetVehicleVelocity(vid, POS[0], POS[1], POS[2]);
								SetVehicleVelocity(vid, POS[0] > 0 ? POS[0] * 0.75 : 0.0, POS[1] > 0 ? POS[1] * 0.75 : 0.0, POS[2]);
							    return true;
						   }
						   if(newkeys & KEY_CROUCH && PlayerInfo[playerid][Player_Bounce] &&  !PlayerInfo[playerid][Player_InGWAR]) // vehicle bounce
						   {
								new Float:vPOS[3];
								GetVehicleVelocity(GetPlayerVehicleID(playerid), vPOS[0], vPOS[1], vPOS[2]);
								SetVehicleVelocity(GetPlayerVehicleID(playerid), vPOS[0], vPOS[1], vPOS[2] + 0.3);
							  	return true;
						   }
			  	     }
			  	     case PLAYER_STATE_ONFOOT:
			  	     {
							if(newkeys & KEY_JUMP && PlayerInfo[playerid][Player_SJ] &&  !PlayerInfo[playerid][Player_InGWAR]) // superjump Jump (Space)
							{
								 // to avoid bugs wwhile aiming.
								new cammode = GetPlayerCameraMode(playerid);
				                if(cammode != 7 && cammode != 8 && cammode != 46 && cammode != 51 && cammode != 53)
				                {
									new Float:Jump[3];
							        GetPlayerVelocity(playerid, Jump[0], Jump[1], Jump[2]);
							        SetPlayerVelocity(playerid, Jump[0], Jump[1], floatadd(Jump[2], 4.5));
							    }
							 }
			  	       }
		  	    }
	  	   }
	  	   case MODE_IP:
	  	   {
                 if(GetPlayerState(playerid == PLAYER_STATE_DRIVER) && GetVehicleModel(GetPlayerVehicleID(playerid)) == 411)
                 {
                       if( (newkeys & KEY_FIRE || newkeys & KEY_ACTION))  // Speed boost for IP
					   { 
	                        if(PlayerInfo[playerid][Player_ResetNos] != 0) return SendPlayerTextNotice(playerid, "Vehicle Boost In Cooldown"," ");
							if(IsNosVehicleModel(GetVehicleModel(GetPlayerVehicleID(playerid)))) AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
                            PlayerInfo[playerid][Player_ResetNos] = 10;
	                        return true;
	                   }
	                   if(newkeys & KEY_LOOK_BEHIND) // flip
					   {
					   	        if(PlayerInfo[playerid][Player_ResetFix] != 0) return SendPlayerTextNotice(playerid, "Vehicle Fix In Cooldown"," ");
                                RepairVehicle(GetPlayerVehicleID(playerid));
                                PlayerInfo[playerid][Player_ResetFix] = 10;
							    return true;
					   }
                  }
	  	      }
	  }
	  return 1;
}	
stock IsNosVehicleModel(modelid)
{
	switch(modelid)
	{
		case 581, 523, 462, 521, 463, 522, 461, 448, 468, 586, 509, 481, 510, 472,
		473, 493, 595, 484, 430, 453, 452, 446, 454, 590, 569, 537, 538, 570, 449,
		520, 425, 476, 432, 513, 497, 593, 511:
		{
		    return false;
		}
	}
	return true;
}
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
    foreach(new i : Player)
    {
    	if(PlayerInfo[i][Player_Mode] == MODE_SPEC && PlayerInfo[i][Player_Spec] == playerid)
    	{
    		SCM(i, msg_green, "** Your interior has been changed!");
    		SetPlayerInterior(i, newinteriorid);
    	}
    }
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && PlayerInfo[playerid][Player_Speedo] == true)
 	{
		 	new Float:vSpeed, vSpeedValue, Float:vPos[3], vString[60];
	        GetVehicleVelocity(GetPlayerVehicleID(playerid), vPos[0],vPos[1],vPos[2]);

			vSpeed = floatmul(floatsqroot(floatadd(floatadd(floatpower(vPos[0], 2), floatpower(vPos[1], 2)),  floatpower(vPos[2], 2))), 100.0);
	       	vSpeedValue = floatround(floatdiv(vSpeed, 0.75), floatround_floor);
	        format(vString, sizeof(vString),"%d KM/H", vSpeedValue);
	        PlayerTextDrawSetString(playerid, PlayerTD[Speedo][playerid], vString);
	}
	return 1;
}

publicEx PlayerRequestRegister(playerid)
{

    PlayerInfo[playerid][Player_ID] = cache_insert_id();
    PlayerInfo[playerid][Player_Logged] = true;
    PlayerInfo[playerid][Player_LastOnline] = gettime();
    PlayerInfo[playerid][Player_Joined] = gettime();
    SendPlayerTextNotice(playerid, "+$10,000~n~startcash", "");
    GivePlayerMoney(playerid, 1000);
    PlayerInfo[playerid][Player_Cash] = 1000;
    format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_white"%s(%i) "text_green"has registered, making the server have a total of "text_blue"%s "text_green"players registered.",PlayerInfo[playerid][Player_Name], playerid, Currency(PlayerInfo[playerid][Player_ID]));
	SCMToAll(msg_green, MainStr);
	SCM(playerid, msg_white,""SERVER_TAG" "text_white"You are now registered, and have been logged in");
	
	// update join time once.
	mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `joined` = %d, `lastonline` = %d , `online` = 1 WHERE `ID` = %d LIMIT 1;",PlayerInfo[playerid][Player_Joined],PlayerInfo[playerid][Player_LastOnline],PlayerInfo[playerid][Player_ID] );
	mysql_tquery(fwdb, MainStr);

    format(MainStr, sizeof(MainStr),  "INSERT INTO `settings`(`ID`) VALUES (%d)",  PlayerInfo[playerid][Player_ID]);
    mysql_query(fwdb, MainStr);
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
        cache_get_value_name(0, "email",PlayerInfo[playerid][Player_Email], 40);
        cache_get_value_name_int(0, "gang_id",PlayerInfo[playerid][Player_GangID]);
        cache_get_value_name_int(0, "gang_rank",PlayerInfo[playerid][Player_GangRank]);

        mysql_format(fwdb, MainStr,sizeof(MainStr),"SELECT * FROM `settings` WHERE `ID`=%d LIMIT 1;", PlayerInfo[playerid][Player_ID]);
        new Cache:pSettings = mysql_query(fwdb, MainStr);

        if(cache_num_rows())
        {
               
             cache_get_value_name_bool(0, "speedboost", PlayerInfo[playerid][Player_SB]);
             cache_get_value_name_bool(0, "superjump", PlayerInfo[playerid][Player_SJ]);
             cache_get_value_name_bool(0, "bounce", PlayerInfo[playerid][Player_Bounce]);
             cache_get_value_name_bool(0, "god", PlayerInfo[playerid][Player_God]);
             cache_get_value_name_bool(0, "speedo", PlayerInfo[playerid][Player_Speedo]);
             cache_get_value_name_int(0, "fightstyle", PlayerInfo[playerid][Player_FS]);
             cache_get_value_name_bool(0, "allowpm", PlayerInfo[playerid][Player_AllowPM]);
             cache_get_value_name_bool(0, "allowtp", PlayerInfo[playerid][Player_AllowTP]);
        }
        cache_delete(pSettings);
         
        LoadPlayerAchievements(playerid);
        SetPlayerFightingStyle(playerid, PlayerInfo[playerid][Player_FS]);

        SetPlayerScore(playerid, PlayerInfo[playerid][Player_Score]);
        GivePlayerMoney(playerid, PlayerInfo[playerid][Player_Cash]);

        PlayerInfo[playerid][Player_Logged] = true;
        format(MainStr, sizeof(MainStr),""SERVER_TAG" You were last online at %s\n", 
        	 ConvertUnix(PlayerInfo[playerid][Player_LastOnline]));
        SCM(playerid, msg_white, MainStr);
       
        
       	if(PlayerInfo[playerid][Player_Color] != 0)
       	{
       		SetPlayerColor(playerid, PlayerInfo[playerid][Player_Color]);
       		SCM(playerid, -1, ""SERVER_TAG" "text_blue"Custom Name Color is set\n");
       	}

       	if(PlayerInfo[playerid][Player_Skin] != 999)
       	{
       		SCM(playerid, -1, ""SERVER_TAG" "text_blue"Saved Skin is set\n");
       	}
        if(PlayerInfo[playerid][Player_GangID] != 0)
        {
        	format(MainStr, sizeof MainStr, ""GANG_TAG" "GANG_CHAT"%s %s(%i) has logged in",GangRanks[PlayerInfo[playerid][Player_GangRank]], PlayerInfo[playerid][Player_Name], playerid);
            SendGangNotice(PlayerInfo[playerid][Player_GangID], MainStr);
        }
        mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `online` = 1 WHERE `ID` = %d LIMIT 1;",PlayerInfo[playerid][Player_ID] );
	    mysql_tquery(fwdb, MainStr);

        SCM(playerid, -1, ""SERVER_TAG" "text_green"Your account has been successfully loaded!");
    }
    else DelayKick(playerid); // Just kick the player from the server
	return 1;
}

CMD:vw(playerid)
{
    format(MainStr, sizeof(MainStr), "-? You Virtual World is %d", GetPlayerVirtualWorld(playerid));
    SCM(playerid, msg_blue, MainStr);
	return 1;
}
CMD:w(playerid) return cmd_weapons(playerid);
CMD:weap(playerid) return cmd_weapons(playerid);
CMD:weapons(playerid) 
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    if(PlayerInfo[playerid][Player_God]) return SCM(playerid, msg_red, "ERROR: You can't access weapons while your godmode is turned on");

    cmd_stopanim(playerid);
    ClosePlayerDialog(playerid);
    RequestPlayerWeaponDialog(playerid);
	return 1;
}

// Source by Gammix
CMD:skin(playerid, params[]) 
{
	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");

    new skin;
	if(sscanf(params, "d", skin))
	{
		const MAX_SKINS = 312;
	    new skinsubString[16];
	    static skinstring[MAX_SKINS * sizeof(skinsubString)];

	    if(skinstring[0] == EOS) 
	    {
	        for (new i; i < MAX_SKINS; i++) 
	        {
	        	if(!IsValidSkin(i)) continue;
	            format(skinsubString, sizeof(skinsubString), "%i\tID: %i\n", i, i);
	            strcat(skinstring, skinsubString);
	        }
	    }
	    ShowPlayerDialog(playerid, DIALOG_SKIN_MENU, DIALOG_STYLE_PREVIEW_MODEL, "~h~~y~FW~w~ :: Skin Selection", skinstring, "Select", "Cancel");
	    return true;
	}
	if(GetPlayerSkin(playerid) == skin)
	{
	    SCM(playerid, msg_red, "ERROR: You are already using this skin");
	    return true;
	}

    if(!IsValidSkin(skin) || skin > 311)
	{
	    SCM(playerid, msg_red, "ERROR: Invalid skin id");
	    return true;
	}
    cmd_stopanim(playerid);
    ClosePlayerDialog(playerid);
	SetPlayerSkin(playerid, skin);

	format(MainStr, sizeof(MainStr), ""SERVER_TAG" You have changed your skin to %d", skin);
	SCM(playerid, -1, MainStr);
    return 1;
}

CMD:s(playerid)
{
	if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "You can't use this command right now");
    if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You can't use this command while being in a gang war");
	SavePlayerPos(playerid);
	SCM(playerid, -1, ""text_green"Load position with /l");
    SendPlayerTextNotice(playerid, "~y~~h~Position Saved", "");
	PlayerPlaySound(playerid, 1132, 0, 0, 0);
	PlayerInfo[playerid][Player_SavedPos] = true;
	return 1;
}
CMD:l(playerid)
{
	if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "You can't use this command right now");
	if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You can't use this command while being in a gang war");
	if(!PlayerInfo[playerid][Player_SavedPos]) return  SendPlayerTextNotice(playerid, "~y~Use /s first","");
	if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
	{
	    SCM(playerid, msg_red, "ERROR: You can't load your position while in the passenger seat!");
	    return true;
	}
	for(new i = 0; i < MAX_GZONES; i++)
	{
	    if(GZInfo[i][Zone_Status] == Zone_InAttack && GZInfo[i][Zone_Owner] == PlayerInfo[playerid][Player_GangID])
	    {
	        if(250.0 > GetDistance3D(PlayerInfo[playerid][Player_OldPos][0],PlayerInfo[playerid][Player_OldPos][1],PlayerInfo[playerid][Player_OldPos][2], GZInfo[i][Zone_X], GZInfo[i][Zone_Y],GZInfo[i][Zone_Z]))
	        {
	            return SCM(playerid, msg_red, "Point is next to a Gang Zone which is under attack!");
	        }
		}
	}
	SpawnPlayerEx(playerid, true);
    SendPlayerTextNotice(playerid, "~y~~h~Loaded Position", "");
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}
CMD:leave(playerid) return cmd_exit(playerid);
CMD:exit(playerid)
{
	if(PlayerInfo[playerid][Player_Mode] == MODE_FREEROAM) return SCM(playerid, msg_red, "You can't use this command right now");
	if(RemovePlayer(playerid) != 0)
	{
         SCM(playerid, msg_red, "You can't use this command right now");
	}
	return 1;
}


CMD:vehicle(playerid, params[]) return cmd_v(playerid, params);
CMD:v(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM || PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You can't use this command right now");
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(!PlayerInfo[playerid][Player_Spawned]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You are can't use this command while being in a gang war");
    new spawnveh;
    if(IsNumeric(params))
    {
    	if(strval(params) < 400 || strval(params) > 611)
		{
			return SCM(playerid, msg_red, "ERROR: You entered an invalid vehicle name!");
		}
		switch(strval(params))
		{
			case 425, 432, 447, 430, 435, 449, 450, 453, 464, 520, 569, 570, 584, 590, 591, 594, 606, 607, 608, 610, 611, 537, 538:
			{
	 			if(PlayerInfo[playerid][Player_Admin] == 0) return SCM(playerid, msg_red, "ERROR: You are not allowed to spawn this vehicle");
			}
	   	}
	    cmd_stopanim(playerid);
        ClosePlayerDialog(playerid);
	   	PlayerVehicleSpawn(playerid, strval(params), true);
    }
    else 
    {

    	if(sscanf(params, "s[32]", MainStr))
		{
			ClosePlayerDialog(playerid);
		    RequestPlayerVehicleDialog(playerid);
		    return 1;
		}
        spawnveh = GetVehicleModelIDFromName(MainStr);
        if(spawnveh < 400 || spawnveh > 611)
		{
			return SCM(playerid, msg_red, "ERROR: You entered an invalid vehicle name");
		}
		switch(spawnveh)
		{
			case 425, 432, 447, 430, 435, 449, 450, 453, 464, 520, 569, 570, 584, 590, 591, 594, 606, 607, 608, 610, 611, 537, 538:
			{
	 			if(PlayerInfo[playerid][Player_Admin] == 0) return SCM(playerid, msg_red, "ERROR: You are not allowed to spawn this vehicle");
			}
	   	}
	    cmd_stopanim(playerid);
        ClosePlayerDialog(playerid);
	    PlayerVehicleSpawn(playerid, spawnveh, true);
    }
	return 1;
}

CMD:fightstyle(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_FIGHTSTYLE, DIALOG_STYLE_LIST, ""DIALOG_TAG" Fighting Styles:", "Normal\nBoxing\nKung Fu\nKneehead\nGrabKick\nElbow", "Select", "Cancel");
	return 1;
}

CMD:speedo(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged])  return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SCM(playerid, msg_red, "ERROR: You need to be a driver in a vehicle");
    if(PlayerInfo[playerid][Player_Speedo])
    {
             ToggleSpeedo(playerid, true);
             PlayerInfo[playerid][Player_Speedo] = false;
             SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"You have disabled your speedo");
             PlayerInfoTD(playerid, "~w~Your ~y~Speedo~w~ has been ~r~Disabled", 3500);
             SendPlayerTextNotice(playerid, "SPEEDO:", "~r~OFF");
    }
    else
    {

             ToggleSpeedo(playerid);
             PlayerInfo[playerid][Player_Speedo] = true;
             SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"You have enabled your speedo");
             PlayerInfoTD(playerid, "~w~Your ~y~Speedo~w~ has been ~g~Enabled", 3500);
             SendPlayerTextNotice(playerid, "SPEEDO:", "~g~ON");
     }

	return 1;
}

CMD:togglepm(playerid)
{
   if(PlayerInfo[playerid][Player_AllowPM]) 
   {
     PlayerInfo[playerid][Player_AllowPM] = false;
     SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"You will no longer recieve any pri1vate messages. Type /togglepm to disable");
     PlayerInfoTD(playerid, "~w~Your ~y~Private Messages~w~ has been ~r~Disabled", 2000);
     SendPlayerTextNotice(playerid, "Private Messages:", "~r~OFF");
   }
   else {
     PlayerInfoTD(playerid, "~w~Your ~y~Private Messages~w~ has been ~g~enabled", 2000);
     SendPlayerTextNotice(playerid, "Private Messages:", "~g~ON");
   	 PlayerInfo[playerid][Player_AllowPM] = false;
   }
   PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
   return 1;
}

CMD:autologin(playerid)
{
   if(PlayerInfo[playerid][Player_AutoLogin]) 
   {
     PlayerInfo[playerid][Player_AutoLogin] = 0;
     PlayerInfoTD(playerid, "~w~Your ~y~Auto Login~w~ has been ~r~Disabled", 2000);
     SendPlayerTextNotice(playerid, "Auto Login:", "~r~OFF");
   }
   else {
   	 SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"You wil be a autologged when you spawn next time.");
     PlayerInfoTD(playerid, "~w~Your ~y~Auto Login~w~ has been ~g~enabled", 2000);
     SendPlayerTextNotice(playerid, "Auto Login:", "~g~ON");
   	 PlayerInfo[playerid][Player_AutoLogin] = 1;
   }
   PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
   return 1;
}

CMD:toggletp(playerid)
{
   if(PlayerInfo[playerid][Player_AllowTP]) 
   {
     PlayerInfo[playerid][Player_AllowTP] = false;
     SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"Other Players can no longer teleport to you.");
     PlayerInfoTD(playerid, "~w~Players ~y~Teleport~y~~w~ has been ~r~Disabled", 2000);
     SendPlayerTextNotice(playerid, "Teleport:", "~r~OFF");
   }
   else {
     PlayerInfoTD(playerid, "~w~Players ~y~Teleport~y~~w~ has been ~g~enabled", 2000);
   	 PlayerInfo[playerid][Player_AllowTP] = false;
   	 SendPlayerTextNotice(playerid, "Teleport:", "~g~ON");
   }
   return 0;
}

CMD:superjump(playerid) return cmd_sj(playerid);
CMD:sj(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged])  return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
    

    if(PlayerInfo[playerid][Player_SJ])
    {
             PlayerInfo[playerid][Player_SJ] = false;
             SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"You have disabled your superjump");
             PlayerInfoTD(playerid, "~w~Your ~y~Superjump~w~ has been ~r~Disabled", 3500);
             SendPlayerTextNotice(playerid, "Superjump:", "~r~OFF");
    }
    else
    {

             PlayerInfo[playerid][Player_SJ] = true;
             SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"You have enabled your superjump");
             PlayerInfoTD(playerid, "~w~Your ~y~Superjump~w~ has been ~g~Enabled", 3500);
             SendPlayerTextNotice(playerid, "Superjump:", "~g~ON");
     }

	return 1;
}

CMD:bounce(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged])  return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");

    if(PlayerInfo[playerid][Player_Bounce])
    {
 
             PlayerInfo[playerid][Player_Bounce] = false;
             SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"You have disabled your bounce");
             PlayerInfoTD(playerid, "~w~Your ~y~Bounce~w~ has been ~r~Disabled", 3500);
             SendPlayerTextNotice(playerid, "bounce:", "~r~OFF");
    }
    else
    {


             PlayerInfo[playerid][Player_Bounce] = true;
             SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"You have enabled your bounce");
             PlayerInfoTD(playerid, "~w~Your ~y~Bounce~w~ has been ~g~Enabled", 3500);
             SendPlayerTextNotice(playerid, "Bounce:", "~g~ON");
     }

	return 1;
}

CMD:speedboost(pid) return cmd_sb(pid);
CMD:sb(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged])  return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");

    if(PlayerInfo[playerid][Player_SB])
    {
             if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) RemoveVehicleComponent(GetPlayerVehicleID(playerid), 1010);
             PlayerInfo[playerid][Player_SB] = false;
             SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"You have disabled your speedboost");
             PlayerInfoTD(playerid, "~w~Your ~y~SpeedBoost~w~ has been ~r~Disabled", 3500);
             SendPlayerTextNotice(playerid, "speedboost:", "~r~OFF");
    }
    else
    {

             
             PlayerInfo[playerid][Player_SB] = true;
             SCM(playerid, msg_yellow, ""SERVER_TAG" "text_white"You have enabled your speedboost");
             PlayerInfoTD(playerid, "~w~Your ~y~SpeedBoost~w~ has been ~g~Enabled", 3500);
             SendPlayerTextNotice(playerid, "speedboost:", "~g~ON");
    }
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}
CMD:t(playerid) return cmd_tele(playerid);
CMD:teles(playerid) return cmd_tele(playerid);
CMD:teleport(playerid) return cmd_tele(playerid);
CMD:tele(playerid) 
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
    RequestPlayerTeleDialog(playerid);
	return 1;
}


CMD:ls(playerid) return   SendPlayerToPosition(playerid,  2494.7476, -1666.6097, 13.3438, 88.1632 , 2494.7476, -1666.6097, 13.3438, 88.1632, "Los Santos", true, true, false);
CMD:lv(playerid) return   SendPlayerToPosition(playerid,  2039.8860,1546.1112,10.4450,180.4970,2039.8860,1546.1112,10.4450,180.4970, "Las Venturas", true, true, false);
CMD:sf(playerid) return   SendPlayerToPosition(playerid, -1990.6650, 136.9297, 27.3110, 0.6588, -1990.6650, 136.9297, 27.3110, 0.6588, "San Fierro", true, true, false);

CMD:lsh(playerid) return  SendPlayerToPosition(playerid, 2031.6591,-1415.4594,16.9922,136.5410 , 2031.6591,-1415.4594,16.9922,136.5410, "Los Santos Hospital",true, true, false);
CMD:sfh(playerid) return  SendPlayerToPosition(playerid,  -2663.7432,593.5697,14.2507,181.0684 , -2663.7432,593.5697,14.2507,181.0684, "San Fierro Hospital",true, true, false);
CMD:lvh(playerid) return  SendPlayerToPosition(playerid, 1608.1807,1833.2031,10.8203,174.4132 , 1625.1787,1824.4666,10.8203,352.3649, "Las Venturas Hospital",true, true, false);

CMD:lsa(playerid) return  SendPlayerToPosition(playerid,  1918.7611,-2393.4937,18.5000,183.3526, 1891.7806,-2420.6694,13.5391,192.7526 , "Los Santos Airport",true, true, false);
CMD:sfa(playerid) return  SendPlayerToPosition(playerid, -1173.9863,36.9642,15.7011,133.4367 ,-1200.5752,0.4701,14.1484,35.0490, "San Fierro Airport",true, true, false);
CMD:lva(playerid) return  SendPlayerToPosition(playerid, 1319.0911,1263.2156,12.2010,358.4841 , 1329.5769,1288.3635,10.8203,0.9908, "Las Venturas Airport",true, true, false);

CMD:lspd(playerid) return  SendPlayerToPosition(playerid, 1536.1853,-1671.6768,13.1804,178.0546 , 1544.0552,-1675.9553,13.5577,89.0644 , "LS Police Department",true, true, false);
CMD:sfpd(playerid) return  SendPlayerToPosition(playerid,  -1627.0214,679.1722,7.1901,224.3314 ,-1620.9243,668.2408,6.9872,249.9972, "SF Police Department",true, true, false);
CMD:lvpd(playerid) return  SendPlayerToPosition(playerid, 2291.2131,2426.4822,10.8203,181.4370 , 2284.9829,2413.7065,10.8303,268.8578 , "LV Police Department",true, true, false);

CMD:aa(playerid) return  SendPlayerToPosition(playerid, 376.6015,2540.4746,19.5100,182.1743, 356.9095,2540.0908,16.7060,180.2942 , "Abandoned Airport",true, true, false);
CMD:mc(playerid) return  SendPlayerToPosition(playerid, -2340.2388,-1624.9121,487.7368,270.7733, -2329.3777,-1602.0166,485.3219,276.1001, "Mount Chiliad",true, true, false);
CMD:glen(playerid) return  SendPlayerToPosition(playerid, 1897.0003, -1172.1928, 24.2482, 170.1335 , 1897.0003, -1172.1928, 24.2482, 170.1335, "glen", true, true, false);

CMD:savecolor(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
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

CMD:deletecolor(playerid)
{
	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");

	if(PlayerInfo[playerid][Player_Color] == 0)
	{
	    SCM(playerid, -1, ""SERVER_TAG" "text_green"You have no saved color yet");
	}
	else
	{
	    SCM(playerid, -1, ""SERVER_TAG" "text_red"Color has been deleted");
	}
    PlayerInfo[playerid][Player_Color]  = 0;
	return 1;
}

CMD:saveskin(playerid, params[])
{
	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
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
    else SCM(playerid, msg_red, "ERROR: Invalid Skin ID");
    return 1;
}

CMD:deleteskin(playerid, params[])
{
	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
	
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
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
	if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");

	new rand = random(sizeof(PlayerColors));
	SetPlayerColor(playerid, PlayerColors[rand]);
	format(MainStr, sizeof(MainStr), "Color set! Your new color: {%06x}Color", GetPlayerColor(playerid) >>> 8);
	SCM(playerid, msg_blue, MainStr);
	return 1;
}
CMD:colors(playerid, params[]) return cmd_color(playerid, params);
CMD:color(playerid, params[])
{

	if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
	if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
	
    new rgb[4];
	if(sscanf(params, "iii", rgb[0] , rgb[1], rgb[2]) || !(0 <= rgb[0] <= 255) || !(0 <= rgb[1] <= 255) || !(0 <= rgb[2] <= 255))
	{
		SCM(playerid, -1, ""text_red"INFO: "text_yellow"To set custom colors: Type /color <0-255> <0-255> <0-255>");
		SCM(playerid, -1, ""text_red"INFO: "text_yellow"Type /random to get random colors");
		ShowPlayerDialog(playerid, DIALOG_PLAYER_COLOR, DIALOG_STYLE_LIST, ""SERVER_TAG" Player Colors", ""text_red"Red\n"text_blue"Blue\n"text_white"White\n{FFFF82}Ivory\n{FFB6C1}Pink\n"text_yellow"Yellow\n"text_green"Green\n{15D4ED}Lightblue\n{BABABA}Grey\n{DB881A}Orange\n{800080}Purple\n{00FF00}Light Green\n{B0C4DE}Steelblue\n{FFD700}Gold", "Select", "Exit");
	}
	else
	{
		if(rgb[0] < 30 && rgb[1] < 30 && rgb[2] < 30)
		{
			SCM(playerid, msg_red ,"ERROR: RGB values under 30 are not allowed!");
			return true;
		}
		rgb[3] = ConvertRGB(rgb[0], rgb[1], rgb[2], 99);
		SetPlayerColor(playerid, rgb[3]);

		format(MainStr, sizeof(MainStr), ""text_red"INFO: "text_white"Your new nickname color:{%60x} Color", PlayerColor(playerid));
		SCM(playerid, -1, MainStr);
		SCM(playerid, -1, ""text_red"INFO: "text_green"Type /savecolor to save your color");
	}
	return true;
}
CMD:cc(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return  SCM(playerid, msg_red, "ERROR: You have to be in a vehicle");

    new color[2];
    if(sscanf(params, "ii", color[0], color[1]))
    {
        return SCM(playerid, msg_yellow, "Usage: /cc <color1 id> <color2 id>");
    }

	if(color[0] > 255 || color[1] > 255 || color[0] < 0 || color[1] < 0)
	{
	    return SCM(playerid, msg_yellow, "Usage: /cc <color id> <color2 id>");
	}

	ChangeVehicleColor(GetPlayerVehicleID(playerid), color[0], color[1]);
	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	SendPlayerTextNotice(playerid, "Vehicle repainted", "");
	return 1;
}
CMD:settings(playerid)
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
	if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
   
    new StoreStrings[600];
    strcat(StoreStrings, ""text_red"Features\t\t"text_yellow"Settings\n");

    if(PlayerInfo[playerid][Player_Speedo])
    {
    	strcat(StoreStrings, ""text_white"Speedometer\t\t"text_green"ON\n");
    }
    else strcat(StoreStrings, ""text_white"Speedometer\t\t"text_red"OFF\n");
    
    
    if(PlayerInfo[playerid][Player_SB])
    {
    	strcat(StoreStrings, ""text_white"Speed Boost\t\t"text_green"ON\n");
    }
    else strcat(StoreStrings, ""text_white"Speed Boost\t\t"text_red"OFF\n");

    if(PlayerInfo[playerid][Player_SJ])
    {
    	strcat(StoreStrings, ""text_white"Super Jump\t\t"text_green"ON\n");
    }
    else strcat(StoreStrings, ""text_white"Super Jump\t\t"text_red"OFF\n");

    if(PlayerInfo[playerid][Player_Bounce])
    {
    	strcat(StoreStrings, ""text_white"Vehicle Bounce\t\t"text_green"ON\n");
    }
    else strcat(StoreStrings, ""text_white"Vehicle Bounce\t\t"text_red"OFF\n");

    if(PlayerInfo[playerid][Player_God])
    {
    	strcat(StoreStrings, ""text_white"GodMode\t\t"text_green"ON\n");
    }
    else strcat(StoreStrings, ""text_white"GodMode\t\t"text_red"OFF\n");

    if(PlayerInfo[playerid][Player_AutoLogin])
    {
    	strcat(StoreStrings, ""text_white"Auto Login\t\t"text_green"ON\n");
    }
    else strcat(StoreStrings, ""text_white"Auto Login\t\t"text_red"OFF\n");

    switch(PlayerInfo[playerid][Player_FS])
    {
    	case 4: strcat(StoreStrings, ""text_white"Fight Style\t\tNormal\n");
    	case 5: strcat(StoreStrings, ""text_white"Fight Style\t\tBoxing\n");
        case 6: strcat(StoreStrings, ""text_white"Fight Style\t\tKungFu\n");
        case 7: strcat(StoreStrings, ""text_white"Fight Style\t\tKnee-Head\n");
        case 15: strcat(StoreStrings, ""text_white"Fight Style\t\tGrab Kick\n");
        case 16: strcat(StoreStrings, ""text_white"Fight Style\t\tElbow\n");

    }

    if(PlayerInfo[playerid][Player_AllowTP])
    {
    	strcat(StoreStrings, ""text_white"Allow Teleport\t\t"text_green"ON\n");
    }
    else strcat(StoreStrings, ""text_white"Allow Teleport\t\t"text_red"OFF\n");

    if(PlayerInfo[playerid][Player_AllowPM])
    {
    	strcat(StoreStrings, ""text_white"Allow Private Message\t\t"text_green"ON\n");
    }
    else strcat(StoreStrings, ""text_white"Allow Private Message\t\t"text_red"OFF\n");
    
    strcat(StoreStrings, ""text_green"Change your Email");

    ShowPlayerDialog(playerid, DIALOG_PLAYER_SETTINGS, DIALOG_STYLE_TABLIST_HEADERS, ""DIALOG_TAG" Player Settings", StoreStrings, "Select", "Cancel");
	return 1;
}

CMD:email(playerid, params[])
{

    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
	if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
   
    new setemail[40];
    if(sscanf(params, "s[40]", setemail))
    { 
    	return  SCM(playerid, msg_yellow, "Usage: /email <emaiid>"); 
    }
    if(strlen(setemail) < 5 || strlen(setemail) > 40) return SCM(playerid, msg_red,"ERROR: Email Length: 5 - 40");
    if(!IsValidChar(setemail))
    {
    	SCM(playerid, msg_red, "ERROR: Please enter a valid email id"); 
    	return 1;
    }
    strmid(PlayerInfo[playerid][Player_Email], setemail, 0, 40, 40);
    format(MainStr, sizeof(MainStr), ""SERVER_TAG" You email has been updated: %s", PlayerInfo[playerid][Player_Email]);
    SCM(playerid,-1, MainStr);
    mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `email`='%s' WHERE `ID`=%d", PlayerInfo[playerid][Player_Email], PlayerInfo[playerid][Player_ID]);
    mysql_query(fwdb, MainStr);
	return 1;
}

CMD:ach(playerid, params[]) return cmd_achievements(playerid, params);
CMD:achievements(playerid, params[])
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
	if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");
    new showid = INVALID_PLAYER_ID;
    if(sscanf(params, "u", getotherid))
    {
            showid = playerid;
    }
    else {
        if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red,"ERROR: Invalid Player ID");
		if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
		showid = getotherid;
    }
	new achStr[500];
	strcat(achStr, ""text_yellow"Achievements\t\t"text_yellow"Required/Completed\n");

	for(new i = 0; i < MAX_ACHS; i++)
	{
		if(PlayerInfo[showid][Player_AchCompleted][i] == 1)
		{
			format(MainStr,sizeof(MainStr), ""text_white"%s\t\t"text_green"Completed\n", AchInfo[i][Ach_Name]) ;
		}
		else if(PlayerInfo[showid][Player_AchCompleted][i] == 0)
		{
           if(AchInfo[i][Ach_ID] == ACH_CASH)
           { 
		      format(MainStr,sizeof(MainStr), ""text_white"%s\t\t"text_red"%s\n", AchInfo[i][Ach_Name], AchInfo[i][Ach_ReqText] ) ;
		   }
		   else format(MainStr,sizeof(MainStr), ""text_white"%s\t\t"text_red"%s\n", AchInfo[i][Ach_Name], AchInfo[i][Ach_ReqText] ) ;
		}
		strcat(achStr, MainStr);
	}
	ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_TABLIST_HEADERS, ""DIALOG_TAG" Player Achievements", achStr, "OK", "");
	return 1;
}
CMD:statistics(playerid, params[]) return cmd_stats(playerid, params); 
CMD:stats(playerid, params[])
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Please login to use this command");
	if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right nowe");

    new  otherid, StatsString[400], StoreStatsString[400], totalachs;
    if(sscanf(params,"u", getotherid))
    {
         otherid = playerid;
    }
    else 
    {
    	if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red,"ERROR: Invalid Player ID");
		if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
		otherid = getotherid;
    }
     
    for(new i = 0; i < MAX_ACHS; i++)
    {
    	   if(PlayerInfo[otherid][Player_AchCompleted][i] == 1) ++totalachs;
    }

    new gangStore[30];
    if( PlayerInfo[otherid][Player_GangID] == 0) strmid(gangStore, "None", 0, 30, 30);
    else strmid(gangStore, GangInfo[ PlayerInfo[otherid][Player_GangID] ][Gang_Name] , 0, 30, 30);

    format(StatsString, sizeof(StatsString), ""text_white"%s's Statistics: #%d\n\nScore: %d\nMoney: %s\nKills: %d\nDeaths: %d\nKDR: %0.2f",
    	 PlayerInfo[otherid][Player_Name], PlayerInfo[otherid][Player_ID], PlayerInfo[otherid][Player_Score],Currency(PlayerInfo[otherid][Player_Cash]),
    	 PlayerInfo[otherid][Player_Kills],PlayerInfo[otherid][Player_Deaths],Float:PlayerInfo[otherid][Player_Kills]/Float:PlayerInfo[otherid][Player_Deaths]);
    strcat(StoreStatsString,StatsString);
    
  
    format(StatsString, sizeof(StatsString), "\nGang: %s\nAchievements Completed: %d/%d\nPlay Time: %s\nLast Login: %s\nRegistration Date: %s",
    gangStore, totalachs,MAX_ACHS, FormatPlayTime(otherid), ConvertUnix(PlayerInfo[otherid][Player_LastOnline]),ConvertUnix(PlayerInfo[otherid][Player_Joined]));

    strcat(StoreStatsString,StatsString);

    ShowPlayerDialog(otherid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Player Statistics", StoreStatsString, "OK", "");
	return 1;
}

CMD:gethere(playerid, params[]) cmd_get(playerid, params);
CMD:get(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return  SCM(playerid, msg_red, "ERROR: You can't use this command right now");

    
    if(sscanf(params, "u", getotherid)) return SCM(playerid, msg_yellow, "Usage: /get <id/name>");

    if(getotherid == INVALID_PLAYER_ID) return  SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(getotherid == playerid) return SCM(playerid, msg_red, "ERROR: You can't get yourself");
    if(PlayerInfo[getotherid][Player_InGWAR])
    	 return  SCM(playerid, msg_red, "ERROR: The player is in gang war mode.");

    if(PlayerInfo[getotherid][Player_Mode] != MODE_FREEROAM) return  SCM(playerid, msg_red, "ERROR: Player is currently in different dimension! Try later");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't teleport dead players");
    
    if(PlayerInfo[getotherid][Player_Admin] >  PlayerInfo[playerid][Player_Admin])
    	 return  SCM(playerid, msg_red, "ERROR: You can't get higher level admins");

	format(MainStr, sizeof(MainStr), "You have been teleported to Admin %s's location", PlayerInfo[playerid][Player_Name]);
	SCM(getotherid, msg_blue, MainStr);
	format(MainStr, sizeof(MainStr), "You have teleported %s(%i) to your location",PlayerInfo[getotherid][Player_Name], getotherid);
	SCM(playerid, msg_blue, MainStr);

    new Float:POS[3];
	GetPlayerPos(playerid, POS[0], POS[1], POS[2]);
	SetPlayerInterior(getotherid, GetPlayerInterior(playerid));
	SetPlayerVirtualWorld(getotherid, GetPlayerVirtualWorld(playerid));
	
	if(GetPlayerState(getotherid) == PLAYER_STATE_DRIVER)
	{
		SetVehiclePos(GetPlayerVehicleID(getotherid), POS[0] + 2.0, POS[1], POS[2] + 0.5);
		LinkVehicleToInterior(GetPlayerVehicleID(getotherid), GetPlayerInterior(playerid));
		SetVehicleVirtualWorld(GetPlayerVehicleID(getotherid), GetPlayerVirtualWorld(playerid));
	}
	else
	{
		SetPlayerPos(getotherid, floatadd(POS[0], 2), POS[1], POS[2]);
	}

	return 1;
}
CMD:getip(playerid, params[])
{

    if(PlayerInfo[playerid][Player_Admin] < Head_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	if(sscanf(params, "u", getotherid))
 	{
  		SCM(playerid, msg_yellow, "Usage: /getip <id/name>");
		return true;
	}
	if(getotherid == INVALID_PLAYER_ID)
		return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
	if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(PlayerInfo[playerid][Player_Admin] !=  0)
  		 return SCM(playerid, msg_red, "ERROR: You can't get an administrator ip!");

	format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"%s(%i)'s IP: %s", PlayerInfo[getotherid][Player_Name], getotherid, PlayerInfo[playerid][Player_IP]);
	SCM(playerid, -1, MainStr);
	return true;
}
CMD:rv(playerid, params[])
{
	if(PlayerInfo[playerid][Player_Admin] < Head_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
	
    new rvreason[50];
    if(sscanf(params, "s[50]", rvreason))
    {
        SCM(playerid, msg_yellow, "Usage: /rv <reason>");
        return 1;
    }
    
    foreach(new i : Player)
    {
        if(!PlayerInfo[i][Player_Logged]) continue;
        if(!PlayerInfo[i][Player_Spawned]) continue;
        if(!IsPlayerInAnyVehicle(i) && PlayerInfo[i][Player_Mode] == MODE_FREEROAM)
        {
            DestroyPlayerVehicles(i);
        }
    }

	format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"Admin %s(%i) destroyed all unoccupied player vehicles [Reason: %s]",  PlayerInfo[playerid][Player_Name], playerid, rvreason);
	SCMToAll(-1, MainStr);
	return 1;
}
CMD:slap(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
   
    
	if(sscanf(params, "u", getotherid))
	{
	    SCM(playerid, msg_yellow, "Usage: /slap <ID/name>");
	    return true;
	}

	if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red,"ERROR: Invalid Player ID");
	if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't slap dead players");
    if(PlayerInfo[getotherid][Player_Mode] != MODE_FREEROAM) return  SCM(playerid, msg_red, "ERROR: Player is currently in different dimension! Try later");

    new Float:POS[3];
    if(getotherid == playerid) SCM(playerid, msg_blue, "You have slapped yourself");
    else { 
    if(PlayerInfo[getotherid][Player_Admin] > PlayerInfo[playerid][Player_Admin])  return  SCM(playerid, msg_red, "ERROR: You can't slap your superiors");
    format(MainStr, sizeof(MainStr), "You have slapped %s(%i).", PlayerInfo[getotherid][Player_Name], getotherid);
	SCM(playerid, msg_blue, MainStr);
    }
	GetPlayerPos(getotherid, POS[0], POS[1], POS[2]);
	SetPlayerPos(getotherid, POS[0], POS[1], POS[2] + 9.0);

	PlayerPlaySound(getotherid, 1130, 0.0, 0.0, 0.0);
	return true;
}
CMD:gotoxyz(playerid, params[])
{
   
	if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You cannot use this command right now");
	
    new Float:POS[3];
	if(sscanf(params, "fff", POS[0], POS[1], POS[2]) && sscanf(params, "p<,>fff", POS[0], POS[1], POS[2]))
	{
		SCM(playerid, msg_yellow, "Usage: /gotoxyz <X> <Y> <Z>");
		return true;
	}

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vID = GetPlayerVehicleID(playerid);
	    Streamer_UpdateEx(playerid, POS[0], POS[1], POS[2]);
		SetVehiclePos(vID, POS[0], POS[1], POS[2]);
	    SetVehicleVirtualWorld(vID, 0);
   		LinkVehicleToInterior(vID, 0);
		PutPlayerInVehicle(playerid, vID, 0);
	}
    else 
    {
    	Streamer_UpdateEx(playerid,POS[0], POS[1], POS[2]);
		SetPlayerPos(playerid, POS[0], POS[1], POS[2]);
    }
	format(MainStr, sizeof(MainStr), ""text_blue"You have teleported yourself to %f %f %f!", POS[0], POS[1], POS[2]);
	SCM(playerid, -1, MainStr);
	
	return true;
}
CMD:god(playerid)
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You cannot use this command right now");
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: You need to login  use this command");
    if(PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "You can't use this command while being in a gang war");

    if(PlayerInfo[playerid][Player_God])
    {
            PlayerInfo[playerid][Player_God] = false;
            SendPlayerTextNotice(playerid, "GODMODE:", "~r~OFF");
            SCM(playerid, msg_white, ""SERVER_TAG" You have disabled your godmode.");
            SCM(playerid, msg_white, ""text_green"** You have received random weapons");
            WeaponReset(playerid);
            SetPlayerHealth(playerid, 100.0);
            PlayerInfoTD(playerid, "~w~Your ~y~GodMode~w~ has been ~r~Disabled", 3500);
            TextDrawShowForPlayer(playerid, TDInfo[PlayerGod]);
            TextDrawHideForPlayer(playerid, TDInfo[PlayerGod]);
    }
    else 
    {
    	    new Float:PlayerHealth;
	        GetPlayerHealth(playerid, PlayerHealth);
			if(PlayerHealth < 40.0) return SendPlayerTextNotice(playerid, "~r~Can't activate god,", "Health below 40");
            PlayerInfo[playerid][Player_God] = true;
            SendPlayerTextNotice(playerid, "GODMODE:", "~g~ON");
            SCM(playerid, msg_white, ""SERVER_TAG" You have enabled your godmode.");
            SCM(playerid, msg_white, ""text_green"** Your weapons are removed. Use /god to disable godmode");
            ResetPlayerWeapons(playerid);           
            SetPlayerHealth(playerid, 99999.0);
            PlayerInfoTD(playerid, "~w~Your ~y~GodMode~w~ has been ~g~Enabled", 3500);
            TextDrawShowForPlayer(playerid, TDInfo[PlayerGod]);
    }
	return 1;
}
CMD:report(playerid, params[])
{
   if(PlayerInfo[playerid][Player_Admin]) return SCM(playerid, msg_red, "ERROR: Only for Players, Ez Admin.");
 
   new reason[40];
   if(sscanf(params, "us[40]", getotherid, reason))
   {
	    SCM(playerid, msg_yellow, "Usage: /report <id/name> <reason>");
	    return true;
   }
   if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red,"ERROR: Invalid Player ID");
   if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
   if(getotherid == playerid || PlayerInfo[getotherid][Player_Admin] != 0) return SCM(playerid, msg_red, "ERROR: You can't report yourself or an administrator.");
   
   if(strlen(reason) > 40 || strlen(reason) < 4) return SCM(playerid, msg_red, "ERROR: Reason Length: 4-40");
   if(GetPVarInt(getotherid, "ReportCooldown") >= gettime())
   {
        SCM(playerid, msg_red, "ERROR: Please wait few seconds for reporting another player.");
    	return 1;
   }
   else if(GetPVarInt(getotherid, "ReportCooldown")) DeletePVar(getotherid, "ReportCooldown");    

   if(!SendAdminNotice(""text_yellow"**"text_red" A new report has been submitted from a player. Please use /reports to check out the report", true))
   {
          return SCM(playerid, msg_red, "ERROR: There are no admins online");
   }
   format(MainStr, sizeof(MainStr), "%s(%i) -> %s(%i) Reason: %s", PlayerInfo[playerid][Player_Name], playerid, PlayerInfo[getotherid][Player_Name], getotherid, reason);

   for(new pr = 1; pr < MAX_REPORTS - 1; pr++)
   {
		PlayerReports[pr] = PlayerReports[pr + 1];
   }
   PlayerReports[MAX_REPORTS - 1] = MainStr;

   SCM(playerid, msg_green, "Thanks for reporting!");
   SetPVarInt(getotherid, "ReportCooldown", gettime()+40); // 40 seconds
   return 1;
}
CMD:reports(playerid)
{
	if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

  	new rCount, rString[500],  rStoreString[500];
  	strcat(rStoreString, "\n");
  	for(new i = 1; i < MAX_REPORTS; i++)
	{
  		if(strcmp(PlayerReports[i], "_", false) != 0)
		{
			rCount++;
			format(rString, sizeof(rString), ""text_white"%s\n", PlayerReports[i]);
			strcat(rStoreString, rString);
		}
	}
	if(rCount == 0)
	{
		SCM(playerid, msg_red, "ERROR: No reports found!");
	}
	else ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Player Reports", rStoreString, "OK", "");
    return 1;
}
CMD:clearreports(playerid)
{
    if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return SCM(playerid, msg_red,  "ERROR: You don't have sufficient permission to use this command");
    new rCount;
  	for(new i = 1; i < MAX_REPORTS; i++)
	{
  		if(strcmp(PlayerReports[i], "_", false) != 0)
		{
			rCount++;
			PlayerReports[i] = "_";
		}
	}
	if(rCount == 0)
	{
		SCM(playerid, msg_red, "ERROR: No reports found!");

	}
	else SCM(playerid, msg_green, "Reports are cleared");
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}
CMD:caps(playerid, params[])
{

    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    

	if(sscanf(params, "u", getotherid))
	{
	    SCM(playerid, msg_yellow, "Usage: /caps <id/name>");
	    return true;
	}
    if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
	if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
   

    if(GetPVarInt(getotherid, "PlayerCaps") >= gettime())
    {
        SCM(playerid, msg_red, "ERROR: Player has been caps'd recently, Please wait!");
    	return 1;
    }    
    
    if(PlayerInfo[getotherid][Player_Caps])
    {      
    	   PlayerInfo[getotherid][Player_Caps] = false;
    	   SetPVarInt(getotherid, "PlayerCaps", gettime()+30); // 30 seconds
           format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red" %s(%i)'s caps has been enabled by an Administrator", PlayerInfo[getotherid][Player_Name], getotherid);
           SCMToAll(-1, MainStr);
           format(MainStr, sizeof(MainStr), "Your caps has been enabled by an Administrator");
           SCM(getotherid, msg_red, MainStr);
    }
    else 
    {
    	   PlayerInfo[getotherid][Player_Caps] = true;
    	   DeletePVar(getotherid, "PlayerCaps");
           format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red" %s(%i)'s caps has been disabled by an Administrator", PlayerInfo[getotherid][Player_Name], getotherid);
           SCMToAll(-1, MainStr);
           format(MainStr, sizeof(MainStr), "Your caps has been disabled by an Administrator");
           SCM(getotherid, msg_red, MainStr);
    }

    return 1;
}
CMD:pm(playerid, params[]) 
{
    if(PlayerInfo[playerid][Player_Muted]) return SCM(playerid, msg_red, "ERROR: You are muted! Please wait.");
    
    new pmtext[140];
    if(sscanf(params, "us[140]", getotherid, pmtext)) return SCM(playerid, msg_yellow, "Usage: /pm <id/name> <msg>");

    if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(getotherid == playerid) return SCM(playerid, msg_red, "ERROR: You can't pm yourself!");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't pm dead players");
    if(strlen(pmtext) < 0 || strlen(pmtext) > 140) return SCM(playerid, msg_red, "ERROR: Message is too short or too long.");

    if(PlayerInfo[getotherid][Player_Ignore][playerid] == 1)
    {
	    SCM(playerid, msg_red,"ERROR: The player has ignored you.");

	    format(MainStr, sizeof(MainStr), ""text_red"*** "text_blue"%s(%i) has tried to send you a pm!",PlayerInfo[playerid][Player_Name], playerid);
	    SCM(getotherid, -1, MainStr);
    	return 1;
    }
    if(!PlayerInfo[getotherid][Player_AllowPM]) return SCM(playerid, msg_red,"ERROR: The player has disabled their private messages.");
    format(MainStr, sizeof(MainStr), ""text_red"***"text_white"["text_red"PM"text_white"] from %s(%i): %s", PlayerInfo[playerid][Player_Name], playerid, pmtext);
    SCM(getotherid, -1, MainStr);

	format(MainStr, sizeof(MainStr), ""text_green">>>"text_white"["text_green"PM"text_white"] to %s(%i): %s", PlayerInfo[getotherid][Player_Name], getotherid, pmtext);
	SCM(playerid, -1, MainStr);

    
   	format(MainStr, sizeof(MainStr), "~g~~h~~h~PM from ~y~~h~%s(%i)", PlayerInfo[playerid][Player_Name], playerid);
	PlayerInfoTD(getotherid, MainStr, 3500);

	format(MainStr, sizeof(MainStr), "~g~~h~~h~PM sent to ~b~~h~~h~%s(%i)!",  PlayerInfo[getotherid][Player_Name], getotherid);
	PlayerInfoTD(playerid, MainStr, 3500);

    SetPVarInt(getotherid, "LastPMID", playerid);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

    if(PlayerInfo[getotherid][Player_Afk] == 1)
    {
      SCM(playerid, msg_red, "*** The player is in AFk may not able to view your pm unti they come back from AFK.");
      SetPVarInt(getotherid, "PlayerRecivedPM", 1);
    }
    else PlayerPlaySound(getotherid, 1057, 0.0, 0.0, 0.0);
    
	format(MainStr, sizeof(MainStr), "{BABABA}[PM] from %s(%i) to %s(%i): %s", PlayerInfo[playerid][Player_Name], playerid, PlayerInfo[getotherid][Player_Name], getotherid, pmtext);
	SendAdminNotice(MainStr);
	return 1;
}
CMD:r(playerid, params[])
{
    if(GetPVarInt(playerid, "LastPMID") == INVALID_PLAYER_ID)
	{
		return SCM(playerid, msg_red, "ERROR: Noone has send you a message yet");
	}
    new rpmtext[140];
	if(sscanf(params, "s[140]", rpmtext))
	{
	    return SCM(playerid, msg_yellow, "Usage: /r <message>");
	}

	new PM_ID = GetPVarInt(playerid, "LastID");
	if(PM_ID == INVALID_PLAYER_ID) return SCM(playerid, -1, "ERROR: Invalid Player!");
    if(!PlayerInfo[PM_ID][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[PM_ID][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't reply to dead players");
    if(strlen(rpmtext) < 0 || strlen(rpmtext) > 140) return SCM(playerid, msg_red, "ERROR: Message is too short or too long.");

	if(PlayerInfo[PM_ID][Player_Ignore][playerid] == 1)
    {
	    SCM(playerid, msg_red,"ERROR: The player has ignored you.");

	    format(MainStr, sizeof(MainStr), ""text_red"*** "text_blue"%s(%i) has tried to send you a pm!",PlayerInfo[playerid][Player_Name], playerid);
	    SCM(PM_ID, -1, MainStr);
    	return 1;
    }
    if(!PlayerInfo[PM_ID][Player_AllowPM]) return SCM(playerid, msg_red,"ERROR: The player has disabled their private messages.");
    format(MainStr, sizeof(MainStr), ""text_red"***"text_white"["text_red"PM"text_white"] from %s(%i): %s", PlayerInfo[playerid][Player_Name], playerid, rpmtext);
    SCM(PM_ID, -1, MainStr);

	format(MainStr, sizeof(MainStr), ""text_green">>>"text_white"["text_green"PM"text_white"] to %s(%i): %s", PlayerInfo[PM_ID][Player_Name], PM_ID, rpmtext);
	SCM(playerid, -1, MainStr);


   	format(MainStr, sizeof(MainStr), "~g~~h~~h~PM from ~y~~h~%s(%i)", PlayerInfo[playerid][Player_Name], playerid);
	PlayerInfoTD(PM_ID, MainStr, 3500);

	format(MainStr, sizeof(MainStr), "~g~~h~~h~PM sent to ~b~~h~~h~%s(%i)!",  PlayerInfo[PM_ID][Player_Name], PM_ID);
	PlayerInfoTD(playerid, MainStr, 3500);

	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);


    if(PlayerInfo[PM_ID][Player_Afk] == 1)
    { 
      SCM(playerid, msg_red, "*** The player is in AFk may not able to view your pm unti they come back from AFK.");
      SetPVarInt(PM_ID, "PlayerRecivedPM", 1);
    }
    else PlayerPlaySound(PM_ID, 1057, 0.0, 0.0, 0.0);

    SetPVarInt(PM_ID, "LastPMID", playerid);
	format(MainStr, sizeof(MainStr), "{BABABA}[PM] from %s(%i) to %s(%i): %s", PlayerInfo[playerid][Player_Name], playerid, PlayerInfo[PM_ID][Player_Name], PM_ID, rpmtext);
	SendAdminNotice(MainStr);
	return 1;
}

CMD:a(playerid, params[]) return cmd_achat(playerid, params);
CMD:achat(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    new achat[350], amsg[350];
    if(sscanf(params, "s[350]", achat)) return SCM(playerid, msg_yellow, "Usage: /a <text>");
    if(strlen(achat) > 350 || strlen(achat) < 1) return 1;


    format(amsg, sizeof(amsg), ""text_red"[ADMIN] {%06x}%s(%i): "text_green"%s", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid, achat);
    SendAdminNotice(amsg);
	return 1;
}

CMD:jetpack(playerid)
{
	if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: Please use /exit to access jetpack");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	SendPlayerTextNotice(playerid, "Jetpack Enabled", "");
	return true;
}
CMD:admins(playerid)
{
    if(PlayerInfo[playerid][Player_Score] <  200) return SCM(playerid, msg_red, "ERROR: You need 200 score to view online admins list");
    
    new acount = 0, StoreAdmin[500];
    strcat(StoreAdmin, "\n"text_yellow"Administrators:"text_white"\n\n");
    foreach(new i : Player)
    {
    	
    	if(PlayerInfo[i][Player_Admin] == 0) continue;
    	acount++;
    	if(PlayerInfo[i][Player_Afk] == 1)
    	{
             format(MainStr, sizeof(MainStr), " %d. %s(%i) (%s) "text_red"[AFK]\n", acount, PlayerInfo[i][Player_Name], i,AdminLevels[PlayerInfo[i][Player_Admin]]);
             strcat(StoreAdmin,MainStr);
    	}
        else {
             format(MainStr, sizeof(MainStr), " %d. %s(%i) (%s)\n", acount, PlayerInfo[i][Player_Name], i,AdminLevels[PlayerInfo[i][Player_Admin]]);
             strcat(StoreAdmin,MainStr);
        }
    }
    if(!acount) return SendPlayerTextNotice(playerid, "No Admins online", " ");
     
    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""SERVER_TAG" Online Admins", StoreAdmin, "OK", "");

	return 1;
}
CMD:asay(playerid, params[])
{
	if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
	
	new sayann[100];
	if(sscanf(params, "s[100]", sayann))
	{
	    SCM(playerid, msg_yellow, "Usage: /asay <text>");
	    return true;
	}
	    
    if(strlen(sayann) > 100 || strlen(sayann) < 3) return SCM(playerid, msg_red, "ERROR: Text can't be in too long! Length: 3-100");

	format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"Admin %s(%i): %s", PlayerInfo[playerid][Player_Name], playerid, sayann);
	SCMToAll(-1, MainStr);
	return 1;
}

CMD:announce(playerid, params[]) return cmd_ann(playerid, params);
CMD:ann(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    new aann[50];
	if(sscanf(params, "s[50]", aann))
	{
	    SCM(playerid, msg_yellow, "Usage: /ann <msg>");
	    return true;
	}

    if(strlen(aann) > 50 || strlen(aann) < 1) return SCM(playerid, msg_red, "ERROR: Text can't be in too long! Length: 1-50");

	format(MainStr, sizeof(MainStr), "%s", aann);
	GameTextForAll(MainStr, 4500, 3);
	return 1;
}
CMD:warn(playerid, params[])
{
	if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	new awarn[50];
	if(sscanf(params, "us[50]", getotherid, awarn))
	{
	    SCM(playerid, msg_yellow, "Usage: /warn <id/Name> <reason>");
	    return true;
	}
	if(getotherid == INVALID_PLAYER_ID)
        return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(getotherid == playerid) return SCM(playerid, msg_red, "ERROR: You can't warn yourself!");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't warn dead players");

	if(strlen(awarn) > 50)
	{
	    SCM(playerid, msg_red, "ERROR: Reason can't be longer than 50 characters!");
	    return true;
	}
	if(PlayerInfo[getotherid][Player_Admin] > PlayerInfo[playerid][Player_Admin])  return   SCM(playerid, msg_red, "ERROR: You can't warn your superiors");

	if(GetPVarInt(getotherid, "PlayerWarned") >= gettime())
	{
        return SCM(playerid, msg_red, "ERROR: Player has just recently been warned");
	}
	else DeletePVar(getotherid, "PlayerWarned");
	

    PlayerInfo[getotherid][Player_Warns]++;

    if(PlayerInfo[getotherid][Player_Warns] == MAX_WARNS)
    {
		 format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"%s(%i) has been kicked. [Reason: excessives warnings] [Warnings: %d/%d]", PlayerInfo[getotherid][Player_Name], getotherid, PlayerInfo[getotherid][Player_Warns] , MAX_WARNS);
		 SCMToAll(-1, MainStr);
		 DelayKick(getotherid);
	}
	else 
	{
	     format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"%s(%i) has been warned by an Administrator. [Reason: %s] [Warnings: %d/%d]", PlayerInfo[getotherid][Player_Name], getotherid, awarn, PlayerInfo[getotherid][Player_Warns] , MAX_WARNS);
	     SCMToAll(-1, MainStr);
	     SetPVarInt(getotherid, "PlayerWarned", gettime()+10); // 10 seconds 
	}
	PlayerPlaySound(getotherid, 1186, 0.0, 0.0, 0.0);
	return true;
}
CMD:jail(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

    new reason[60], time;
	if(sscanf(params, "uis[60]", getotherid, time, reason))
	{
	    SCM(playerid, msg_yellow, "Usage: /jail <id/Name> <seconds> <reason>");
	    return true;
 	}
 	if(strlen(reason) > 60 || strlen(reason) < 5) return SCM(playerid, msg_red, "ERROR: Reason Length: 5-60");
    if(time < 10 || time > 600) return SCM(playerid, msg_red, "ERROR: Time Duration: 10 - 600");
    if(getotherid == INVALID_PLAYER_ID)
        return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(getotherid == playerid) return SCM(playerid, msg_red, "ERROR: You can't jail yourself!");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't jail dead players");
    if(PlayerInfo[getotherid][Player_Mode] == MODE_JAILED) return SCM(playerid, msg_red, "Player is already jailed! Type /unjail to unjail.");
    if(PlayerInfo[getotherid][Player_Admin] > PlayerInfo[playerid][Player_Admin])  return   SCM(playerid, msg_red, "ERROR: You can't jail your superiors");
    if(PlayerInfo[getotherid][Player_Mode] != MODE_FREEROAM && RemovePlayer(getotherid) != 0) return SCM(playerid, msg_red, "ERROR: Player is currently in different dimension! Try later");
    
    if(PlayerInfo[getotherid][Player_InGWAR])
    {
       PlayerInfo[getotherid][Player_InGWAR] = false;
       SCM(getotherid, -1, ""text_green"You are no longer invloved in Gang War mode!");
       for(new ix = 0; ix < MAX_GZONES; ix++)
       {
         TextDrawHideForPlayer(getotherid, GZInfo[ix][Zone_TD]);
         GangZoneStopFlashForPlayer(getotherid, GZInfo[ix][Zone_Area]);
       }
    }
    ResetPlayerWeapons(getotherid);
    PlayerInfo[getotherid][Player_Mode] = MODE_JAILED;
    PlayerInfo[getotherid][Player_JailTime] = time;
    
    SetPlayerInterior(getotherid, 3);
	SetPlayerVirtualWorld(getotherid, JAIL_WORLD);
	SetPlayerFacingAngle(getotherid, 360.0);
	SetPlayerPos(getotherid, 197.5662, 175.4800, 1004.0);

    format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"%s(%i) has been jailed by an Admin %s(%i) for %i seconds [Reason: %s]", PlayerInfo[getotherid][Player_Name], getotherid, 
    	PlayerInfo[playerid][Player_Name], playerid, time, reason);
	SCMToAll(-1, MainStr);

    ClosePlayerDialog(getotherid);
	return 1;
}
CMD:spectators(playerid)
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");

	new countspec, specname[MAX_PLAYER_NAME];
	foreach(new i : Player)
	{
	    if(PlayerInfo[i][Player_Mode] == MODE_SPEC)
	    {
	        ++countspec;
		}
	}

	if(countspec == 0)	return SCM(playerid, msg_red, "INFO: There isn't anyone spectating!");

	if(countspec == 1) SCM(playerid, -1, ""SERVER_TAG" "text_green"Displaying a list of 1 player spectating:");
	else {

		format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_green"Displaying a list of %i admin(s) spectating:", countspec);
		SCM(playerid, -1, MainStr);
	}

	countspec = 0;

	foreach(new i : Player)
	{
	    if(PlayerInfo[i][Player_Mode] == MODE_SPEC)
	    {
		    ++countspec;
		    GetPlayerName(PlayerInfo[i][Player_Spec], specname, MAX_PLAYER_NAME);
			format(MainStr, sizeof(MainStr), "  "text_red"%d. "text_white"%s(%i) spectating %s(%i).", countspec, PlayerInfo[i][Player_Name], i, specname, PlayerInfo[i][Player_Spec]);
		    SCM(playerid, -1, MainStr);
		}
	}
	return true;
}
CMD:spectate(playerid, params[]) return cmd_spec(playerid, params);
CMD:spec(playerid, params[]) 
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM && PlayerInfo[playerid][Player_Mode] != MODE_SPEC) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");
    if(!PlayerInfo[playerid][Player_InGWAR]) return SCM(playerid, msg_red, "ERROR: You are can't use this command while being in  gang war");
    if(sscanf(params, "u", getotherid))
    {
    	return SCM(playerid, msg_yellow, "Usage: /spec <id/Name>");
    }

    if(getotherid == INVALID_PLAYER_ID)
        return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(getotherid == playerid) return SCM(playerid, -1, "ERROR: You can't spectate yourself");
    
    if(!PlayerInfo[getotherid][Player_Spawned]) return SCM(playerid, msg_red, "ERROR: Can't spectate dead players");
    if(PlayerInfo[getotherid][Player_Admin] > PlayerInfo[playerid][Player_Admin]) return SCM(playerid, -1, "ERROR: You can't spectate higher level admins");
    if(PlayerInfo[getotherid][Player_Mode] == MODE_SPEC || GetPlayerState(getotherid) == PLAYER_STATE_SPECTATING) return SCM(playerid, -1, "ERROR: Player is spectating someone");
    
	PlayerInfo[playerid][Player_Spec] = getotherid;
    PlayerInfo[playerid][Player_Mode] = MODE_SPEC;

	SavePlayerPos(playerid);
	SetPlayerInterior(playerid, GetPlayerInterior(getotherid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(getotherid));
		
	TogglePlayerSpectating(playerid, true);

	if(IsPlayerInAnyVehicle(getotherid))
	{
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(getotherid));
	}
	else PlayerSpectatePlayer(playerid, getotherid);

    new totalspecs = 0;
    foreach(new i : Player)
	{
	    if(PlayerInfo[i][Player_Spec] == getotherid && PlayerInfo[i][Player_Mode] == MODE_SPEC && i != playerid)
	    { 
	        totalspecs++;
	    }
	}
	if(totalspecs == 1)
	{
		format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_green"%s(%i) is also being spectated by another admins", PlayerInfo[getotherid][Player_Name], getotherid);
        SCM(playerid, -1, MainStr);
	}
	else if(totalspecs > 1)
	{
	    format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_green"%s(%i) is also spectated by %i other admins", PlayerInfo[getotherid][Player_Name], getotherid, totalspecs);
        SCM(playerid, -1, MainStr);
	}
	return 1;
}
CMD:unspec(playerid)
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    if(PlayerInfo[playerid][Player_Mode] != MODE_SPEC) return SCM(playerid, msg_red, "ERROR: You are not in spectating mode.");

    PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
    SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
    PlayerInfo[playerid][Player_Spec] = INVALID_PLAYER_ID;
    SetPlayerInterior(playerid, 0);
    TogglePlayerSpectating(playerid, false);
    SpawnPlayerEx(playerid, true);
	SendPlayerTextNotice(playerid, "~r~No longer Spectating", "");
	return 1;
}
CMD:ignore(playerid, params[])
{

    if(sscanf(params,"u", getotherid)) return SCM(playerid, msg_yellow, "Usage: /ignore <id/name>");

    if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(getotherid == playerid)  return SCM(playerid, msg_red, "ERROR: You can't ignore yourself");
    if(PlayerInfo[playerid][Player_Ignore][getotherid] == 1)
  		return cmd_unignore(playerid, params);

	PlayerInfo[playerid][Player_Ignore][getotherid] = 1;

	format(MainStr, sizeof(MainStr), ""SERVER_TAG" %s(%i) is now ignored by you. They wont be able to teleport to you or PM you. (/ignorelist)", PlayerInfo[getotherid][Player_Name], getotherid);
	SCM(playerid, -1, MainStr);
	return 1;
}
CMD:unignore(playerid, params[])
{

   	if(sscanf(params, "u", getotherid))
	{
	    SCM(playerid, msg_yellow, "Usage: /unignore <id/name>");
	    return true;
	}

	if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");

	
    if(PlayerInfo[playerid][Player_Ignore][getotherid] == 0)
	{
		SCM(playerid, msg_red, "ERROR: You are not ignoring this player. Please use /ignorelist");
		return true;
	}

	PlayerInfo[playerid][Player_Ignore][getotherid] = 0;

	format(MainStr, sizeof(MainStr), ""SERVER_TAG" %s(%i) is no longer blocked by you.", PlayerInfo[getotherid][Player_Name], getotherid);
	SCM(playerid, -1, MainStr);
	return true;
}
CMD:ignorelist(playerid, params[])
{
    new ignore_count = 0;
    if(sscanf(params, "i", getotherid))
	{
		foreach(new i : Player)
		{
		    if(PlayerInfo[playerid][Player_Ignore][i] == 0)
				continue;

			++ignore_count;
		}

		if(ignore_count == 0)
			return SCM(playerid, msg_red, "[IGNORE] You aren't ignoring anybody.");


		format(MainStr, sizeof(MainStr), "[IGNORE] You are ignoring %d player(s):", ignore_count);
		SCM(playerid, msg_green, MainStr);
        
        ignore_count = 0;
		foreach(new i : Player)
		{
		    if(PlayerInfo[playerid][Player_Ignore][i] == 0)
				continue;

			++ignore_count;

			format(MainStr, sizeof(MainStr), "    %d. %s(%i)", ignore_count, PlayerInfo[i][Player_Name], i);
			SCM(playerid, msg_yellow, MainStr);
		}
	}
	else
	{
	    if(PlayerInfo[playerid][Player_Admin] == 0)
	    	return SCM(playerid, msg_red, "ERROR: Only admins can view others ignorelist. Use /ignorelist without parameters to view your ignorelist!");

		ignore_count = 0;
		foreach(new i : Player)
		{
		    if(PlayerInfo[getotherid][Player_Ignore][i] == 0)
				continue;

			++ignore_count;
		}

       

		if(ignore_count == 0)
		{
		    SCM(playerid, msg_red, "[IGNORE] That player isn't ignoring anybody.");
		    return true;
		}

		format(MainStr, sizeof(MainStr), "[IGNORE] %s(%i) is ignoring %d player(s):",PlayerInfo[getotherid][Player_Name], getotherid, ignore_count);
		SCM(playerid, msg_green, MainStr);
         
        ignore_count = 0;
		foreach(new i : Player)
		{
		    if(PlayerInfo[getotherid][Player_Ignore][i] == 0)
				continue;

			++ignore_count;

			format(MainStr, sizeof(MainStr), "    %d. %s(%i)", ignore_count, PlayerInfo[i][Player_Name], i);
			SCM(playerid, msg_yellow, MainStr);
		}
	}
	return true;
}
CMD:unjail(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

    
	if(sscanf(params, "uis[60]", getotherid))
	{
	    SCM(playerid, msg_yellow, "Usage: /jail <id/Name>");
	    return true;
 	}
 	if(getotherid == INVALID_PLAYER_ID)
        return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(PlayerInfo[getotherid][Player_Mode] != MODE_JAILED) return SCM(playerid, msg_red, "Player is not jailed");
   
    
    PlayerInfo[getotherid][Player_Mode] = MODE_FREEROAM;
    PlayerInfo[getotherid][Player_JailTime] = 0;
    SetPlayerVirtualWorld(getotherid, FREEROAM_WORLD);
    SetPlayerInterior(getotherid, 0);
    WeaponReset(getotherid);
    SpawnPlayer(getotherid);

    format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"%s(%i) has been unjailed by an Admin %s(%i)", PlayerInfo[getotherid][Player_Name], getotherid, 
    	PlayerInfo[playerid][Player_Name], playerid);
	SCMToAll(-1, MainStr);
	return 1;
}

/* Used to create teleports.
CMD:createteleport(playerid, params[])
{
	new telecmd[10],telename[30], teleenum[800], telestr[800];
    if(sscanf(params, "s[10]s[30]",telecmd, telename))
     return 1;
    
    new Float:POS[4];
    GetPlayerPos(playerid, POS[0], POS[1], POS[2]);

    GetPlayerFacingAngle(playerid, POS[3]);

    format(teleenum, sizeof teleenum, "{Tele_Cities, '%s', '%s', %.4f,%.4f,%.4f,FREEROAM_WORLD,true},\r\n",telename,telecmd,POS[0], POS[1], POS[2]);
    new File:LTeleenum = fopen("/Log/telenum.txt", io_append);
	fwrite(LTeleenum, teleenum);
	fclose(LTeleenum);


    format(telestr, sizeof(telestr), "SendPlayerToPosition(playerid,  %.4f, %.4f, %.4f, %.4f , %.4f, %.4f, %.4f, %.4f, '%s', true, true, false);\r\n", 
    	POS[0], POS[1], POS[2],POS[3],POS[0], POS[1], POS[2],POS[3],telename);
	new File:Ltelestr = fopen("/Log/teles.txt", io_append);
	fwrite(Ltelestr, telestr);
	fclose(Ltelestr);
	return 1;
}
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{

    SetPlayerPos(playerid, fX, fY,fZ);
	return 1;
}*/
CMD:clearchat(playerid)
{
	if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
	
	for(new i = 0; i < 50; i++)
	{
		SCMToAll(-1, " ");
	}
	GameTextForAll("~g~~h~Chat Cleared", 3400, 3);
	return 1;
}
CMD:go(playerid, params[])
{
    if(!PlayerInfo[playerid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: You need to be logged in to use this command.");
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: You can't use this command right now");

    if(sscanf(params, "u", getotherid))
	{
		SCM(playerid, msg_yellow, "Usage: /goto <id/name>");
		return true;
	}
	if(getotherid == INVALID_PLAYER_ID)
		return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
	if(getotherid == playerid)
		return SCM(playerid, msg_red, "ERROR: You can't teleport to yourself");


	if(PlayerInfo[playerid][Player_Admin] == 0) // if not admin
	{
		if(PlayerInfo[getotherid][Player_Admin] != 0) return SCM(playerid, msg_red, "ERROR: You can't teleport to admios");

		if(PlayerInfo[getotherid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: Player is currently in different dimension! Try later");
		if(PlayerInfo[getotherid][Player_InGWAR]) return SCM(playerid, msg_red, "ERROR: Player is currently in gang war");
        
		if(PlayerInfo[getotherid][Player_Ignore][playerid] == 1)
		{
		    SCM(playerid, msg_red, "ERROR: The player has ignored you.");

		    format(MainStr, sizeof(MainStr), ""text_red"*** "text_blue"%s(%d) has tried to teleport to you!",  PlayerInfo[playerid][Player_Name], playerid);
			SCM(getotherid, -1, MainStr);
		    return true;
		}
		if(!PlayerInfo[playerid][Player_AllowTP]) return SCM(playerid, msg_red, "** The Player has disabled their player teleport");
	}
    
	new Float:POS[3];
	GetPlayerPos(getotherid, POS[0], POS[1], POS[2]);
	SetPlayerInterior(playerid, GetPlayerInterior(getotherid));
    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(getotherid));
    
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		SetVehiclePos(GetPlayerVehicleID(playerid), floatadd(POS[0], 3), POS[1], POS[2]);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(getotherid));
		SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetPlayerVirtualWorld(getotherid));
	}
	else
	{
		SetPlayerPos(playerid, floatadd(POS[0], 2), POS[1], POS[2]);
	}
	
	format(MainStr, sizeof(MainStr), "You have teleported to %s(%i)!", PlayerInfo[getotherid][Player_Name], getotherid);
	SCM(playerid, msg_blue, MainStr);
	format(MainStr, sizeof(MainStr), "%s(%i) has teleported to you!", PlayerInfo[playerid][Player_Name], playerid);
	SCM(getotherid, msg_blue, MainStr);

	return 1;
}
CMD:cashfall(playerid, params[])
{

    if(PlayerInfo[playerid][Player_Admin] < CEA_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

    new ecash;
    if(sscanf(params, "d", ecash)) return SCM(playerid, msg_yellow, "Usage: /cashfall <1-2000000>");
    if(ecash > 2000000) return SCM(playerid, msg_red, "ERROR: You can't reward more than $2,000,000 cash!");
    if(ecash < 1000)  return SCM(playerid, msg_red, "ERROR: You can't reward anyone less than $1,000 cash!");

    format(MainStr, sizeof(MainStr), ""text_green"[Global] "text_yellow"%s(%i)"text_white" has given everyone "text_yellow"%s "text_white"cash.", PlayerInfo[playerid][Player_Name], playerid, Currency(ecash));
    SCMToAll(-1, MainStr);
    GameTextForAll("~g~~h~~h~Cash for Everyone", 3200, 3);

    format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: -~n~  ~g~~h~Cash~w~: ~g~+$%s", Currency(ecash));
    foreach(new i : Player)
    {
        if(PlayerInfo[i][Player_Logged])
        {
            SendPlayerMoney(i, ecash);
            PlayerPoints(i,MainStr);
	        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
        }
    }
    return 1;
}
CMD:scorefall(playerid, params[])
{

    if(PlayerInfo[playerid][Player_Admin] < CEA_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

    new escore;
    if(sscanf(params, "d", escore)) return SCM(playerid, msg_yellow, "Usage:s /scorefall <1-500>");
    if(escore > 500) return SCM(playerid, msg_red, "ERROR: You can't reward more than 500 score!");
    if(escore < 1)  return SCM(playerid, msg_red, "ERROR: You can't reward anyone less than 1 score!");

    format(MainStr, sizeof(MainStr), ""text_green"[Global] "text_yellow"%s(%i)"text_white" has given everyone "text_yellow"%d "text_white" score.", PlayerInfo[playerid][Player_Name], playerid, escore);
    SCMToAll(-1, MainStr);
    GameTextForAll("~g~~h~~h~Score for Everyone", 3200, 3);
    format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: ~g~+%d~n~  ~g~~h~Cash~w~: ~w~-", escore);
    foreach(new i : Player)
    {
        if(PlayerInfo[i][Player_Logged])
        {
            SendPlayerScore(i, escore);
            PlayerPoints(i,MainStr);
	        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
        }
    }
    return 1;
}
CMD:setscore(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < CEA_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
   
    new setscore;
    if(sscanf(params,"ui", getotherid, setscore)) return SCM(playerid, msg_yellow, "Usage: /setscore <id/name> <score>");

    if(setscore < 0 || setscore > 1000000)
	{
		return SCM(playerid, msg_red, "ERROR: Score: 0 - 1,000,000");
	}
	if(getotherid == INVALID_PLAYER_ID)
        return  SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    
    PlayerInfo[getotherid][Player_Score] = setscore;
    SetPlayerScore(getotherid, setscore);
    
    if(PlayerInfo[getotherid][Player_Score] >= AchInfo[ACH_SCORE][Ach_Req] && PlayerInfo[getotherid][Player_AchCompleted][ACH_SCORE] == 0)
    {
    	SCM(getotherid, msg_green, ""SERVER_TAG" "text_green"You have achieved the score gainer");
    	PlayerInfo[getotherid][Player_AchCompleted][ACH_SCORE] = 1;
    
    	TextDrawShowForPlayer(getotherid, TDInfo[AchTextFetch]);
        SetTimerEx("StopAchDataFetch", 3500, false, "isi" ,getotherid,  AchInfo[ACH_SCORE][Ach_Name], ACH_SCORE);
    }

    format(MainStr,sizeof(MainStr), "Admin %s(%i) has set you score: %i", PlayerInfo[playerid][Player_Name], playerid, setscore);
    SCM(getotherid, msg_blue, MainStr);
    
    format(MainStr,sizeof(MainStr), "You have set %s(%i) score: %i", PlayerInfo[getotherid][Player_Name], getotherid, setscore);
    SCM(playerid, msg_blue, MainStr);

    format(MainStr,sizeof(MainStr), ""text_red"[ADMIN] %s(%i) has set %s(%i) score: %i", PlayerInfo[playerid][Player_Name], playerid, PlayerInfo[getotherid][Player_Name], getotherid, setscore);
    SendAdminNotice(MainStr);
	return 1;
}
CMD:setcash(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < CEA_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
   
    new setcash;
    if(sscanf(params,"ui", getotherid, setcash)) return SCM(playerid, msg_yellow, "Usage: /setcash <id/name> <cash>");

    if(setcash < 0 || setcash > 50000000)
	{
		return SCM(playerid, msg_red, "ERROR: Cash: 0 - 50,000,000");
	}
	if(getotherid == INVALID_PLAYER_ID)
        return  SCM(playerid, msg_red,"ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    
    PlayerInfo[getotherid][Player_Cash] = setcash;
    ResetPlayerMoney(getotherid);
    GivePlayerMoney(getotherid, setcash);
    
    if(PlayerInfo[getotherid][Player_Cash] >= AchInfo[ACH_CASH][Ach_Req] && PlayerInfo[getotherid][Player_AchCompleted][ACH_CASH] == 0)
    {
    	SCM(getotherid, msg_green, ""SERVER_TAG" "text_green"You have achieved the Rich Player");
    	PlayerInfo[getotherid][Player_AchCompleted][ACH_CASH] = 1;
    	TextDrawShowForPlayer(getotherid, TDInfo[AchTextFetch]);
        SetTimerEx("StopAchDataFetch", 3500, false, "isi" ,getotherid,  AchInfo[ACH_CASH][Ach_Name], ACH_CASH);
    }

    format(MainStr,sizeof(MainStr), "Admin %s(%i) has set you cash: %s", PlayerInfo[playerid][Player_Name], playerid, Currency(setcash));
    SCM(getotherid, msg_blue, MainStr);
    
    format(MainStr,sizeof(MainStr), "You have set %s(%i) cash: %s", PlayerInfo[getotherid][Player_Name], getotherid, Currency(setcash));
    SCM(playerid, msg_blue, MainStr);

    format(MainStr,sizeof(MainStr), ""text_red"[ADMIN] %s(%i) has set %s(%i) cash: %s", PlayerInfo[playerid][Player_Name], playerid, PlayerInfo[getotherid][Player_Name], getotherid, Currency(setcash));
    SendAdminNotice(MainStr);
	return 1;
}
CMD:sethealth(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < CEA_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	new Float:health;
	if(sscanf(params, "uf", getotherid, health))
	{
	    SCM(playerid, msg_yellow, "Usage: /sethealth <id/name> <health>");
	    return true;
	}

	if(getotherid == INVALID_PLAYER_ID)
        return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return SCM(playerid, msg_red, "ERROR: Can't set health for dead players");
    
	if(health < 0 || health > 100)
	{
	    SCM(playerid, msg_red, "ERROR: Health: 0 - 100");
		return true;
	}

	SetPlayerHealth(getotherid, health);
	format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_white"You have set %s(%i)'s health to %f", PlayerInfo[getotherid][Player_Name], getotherid, health);
	SCM(playerid, -1, MainStr);
	format(MainStr, sizeof(MainStr), "Admin %s(%i) have set your health to %f", PlayerInfo[playerid][Player_Name], playerid, health);
	SCM(getotherid, msg_blue, MainStr);
	return true;
}

CMD:givescore(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < CEA_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
   
    new givescore;
    if(sscanf(params,"ui", getotherid, givescore)) return SCM(playerid, msg_yellow, "Usage: /givescore <id/name> <score>");

    if(givescore < 0 || givescore > 500)
	{
		return SCM(playerid, msg_red, "ERROR: Score: 0 - 500");
	}
	if(getotherid == INVALID_PLAYER_ID)
        return  SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");

    SendPlayerScore(getotherid, givescore);

    format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: ~g~+%d~n~  ~g~~h~Cash~w~: -", givescore);
    PlayerPoints(playerid, MainStr);

    format(MainStr,sizeof(MainStr), "Admin %s(%i) has given you score: %i", PlayerInfo[playerid][Player_Name], playerid, givescore);
    SCM(getotherid, msg_blue, MainStr);
    
    format(MainStr,sizeof(MainStr), "You have given %s(%i) score: %i", PlayerInfo[getotherid][Player_Name], getotherid, givescore);
    SCM(playerid, msg_blue, MainStr);

    format(MainStr,sizeof(MainStr), ""text_red"[ADMIN] %s(%i) has given %s(%i) score: %i", PlayerInfo[playerid][Player_Name], playerid, PlayerInfo[getotherid][Player_Name], getotherid, givescore);
    SendAdminNotice(MainStr);
	return 1;
}
CMD:givecash(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < CEA_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
   
    new givecash;
    if(sscanf(params,"ui", getotherid, givecash)) return SCM(playerid, msg_yellow, "Usage: /givecash <id/name> <cash>");

    if(givecash < 0 || givecash > 1000000)
	{
		return SCM(playerid, msg_red, "ERROR: Cash: 0 - 1,000,000");
	}
	if(getotherid == INVALID_PLAYER_ID)
        return  SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");

    SendPlayerMoney(getotherid, givecash);
    
    format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: -~n~  ~g~~h~Cash~w~: ~g~+$%s", Currency(givecash) );
    PlayerPoints(playerid, MainStr);
    format(MainStr,sizeof(MainStr), "Admin %s(%i) has given you cash: %s", PlayerInfo[playerid][Player_Name], playerid, Currency(givecash) );
    SCM(getotherid, msg_blue, MainStr);

    format(MainStr,sizeof(MainStr), "You have given %s(%i) cash: %s", PlayerInfo[getotherid][Player_Name], getotherid, Currency(givecash));
    SCM(playerid, msg_blue, MainStr);

    format(MainStr,sizeof(MainStr), ""text_red"[ADMIN] %s(%i) has given %s(%i) cash: %s", PlayerInfo[playerid][Player_Name], playerid, PlayerInfo[getotherid][Player_Name], getotherid, Currency(givecash));
    SendAdminNotice(MainStr);
	return 1;
}
CMD:giveweapon(playerid, params[])
{
	if(PlayerInfo[playerid][Player_Admin] < Head_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	new weaponID, 
	    weaponName[20],
	    ammo_a;

	if(sscanf(params, "udD(500)", getotherid, weaponID, ammo_a))
	{
	   SCM(playerid, msg_yellow, "Usage: /giveweapon <ID> <Weapon ID> <ammo>");
	   return true;
	}

	if(getotherid == INVALID_PLAYER_ID)
        return  SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(PlayerInfo[getotherid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: Player is currently in different dimension! Try later");
    if(PlayerInfo[getotherid][Player_God]) return SCM(playerid, msg_red, "ERROR: Player has godmode enabled");
	if(ammo_a < 0 || ammo_a > 999999)
	{
	    SCM(playerid, msg_red, "ERROR: Invalid ammo provided!");
	    return true;
	}

	if(weaponID < 0 && weaponID > 47)
	{
	    if(weaponID == 20)
	    {
			SCM(playerid, msg_red, "ERROR: Invalid weapon ID provided!");
			return true;
		}
		SCM(playerid, msg_red, "ERROR: Invalid weapon ID provided!");
		return true;
	}

	GetWeaponName(weaponID, weaponName, sizeof(weaponName));
	if(weaponID == 38 || weaponID == 35 || weaponID == 36)
	{
	    if(PlayerInfo[playerid][Player_Admin] == 0)
	 	{
	    	format(MainStr, sizeof(MainStr), ""text_red"ERROR: You can't give out %s to regular players, they will get banned!", weaponName);
			SCM(playerid, -1, MainStr);
	    	return true;
  		}
	}
	GivePlayerWeapon(getotherid, weaponID, ammo_a);


	format(MainStr, sizeof(MainStr), ""SERVER_TAG" %s(%i) gave you a %s(%d) with %d ammo.", PlayerInfo[playerid][Player_Name], playerid, weaponName, weaponID, ammo_a);
	SCM(getotherid, -1, MainStr);
	format(MainStr, sizeof(MainStr), ""SERVER_TAG" You gave %s(%i) a %s(%d) with %d ammo.", PlayerInfo[getotherid][Player_Name], getotherid, weaponName, weaponID, ammo_a);
	SCM(playerid, -1, MainStr);
    return true;
}

CMD:getin(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
	
	new seat;
	if(sscanf(params, "ud", getotherid, seat))
	{
		SCM(playerid, msg_yellow, "Usage: /getin <id/Name> <seat id>");
		return true;
	}

	if(getotherid == INVALID_PLAYER_ID)
		return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
	
	if(!IsPlayerInAnyVehicle(getotherid))
	{
		format(MainStr, sizeof(MainStr), "ERROR: %s(%i) is not in any vehicle!", PlayerInfo[getotherid][Player_Name], getotherid);
		SCM(playerid, msg_red, MainStr);
		return true;
	}

	if(IsVehicleOneSeater(GetPlayerVehicleID(getotherid)))
	{
		format(MainStr, sizeof(MainStr), "ERROR: %s(%i) is currently driving a one seat vehicle!", PlayerInfo[getotherid][Player_Name], getotherid);
		SCM(playerid, msg_red, MainStr);
		return true;
	}

	if(seat < 0 || seat > 3)
	{
		SCM(playerid, msg_red, "ERROR: You can choose seat from 0 - 3!");
		return true;
	}

	new vID = GetPlayerVehicleID(getotherid), 
	vv = GetVehicleModel(vID);

	foreach(new i : Player)
	{
	    if(!IsPlayerInVehicle(i, vID)) continue;
	    if(GetPlayerVehicleSeat(i) == seat)
	    {
			format(MainStr, sizeof(MainStr), "ERROR: Seat %d in %s(%i)'s %s(%d) is occupied by %s(%i).", seat, PlayerInfo[getotherid][Player_Name], getotherid, 
				GetVehicleName[vv - 400], vID, PlayerInfo[i][Player_Name], i);
			SCM(playerid, msg_red, MainStr);
			return true;
		}
	}

	SetPlayerInterior(playerid, GetPlayerInterior(getotherid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(getotherid));
	PutPlayerInVehicle(playerid, vID, seat);

	format(MainStr, sizeof(MainStr), "%s(%i) teleported into your %s(%d) to seat %d.", PlayerInfo[playerid][Player_Name], playerid, GetVehicleName[vv - 400], vID, seat);
	SCM(getotherid, msg_blue, MainStr);
	format(MainStr, sizeof(MainStr), "You teleported into %s(%i)'s %s(%d) to seat %d.", PlayerInfo[getotherid][Player_Name], getotherid, GetVehicleName[vv - 400], vID, seat);
	SCM(playerid, msg_blue, MainStr);

	return true;
}

CMD:mute(playerid, params[])
{

	if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	new reason[50], time;
	if(sscanf(params, "uD(120)s[50]", getotherid, time, reason))
	{
	    SCM(playerid, msg_yellow, "Usage: /mute <id/name> <seconds> <reason>");
	    return true;
	}
	if(getotherid == INVALID_PLAYER_ID)
		return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");

    if(strlen(reason) < 0 || strlen(reason) > 50)
	{
	 	SCM(playerid, msg_red, "ERROR: Reason too long! Must be smaller than 50 characters!");
	   	return true;
	}


	if(time < 10 || time > 600)
	{
 			SCM(playerid, msg_red, "ERROR: Mute time must remain between 10 and 600 seconds");
	    	return true;
	}
    
    if(PlayerInfo[getotherid][Player_Admin] > PlayerInfo[playerid][Player_Admin])  return   SCM(playerid, msg_red, "ERROR: You can't mute your superiors");
	if(PlayerInfo[playerid][Player_Muted]) return SCM(playerid, msg_red, "Player is already muted! Type /unmute to unmute that player");

    
    PlayerInfo[playerid][Player_MuteTime] = time;
    PlayerInfo[playerid][Player_Muted] = true;

    
    format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"Admin %s(%i) has muted %s(%i) for %d seconds [Reason: %s]", PlayerInfo[playerid][Player_Name], playerid, PlayerInfo[getotherid][Player_Name], getotherid,time, reason);
    SCMToAll(-1, MainStr);
   
    SendPlayerTextNotice(getotherid, "~r~~h~muted", ""); 
    return 1;
}
CMD:unmute(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	if(sscanf(params, "u", getotherid))
	{
	    SCM(playerid, msg_yellow, "Usage: /mute <id/name>");
	    return true;
	}

    if(getotherid == INVALID_PLAYER_ID)
        return SCM(playerid, msg_red, "ERROR: Invalid Player ID");

	if(!PlayerInfo[getotherid][Player_Muted])
	    return SCM(playerid, msg_red, "ERROR: The player isn't muted!");

	PlayerInfo[getotherid][Player_Muted] = false;
	PlayerInfo[getotherid][Player_MuteTime] = 0;

	format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"%s(%i) has been unmuted by an Administrator", PlayerInfo[getotherid][Player_Name], getotherid);
	SCMToAll(-1, MainStr);
	return true;
}
CMD:resettime(playerid, params[])
{
	SetPlayerTime(playerid, 12, 0);
	SetPlayerWeather(playerid, 1);
	
    SCM(playerid, msg_green, "Timne has ben resetted!");
	return 1;
}

CMD:day(playerid, params[])
{
	if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    SetWorldTime(12);
    SetWeather(1);
    format(MainStr, sizeof(MainStr), ""text_red"Administrator {%06x}%s(%i) "text_red"has changed the time to: "text_yellow"day time", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid);
	SCMToAll(-1, MainStr);
	return 1;
}


CMD:explode(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	if(sscanf(params, "u", getotherid))
	{
		SCM(playerid, msg_yellow, "Usage: /explode <id/Name>");
		return true;
	}

	if(getotherid == INVALID_PLAYER_ID)
		return  SCM(playerid, msg_red, "ERROR: Invalid Player ID");

    if(PlayerInfo[playerid][Player_Admin] > 0)
	{
		return SCM(playerid, msg_red, "ERROR: You cannot use this command on an admin");
	}


    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't explode dead players");
    
	format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"You have exploded %s(%i).", PlayerInfo[getotherid][Player_Name], getotherid);
	SCM(playerid, -1, MainStr);
    new Float:POS[3];
	GetPlayerPos(getotherid, POS[0], POS[1], POS[2]);
	CreateExplosion(POS[0], POS[1], POS[2], 7, 5.0);
	return true;
}
CMD:night(playerid, params[])
{
	    if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
	
	    SetWorldTime(0);
	    SetWeather(17);
	    format(MainStr, sizeof(MainStr), ""text_red"Administrator {%06x}%s(%i) "text_red"has changed the time to: "text_yellow"night time", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid);
		SCMToAll(-1, MainStr);
     	return 1;
}
CMD:akill(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	if(sscanf(params, "u", getotherid))
	{
		SCM(playerid, msg_yellow, "Usage: /akill <id/Name>");
		return true;
	}

	if(getotherid == INVALID_PLAYER_ID)
		return  SCM(playerid, msg_red, "ERROR: Invalid Player ID");

    if(PlayerInfo[playerid][Player_Admin] > 0)
	{
		return SCM(playerid, msg_red, "ERROR: You cannot use this command on an admin");
	}


    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't kill dead players");
    if(PlayerInfo[getotherid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: Player is currently in different dimension! Try later");
    
    SetPlayerHealth(getotherid, 0.0);

	format(MainStr, sizeof(MainStr),""text_red"Admin %s(%i) killed you", PlayerInfo[playerid][Player_Name], playerid);
	SCM(getotherid, -1, MainStr);
	format(MainStr, sizeof(MainStr),""text_red"[ADMIN] Admin %s(%i) killed %s(%i)", PlayerInfo[playerid][Player_Name], playerid,PlayerInfo[getotherid][Player_Name], getotherid);
	SendAdminNotice(MainStr);
	return true;
}
CMD:cuff(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	if(sscanf(params, "u", getotherid))
	{
	    SCM(playerid, msg_yellow, "Usage: /cuff <id/name>");
	    return true;
	}

	if(getotherid == INVALID_PLAYER_ID)
        return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't cuff dead players");
    
	SetPlayerSpecialAction(getotherid, SPECIAL_ACTION_CUFFED);

	format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_red"You have cuffed %s(%i). Type /uncuff to uncuff the player",playerid,PlayerInfo[getotherid][Player_Name], getotherid);
	SCM(playerid, -1, MainStr);

	format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_red"%s(%i) has cuffed you.", PlayerInfo[playerid][Player_Name], playerid);
	SCM(getotherid, -1, MainStr);
	return true;
}
CMD:uncuff(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	if(sscanf(params, "u", getotherid))
	{
	    SCM(playerid, msg_yellow, "Usage: /uncuff <id/name>");
	    return true;
	}

	if(getotherid == INVALID_PLAYER_ID)
        return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't uncuff dead players");
    
	SetPlayerSpecialAction(getotherid, SPECIAL_ACTION_NONE);

	format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_green"You have uncuffed %s(%i). Type /uncuff to uncuff the player",playerid,PlayerInfo[getotherid][Player_Name], getotherid);
	SCM(playerid, -1, MainStr);

	format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_green"%s(%i) has uncuuffed you.", PlayerInfo[playerid][Player_Name], playerid);
	SCM(getotherid, -1, MainStr);
	return true;
}
CMD:freeze(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	if(sscanf(params, "u", getotherid))
	{
		SCM(playerid, msg_yellow, "Usage: /freeze <id/Name>");
		return true;
	}

	if(getotherid == INVALID_PLAYER_ID)
		return  SCM(playerid, msg_red, "ERROR: Invalid Player ID");

    if(PlayerInfo[playerid][Player_Admin] > 0)
	{
		return SCM(playerid, msg_red, "ERROR: You cannot use this command on an admin");
	}


    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't freeze dead players");
    if(PlayerInfo[getotherid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: Player is currently in different dimension! Try later");
    
    PlayerInfo[getotherid][Player_Freeze] = true;
    TogglePlayerControllable(getotherid, false);

	format(MainStr, sizeof(MainStr),""text_red"Admin %s(%i) frozen you", PlayerInfo[playerid][Player_Name], playerid);
	SCM(getotherid, -1, MainStr);
	format(MainStr, sizeof(MainStr),""text_red"[ADMIN] Admin %s(%i) frozen %s(%i)", PlayerInfo[playerid][Player_Name], playerid,PlayerInfo[getotherid][Player_Name], getotherid);
	SendAdminNotice(MainStr);
	return true;
}
CMD:unfreeze(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

	if(sscanf(params, "u", getotherid))
	{
		SCM(playerid, msg_yellow, "Usage: /unfreeze <id/Name>");
		return true;
	}

	if(getotherid == INVALID_PLAYER_ID)
		return  SCM(playerid, msg_red,"ERROR: Invalid Player ID");

    if(PlayerInfo[playerid][Player_Admin] > 0)
	{
		return SCM(playerid, msg_red, "ERROR: You cannot use this command on an admin");
	}

    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't unfreeze dead players");
    if(PlayerInfo[getotherid][Player_Freeze]) return  SCM(playerid, msg_red, "ERROR: Player is not frozen");
    if(PlayerInfo[getotherid][Player_Mode] != MODE_FREEROAM) return SCM(playerid, msg_red, "ERROR: Player is currently in different dimension! Try later");
    
    PlayerInfo[getotherid][Player_Freeze] = false;
    TogglePlayerControllable(getotherid, true);

	format(MainStr, sizeof(MainStr),""text_red"Admin %s(%i) has unfrozen you", PlayerInfo[playerid][Player_Name], playerid);
	SCM(getotherid, -1, MainStr);
	format(MainStr, sizeof(MainStr),""text_red"[ADMIN] Admin %s(%i) has unfrozen %s(%i)", PlayerInfo[playerid][Player_Name], playerid,PlayerInfo[getotherid][Player_Name], getotherid);
	SendAdminNotice(MainStr);
	return true;
}
CMD:time(playerid, params[])
{
	new thour, tmin;
	if(sscanf(params, "ii", thour, tmin))
	{
         SCM(playerid, msg_yellow, "Usage: /time <hour> <minute>");
         return true;
	}
	SetPlayerTime(playerid, thour, tmin);
    SCM(playerid, msg_green, "Time set! Use /resettime to reset your time!");
	return 1;
}
CMD:dawn(playerid, params[])
{
	    if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
	
		SetWorldTime(6);
		SetWeather(1);
		format(MainStr, sizeof(MainStr), ""text_red"Administrator {%06x}%s(%i) "text_red"has changed the time to: "text_yellow"Dawn",  PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid);
		SCMToAll(-1, MainStr);
	    return 1;
}
CMD:kick(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < Junior_Level) return SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

    new kicktext[80];
	if(sscanf(params, "us[80]", getotherid, kicktext))
	{
	    SCM(playerid, msg_yellow, "Usage: /kick <id/Name> <reason>");
	    return true;
	}
	if(getotherid == INVALID_PLAYER_ID)
        return SCM(playerid, -1, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
    if(!PlayerInfo[getotherid][Player_Spawned]) return  SCM(playerid, msg_red, "ERROR: Can't kick dead players");

	if(GetPVarInt(getotherid, "PlayerKicked")) return SCM(playerid, msg_red, "ERROR: Player has already been removed from the server.");

	if(strlen(kicktext) > 80 || strlen(kicktext) < 5)
	{
	    SCM(playerid, msg_red, "ERROR: Reason can't be longer than 80 and lesser than 5 characters!");
	    return true;
	}

    format(MainStr, sizeof(MainStr), ""text_yellow"** "text_red"%s(%i) has been kicked by Admin %s(%i) [Reason: %s]",  PlayerInfo[getotherid][Player_Name], getotherid,  PlayerInfo[playerid][Player_Name], playerid, kicktext);
    SCMToAll(-1, MainStr);
	SendPlayerTextNotice(getotherid, "~r~~h~Kicked!", "");
	SetPVarInt(getotherid, "PlayerKicked", 1);
	DelayKick(getotherid);
	return 1;
}


CMD:tban(playerid, params[]) return cmd_tempban(playerid, params);
CMD:tempban(playerid, params[])
{
   if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

   new ban_reason[40], ban_days, ban_lift;
   if(sscanf(params, "uds[40]", getotherid, ban_days, ban_reason))
   	             return SCM(playerid, msg_yellow, "Usage: /tban <id/name> <days> <reason>");
   if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
   if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");
   if(getotherid == playerid) return SCM(playerid, msg_red, "ERROR: You are not able to ban yourself");
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

	 SendPlayerTextNotice(ban_player, "~r~You are Banned!", "");

	 format(ban_msg, sizeof(ban_msg), ""text_white"Hello %s,\nBan ID: %d\nBanned by: %s\nBan Date: %s\nBan Lift: %s\nReason: %s\nWrongly Banned? Do a ban appeal in forum!",
	 	PlayerInfo[ban_player][Player_Name], cache_insert_id(), PlayerInfo[admin][Player_Name], ConvertUnix(gettime()), ConvertUnix(days), reason);
	 ShowPlayerDialog(ban_player, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Ban Notice", ban_msg, "OK", "");

	 DelayKick(ban_player);
     return 1;
}
CMD:unban(playerid, params[])
{
    if(PlayerInfo[playerid][Player_Admin] < CEA_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    
    new accid;
    if(sscanf(params, "i", accid))
    {
        return SCM(playerid, msg_yellow, "Usage: /unban <account id>");
    }

    if(accid < 1) return SCM(playerid, msg_red, "ERROR: Invalid account id");
    
    mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT `ban_user`, `ban_ip` FROM `bans` WHERE `ban_id` = %i LIMIT 1;", accid);
    mysql_tquery(fwdb, MainStr, "OnQueryUnbanPlayer", "ii", playerid, accid);
	return 1;
}

publicEx OnQueryUnbanPlayer(playerid, accid)
{
    if(!cache_num_rows()) return  SCM(playerid, -1, "ERROR: Account ID not found in database!");
     
    new ban_name[MAX_PLAYER_NAME], ban_ip[16];

    cache_get_value_index(0, 0, ban_name);
    cache_get_value_index(0, 1, ban_ip);

    mysql_format(fwdb, MainStr, sizeof(MainStr), "DELETE FROM `bans` WHERE ban_ip = '%s'", ban_ip);
    mysql_query(fwdb, MainStr);
    
 	format(MainStr, sizeof(MainStr), ""SERVER_TAG" "text_red"%s has been unbanned by an Administrator",ban_name);
	SCMToAll(-1, MainStr);
	return 1;
}

CMD:ban(playerid, params[])
{
   if(PlayerInfo[playerid][Player_Admin] < Lead_Level) return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");

   new  ban_reason[40];
   if(sscanf(params, "us[40]", getotherid, ban_reason))
   	             return SCM(playerid, msg_yellow, "Usage: /ban <id/name> <reason>");
   if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red,"ERROR: Invalid Player ID");
   if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");

   if(getotherid == playerid) return SCM(playerid, msg_red, "ERROR: You are not able to ban yourself");

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
	 SendPlayerTextNotice(ban_player, "~r~You are Banned!", "");

	 format(ban_msg, sizeof(ban_msg), ""text_white"Hello %s,\nBan ID: %d\nBanned by: %s\nBan Date: %s\nBan Lift: Permanent\nReason: %s\nWrongly Banned? Do a ban appeal in forum!",
	 	PlayerInfo[ban_player][Player_Name], cache_insert_id(), PlayerInfo[admin][Player_Name], ConvertUnix(gettime()), reason);
	 ShowPlayerDialog(ban_player, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""DIALOG_TAG" Ban Notice", ban_msg, "OK", "");

	 DelayKick(ban_player);
     return 1;
}

#define AC_NAME "[BOT]BillieEilish"
CMD:setlevel(playerid, params[]) return cmd_setadmin(playerid, params);
CMD:setadmin(playerid, params[])
{

    if(PlayerInfo[playerid][Player_Admin] < CEA_Level)
		if(!IsPlayerAdmin(playerid))
			 return  SCM(playerid, msg_red, "ERROR: You don't have sufficient permission to use this command");
    
    new  getalevel;
    if(sscanf(params, "ui", getotherid, getalevel)) return SCM(playerid, msg_yellow, "Usage: /setadmin <id/name> <level>");

    if(getotherid == INVALID_PLAYER_ID) return SCM(playerid, msg_red, "ERROR: Invalid Player ID");
    if(!PlayerInfo[getotherid][Player_Logged]) return SCM(playerid, msg_red, "ERROR: Player not connected");

    if(getalevel < 0 || getalevel > Founder_Level) return SCM(playerid, msg_red, "ERROR: Level Range ( 0 - 5 )");

    if(PlayerInfo[playerid][Player_Admin] == CEA_Level)
	{
		if(getalevel > CEA_Level)
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
    	(getalevel > PlayerInfo[getotherid][Player_Admin]) ? ("promoted") : AC_NAME,  PlayerInfo[getotherid][Player_Name],  AdminLevels[ PlayerInfo[getotherid][Player_Admin] ] );
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
    PlayerInfo[playerid][Player_WeapCat] = -1;
    PlayerInfo[playerid][Player_VehCat] = -1;
    PlayerInfo[playerid][Player_LastDM] = DM_None;
    PlayerInfo[playerid][Player_LastSky] = -1;
    PlayerInfo[playerid][Player_LastPark] = -1;
    PlayerInfo[playerid][Player_LastIP] = -1;
    PlayerInfo[playerid][Player_LastBMX] = -1;
    PlayerInfo[playerid][Player_TeleCat] = -1;
    PlayerInfo[playerid][Player_Warns] = 0;
    PlayerInfo[playerid][Player_Muted] = false;
    PlayerInfo[playerid][Player_MuteTime] = 0;
    SetPVarInt(playerid, "PlayerKicked", 0);
    PlayerInfo[playerid][Player_Caps] = false;
    PlayerInfo[playerid][Player_JailTime] = 0;
    SetPlayerTeam(playerid, NO_TEAM);
    PlayerInfo[playerid][Player_Freeze] = false;
    PlayerInfo[playerid][Player_Speedo] = true;
    PlayerInfo[playerid][Player_God] = false;
    PlayerInfo[playerid][Player_Vehicle] = INVALID_VEHICLE_ID;
    PlayerInfo[playerid][Player_Spec] = INVALID_PLAYER_ID;
    SetPVarInt(playerid, "LastPMID", INVALID_PLAYER_ID);
    PlayerInfo[playerid][Player_Afk] = 0;
    PlayerInfo[playerid][Player_SB] = true;
    PlayerInfo[playerid][Player_Bounce] = true;
    PlayerInfo[playerid][Player_SJ] = false;
    PlayerInfo[playerid][Player_FS] = 4;
    PlayerInfo[playerid][Player_AllowPM] = true;
    PlayerInfo[playerid][Player_AllowTP] = true;
    PlayerInfo[playerid][Player_LoadMap] = false;
    for(new i = 0; i < MAX_ACHS; i++)
    {
    	PlayerInfo[playerid][Player_AchCompleted][i] = 0;
    }
    for(new i = 0; i < MAX_SKYDIVE_ACH; i++) 
    {
    	PlayerInfo[playerid][Player_AchSkydive][i] = 0;
    }
    SetPVarInt(playerid, "SkydiveAchInfo", 0);
    PlayerInfo[playerid][Player_ResetNos] = 0;
    PlayerInfo[playerid][Player_ResetFix] = 0;
    PlayerInfo[playerid][Player_AutoLogin] = 0;
    PlayerInfo[playerid][Player_GangID] = 0;
    PlayerInfo[playerid][Player_GangRank] = 0;   
    PlayerInfo[playerid][Player_SavedPos] = false;   

    PlayerInfo[playerid][Player_InGWAR] = false;
}


publicEx ServerTimer()
{
  foreach(new i : Player) if(PlayerInfo[i][Player_Logged])
  {
  	    // GOD Control
  	    if(PlayerInfo[i][Player_God] && PlayerInfo[i][Player_Mode] == MODE_FREEROAM && !PlayerInfo[i][Player_InGWAR])
  	    {
  	    	SetPlayerHealth(i, 99999.0);
  	    }
  	    // to avoid money hack.
	    if(GetPlayerMoney(i) > PlayerInfo[i][Player_Cash])
		{
			ResetPlayerMoney(i);
			GivePlayerMoney(i, PlayerInfo[i][Player_Cash]);
		}

		// muted
		if(PlayerInfo[i][Player_Muted])
	    {
           PlayerInfo[i][Player_MuteTime]--;
	       if(!PlayerInfo[i][Player_MuteTime])
	       {
	       	   PlayerInfo[i][Player_MuteTime] = 0;
	       	   PlayerInfo[i][Player_Muted] = false;
	       	   SCM(i, msg_red, "Your mute period has been expired!");
	       }
		}
		switch(PlayerInfo[i][Player_Mode])
		{
			case MODE_JAILED:
			{
				   PlayerInfo[i][Player_JailTime]--;
                   if(!PlayerInfo[i][Player_JailTime])
                   {
		                PlayerInfo[i][Player_JailTime] = 0;
		                PlayerInfo[i][Player_Mode] = MODE_FREEROAM;
					    SetPlayerVirtualWorld(i, FREEROAM_WORLD);
					    SetPlayerInterior(i, 0);
		                WeaponReset(i);
						SpawnPlayer(i);
				    	SCM(i, -1, ""text_red"You have been un-jailed by the server.");
                   }
			}
			case MODE_IP:
			{
				if(PlayerInfo[i][Player_ResetNos])
				{
					PlayerInfo[i][Player_ResetNos]--;
					if(PlayerInfo[i][Player_ResetNos] == 5) RemoveVehicleComponent(GetPlayerVehicleID(i), 1010);
					if(PlayerInfo[i][Player_ResetNos] == 0)
					{
					   PlayerInfo[i][Player_ResetNos] = 0;
					}
                }

				if(PlayerInfo[i][Player_ResetFix])
				{
					PlayerInfo[i][Player_ResetFix]--;
					if(PlayerInfo[i][Player_ResetFix] == 0)
					{
					   PlayerInfo[i][Player_ResetFix] = 0;
					}
				}

                new ipvehStore[250];

				format(ipvehStore, sizeof(ipvehStore), "~w~Boost: %s~n~~w~Fix: %s", PlayerInfo[i][Player_ResetNos] == 0 ?  ("~g~~h~~h~Available") : ("~r~~h~~h~Cooldown"),
					PlayerInfo[i][Player_ResetFix] == 0 ?  ("~g~~h~~h~Available"): ("~r~~h~~h~Cooldown"));
				PlayerTextDrawSetString(i, PlayerTD[ChallengeVehInfo][i], ipvehStore);
			}
		}
  }

  // server text update
  static const RandomTDColor[][] =
  {
  	   "~b~Fr~h~ee~h~roam ~r~Wo~h~rld",
  	   "~p~Fr~h~ee~h~roam ~b~Wo~h~rld",
  	   "~y~Free~h~roam ~r~Wo~h~rld",
  	   "~r~Fr~h~ee~h~roam ~g~Wo~h~rld"
  };
  TextDrawSetString(TDInfo[ServerText][0], RandomTDColor[random(sizeof(RandomTDColor))] );

  // gang Zone Locked
  for(new i = 0; i < MAX_GZONES; i++)
  { 
         if(!GZInfo[i][Zone_Exist]) continue;
       
       	 if(GZInfo[i][Zone_LockTime])
         {
             GZInfo[i][Zone_LockTime]--;
	         if(GZInfo[i][Zone_LockTime] == 0)
	         {
	                 GZInfo[i][Zone_LockTime] = 0;
	                 GZInfo[i][Zone_Status] = Zone_InStock;
	                 UpdateGangZoneLabel(i);
	         }
         }
         if(GZInfo[i][Zone_Status] == Zone_InAttack)
         {
         	 if(GZInfo[i][Zone_AttackTime])
         	 {
                   GZInfo[i][Zone_AttackTime]--;
                   format(MainStr, sizeof(MainStr), "Gang War: %s~n~Defend the Gang Zone!~n~~n~~n~Timeleft: %s", GZInfo[i][Zone_Name], ChangeSecToMin(GZInfo[i][Zone_AttackTime]));
                   TextDrawSetString(GZInfo[i][Zone_TD], MainStr);

                   if(GZInfo[i][Zone_AttackTime] == 0)
                   {
                        GZInfo[i][Zone_AttackTime] = 0;                        
                        if(GZInfo[i][Zone_Attacker] != 0)
                        {
                                new gzpcount = 0;
                                        
                                foreach(new p : Player) if(PlayerInfo[p][Player_Logged])
                                {
                            		if(IsPlayerInDynamicArea(p, GZInfo[i][Zone_Streamer]) && PlayerInfo[p][Player_InGWAR] && PlayerInfo[p][Player_Afk] == 0)
                            		{
                            			if(PlayerInfo[p][Player_GangID] == GZInfo[i][Zone_Attacker])
                            			{
                                			gzpcount++;
                                		}
                            		}
                                }

                            	// if no attackers in zone
                            	if(gzpcount == 0)
                            	{
                            		// send message to attackers
                                    format(MainStr, sizeof(MainStr),""GANG_TAG" "GANG_CHAT"Your gang has failed to capture the gang zone: %s. No members left.", GZInfo[i][Zone_Name]);
                                    SendGangNotice(GZInfo[i][Zone_Attacker], MainStr);
                                    Iter_Remove(InGangWar, GZInfo[i][Zone_Attacker]);

                            		// send message to owners
                            		if(GZInfo[i][Zone_Owner] != 0)
                            		{
	                                    format(MainStr, sizeof(MainStr),""GANG_TAG" "GANG_CHAT"Your gang has re-captured the gang zone: %s", GZInfo[i][Zone_Name]);
	                                    SendGangNotice(GZInfo[i][Zone_Owner], MainStr);
	                                    format(MainStr, sizeof(MainStr),""GANG_TAG" Your gang earned 20 score for re-capturing the gang war.");
	                                    SendGangNotice(GZInfo[i][Zone_Owner], MainStr);
	                                    SendPlayerGangScore(GZInfo[i][Zone_Owner], 20);
	                                    Iter_Remove(InGangWar, GZInfo[i][Zone_Owner]);
                                    }   
                                    foreach(new ownp : Player) 
                                    {
                            	       if(PlayerInfo[ownp][Player_Logged])
                                       { 
                                           	if(GZInfo[i][Zone_Owner] != 0 && PlayerInfo[ownp][Player_GangID] == GZInfo[i][Zone_Owner])
	                                    	{
	                                    		   if(PlayerInfo[ownp][Player_InGWAR])
				                                   {
				                                        PlayerInfo[ownp][Player_InGWAR] = false;
			                                        	SendPlayerMoney(ownp, 20000);
			                                        	SendPlayerScore(ownp, 15);
			                                        	PlayerPoints(ownp,"~y~Points~w~:~n~  ~b~Score~w~: ~g~+15~n~  ~g~~h~Cash~w~: ~g~+$20,000");
				                                   }	
	                                    	}
	                                    	if(PlayerInfo[ownp][Player_GangID] == GZInfo[i][Zone_Attacker])
	                                    	{
	                                    		 TextDrawHideForPlayer(ownp,GZInfo[i][Zone_TD]);
	                                    		 if(PlayerInfo[ownp][Player_InGWAR])
	                                    		 {
	                                    		     PlayerInfo[ownp][Player_InGWAR] = false;
	                                    		     GangZoneStopFlashForPlayer(ownp, GZInfo[i][Zone_Area]);
	                                    		 }
	                                    	}
	                                    }
	                                }   
                                    GZInfo[i][Zone_LockTime] = ZONE_REST_CAPFAIL;
    
                                    format(MainStr, sizeof(MainStr), ""text_white"** FW {D2691E} Gang %s has failed to capture the gang zone: %s", GangInfo[GZInfo[i][Zone_Attacker]][Gang_Name], GZInfo[i][Zone_Name]);
                                    SCMToAll(msg_white, MainStr);

                                    if(GZInfo[i][Zone_Owner] != 0) format(MainStr, sizeof(MainStr), ""text_white"** FW {D2691E} Zone retains as %s's zone and the zone will be locked for %s", GangInfo[GZInfo[i][Zone_Owner]][Gang_Name], SecToMin(GZInfo[i][Zone_LockTime]));
                                    else format(MainStr, sizeof(MainStr), ""text_white"** FW {D2691E} Zone retained and the zone will be locked for %s", SecToMin(GZInfo[i][Zone_LockTime]));
                                    SCMToAll(msg_white, MainStr);

                                }
                                else if(gzpcount)
                                {
                                	// if atleast 1 or more attackers in zone

                                	// send message to attackers
                                	if(GZInfo[i][Zone_Owner] != 0)
                                	{
	                                    format(MainStr, sizeof(MainStr),""GANG_TAG" "GANG_CHAT"Your gang has failed to re-capture the gang zone: %s", GZInfo[i][Zone_Name]);
	                                    SendGangNotice(GZInfo[i][Zone_Owner], MainStr);
	                                    Iter_Remove(InGangWar, GZInfo[i][Zone_Owner]);                        
                                    }
                            		// send message to owners

                                    format(MainStr, sizeof(MainStr),""GANG_TAG" "GANG_CHAT"Your gang has captured the gang zone: %s with %i tied member(s)", GZInfo[i][Zone_Name], gzpcount);
                                    SendGangNotice(GZInfo[i][Zone_Attacker], MainStr);
                                    format(MainStr, sizeof(MainStr),""GANG_TAG" Your gang earned 20 score for capturing the gang zone.");
                                    SendGangNotice(GZInfo[i][Zone_Attacker], MainStr);
                                    SendPlayerGangScore(GZInfo[i][Zone_Attacker], 20); 
                                    Iter_Remove(InGangWar, GZInfo[i][Zone_Attacker]);

                                    foreach(new ownp : Player) 
                                    {
                            	       if(PlayerInfo[ownp][Player_Logged])
                                       { 
                                           	if(PlayerInfo[ownp][Player_GangID] == GZInfo[i][Zone_Attacker])
	                                    	{
	                                    		   TextDrawHideForPlayer(ownp,GZInfo[i][Zone_TD]);
	                                    		   if(PlayerInfo[ownp][Player_InGWAR])
				                                   {
				                                        PlayerInfo[ownp][Player_InGWAR] = false;
			                                        	SendPlayerMoney(ownp, 35000);
			                                        	SendPlayerScore(ownp, 30);
			                                        	PlayerPoints(ownp,"~y~Points~w~:~n~  ~b~Score~w~: ~g~+30~n~  ~g~~h~Cash~w~: ~g~+$35,000");  
			                                        	GangZoneStopFlashForPlayer(ownp, GZInfo[i][Zone_Area]);   
				                                   }	
				                                   if(GZInfo[ownp][Zone_Owner] != 0 && PlayerInfo[ownp][Player_GangID] == GZInfo[ownp][Zone_Owner])
		                                    	   {
		                                    		 if(PlayerInfo[ownp][Player_InGWAR])  PlayerInfo[ownp][Player_InGWAR] = false;
		                                    	   }
	                                    	}
	                                    }
	                                }  

                                    GZInfo[i][Zone_LockTime] = ZONE_REST_CAP;
                                    if(GZInfo[i][Zone_Owner] != 0)
                                    {
	                                    format(MainStr, sizeof(MainStr), ""text_white"** FW {D2691E} Gang %s has captured the gang zone: %s owned by: %s", GangInfo[GZInfo[i][Zone_Attacker]][Gang_Name], GZInfo[i][Zone_Name],  GangInfo[GZInfo[i][Zone_Owner]][Gang_Name]);
	                                }
	                                else {
	                                	format(MainStr, sizeof(MainStr), ""text_white"** FW {D2691E} Gang %s has captured the gang zone: %s", GangInfo[GZInfo[i][Zone_Attacker]][Gang_Name], GZInfo[i][Zone_Name]);
	                                }
	                                SCMToAll(msg_white, MainStr);
                                    format(MainStr, sizeof(MainStr), ""text_white"** FW {D2691E} The zone will be locked for %s", SecToMin(GZInfo[i][Zone_LockTime]));
                                    SCMToAll(msg_white, MainStr);

                                    GZInfo[i][Zone_Owner] = GZInfo[i][Zone_Attacker];

                                    mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `gzones` SET `z_Owner` = %i WHERE `z_ID` = %i", GZInfo[i][Zone_Owner], GZInfo[i][Zone_ID]);
                                    mysql_query(fwdb, MainStr); 
                                }

                                // sync zone colors
                                foreach(new resetp : Player) 
                                {
                                	if(PlayerInfo[resetp][Player_Logged])
                                    { 
                                    	SyncGangZoneForPlayer(resetp);
                                    }
                                }

                                GZInfo[i][Zone_Status] = Zone_InLock;
                                GZInfo[i][Zone_Attacker] = 0;
                                UpdateGangZoneLabel(i);

                        }
                   }
         	 }
         }
  }
  return 1;
}

publicEx ServerRandMSG()
{
    static const RandomMSG[][] =
    {

    	"~w~Use ~y~/report ~w~to report players",
    	"~w~Spawn your vehicle using ~p~/v",
    	"~w~Change your skin using ~b~/skin",
    	"  ~w~Grab weapons using ~r~/w",
    	"~w~Use ~p~/t ~w~to see all teleports"
    };
    TextDrawSetString(TDInfo[ServerRandomMSG], RandomMSG[random(sizeof(RandomMSG))] );

    static const RandomChatMSG[][] =
    {
    	""SERVER_TAG""text_white" Visit our website "text_green""#SERVER_WEB"",
    	""SERVER_TAG""text_white" Join "text_red"minigames "text_white"or "text_blue"challenges "text_white"to earn cash and score",
    	""SERVER_TAG""text_white" Use "text_yellow"/report "text_white"to report players"
    };
    SCMToAll(-1, RandomChatMSG[random(sizeof(RandomChatMSG))] );
	return 1;
}
stock DelayKick(playerid)
{
    SetTimerEx("KickEx", 100, 0, "i", playerid);
}
publicEx KickEx(playerid) return Kick(playerid);

publicEx ForcePlayerToSpawn(playerid) return SpawnPlayer(playerid);

stock PlayerVehicleSpawn(playerid, model, bool:user_spawn = false)
{
	cmd_stopanim(playerid);
	ClosePlayerDialog(playerid);

    DestroyPlayerVehicles(playerid);

    new Float:POS[4];

	GetPlayerPos(playerid, POS[0], POS[1], POS[2]);
	GetPlayerFacingAngle(playerid, POS[3]);

	PlayerInfo[playerid][Player_Vehicle] = CreateVehicle(model, POS[0], POS[1], POS[2], POS[3], random(128) + 127, random(128) + 127, -1);

	SetVehicleZAngle(PlayerInfo[playerid][Player_Vehicle], POS[3]);
	SetVehicleVirtualWorld(PlayerInfo[playerid][Player_Vehicle], GetPlayerVirtualWorld(playerid));
	LinkVehicleToInterior(PlayerInfo[playerid][Player_Vehicle], GetPlayerInterior(playerid));
	SetVehicleNumberPlate(PlayerInfo[playerid][Player_Vehicle], ""text_blue"FW");
	SetVehicleToRespawn(PlayerInfo[playerid][Player_Vehicle]);
	PutPlayerInVehicle(playerid, PlayerInfo[playerid][Player_Vehicle], 0);

    if(user_spawn)
    {
    	format(MainStr, sizeof(MainStr), "%s",GetVehicleName[model - 400]);
    	SendPlayerTextNotice(playerid, "~y~Spawned Vehicle", MainStr);
    }
	return 1;
}

GivePlayerSkydiveAchievement(playerid)
{
      SCM(playerid, msg_green, ""SERVER_TAG" "text_green"You have achieved the God of Skydiving");
      PlayerInfo[playerid][Player_AchCompleted][ACH_SKYDIVER] = 1;

      TextDrawShowForPlayer(playerid, TDInfo[AchTextFetch]);
      SetTimerEx("StopAchDataFetch", 3500, false, "isi" ,playerid,  AchInfo[ACH_SKYDIVER][Ach_Name], ACH_SKYDIVER);
      return 1;
}

DestroyPlayerVehicles(playerid)
{
    if(PlayerInfo[playerid][Player_Vehicle] != INVALID_VEHICLE_ID)
    {
    	if(IsValidVehicle(PlayerInfo[playerid][Player_Vehicle])) DestroyVehicle(PlayerInfo[playerid][Player_Vehicle]);
    	PlayerInfo[playerid][Player_Vehicle] = INVALID_VEHICLE_ID;
    }
	return 1;
}

SendPlayerMoney(playerid, sendcash)
{
	if(playerid == INVALID_PLAYER_ID) return 1;

	if(PlayerInfo[playerid][Player_Cash] >= 1000000000) return 1;
    ResetPlayerMoney(playerid);

    PlayerInfo[playerid][Player_Cash] += sendcash;
    GivePlayerMoney(playerid, PlayerInfo[playerid][Player_Cash]);

    if(PlayerInfo[playerid][Player_Cash] >= AchInfo[ACH_CASH][Ach_Req] && PlayerInfo[playerid][Player_AchCompleted][ACH_CASH] == 0)
    {
    	SCM(playerid, msg_green, ""SERVER_TAG" "text_green" You have achieved the Rich Player");
    	PlayerInfo[playerid][Player_AchCompleted][ACH_CASH] = 1;
    	TextDrawShowForPlayer(playerid, TDInfo[AchTextFetch]);
        SetTimerEx("StopAchDataFetch", 3500, false, "isi" ,playerid,  AchInfo[ACH_CASH][Ach_Name], ACH_CASH);
    }
    return 1;
}
SendPlayerScore(playerid, sendscore)
{
	if(playerid == INVALID_PLAYER_ID) return 1;

    PlayerInfo[playerid][Player_Score] += sendscore;
    
    SetPlayerScore(playerid, PlayerInfo[playerid][Player_Score]);
    
    if(PlayerInfo[playerid][Player_Score] >= AchInfo[ACH_SCORE][Ach_Req] && PlayerInfo[playerid][Player_AchCompleted][ACH_SCORE] == 0)
    {
    	SCM(playerid, msg_green, ""SERVER_TAG" "text_green"You have achieved the score gainer");
    	PlayerInfo[playerid][Player_AchCompleted][ACH_SCORE] = 1;
    	TextDrawShowForPlayer(playerid, TDInfo[AchTextFetch]);
    	SetTimerEx("StopAchDataFetch", 3500, false, "isi" ,playerid,  AchInfo[ACH_SCORE][Ach_Name], ACH_SCORE);
    }
    return 1;

}
SendAdminNotice(const notice[], bool:alert = false)
{
	new admincount;
    foreach(new i : Player)
    {
    	if(PlayerInfo[i][Player_Admin] == 0) continue;
    	admincount++;
    	SCM(i, -1, notice);
    	if(alert) PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
    }
    if(!admincount) return 0;
	return 1;
}
stock IsVehicleOneSeater(vehicleid)
{
    switch(GetVehicleModel(vehicleid))
    {
        case 406, 425, 430, 432, 435, 441, 446, 448, 449, 450, 452, 453, 454, 460, 464, 465, 472,
			473, 476, 481, 484, 485, 486, 493, 501, 509, 510, 512, 513, 519, 520, 530, 531, 532,
		 	539, 553, 564, 568, 571, 572, 574, 577, 584, 590, 591, 592, 593, 594, 595, 606,
		 	607, 608, 610, 611: return true;
    }
    return false;
}

stock RequestPlayerWeaponDialog(playerid)
{
	new StoreStre[200];
	for(new i = 0; i < sizeof(WeaponMenuDialog); i++)
	{
		format(MainStr, sizeof(MainStr), ""text_white"%s\n", WeaponMenuDialog[i][WeapMCatName]);
		strcat(StoreStre, MainStr);
	}
    ShowPlayerDialog(playerid, DIALOG_WEAPON_MENU, DIALOG_STYLE_LIST, ""DIALOG_TAG" Weapons Menu", StoreStre, "Choose", "Close");
    StoreStre[0] = EOS;
	return true;
}
stock RequestPlayerVehicleDialog(playerid)
{ 
	new StoreStre[500];
	for(new i = 0; i < sizeof(VehicleDialog); i++)
	{
		format(MainStr, sizeof(MainStr), ""text_white"%s\n", VehicleDialog[i][CatName]);
		strcat(StoreStre, MainStr);
	}
    ShowPlayerDialog(playerid, DIALOG_VEHICLE_MENU, DIALOG_STYLE_LIST, ""DIALOG_TAG" Vehicle Menu", StoreStre, "Choose", "Close");
	return true;
}
stock RequestPlayerTeleDialog(playerid)
{ 
	new StoreStre[200];
	for(new i = 0; i < sizeof(TeleportDialog); i++)
	{
		format(MainStr, sizeof(MainStr), ""text_white"%s\n", TeleportDialog[i][CatName]);
		strcat(StoreStre, MainStr);
	}
    ShowPlayerDialog(playerid, DIALOG_TELEPORT_MENU, DIALOG_STYLE_LIST, ""DIALOG_TAG" Teleport Menu", StoreStre, "Choose", "Close");
	return true;
}
stock RequestPlayerWeaponsList(playerid, category)
{
    new catMainStr[500], StorecatMainStr[500];
    PlayerInfo[playerid][Player_WeapCat] = category;
    for(new i = 0; i < sizeof(WeaponDialog); i++)
    {
    	if(WeaponDialog[i][WeapCatID] == category)
    	{
	    	format(catMainStr, sizeof(catMainStr), "%i(0.0, 0.0, -50.0, 1.5)\t%s\n",WeaponDialog[i][WeapModelID], WeaponDialog[i][WeapName]);
	    	strcat(StorecatMainStr, catMainStr);
	    }
    } 
    ShowPlayerDialog(playerid, DIALOG_WEAPON_SELECT, DIALOG_STYLE_PREVIEW_MODEL, "~h~~y~FW~w~ :: Weapons", StorecatMainStr, "Select", "Close");
	return true;
}
stock RequestPlayerVehiclesList(playerid, category)
{
    new catMainStr2[1700], StorecatMainStr2[1700];
    PlayerInfo[playerid][Player_VehCat] = category;
    for(new i = 0; i < sizeof(VehicleMenu); i++)
    {
    	if(VehicleMenu[i][V_ID] == category)
    	{
	    	format(catMainStr2, sizeof(catMainStr2), "%i(0.0, 0.0, -50.0, 1.0)\t%s\n", VehicleMenu[i][V_Model], GetVehicleName[VehicleMenu[i][V_Model] - 400]);
		    strcat(StorecatMainStr2, catMainStr2);
	    }
    } 
    ShowPlayerDialog(playerid, DIALOG_VEHICLE_SELECT, DIALOG_STYLE_PREVIEW_MODEL, "~h~~y~FW~w~ :: Vehicles", StorecatMainStr2, "Select", "Close");
	return true;
}
stock RequestPlayerTeleList(playerid, category)
{
    new catMainStr[500], StorecatMainStr[500];
    PlayerInfo[playerid][Player_TeleCat] = category;
    for(new i = 0; i < sizeof(TeleportNames); i++)
    {
    	if(TeleportNames[i][TeleID] == category)
    	{
	    	format(catMainStr, sizeof(catMainStr), ""text_white"%s [/%s]\n", TeleportNames[i][TeleName], TeleportNames[i][TeleCmd]);
	    	strcat(StorecatMainStr, catMainStr);
	    }
    } 
    ShowPlayerDialog(playerid, DIALOG_TELEPORT_SELECT, DIALOG_STYLE_LIST, ""DIALOG_TAG" Teleports", StorecatMainStr, "Select", "Close");
    
	return true;
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

publicEx UpdatePlayerSpawn(playerid)
{
	if(!PlayerInfo[playerid][Player_LoadMap]) return 1;
    TogglePlayerControllable(playerid, true);
    PlayerInfo[playerid][Player_LoadMap] = false;
    KillTimer(PlayerInfo[playerid][Player_tLoadMap]);
    TextDrawHideForPlayer(playerid, TDInfo[ObjectsLoad]);
    return 1; 
}
RemovePlayer(playerid)
{
    switch(PlayerInfo[playerid][Player_Mode])
    {
       case MODE_DM:
       {
           PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
           SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
           PlayerInfo[playerid][Player_LastDM] = DM_None;
           SetPlayerInterior(playerid, 0);
           WeaponReset(playerid);
           SpawnPlayerEx(playerid, true);
           DMTextDraw(playerid);
       	   return 0;
       }
       case MODE_SKYDIVE:
       {
           PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
           SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
           PlayerInfo[playerid][Player_LastSky] = -1;
           SetPlayerInterior(playerid, 0);
           WeaponReset(playerid);
           SpawnPlayerEx(playerid, true);
       	   return 0;
       }
       case MODE_PARKOUR:
       {
           PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
           SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
           PlayerInfo[playerid][Player_LastPark] = -1;
           SetPlayerInterior(playerid, 0);
           WeaponReset(playerid);
           SpawnPlayerEx(playerid, true);
       	   return 0;
       }
       case MODE_IP:
       {
           PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
           SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
           PlayerInfo[playerid][Player_LastIP] = -1;
           PlayerInfo[playerid][Player_ResetFix] = 0;
           PlayerInfo[playerid][Player_ResetNos] = 0;
           PlayerTextDrawHide(playerid, PlayerTD[ChallengeVehInfo][playerid]);
           SetPlayerInterior(playerid, 0);
           WeaponReset(playerid);
           SpawnPlayerEx(playerid, true);
       	   return 0;
       }
       case MODE_BMX:
       {
           PlayerInfo[playerid][Player_Mode] = MODE_FREEROAM;
           SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
           PlayerInfo[playerid][Player_LastBMX] = -1;
           SetPlayerInterior(playerid, 0);
           WeaponReset(playerid);
           SpawnPlayerEx(playerid, true);
       	   return 0;
       }
       default: return 1;
    }
    return 2;
}


ResetPlayerGod(playerid)
{   
    PlayerInfo[playerid][Player_God] = false;
    SetPlayerHealth(playerid, 100.0);
    TextDrawHideForPlayer(playerid, TDInfo[PlayerGod]);
    PlayerInfoTD(playerid, "~w~Your ~y~GodMode~w~ has been ~r~Disabled", 3500);
	return 1;
}
// Enable Speedo
ToggleSpeedo(playerid, bool:hide = false)
{

    if(hide)
    {
    	
        PlayerTextDrawHide(playerid, PlayerTD[Speedo][playerid]);
    }
    else
    {
    	
    	
        PlayerTextDrawShow(playerid, PlayerTD[Speedo][playerid]);

    }
	return 1;
}

WeaponReset(playerid)
{
	
	ResetPlayerWeapons(playerid);

    if(PlayerInfo[getotherid][Player_God]) return 1;

    new wrif = GetRandomDMWeapons(WEAPON_RIFLES);
    GivePlayerWeapon(playerid, WeaponDialog[wrif][WeapModel], 9999999); // infinite

    new wsub = GetRandomDMWeapons(WEAPON_SUBMACHINES);
    GivePlayerWeapon(playerid, WeaponDialog[wsub][WeapModel], 9999999);

    new wshot = GetRandomDMWeapons(WEAPON_SHOTGUNS);
    GivePlayerWeapon(playerid, WeaponDialog[wshot][WeapModel], 9999999);

    new whand = GetRandomDMWeapons(WEAPON_HANDGUNS);
    GivePlayerWeapon(playerid, WeaponDialog[whand][WeapModel], 9999999);

    new wmelee = GetRandomDMWeapons(WEAPON_MELEE);
    GivePlayerWeapon(playerid, WeaponDialog[wmelee][WeapModel], 1);
   
    switch(random(2))
    {
    	case 1: {
	    new wspecial = GetRandomDMWeapons(WEAPON_SPECIAL);
	    GivePlayerWeapon(playerid, WeaponDialog[wspecial][WeapModel], 10);
	    }
	}
	return 1;
}
GetRandomDMWeapons(Weapon_ID)
{
    new rankweapid[sizeof(WeaponDialog)], weapcount;
    for(new i,j=sizeof(WeaponDialog); i < j; i++)
    {
        if(WeaponDialog[i][WeapCatID] == Weapon_ID)
        {
            rankweapid[weapcount++]=i;
        }
    }
    return rankweapid[random(weapcount)];
}


stock PlayerRequestSaveStats(playerid)
{
	mysql_format(fwdb, MainStr, sizeof(MainStr), "UPDATE `users` SET `color` = %d, `lastonline` = %d, `playtime`= %d,`skin`=%d,`kills`=%d,`deaths`=%d,`cash`=%d, `score`= %d, `online` = 0,`autologin`=%d WHERE `ID` = %d LIMIT 1;",
	PlayerInfo[playerid][Player_Color],gettime(),CalculatePlayTime(playerid),PlayerInfo[playerid][Player_Skin],PlayerInfo[playerid][Player_Kills],PlayerInfo[playerid][Player_Deaths],
	PlayerInfo[playerid][Player_Cash],PlayerInfo[playerid][Player_Score],PlayerInfo[playerid][Player_AutoLogin],PlayerInfo[playerid][Player_ID]);
	mysql_query(fwdb, MainStr);

	mysql_format(fwdb, MainStr,sizeof(MainStr),"UPDATE `settings` SET `speedboost`=%d,`superjump`=%d,`bounce`=%d,`god`=%d,`speedo`=%d,`fightstyle`=%d,`allowtp`=%d,`allowpm`=%d WHERE `ID`=%d LIMIT 1;", 
	PlayerInfo[playerid][Player_SB], PlayerInfo[playerid][Player_SJ],PlayerInfo[playerid][Player_Bounce],PlayerInfo[playerid][Player_God],PlayerInfo[playerid][Player_Speedo],
	PlayerInfo[playerid][Player_FS],PlayerInfo[playerid][Player_AllowTP],PlayerInfo[playerid][Player_AllowPM],PlayerInfo[playerid][Player_ID]);
    mysql_query(fwdb, MainStr);
}

stock LoadPlayerAchievements(playerid)
{
    mysql_format(fwdb, MainStr, sizeof(MainStr), "SELECT * FROM `playerachs` WHERE `reg_id` = %i",PlayerInfo[playerid][Player_ID] );
    new Cache: achquery = mysql_query(fwdb, MainStr);
    new ach_id;
    if(cache_num_rows())
    {
    	  for(new i = 0; i < cache_num_rows() && i < MAX_ACHS; i++)
    	  {
                 cache_get_value_name_int(i, "ach_id", ach_id);
                 cache_get_value_name_int(i, "ach_status", PlayerInfo[playerid][Player_AchCompleted][ach_id]);
                 ach_id++;
          }
    }
    cache_delete(achquery);
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

SavePlayerPos(playerid)
{
	GetPlayerPos(playerid,  PlayerInfo[playerid][Player_OldPos][0], PlayerInfo[playerid][Player_OldPos][1], PlayerInfo[playerid][Player_OldPos][2]);
	GetPlayerFacingAngle(playerid, PlayerInfo[playerid][Player_OldPos][3]);
}

SpawnPlayerEx(playerid, bool:lastPos = false)
{
	if(lastPos) 
	{
    SetPlayerPos(playerid,  PlayerInfo[playerid][Player_OldPos][0], PlayerInfo[playerid][Player_OldPos][1], floatadd(PlayerInfo[playerid][Player_OldPos][2], 3.0));
	SetPlayerFacingAngle(playerid, PlayerInfo[playerid][Player_OldPos][3]);
	SetCameraBehindPlayer(playerid);
	}
	else {
	new spawnrand =  random(sizeof(PlayerSpawns));
	Streamer_UpdateEx(playerid, PlayerSpawns[spawnrand][0], PlayerSpawns[spawnrand][1], PlayerSpawns[spawnrand][2]);
	SetPlayerPos(playerid, PlayerSpawns[spawnrand][0], PlayerSpawns[spawnrand][1], floatadd(PlayerSpawns[spawnrand][2], 3.0));
	SetPlayerFacingAngle(playerid,floatadd(PlayerSpawns[spawnrand][3], 2.5) );
	SetCameraBehindPlayer(playerid); }
	return 1;
}

SendPlayerToPosition(playerid, Float:X, Float:Y, Float:Z, Float:Angle, Float:XVeh, Float:YVeh, Float:ZVeh, Float:AngleVeh, const map[], bool:vehspawn = true, bool:cmdtext = true, bool:updatepos = true)
{
    if(PlayerInfo[playerid][Player_Mode] != MODE_FREEROAM)
	{   
		return SCM(playerid, msg_red, "ERROR: You can't use this command right now"); 
	}
	
	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	SetPlayerInterior(playerid, 0);

    if(vehspawn)
    {
        
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			new vID = GetPlayerVehicleID(playerid);
		    if(updatepos) Streamer_UpdateEx(playerid, XVeh, YVeh, ZVeh);

			SetVehiclePos(vID, XVeh, YVeh, floatadd(ZVeh, 4.5));
		    SetVehicleVirtualWorld(vID, 0);
	   		SetVehicleZAngle(vID, AngleVeh);
	   		LinkVehicleToInterior(vID, 0);
			PutPlayerInVehicle(playerid, vID, 0);
		}
        else 
	    {
	    	if(updatepos) Streamer_UpdateEx(playerid, X, Y, Z);

			SetPlayerPos(playerid, X, Y, floatadd(Z, 2.5));
			SetPlayerFacingAngle(playerid, Angle);

	    }
	}
	else
	{
	    	if(updatepos) Streamer_UpdateEx(playerid, X, Y, Z);

			SetPlayerPos(playerid, X, Y, floatadd(Z, 2.5));
			SetPlayerFacingAngle(playerid, Angle);
	}
    SetCameraBehindPlayer(playerid);
    
 
    new cmd[10];
    strcat(cmd, "/");
    for(new i = 0; i < sizeof(TeleportNames); i++)
    { 
          if(!strcmp(map, TeleportNames[i][TeleName], true))
          {
          	  strcat(cmd, TeleportNames[i][TeleCmd], 10);
          	  break;
          }
    }
    if(cmdtext)
    {
       SendPlayerTextNotice(playerid, map , cmd); 
    }

    format(MainStr, sizeof(MainStr), "~y~%s ~w~went to ~p~%s",PlayerInfo[playerid][Player_Name], cmd);
    TextDrawSetString(TDInfo[ServerTele], MainStr);
    return 1;
}

SendPlayerTextNotice(playerid, const text1[], const text2[])
{
    format(MainStr, sizeof(MainStr), "~y~%s~n~~w~%s", text1, text2);
    GameTextForPlayer(playerid, MainStr, 3500, 3);
	return 1;
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
IsNumeric(const string[])
{
	for(new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}

stock GetVehicleModelIDFromName(vname[])
{
	for(new ii = 0; ii < 211; ii++)
	{
		if(strfind(GetVehicleName[ii], vname, true) != -1 )
			return ii + 400;
	}
	return -1;
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
>>>>>>> 20febfa (Updated Version)
