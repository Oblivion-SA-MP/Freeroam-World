#include <YSI\y_hooks>

#define Maths_Interval 300000 // 5 mins

enum MathsEnum {
  
   bool:MathsAnswered,
   MathsReward,
   MathsAnswer,
   MathsTickCount,
   MathsCurrent[15]
};

new MathsInfo[MathsEnum];


hook OnGameModeInit()
{

    ServerVars[Server_MathsTimer] =  SetTimer("MathsTest", Maths_Interval, true);
	return 1;
}

hook OnGameModeExit()
{
    MathsInfo[MathsAnswered] = true;
    KillTimer(ServerVars[Server_MathsTimer]);
	return 1;
}


publicEx MathsTest()
{
   
   	if(!MathsInfo[MathsAnswered])
	{
		format(MainStr, sizeof(MainStr), ""text_white"["text_yellow"MATHS"text_white"] Previous question wasn't answered "text_yellow"(right answer was %d)", MathsInfo[MathsAnswer]);
		SCMToAll(-1, MainStr);
	}
   
    new randnum1 = random(100), randnum2 = random(100), randnum3 = random(100),
	OP1 = random(3),OP2 = random(3),
	FOP1[2], FOP2[2];
	
    MathsInfo[MathsTickCount] = 0;
    MathsInfo[MathsAnswer] = 0;
    MathsInfo[MathsAnswered] = false;
    MathsInfo[MathsReward] = 0;

    // 0 = -
    // 1 = +
    // 2 = *

	switch(OP1)
	{
		case 0:
        {
        	format(FOP1, sizeof(FOP1), "-");
        	MathsInfo[MathsReward] = MathsInfo[MathsReward] + 2500;
            switch(OP2)
            {
            	case 0:
                {
                	format(FOP2, sizeof(FOP2), "-");
                    MathsInfo[MathsAnswer] = randnum1-randnum2-randnum3;
                    MathsInfo[MathsReward] = MathsInfo[MathsReward] + 2500;
             	}
                case 1:
                {
                	format(FOP2, sizeof(FOP2), "+");
                    MathsInfo[MathsAnswer] = randnum1-randnum2+randnum3;
                    MathsInfo[MathsReward] = MathsInfo[MathsReward] + 2000;
                }
                case 2:
                {
                	format(FOP2, sizeof(FOP2), "*");
                	MathsInfo[MathsAnswer] = randnum1-randnum2*randnum3;
                	MathsInfo[MathsReward] = MathsInfo[MathsReward] + 3500;
            	}
          	}
 		}
  		case 1:
    	{
     		format(FOP1, sizeof(FOP1), "+");
			MathsInfo[MathsReward] = MathsInfo[MathsReward] + 2000;
            switch(OP2)
			{
   				case 0:
                {
                	format(FOP2, sizeof(FOP2), "-");
                    MathsInfo[MathsAnswer] = randnum1+randnum2-randnum3;
                    MathsInfo[MathsReward] = MathsInfo[MathsReward] + 2500;
                }
                case 1:
                {
                	format(FOP2, sizeof(FOP2), "+");
                    MathsInfo[MathsAnswer] = randnum1+randnum2+randnum3;
                    MathsInfo[MathsReward] =MathsInfo[MathsReward]+ 2000;
                }
                case 2:
                {
                	format(FOP2, sizeof(FOP2), "*");
                	MathsInfo[MathsAnswer] = randnum1+randnum2*randnum3;
                	MathsInfo[MathsReward] = MathsInfo[MathsReward] + 3500;
           		}
			}
		}
		case 2:
		{
			format(FOP1, sizeof(FOP1), "*");
			MathsInfo[MathsReward] = MathsInfo[MathsReward] + 3500;
			switch(OP2)
			{
				case 0:
				{
					format(FOP2, sizeof(FOP2), "-");
					MathsInfo[MathsAnswer] = randnum1*randnum2-randnum3;
					MathsInfo[MathsReward] = MathsInfo[MathsReward] + 2500;
				}
				case 1:
				{
					format(FOP2, sizeof(FOP2), "+");
					MathsInfo[MathsAnswer] = randnum1*randnum2+randnum3;
					MathsInfo[MathsReward] = MathsInfo[MathsReward] + 2000;
				}
				case 2:
				{
					format(FOP2, sizeof(FOP2), "x");
					MathsInfo[MathsAnswer] = randnum1*randnum2*randnum3;
					MathsInfo[MathsReward] = MathsInfo[MathsReward] + 3500;
				}
			}
		}
	}
	format(MathsInfo[MathsCurrent], sizeof(MathsInfo[MathsCurrent]), "%i%s%i%s%i", randnum1, FOP1, randnum2, FOP2, randnum3);

	format(MainStr, sizeof(MainStr), ""text_white"["text_yellow"MATHS"text_white"] Calculate "text_red"%s "text_white"and write /ans <answer> "text_yellow"(Score: 10 | Cash: $%s)", MathsInfo[MathsCurrent], Currency(MathsInfo[MathsReward]));
	SCMToAll(-1, MainStr);

	MathsInfo[MathsTickCount] = GetTickCount();
	return 1;
}

