--[[----------------------------------------------------------------------------------
	NazGuildRecruiter Core addon
	
	TODO:  Respond with a WHISPER to a "who's online, are you enabled, and what guild are you attuned to?"  Preferrably even if disabled, this will help guild leaders test it for their members.
            Add Ability_Warrior_RallyingCry as the LDB icon
            Ace2 -> Ace3/LibStub
            Remove need for RollCall
------------------------------------------------------------------------------------]]

local L = LibStub("AceLocale-3.0"):GetLocale("NazGuildRecruiter")
local ZBZ = LibStub("LibBabble-Zone-3.0")
local Z = ZBZ:GetLookupTable()
local ZR = ZBZ:GetReverseLookupTable()
local rollcall = AceLibrary("RollCall-1.0")
local dewdrop = AceLibrary("Dewdrop-2.0")

local city = {}

--[[----------------------------------------------------------------------------------
	Notes:
	* Returns true if player is in city, false otherwise
------------------------------------------------------------------------------------]]
local function IsCity()
    zone=GetZoneText()
    if city[zone] == 1 then --already checked and this zone is a city
        return true
    elseif city[zone] == 0 then --already checked and this zone is not a city
        return false
    else
        local channels = { EnumerateServerChannels() }
        for i, v in ipairs(channels) do
            if v == L["GuildRecruitment"] then --if we have a GuildRecruitment channel then we are in a city
                city[zone] = 1
                return true
            end
        end --if we got through all the channels then we aren't in a city so . . .
        city[zone] = 0
        return false
    end
end

