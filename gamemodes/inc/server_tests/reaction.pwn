#include <YSI\y_hooks>

#define Reaction_Interval 360000 // 8 minutes
#define Reaction_End 180000 // 3 minutes

enum RactEnum {
	RewardCash,
	RewardScore,
	ReactChars[18],
	TickCount,
	bool:Started
};

new ReactionInfo[RactEnum];

new ReactionCharacters[][] =
	{
	    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
	};

hook OnGameModeInit()
{
	ReactionInfo[Started] = false;
	ReactionInfo[TickCount] = 0;
    ServerVars[Server_ReactionTimer] = SetTimer("ReactionStart", Reaction_Interval, true);
	return 1;
}

hook OnGameModeExit()
{
    KillTimer(ServerVars[Server_ReactionTimer]);
    KillTimer(ServerVars[Server_ReactionTimerEnd]);
	return 1;
}


publicEx ReactionStart()
{
    if(ReactionInfo[Started]) return 1;
    

    ReactionInfo[Started] = true;
    strmid(ReactionInfo[ReactChars], "", 0, 18, 18);

	new ReactLength = random(8) + 2;
	ReactionInfo[RewardCash] = random(8000) + 800;
	ReactionInfo[RewardScore] = random(8)+1;

	for(new i  = 0; i < ReactLength; i++)
	{
		 format(ReactionInfo[ReactChars], sizeof(ReactionInfo[ReactChars]), "%s%s", ReactionInfo[ReactChars], ReactionCharacters[random(sizeof(ReactionCharacters))][0]);
    }
    
    format(MainStr, sizeof(MainStr), ""text_white"["text_blue"REACTION"text_white"] The first player to type "text_red"'%s'"text_white" wins score "text_red"%i"text_white" and cash "text_red"$%s", ReactionInfo[ReactChars], ReactionInfo[RewardScore], Currency(ReactionInfo[RewardCash]) );
    SCMToAll(-1, MainStr);

    ReactionInfo[TickCount] = GetTickCount(); 
	ServerVars[Server_ReactionTimerEnd] = SetTimer("ReactionEnd", Reaction_End, false);
	return 1;
}

publicEx ReactionEnd()
{

    if(!ReactionInfo[Started]) return 1;
    
    format(MainStr, sizeof(MainStr), ""text_white"["text_blue"REACTION"text_white"] No one has won the reaction test. Reaction Test Ended! ");
    SCMToAll(-1, MainStr);
    ReactionInfo[TickCount] = 0;
    KillTimer(ServerVars[Server_ReactionTimerEnd]);
    ReactionInfo[Started] = false;
	return 1;
}

