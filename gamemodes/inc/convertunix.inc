#define SPLITTER .

static const MonthTimes[12][4] =
{
	{ 31, 31, 2678400, 2678400 },
	{ 28, 29, 2419200, 2505600 },
	{ 31, 31, 2678400, 2678400 },
	{ 30, 30, 2592000, 2592000 },
	{ 31, 31, 2678400, 2678400 },
	{ 30, 30, 2592000, 2592000 },
	{ 31, 31, 2678400, 2678400 },
	{ 31, 31, 2678400, 2678400 },
	{ 30, 30, 2592000, 2592000 },
	{ 31, 31, 2678400, 2678400 },
	{ 30, 30, 2592000, 2592000 },
	{ 31, 31, 2678400, 2678400 }
};

IsLeapYear(year)
{
	if(year % 4 == 0) return 1;
	else return 0;
}

TimestampToDate(Timestamp, &year, &month, &day, &hour, &minute, &second, HourGMT, MinuteGMT = 0)
{
	new rtmp = 2;
	year = 1970;
	month = 1;
	Timestamp -= 172800; // Delete two days from the current timestamp. This is necessary, because the timestamp retrieved using gettime() includes two too many days.
	for(;;)
	{
		if(Timestamp >= 31536000)
		{
			year ++;
			Timestamp -= 31536000;
			rtmp ++;
			if(rtmp == 4)
			{
				if(Timestamp >= 31622400)
				{
					rtmp = 0;
					year ++;
					Timestamp -= 31622400;
				}
				else break;
			}
		}
		else break;
	}
	for(new i = 0; i < 12; i ++)
	{
		if(Timestamp >= MonthTimes[i][2 + IsLeapYear(year)])
		{
			month ++;
			Timestamp -= MonthTimes[i][2 + IsLeapYear(year)];
		}
		else break;
	}
	day = 1 + (Timestamp / 86400);
	Timestamp %= 86400;
	hour = HourGMT + (Timestamp / 3600);
	Timestamp %= 3600;
	minute = MinuteGMT + (Timestamp / 60);
	second = (Timestamp % 60);
	if(minute > 59)
	{
		minute = 0;
		hour ++;
		if(hour > 23)
		{
			hour -= 24;
			day ++;
			if(day > MonthTimes[month][IsLeapYear(year)])
			{
				day = 1;
				month ++;
				if(month > 12)
				{
					month = 1;
					year ++;
				}
			}
		}
	}
	return 1;
}

ConvertUnix(unixtime)
{
  	new unix_time_str[60],
		unix_time[6];
    TimestampToDate(unixtime, unix_time[0], unix_time[1], unix_time[2], unix_time[3], unix_time[4], unix_time[5], 1);

    format(unix_time_str, sizeof(unix_time_str), "%02i/%02i/%i %02i:%02i:%02i", unix_time[2], unix_time[1], unix_time[0], unix_time[3], unix_time[4], unix_time[5]);
	return unix_time_str;
}