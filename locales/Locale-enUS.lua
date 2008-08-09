local L = AceLibrary("AceLocale-2.2"):new("NazGuildRecruiter")

L:RegisterTranslations("enUS", function() return {
    ["Slash-Commands"] = {"/NazGuildRecruiter", "/ngr"},
    ["Attune"] = true,
    ["Attune NazGuildRecruiter to your current guild."] = true,
    ["NazGuildRecruiter is now attuned to GUILDNAME"] = true, --make sure you use the word GUILDNAME unlocalized
    ["Turning myself on"] = true,
    ["Last time spammed in zone"] = true,
    ["Spit out to chat the last time someone in this guild has spammed in this zone"] = true,
    ["The last time spammed in this zone was NUMMINUTES minutes ago"] = true, --make sure you use the word NUMMINUTES unlocalized
    ["Message"] = true,
    ["The message text to be displayed"] = true,
    ["<Your message here>"] = true,
    ["Interval"] = true,
    ["The amount of minutes between spammings in a particular location"] = true,
    ["<minutes here>"] = true,
    ["CitySpam Enabled?"] = true,
    ["Should I spam in cities?"] = true,
    ["Disabled"] = true,
    ["Enabled"] = true,
    ["MOTD cycler"] = true,
    ["Cycles into guildchat the MOTD periodically"] = true,
    ["Enabled?"] = true,
    ["Should I cycle the message of the day?"] = true,
    ["Cycle interval"] = true,
    ["How many minutes between Spamming the message of the day in guildchat?"] = true,
    ["ZoneSpam Enabled?"] = true,
    ["Should I spam in regular zones?"] = true,
    ["Range of levels you are recruiting"] = true,
    ["only applicable if zonespam is checked"] = true,
    ["Minimum"] = true,
    ["Maximum"] = true,
    ["The minimum level of people you are looking for (used when zonespamming so you don't spam the wrong zone)"] = true,
    ["The maximum level of people you are looking for (used when zonespamming so you don't spam the wrong zone)"] = true,
    ["<minumum level>"] = true,
    ["<maximum level>"] = true,
    ["Cannot set a minimum level higher than the maximum"] = true,
    ["Cannot set a maximum level lower than the minimum"] = true,
    ["You are not in a guild, disabling myself"] = true,
    ["Shutting myself off since you are in nowguild and attuned to differentguild.  To attune to your current guild please type \"/ngr attune\""] = true, --make sure you use the words nowguild and differentguild unlocalized
    ["Your version of NazGuildRecruiter is not up to date, please consider upgrading.  Disabling myself."] = true,
    ["Cannot join the GuildRecruitment channel, turning cityspam off"] = true,
    ["Cannot join the General channel, turning zonespam off"] = true,
    ["Setup complete, Ready to start recruiting"] = true,
    
    --NOTE:  THIS NEXT SECTION MUST BE EXACTLY WHAT YOU SEE WHEN LOGGED INTO THAT LOCALE OR IT WILL BREAK ADDON--
    
    ["City"] = true,
    ["GuildRecruitment"] = true, --name of the channel
} end)