local options = { 
    type='group',
    args = {
		attune = {
			type = 'execute',
			name = L["Attune"],
			desc = L["Attune NazGuildRecruiter to your current guild."],
			disabled = function()
								if NazGuildRecruiter:GetGuildName() ~= NazGuildRecruiter.db.profile.guild then --not attuned to your current guild
									return false
								else
									return true
								end
							end,
			func = 	function()
							NazGuildRecruiter:Print(gsub(L["NazGuildRecruiter is now attuned to GUILDNAME"], 'GUILDNAME', NazGuildRecruiter.db.profile.guild, 1))
							NazGuildRecruiter.db.profile.guild = NazGuildRecruiter:GetGuildName()
							if not NazGuildRecruiter:IsActive() then 
								NazGuildRecruiter:ToggleActive(true)
								NazGuildRecruiter:Print(L["Turning myself on"])
							end
						end,
			confirm = true,
			order = 1,
		},
		lastspam = {
			type = 'execute',
			name = L["Last time spammed in zone"],
			desc = L["Spit out to chat the last time someone in this guild has spammed in this zone"],
			func = 	function()
							local currentzone
							if IsCity() then --This zone is a city so treat all cities as one
								currentzone = "City"
							else
                                currentzone = ZR[GetZoneText()]
                            end
							NazGuildRecruiter:Print(gsub(L["The last time spammed in this zone was NUMMINUTES minutes ago"], "NUMMINUTES", tostring(tonumber(NazGuildRecruiter:GetTime()) - tonumber(NazGuildRecruiter.db.profile.lasttime[currentzone]))))
						end,
			order = 1,
		},
		msg = {
            type = 'text',
            name = L["Message"],
            desc = L["The message text to be displayed"],
            usage = L["<Your message here>"],
            get = function()
						return NazGuildRecruiter.db.profile.message
					end,
            set = function(newValue)
						NazGuildRecruiter.db.profile.message = newValue
					end,
			order = 5,
        },
		interval = {
			type = 'range',
			name = L["Interval"],
			desc = L["The amount of minutes between spammings in a particular location"],
			usage = L["<minutes here>"],
			min = 15,
			max = 120,
			step = 1,			
			get = function()
						return NazGuildRecruiter.db.profile.between
					end,
			set = function(newValue)
						NazGuildRecruiter.db.profile.between = newValue
					end,
			order = 10,
		},
		cityspam = {
			type = 'toggle',
			name = L["CitySpam Enabled?"],
			desc = L["Should I spam in cities?"],
			get = function()
						return NazGuildRecruiter.db.profile.cityspam
					end,
			set = function(newValue)
						NazGuildRecruiter.db.profile.cityspam = newValue
					end,
			map = { [false] = L["Disabled"], [true] = L["Enabled"] },
			order = 15,
		},
		motdcycle = {
			type = 'group',
			name = L["MOTD cycler"],
			desc = L["Cycles into guildchat the MOTD periodically"],
			order = 30,
			args = {
				toggle = {
					type = 'toggle',
					name = L["Enabled?"],
					desc = L["Should I cycle the message of the day?"],
					get = function()
								return NazGuildRecruiter.db.profile.motdcycle
							end,
					set = function(newValue)
								NazGuildRecruiter.db.profile.motdcycle = newValue
							end,
					map = { [false] = L["Disabled"], [true] = L["Enabled"] },
					order = 31,
				},
				cycletime = {
					type = 'range',
					name = L["Cycle interval"],
					desc = L["How many minutes between Spamming the message of the day in guildchat?"],
					min = 30,
					max = 240,
					step = 5,			
					disabled = function()
										if NazGuildRecruiter.db.profile.motdcycle then --cycle
											return false
										else
											return true
										end
									end,
					get = function()
								return NazGuildRecruiter.db.profile.cycletime
							end,
					set = function(newValue)
								NazGuildRecruiter.db.profile.cycletime = newValue
							end,
					order = 32,
				},
			},
		},
		zonespam = {
			type = 'toggle',
			name = L["ZoneSpam Enabled?"],
			desc = L["Should I spam in regular zones?"],
			get = function()
						return NazGuildRecruiter.db.profile.zonespam
					end,
			set = function(newValue)
						NazGuildRecruiter.db.profile.zonespam = newValue
					end,
			map = { [false] = L["Disabled"], [true] = L["Enabled"] },
			order = 20,
		},
		levels = {
			type = 'group',
			name = L["Range of levels you are recruiting"],
			desc = L["only applicable if zonespam is checked"],
			disabled = function()
								if NazGuildRecruiter.db.profile.zonespam then return false end
								return true
							end,
			order = 25,
			args = {
				minlevel = {
					type = 'range',
					name = L["Minimum"],
					desc = L["The minimum level of people you are looking for (used when zonespamming so you don't spam the wrong zone)"],
					usage = L["<minumum level>"],
					min = 1,
					max = 70,
					step = 1,			
					get = function()
								return NazGuildRecruiter.db.profile.minlevel
							end,
					set = function(newValue)
								if newValue > NazGuildRecruiter.db.profile.maxlevel then
									NazGuildRecruiter:Print(L["Cannot set a minimum level higher than the maximum"])
								return
								end
								NazGuildRecruiter.db.profile.minlevel = newValue
							end,
					order = 26,
				},
				maxlevel = {
					type = 'range',
					name = L["Maximum"],
					desc = L["The maximum level of people you are looking for (used when zonespamming so you don't spam the wrong zone)"],
					usage = L["<maximum level>"],
					min = 1,
					max = 70,
					step = 1,			
					get = function()
								return NazGuildRecruiter.db.profile.maxlevel
							end,
					set = function(newValue)
								if newValue < NazGuildRecruiter.db.profile.minlevel then
									NazGuildRecruiter:Print(L["Cannot set a maximum level lower than the minimum"])
									return
								end
								NazGuildRecruiter.db.profile.maxlevel = newValue
							end,
					order = 27,
				},
			},
		},
	},
}

NazGuildRecruiter = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0", "AceComm-2.0")
NazGuildRecruiter:RegisterChatCommand(L["Slash-Commands"], options)
NazGuildRecruiter:SetCommPrefix("NazGuildRecruiter")
NazGuildRecruiter:SetDefaultCommPriority("BULK")

local tabfinal = {}
local motdcount
local zones = NGR_Zones

