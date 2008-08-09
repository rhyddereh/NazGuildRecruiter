NazGuildRecruiter is a wow addon to help in guild recruitment. It is coded with Ace2 Libraries, this was created for the guild Nazgûl on Altar of Storms and the default message is ours (if you are part of a different guild be sure to change it and attune to the new guild). 

Features:


	Needs to be attuned to your guild before it will work, and afterwards will not spam for any other guilds you may be part of (on alts, different servers, etc.) 
	Uses GuildRecruitment channel in all cities 
	Skips Instances and Battlegrounds 
	Spams upon zone entrance and periodically when questing in zones (based on minimum and maximum recommended level of the zone, for example if you do not want lowbies it will skip durotar, etc.) 
	Will only spam if someone who can invite and has this addon is online (if you cannot invite yourself) 
	Coordinates with everyone else who has this addon so you don't overspam a zone 
	Cycles the Guild Message of the day periodically if you have permissions to do so and that option is selected

Getting Started:


	1. Type /ngr msg <your spam here> - this will set the spam message 
	2. Change any other behavior you wish using the commands below 
	3. Type /ngr attune - this will attune the addon to your current guild and go to work 

Commands:


	/ngr - shows available commands 
	/ngr attune - attunes the addon to your current guild 
	/ngr msg <your message here> - Changes the message to spam
	/ngr interval ## - replace ## with the number of minutes between spammings in a particular zone
	/ngr cityspam - toggles spamming via the guild recruitment channel in cities (you need to be joined of course) 
	/ngr zonespam - toggles spamming via general in regular zones 
	/ngr levels minimum ## - set the minimum level you want to recruit (used to determine which zone to spam in, only means anything if zonespam is toggled on) 
	/ngr levels maximum ## - set the maximum level you want to recruit (used to determine which zone to spam in, only means anything if zonespam is toggled on)
	/ngr motdcycle toggle - enable/disable Cycling of the Message of the day to guildchat
	/ngr motdcycle interval ## - replace ## with the number of minutes between cycling the Message of the day
	/ngr standby - suspends this addon 
	/ngr profile reset - resets to defaults