CMD:ans(playerid, params[])
{
	if(!MathsInfo[MathsAnswered])
	{
	    SCM(playerid, -1, ""text_white"["text_yellow"MATHS"text_white"] Sorry, not maths is in progress!");
	    return true;
	}
	new mathsanswer;
	if(sscanf(params, "i", mathsanswer))
	{
	    SCM(playerid, msg_yellow, "/ans <answer>");
	    return true;
	}


	if(MathsInfo[MathsAnswered])
	{
	    if(mathsanswer == MathsInfo[MathsAnswer])
	    {
	    	format(MainStr, sizeof(MainStr), ""text_white"["text_yellow"MATHS"text_white"] Sorry, you're too late, although your answer(%d) would have been right!", mathsanswer);
 		}
		else
		{
		    format(MainStr, sizeof(MainStr), ""text_white"["text_yellow"MATHS"text_white"] Sorry, you're too late, even though your answer(%d) would have been wrong!", mathsanswer);
		}
		SCM(playerid, -1, MainStr);
	    return true;
	}

	if(mathsanswer > MathsInfo[MathsAnswer] || mathsanswer < MathsInfo[MathsAnswer])
	{
	    format(MainStr, sizeof(MainStr), ""text_white"["text_yellow"MATHS"text_white"] Sorry, your answer(%d) to %s is wrong!", mathsanswer, MathsInfo[MathsCurrent]);
	    SCM(playerid, -1, MainStr);
		return true;
	}
	
	// Calculate seconds and milliseconds from tickcount
	new mathstime = GetTickCount() - MathsInfo[MathsTickCount],
	mathssecond = mathstime / 1000;
	mathstime = mathstime - mathssecond * 1000;

	format(MainStr, sizeof(MainStr),""text_white"["text_yellow"MATHS"text_white"] {%06x}%s(%i) "text_white"has correctly answered %s (answer: %d) in %2d.%03d seconds!", PlayerColor(playerid), PlayerInfo[playerid][Player_Name], playerid, MathsInfo[MathsCurrent], mathsanswer, mathssecond, mathstime);
	SCMToAll(-1, MainStr);

	format(MainStr,sizeof(MainStr), "-> You earned +4 score and $%s cash", Currency(MathsInfo[MathsReward]));
    SCM(playerid, msg_yellow, MainStr);


	format(MainStr, sizeof(MainStr), "~y~Points~w~:~n~  ~b~Score~w~: ~g~+10~n~  ~g~~h~Cash~w~: ~g~+$%s", Currency(MathsInfo[MathsReward]));
	PlayerPoints(playerid,MainStr);

	PlayerInfoTD(playerid, "~w~You won the ~r~maths test", 4000);

	SendPlayerScore(playerid, 10);
	SendPlayerScore(playerid, MathsInfo[MathsReward]);


	MathsInfo[MathsAnswered] = true;

	format(MainStr, sizeof(MainStr), "Won a math challenge.");
	SetPlayerChatBubble(playerid, MainStr, msg_green, 40.0, 5000);
	return true;
}