local t1
local function SetLayout(this)
  dewdrop:Close()  -- closes any open dewdrop menu when switching
  if not t1 then
    -- title text
    t1 = this:CreateFontString(nil, "ARTWORK")
    t1:SetFontObject(GameFontNormalLarge)
    t1:SetJustifyH("LEFT") 
    t1:SetJustifyV("TOP")
    t1:SetPoint("TOPLEFT", 16, -16)
    t1:SetText(this.name)

    -- description text
    local t2 = this:CreateFontString(nil, "ARTWORK")
    t2:SetFontObject(GameFontHighlightSmall)
    t2:SetJustifyH("LEFT") 
    t2:SetJustifyV("TOP")
    t2:SetHeight(43)
    t2:SetPoint("TOPLEFT", t1, "BOTTOMLEFT", 0, -8)
    t2:SetPoint("RIGHT", this, "RIGHT", -32, 0)
    t2:SetNonSpaceWrap(true)
    local function GetInfo(field)
      return GetAddOnMetadata(this.addon, field) or "N/A"
    end
    t2:SetFormattedText("Notes: %s\nAuthor: %s\nVersion: %s\nRevision: %s", GetInfo("Notes"), GetInfo("Author"), GetInfo("Version"), GetInfo("X-Build"))

    -- general button
    local b = CreateFrame("Button", nil, this, "UIPanelButtonTemplate")
    b:SetWidth(120)
    b:SetHeight(20)
    b:SetText("Options Menu")
    b:SetScript("OnClick", NazGuildRecruiter.DewOptions)  -- your options function here
    b:SetPoint("TOPLEFT", t2, "BOTTOMLEFT", -2, -8)
  end
end

function NazGuildRecruiter:DewOptions()
	dewdrop:Open('dummy', 'children', function() dewdrop:FeedAceOptionsTable(options) end, 'cursorX', true, 'cursorY', true)
end

local function CreateUIOptionsFrame(addon)  -- call from your load function, using your addon's name
  local panel = CreateFrame("Frame")
  panel.name = GetAddOnMetadata(addon, "Title") or addon
  panel.addon = addon
  panel:SetScript("OnShow", SetLayout)
  InterfaceOptions_AddCategory(panel)
end

--Reusable Functions

--[[----------------------------------------------------------------------------------
	Notes:
	* Removes a table row given the row's value
	Inputs:
		*table - table to remove the value from
		*value - value to remove
	Returns:
	* bool - true if found, failed if not found
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:tremovebyval(tab, val)
   for k,v in pairs(tab) do
     if(v==val) then
       table.remove(tab, k)
       return true
     end
   end
   return false
 end
 
 --[[----------------------------------------------------------------------------------
	Notes:
	* Get guild name
	Inputs:
		* none
	Returns:
	* string - your guild name
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:GetGuildName()
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
	return guildName
 end

 --[[----------------------------------------------------------------------------------
	Notes:
	*	Checks to see if the recommended zone levels are within our specified range
		I iterate in the offchance that you have selected, for example level of 56-56
		and the recommended levels are 50-60, this is the only way to be sure that it
		returns true
	Returns:
	* bool - true if appropriate level, failed if not
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:Recommended()
    if not zones[zone] then return false end -- return false if we have no info for the zone
	local zone = GetZoneText()
    local low = zones[zone].low or 0
    local high = zones[zone].high or 0
    if low < self.db.profile.minlevel and high >= self.db.profile.minlevel then
        return true
    elseif high > self.db.profile.maxlevel and low <= self.db.profile.maxlevel then
        return true
    elseif low >= self.db.profile.minlevel and high <= self.db.profile.maxlevel then
        return true
    elseif low == self.db.profile.minlevel or low == self.db.profile.maxlevel or high == self.db.profile.minlevel or high == self.db.profile.maxlevel then
        return true
    else
        return false --none of the levels recommended is within our range, so return false
    end
end
 
--[[----------------------------------------------------------------------------------
	Notes:
	* Checks to see if you should spam or not based on timestamps
	Inputs:
		*string - zone to check for
	Returns:
	* bool - true if long enough, failed if not
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:CheckTime(zone)
	if type(self.db.profile.lasttime) ~= "table" then self.db.profile.lasstime = {} end --fix a corrupted variable from another user
    if zone ~= "City" then
        zone = ZR[zone]
    end
	if self.db.profile.lasttime[zone] == nil then self.db.profile.lasttime[zone] = 0 end --cannot perform arithmatic on a nil value
	local diff = self:GetTime() - self.db.profile.lasttime[zone]
	if diff < -3000 then --It is new year YAY!
		self.db.profile.lasttime[zone] = self:GetTime() --set the last spamming to be at midnight New Years Eve or the current time if this gets called in error
	elseif diff >= self.db.profile.between then --It has been long enough
		return true
	end
	return false
 end
 
--[[----------------------------------------------------------------------------------
	Notes:
	* Combines two tables, returns the synthesis
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:combinetable(tab1, tab2, diff)
	tabfinal = {}
    for zone, time in pairs(tab1) do --iterate through and adjust their diff (this is to hopefully fix different time settings mucking things up)
        tab2[zone] = time + diff
    end
	for zone, time in pairs(tab1) do --iterate through the first table
		if tab2[zone] == nil then --in first table not second
			tabfinal[zone] = time --add the first zone to the final table
		elseif tab2[zone] >= time then --second table is the highest
			tabfinal[zone] = tab2[zone] --add the second zone to the final table
		else -- must mean that the first table is the highest
			tabfinal[zone] = time
		end
		tab1[zone] = nil -- empty out that zones data as it's now dealt with
		tab2[zone] = nil
	end
	for zone, time in pairs(tab2) do --iterate though anything left in the second table
		tabfinal[zone] = time --add whatever is left to the final table
	end
	return tabfinal
end

--[[----------------------------------------------------------------------------------
	Notes:
	* This checks to see if it's been cycletime from lastcycletime, if so
		cycle and record lastcycletime.
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:motdcycler()
	if self.db.profile.motdcycle and CanEditMOTD()  then --If you cannot edit the MOTD or have disabled the option, then do nothing silly
		local now = self:GetTime() -- save the timestamp for now so we can use it 2x later
		if self.db.profile.lastcycletime - now > 3000 then self.db.profile.lastcycletime = 0 end --check for very bad data
        if (self.db.profile.lastcycletime + self.db.profile.cycletime) <= now then -- It's been long enough so cycle silly
			self:SendCommMessage("GUILD", self.version, "cycled", "",self.db.profile.lastcycletime) -- let the world know I'm cycling
			GuildSetMOTD(GetGuildRosterMOTD()) -- set it to the same as it was
			self.db.profile.lastcycletime = now -- record the new time
		end
	end
end

--[[----------------------------------------------------------------------------------
	Notes:
	* Returns the server time in the minutes since newyears
	Inputs:
		* none
	Returns:
	* string - timestamp
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:GetTime()
	local localOffset
	local loc = tonumber(date("%H"))
	local utc = tonumber(date("!%H"))
	localOffset = loc - utc
	if localOffset >= 12 then
		localOffset = localOffset - 24
	elseif localOffset < -12 then
		localOffset = localOffset + 24
	end
	local serverHour, serverMinute = GetGameTime()
	local Lyday = tonumber(date("%j"))
	if localOffset + utc > 24 then
		Lyday = Lyday - 1
	elseif localOffset + utc < 0 then
		Lyday = Lyday + 1
	end
	return (Lyday*1440)+(serverHour*60)+(serverMinute)
end

--Setup functions

--[[----------------------------------------------------------------------------------
	Notes:
	* Sets up the addon, called on Enable
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("NazScroogeDB", {}, "Default")
    self.db:RegisterDefaults({
        profile = {
            message = "Nazg\195\186l is currently recruiting all levels and classes! We are a casual leveling guild just looking to have a good time and get to that almighty level 70. Whisper me for more info, or an invite!",
            between = 30,
            cityspam = true,
            zonespam = true,
            maxlevel = 55,
            minlevel = 1,
            lasttime = {},
            motdcycle = true,
            cycletime = 45,
            lastcycletime = 0,
            guild = "None",
        },
    })
	if not self.version then self.version = tonumber(GetAddOnMetadata("NazGuildRecruiter", "Version")) end --pull version from toc
	if not self.revision then self.revision = tonumber(GetAddOnMetadata("NazGuildRecruiter", "Revision")) end --pull revision from toc
    CreateUIOptionsFrame('NazGuildRecruiter')
end

function NazGuildRecruiter:OnEnable()
    motdcount = 0
	if IsInGuild() then else -- make sure you are in a guild
		self:Print(L["You are not in a guild, disabling myself"])
		self:ToggleActive(false) -- shut yourself off if not
		return
	end
	
	if self:GetGuildName() == nil then --too soon to check for right guild (returns nil once and a while for a short time) so try again in .1 sec
		self:ScheduleEvent("Enable", function () self:OnEnable() end, .1)
		return
	end
	
	if self:GetGuildName() ~= self.db.profile.guild then --You are attempting to use this addon attuned to a different guild
		self:Print(gsub(gsub(L["Shutting myself off since you are in nowguild and attuned to differentguild.  To attune to your current guild please type \"/ngr attune\""], "nowguild", self:GetGuildName()), "differentguild", NazGuildRecruiter.db.profile.guild))
		self:ToggleActive(false) -- turn yourself off
		return
	end
	local num, name = GetChannelName(L["GuildRecruitment"] .. " - " .. L["City"])
	self.grchannel = name and num --Sets GuildRecruitment channel number variable (name returns nil if not joined, num always returns something)
	num, name = GetChannelName(GENERAL .. " - " .. GetZoneText()) --Sets the General channel number variable
	self.genchannel = name and num
	self.rctr = {} --Sets up an empty table for the recruiters online
	self.online = {} --Sets up an empty table for the other users online
	self.afkdnd = false --Sets the afkdnd flag to false
	self:RegisterMyself() --Start the registration process
end

--[[----------------------------------------------------------------------------------
	Notes:
	* Registers yourself with the others running the addon and recieves the time tables, etc
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:RegisterMyself()
	self:RegisterComm(self.commPrefix, "GUILD", "ReceiveGuildMessage") --Register to receive guild addon messages
	self:RegisterComm(self.commPrefix, "WHISPER", "ReceiveWhisperMessage") --Register to receive whisper addon messages
	if CanGuildInvite() then --If you are an recruiter
		self:SendCommMessage("GUILD", self.version, "Rctr") --Broadcast that you are online
		self:GetList() -- Get the current list from someone else if anyone is online
	else
		self:SendCommMessage("GUILD", self.version, "Who") --Broadcast the request for online recruiters
		self:ScheduleEvent(function() --Call a timeout function
			if #(self.rctr) == 0 then --No responses
				self:TurnSelfOn() --Register for events and go to work!
				return
			else --Got responses of people online
				self:GetList() -- Get the current list from someone else if anyone is online
			end
		end, 60) --timeout function in 60 seconds
	end
end

--[[----------------------------------------------------------------------------------
	Notes:
	* Gets the list of previously spammed areas if anyone is online with a list
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:GetList()
	self:SendCommMessage("GUILD", self.version, "WhoOn") --ask for all online to respond
	self:ScheduleEvent("NGR_TIMEOUT", function() self:Timeout() end, 10) --timeout function in 10 seconds
end

--[[----------------------------------------------------------------------------------
	Notes:
	* Timeout event/function for the "WhoOn" question
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:Timeout()
	if #(self.online) == 0 then --No responses
	    self:TurnSelfOn() --Register for events and go to work!
	else --Got responses, pick one and ask for the list
		local number = ceil(random(#(self.online))) --randomly pick a person who responded
		self:SendCommMessage("WHISPER", self.online[number], self.version, "List") --ask for their copy of the list
		self:ScheduleEvent("NGR_TIMEOUT", function() self:Timeout() end, 10) --timeout function in 10 seconds
	end
end

--Messaging Functions

--[[----------------------------------------------------------------------------------
	Notes:
	* Message handler for GUILD addon messages
	Inputs: 
		* String - prefix - Prefix sent along with the message, can be ignored since this event will not be called with the wrong prefix
		* String - sender - name of the sending person
		* String - distribrution - distribution method, will always be GUILD since this is the only method registered
		* Float - version - version number of the addon sending the message
		* String - action - What action to be taken
		* String - zone - only used with the spammed action
		* String - time - only used with the spammed action
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:ReceiveGuildMessage(prefix, sender, distribution, version, action, zone, time, ...)
	if version == self.version then --version numbers match
		if action == "Rctr" then --A recruiter came online
			tinsert(self.rctr, 1, sender) --Put them into the list
		elseif action == "WhoOn" then --Someone would like to know if you are online
			self:SendCommMessage("WHISPER", sender, self.version, "Online") --respond that I am online
		elseif action ==  "Who" then --Someone would like to know if you are a recruiter
			if CanGuildInvite() then -- you can, so respond
				self:SendCommMessage("WHISPER", sender, self.version, "Rctr")
			end
		elseif action == "Remove" then --A recruiter went offline or AFK/DND
			self:tremovebyval(self.rctr, sender) --remove them from your list
		elseif action == "Recruited" then --Someone spammed
            if zone ~= "City" then
                zone = ZR[zone]
            end
            self.db.profile.lasttime[zone] = self:GetTime() --update the timestamp in the table
        elseif action == "cycled" then --Someone just cycled the MOTD
			self.db.profile.lastcycletime = self:GetTime() -- record it
		end
	else --version numbers do not match
		if (tonumber(version) > tonumber(self.version)) then --sending addon is with a higher version than ours
		self:Print(L["Your version of NazGuildRecruiter is not up to date, please consider upgrading.  Disabling myself."])
		self:ToggleActive(false) -- turn yourself off
		end --if yours is the higher version do nothing (no else statement)
	end
end

--[[----------------------------------------------------------------------------------
	Notes:
	* Message handler for WHISPER addon messages
	Inputs: 
		* String - prefix - Prefix sent along with the message, can be ignored since this event will not be called with the wrong prefix
		* String - sender - name of the sending person
		* String - distribrution - distribution method, will always be WHISPER since this is the only method registered
		* Float - version - version number of the addon sending the message
		* String - action - What action to be taken
		* various - data - Data packet that comes along with the action
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:ReceiveWhisperMessage(prefix, sender, distribution, version, action, lasttime_data, cycle_timestamp, now, ...)
	if version == self.version then --version numbers match
		if action == "Rctr" then --Recruiter has come online
			tinsert(self.rctr, 1, sender) --Put them into the list
		elseif action == "Online" then --Someone said they were online
			tinsert(self.online, 1, sender) --Put them into the list
		elseif action ==  "List" then --Someone would like your zone-time list
			self:SendCommMessage("WHISPER", sender, self.version, "Data", self.db.profile.lasttime, self.db.profile.lastcycletime, self:GetTime()) --Send your list to the person
		elseif action == "Data" then --Someone sent you thier data
			self:CancelScheduledEvent("NGR_TIMEOUT") --Don't timeout since we have the data now
            local diff = self:GetTime() - now --figure out how different our times are
			self.db.profile.lasttime = self:combinetable(self.db.profile.lasttime, lasttime_data, diff) --combine the tables
			if self.db.profile.lastcycletime < cycle_timestamp then --new cycle timestamp is newer than your old one
				self.db.profile.lastcycletime = cycle_timestamp -- this is the last MOTD cycle time
			end
			self:TurnSelfOn() --Register for events and go to work!
		end
	else --version numbers do not match
		if (version > self.version) then --sending addon is with a higher version than ours
		self:Print(L["Your version of NazGuildRecruiter is not up to date, please consider upgrading.  Disabling myself."])
		self:ToggleActive(false) -- turn yourself off
		end --if yours is the higher version do nothing (no else statement)
	end
end

--Repeating/Working functions

--[[----------------------------------------------------------------------------------
	Notes:
	* Registers for the events
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:TurnSelfOn()
	if not self.grchannel and self.db.profile.cityspam then --don't know what the GR channel number is and am supposed to be using it. . . 
		if IsCity() then --yup we are actually in a city . . . so that must mean we havne't joined the channel yet
			if JoinChannelByName(L["GuildRecruitment"] , nil, ChatFrame1:GetID()) then --were we able to successfully join the channel?
				self.grchannel = GetChannelName(L["GuildRecruitment"] .. " - City") -- get the new index
			else -- too many channels
				self:Print(L["Cannot join the GuildRecruitment channel, turning cityspam off"])
				self.db.profile.cityspam = false
			end
		end
	end
	if not self.genchannel and self.db.profile.zonespam then --don't know what the gen channel number is and am supposed to be using it . . . 
		self.genchannel = GetChannelName(GENERAL .. " - " .. GetZoneText()) -- recheck to see if we can find the channel number again
		if self.genchannel == 0 then -- didn't get back good data, must not be joined
			if JoinChannelByName(GENERAL, nil, ChatFrame1:GetID()) then --were we able to successfully join the channel?
				self.grchannel = GetChannelName(GENERAL .. " - " .. GetZoneText()) --ok what number is it?
			else --too many channels
				self:Print(L["Cannot join the General channel, turning zonespam off"])
				self.db.profile.zonespam = false
			end
		end
	end
	self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE") --Called whenever you join or leave a channel
	self:RegisterEvent("CHAT_MSG_SYSTEM") --Called whenever you go AFK/DND or return from it
	self:RegisterEvent("PLAYER_FLAGS_CHANGED") --Called whenever you go AFK/DND or return from it
	if CanGuildInvite() then --If you are an recruiter
		tinsert(self.rctr, 1, (UnitName("player"))) --Add yourself to the recruiter list
	end
	self:ScheduleRepeatingEvent("NGR_TIMERFUNCTION", function() self:Timer()  end, 30) --Called every 30 seconds
	self:Print(L["Setup complete, Ready to start recruiting"])
end

--[[----------------------------------------------------------------------------------
	Notes:
	* Is called every 30 seconds
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:Timer()
	if self.afkdnd then return end --if afk do nothing
	if #(self.rctr) ~= 0 then--We have recruiters in our list who are not afk or dnd
		local zone = GetZoneText() --Get the zonetext and save it for use throughout the function
        local inInstance, instanceType = IsInInstance()
		if not inInstance then
			if IsCity() then --This zone is a city so treat all cities as one
				if not self.db.profile.cityspam then return end --if not supposed to spam in cities, end now
				zone = "City"
			elseif not self.db.profile.zonespam then return --not a city, so if we aren't supposed to spam elsewhere end now
			end
			if self:CheckTime(zone) then--Check to see if it has been long enough in the current zone
				self:SpamZone(zone) --Spam man, Spam away
			end
		end
	end
    if motdcount >= 9 then 
        self:motdcycler()
    end
    motdcount = motdcount + 1
end

--[[----------------------------------------------------------------------------------
	Notes:
	* This is called every time you join or leave a channel
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:CHAT_MSG_CHANNEL_NOTICE(what, a, b, c, d, e, f, number, channel)
	if strsub(channel, 0, strlen(GENERAL)) == GENERAL then --changed the general channel
		self:ScheduleEvent(function() self:Timer() end, 5) --Call the Timer even to check for spamming, etc. in 5 seconds time (otherwise it was spamming right before actually changing channel
	elseif not self.grchannel and channel == L["GuildRecruitment"] .. " - " .. L["City"] and what == "YOU_JOINED" then --Joined the GuildRecruitment channel
		self.grchannel = number
	end
end

--[[----------------------------------------------------------------------------------
	Notes:
	* This is to check for going into AFK or DND mode
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:PLAYER_FLAGS_CHANGED()
    if UnitIsAFK("player") or UnitIsDND("player") then --You went AFK or DND
		self.afkdnd = true
		if CanGuildInvite() then --If you are a recruiter
			self:SendCommMessage("GUILD", self.version, "Remove") --Ask to be removed from any recruiter list
		end
	end
end

--[[----------------------------------------------------------------------------------
	Notes:
	* This is to check for leaving AFK or DND mode
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:CHAT_MSG_SYSTEM(msg)
    if msg == CLEARED_AFK or msg == CLEARED_DND then --You came back from AFK or DND
		if CanGuildInvite() then --If you are a recruiter
			self:SendCommMessage("GUILD", self.version, "Rctr") --Let people know you are back
		end
		self.afkdnd = false
	end
end

--[[----------------------------------------------------------------------------------
	Notes:
	* This is the actual spam function
	Inputs:
		*string - zone - zone we are spamming for
------------------------------------------------------------------------------------]]
function NazGuildRecruiter:SpamZone(zone)
	if not self:Recommended() and zone ~= "City" then return end --if this isn't the right level zone do nothing
	for s, name in pairs(NazGuildRecruiter.rctr) do --Iterate through the recruiter list and check for people who are offline
		if rollcall:IsMemberOnline(name) then --Yes this one is online
			if zone == "City" then --We are in a city so spam the GuildRecruitment channel instead
				number = self.grchannel
			else --OK not a city so . . . 
                zone = ZR[zone]
				number = self.genchannel
			end
			if number == 0 then return end--Don't know the channel number so don't do anything
			if not (GetZoneText() == zone or zone == "City") then return end --exit out of the function period if we aren't in the same zone again (ie just popped in and out of a zone)
			SendChatMessage(self.db.profile.message,"CHANNEL",nil,number) --send message
			self.db.profile.lasttime[zone] = self:GetTime() --set the timestamp to the current time
			self:SendCommMessage("GUILD", self.version, "Recruited", zone, self.db.profile.lasttime[zone]) --Send message saying you spammed
			return --don't check any more people
		end
	end
end