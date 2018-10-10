--- **Functional** - (R2.4) - Carrier CASE I Recovery Practice
-- 
-- Practice carrier landings.
--
-- Features:
--
--    * CASE I recovery.
--    * Performance evaluation.
--    * Feedback about performance during flight.
--
-- Please not that his class is work in progress and in an **alpha** stage.
-- At the moment training parameters are optimized for F/A-18C Hornet as aircraft and USS Stennis as carrier.
-- Other aircraft and carriers **might** be possible in future but would need a different set of parameters.
--
-- ===
--
-- ### Author: **Bankler** (original idea and script)
-- ### Co-author: **funkyfranky** (implementation as MOOSE class)
--
-- @module Functional.CarrierTrainer
-- @image MOOSE.JPG

--- CARRIERTRAINER class.
-- @type CARRIERTRAINER
-- @field #string ClassName Name of the class.
-- @field #string lid Class id string for output to DCS log file.
-- @field #boolean Debug Debug mode. Messages to all about status.
-- @field Wrapper.Unit#UNIT carrier Aircraft carrier unit on which we want to practice.
-- @field Core.Zone#ZONE_UNIT startZone Zone in which the pattern approach starts.
-- @field Core.Zone#ZONE_UNIT giantZone Zone around the carrier to register a new player.
-- @field #table plyers Table of players. 
-- @extends Core.Fsm#FSM

--- Practice Carrier Landings
--
-- ===
--
-- ![Banner Image](..\Presentations\CARRIERTRAINER\CarrierTrainer_Main.png)
--
-- # The Trainer Concept
--
--
-- bla bla
--
-- @field #CARRIERTRAINER
CARRIERTRAINER = {
  ClassName = "CARRIERTRAINER",
  lid       = nil,
  Debug     = true,
  carrier   = nil,
  startZone = nil,
  giantZone = nil,
  players   = nil,
}

--- Carrier trainer class version.
-- @field #string version
CARRIERTRAINER.version="0.0.1"

--- Player data.
-- @type CARRIERTRAINER.PlayerData
-- @field #number id Player ID.
-- @field #string callsign Callsign of player.
-- @field #number score Player score.
-- @field Wrapper.Unit#UNIT unit Aircraft unit of the player.
-- @field #number lowestAltitude Lowest altitude. 
-- @field #number highestCarrierXDiff 
-- @field #number secondsStandingStill Time player does not move after a landing attempt. 

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Constructor
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Create new carrier trainer.
-- @param #CARRIERTRAINER self
-- @param carriername Name of the aircraft carrier unit.
-- @return #CARRIERTRAINER self
function CARRIERTRAINER:New(carriername)

  -- Inherit everthing from FSM class.
  local self = BASE:Inherit(self, FSM:New()) -- #WAREHOUSE

  -- Set carrier unit.
  self.carrier=UNIT:FindByName(carriername)
  
  if self.carrier then
    self.startZone = ZONE_UNIT:New("startZone", self.carrier,  1000, { dx = -2000, dy = 100, relative_to_unit = true })
    self.giantZone = ZONE_UNIT:New("giantZone", self.carrier, 30000, { dx =  0,    dy = 0,   relative_to_unit = true })
  else
    self:E("ERROR: Carrier unit could not be found!")
  end
  
  -- Set some string id for output to DCS.log file.
  self.lid=string.format("CARRIERTRAINER %s | ", carriername)  
  
  -----------------------
  --- FSM Transitions ---
  -----------------------
  
  -- Start State.
  self:SetStartState("Stopped")

  -- Add FSM transitions.
  --                 From State  -->   Event   -->   To State
  self:AddTransition("Stopped",       "Start",      "Running")
  self:AddTransition("Running",       "Status",     "Running")
  self:AddTransition("Running",       "Stop",       "Stopped")


  --- Triggers the FSM event "Start" that starts the carrier trainer. Initializes parameters and starts event handlers.
  -- @function [parent=#CARRIERTRAINER] Start
  -- @param #CARRIERTRAINER self

  --- Triggers the FSM event "Start" after a delay that starts the carrier trainer. Initializes parameters and starts event handlers.
  -- @function [parent=#CARRIERTRAINER] __Start
  -- @param #CARRIERTRAINER self
  -- @param #number delay Delay in seconds.

  --- Triggers the FSM event "Stop" that stops the carrier trainer. Event handlers are stopped.
  -- @function [parent=#CARRIERTRAINER] Stop
  -- @param #CARRIERTRAINER self

  --- Triggers the FSM event "Stop" that stops the carrier trainer after a delay. Event handlers are stopped.
  -- @function [parent=#CARRIERTRAINER] __Stop
  -- @param #CARRIERTRAINER self
  -- @param #number delay Delay in seconds.
  
  return self
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FSM states
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- On after Start event. Starts the warehouse. Addes event handlers and schedules status updates of reqests and queue.
-- @param #CARRIERTRAINER self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function CARRIERTRAINER:onafterStart(From, Event, To)

  -- Events are handled my MOOSE.
  self:I(self.lid..string.format"Starting Carrier Training %s for carrier unit %s.", CARRIERTRAINER.version, self.carrier:GetName())
  
  -- Handle events.
  self:HandleEvent(EVENTS.Birth)


  -- Init status checkss
  self:__Status(-1)
end

--- On after Status event. Checks player status.
-- @param #CARRIERTRAINER self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function CARRIERTRAINER:onafterStatus(From, Event, To)

  -- Check player status.
  self:_CheckPlayerStatus()

  -- Call status again in one second.
  self:_Status(-1)
end

--- On after Stop event. Unhandle events and stop status updates. 
-- @param #CARRIERTRAINER self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function CARRIERTRAINER:onafterStop(From, Event, To)
  self:UnHandleEvent(EVENTS.Birth)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENT functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Carrier trainer event handler for event birth.
-- @param #CARRIERTRAINER self
-- @param Core.Event#EVENTDATA EventData
function CARRIERTRAINER:OnEventBirth(EventData)
  self:F3({eventbirth = EventData})
  
  local _unitName=EventData.IniUnitName
  local _unit, _playername=self:_GetPlayerUnitAndName(_unitName)
  
  self:T3(self.lid.."BIRTH: unit   = "..tostring(EventData.IniUnitName))
  self:T3(self.lid.."BIRTH: group  = "..tostring(EventData.IniGroupName))
  self:T3(self.lid.."BIRTH: player = "..tostring(_playername))
      
  if _unit and _playername then
  
    local _uid=_unit:GetID()
    local _group=_unit:GetGroup()
    local _gid=_group:GetID()
    local _callsign=_unit:GetCallsign()
    
    -- Debug output.
    local text=string.format("Player %s, callsign %s entered unit %s (ID=%d) of group %s", _playername, _callsign, _unitName, _uid, _group:GetName())
    self:T(self.lid..text)
    MESSAGE:New(text, 5):ToAllIf(self.Debug)
    
    local playerdata={} --#CARRIERTRAINER.PlayerData
    
    playerdata.callsign=_callsign
    
    -- By default, some bomb impact points and do not flare each hit on target.
    self.players[_playername]=playerdata
      
    -- Start check in zone timer.
    if self.planes[_uid] ~= true then
      SCHEDULER:New(nil, self._CheckInZone, {self, EventData.IniUnitName}, 1, 1)
      self.planes[_uid] = true
    end
  
  end 
end

--- Initialize player data.
-- @param #CARRIERTRAINER self
-- @param #string unitname Name of the player unit.
-- @return #CARRIERTRAINER.PlayerData Player data.
function CARRIERTRAINER:_NewPlayer(unitname) 
  local playerData = nil
  
  local existingData = playerDatas[id]
  if(existingData and existingData.unit:IsAlive()) then
    playerData = playerDatas[id]
  else  
    playerData = PlayerData:New(id)
  end

  playerData:InitNewRound()

  playerDatas[id] = playerData
  env.info("Created playerData object for " .. playerData.unit.UnitName)
  
  MessageToAll( "Pilot ID: " .. id .. ". Welcome back, " .. playerData.callsign .. "! Cleared for approach! TCN 1X, BRC 354 (MAG HDG).", 5, "InitZoneMessage" )
  
  playerData.step = 1 -- 1 !!
  playerData.highestCarrierXDiff = -9999999
  playerData.secondsStandingStill = 0
  playerData.summary = "SUMMARY:\n"
end

--- Initialize new approach for player
-- @param #CARRIERTRAINER self
function CARRIERTRAINER:_InitNewRound(playerData)
  playerData.score = 0
  playerData.summary = "SUMMARY:\n"
  playerData.step = 0
  playerData.longDownwindDone = false
  playerData.highestCarrierXDiff = -9999999
  playerData.secondsStandingStill = 0
  playerData.lowestAltitude = 999999
end

--- Increase score for this approach.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data.
-- @param #number amount Amount by which the score is increased.
function CARRIERTRAINER:_IncreaseScore(playerData, amount)
  playerData.score = playerData.score + amount
end

--- Append text to summary text.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data.
-- @param #string item Text item appeded to the summary.
function CARRIERTRAINER:_AddToSummary(playerData, item)
  playerData.summary = playerData.summary .. item .. "\n"
end

--- Append text to result text.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data.
-- @param #string item Text item appeded to the result.
function CARRIERTRAINER:_AddToCollectedResult(playerData, item)
  playerData.collectedResultString = playerData.collectedResultString .. item .. "\n"
end


--- Carrier trainer event handler for event birth.
-- @param #CARRIERTRAINER self
function CARRIERTRAINER:_CheckPlayerStatus()

  -- Loop over all players.
  for _playerName,_playerData in pairs(self.Player) do  
    local playerData = _playerData --#CARRIERTRAINER.PlayerData
    
    if playerData then
    
      -- Player unit.
      local unit = playerData.unit
      
      if unit:IsAlive() then

        if unit:IsInZone(self.giantZone) then
          --Tick(playerData)
        end
        
        -- Check long down wind leg.
        if playerData.step == 6 and not playerData.longDownwindDone and unit:IsInZone(self.giantZone) then
          self:_CheckForLongDownwind(playerData)
        end
        
        if playerData.step == 1 and unit:IsInZone(self.startZone) then
          self:_Start(playerData)
        elseif playerData.step == 2 and unit:IsInZone(self.giantZone) then
          self:_Upwind(playerData)
        elseif playerData.step == 3 and unit:IsInZone(self.giantZone) then
          self:_Break(playerData, "early")
        elseif playerData.step == 4 and unit:IsInZone(self.giantZone) then
          self:_Break(playerData, "late")
        elseif playerData.step == 5 and unit:IsInZone(self.giantZone) then
          self:_Abeam(playerData)
        elseif playerData.step == 6 and unit:IsInZone(self.giantZone) then
          self:_Ninety(playerData)
        elseif playerData.step == 7 and unit:IsInZone(self.giantZone) then
          self:_Wake(playerData)
        elseif playerData.step == 8 and unit:IsInZone(self.giantZone) then
          self:_Groove(playerData)
        elseif playerData.step == 9 and unit:IsInZone(self.giantZone) then
          self:_Trap(playerData)
        end         
      else
        --playerDatas[i] = nil
      end
    end
  end
  
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CARRIER TRAINING functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Start landing pattern.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data table.
function CARRIERTRAINER:_Start(playerData)
  local hint = "Entering the pattern, " .. playerData.callsign .. "! Aim for 800 feet and 350-400 kts on the upwind."
  self:_SendMessageToPlayer(hint, 8, playerData)
  playerData.score = 0
  playerData.step = 2
end 
 
--- Upwind leg.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data table.
function CARRIERTRAINER:_Upwind(playerData) 

  -- Player and carrier position vector.
  local position = playerData.unit:GetVec3()  
  local carrierPosition = self.carrier:GetVec3()

  local diffZ = position.z - carrierPosition.z
  local diffX = position.x - carrierPosition.x
  if(diffZ > 500 or diffZ < 0 or diffX < -4000) then
    self:_AbortPattern(playerData)
    return
  end
  
  if (diffX < 0) then
    return
  end
  
  local idealAltitude = 800
  local altitude = UTILS.Round( UTILS.MetersToFeet( position.y ) )

  local hint = ""
  local score = 0

  if(altitude > 850) then
    score = 5
    hint = "You're high on the upwind."
  elseif(altitude > 830) then
    score = 7
    hint = "You're slightly high on the upwind."
  elseif (altitude < 750) then
    score = 5
    hint = "You're low on the upwind."
  elseif (altitude < 770) then
    score = 7
    hint = "You're slightly low on the upwind."
  else
    score = 10
    hint = "Good altitude on the upwind."
  end

  -- Increase score.
  self:_IncreaseScore(playerData, score)
  
  self:_SendMessageToPlayer(hint, 8, playerData)
  
  self:_PrintAltitudeFeedback(altitude, idealAltitude, playerData)
  self:_PrintScore(score, playerData, true)
  
  
  self:_AddToSummary(playerData, hint)
  
  -- Set step.
  playerData.step = 3
end

--- Break.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data table.
-- @param #string part Part of the break.
function CARRIERTRAINER:_Break(playerData, part)  

  local playerPosition = playerData.unit:GetVec3()
  local carrierPosition = self.carrier:GetVec3()

  local diffZ = playerPosition.z - carrierPosition.z
  local diffX = playerPosition.x - carrierPosition.x

  if(diffZ > 1500 or diffZ < -3700 or diffX < -500) then
    self:_AbortPattern(playerData)
    return
  end

  local limit = -370
    
  if (part == "late") then
    limit = -1470
  end

  if diffZ < limit then
    local idealAltitude = 800
    local altitude = UTILS.Round( UTILS.MetersToFeet( playerPosition.y ) )

    local hint = ""
    local score = 0

    if(altitude > 880) then
      score = 5
      hint = "You're high in the " .. part .. " break."
    elseif(altitude > 850) then
      score = 7
      hint = "You're slightly high in the " .. part .. " break."
    elseif (altitude < 720) then
      score = 5
      hint = "You're low in the " .. part .. " break."
    elseif (altitude < 750) then
      score = 7
      hint = "You're slightly low in the " .. part .. " break."
    else
      score = 10
      hint = "Good altitude in the " .. part .. " break!"
    end

    self:_IncreaseScore(playerData, score)
    
    self:_SendMessageToPlayer( hint, 8, playerData )
    self:_PrintAltitudeFeedback(altitude, idealAltitude, playerData)
    self:_PrintScore(score, playerData, true)
    
    self:_AddToSummary(playerData, hint)

    if (part == "early") then
      playerData.step = 4
    else
      playerData.step = 5
    end
  end
end

--- Break.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data table.
function CARRIERTRAINER:_Abeam(playerData)  
  local playerPosition = playerData.unit:GetVec3()
  local carrierPosition = self.carrier:GetVec3()

  local diffZ = playerPosition.z - carrierPosition.z
  local diffX = playerPosition.x - carrierPosition.x
  if(diffZ > -1000 or diffZ < -3700) then
    self:_AbortPattern(playerData)
    return
  end
  
  local limit = -200
  
  if diffX < limit then
    --local aoa = math.deg(mist.getAoA(playerData.mistUnit))
    local aoa = playerData.unit:GetAoA()
    local aoaFeedback = self:_PrintAoAFeedback(aoa, 8.1, playerData)
    
    local onSpeedScore = self:_GetOnSpeedScore(aoa)
  
    local idealAltitude = 600
    local altitude = UTILS.Round( UTILS.MetersToFeet( playerPosition.y ) )

    local hint = ""
    local score = 0

    if(altitude > 700) then
      score = 5
      hint = "You're high (" .. altitude .. " ft) abeam"
    elseif(altitude > 650) then
      score = 7
      hint = "You're slightly high (" .. altitude .. " ft) abeam"
    elseif (altitude < 540) then
      score = 5
      hint = "You're low (" .. altitude .. " ft) abeam"
    elseif (altitude < 570) then
      score = 7
      hint = "You're slightly low (" .. altitude .. " ft) abeam"
    else
      score = 10
      hint = "Good altitude (" .. altitude .. " ft) abeam"
    end
    
    local distanceHint = ""
    local distanceScore
    local diffEast = carrierPosition.z - playerPosition.z
    
    local nm = diffEast / 1852 --nm conversion
    local idealDistance = 1.2
    
    local roundedNm = UTILS.Round(nm, 2)
    
    if(nm < 1.0) then
      distanceScore = 0
      distanceHint = "too close to the boat (" .. roundedNm .. " nm)"
    elseif(nm < 1.1) then
      distanceScore = 5
      distanceHint = "slightly too close to the boat (" .. roundedNm .. " nm)"
    elseif(nm < 1.3) then
      distanceScore = 10
      distanceHint = "with perfect distance to the boat (" .. roundedNm .. " nm)"
    elseif(nm < 1.4) then
      distanceScore = 5
      distanceHint = "slightly too far from the boat (" .. roundedNm .. " nm)"
    else
      distanceScore = 0
      distanceHint = "too far from the boat (" .. roundedNm .. " nm)"
    end
    
    local fullHint = hint .. ", " .. distanceHint
    
    self:_SendMessageToPlayer( fullHint, 8, playerData )
    self:_SendMessageToPlayer( "(Target: 600 ft and 1.2 nm).", 8, playerData )

    self:_IncreaseScore(playerData, score + distanceScore + onSpeedScore)
    self:_PrintScore(score + distanceScore + onSpeedScore, playerData, true)
    
    self:_AddToSummary(playerData, fullHint .. " (" .. aoaFeedback .. ")")
    playerData.step = 6
  end
end

--- Down wind long check.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data table.
function CARRIERTRAINER:_CheckForLongDownwind(playerData)
  local playerPosition = playerData.unit:GetVec3()
  local carrierPosition = self.carrier:GetVec3()

  local limit = 1500
  
  if carrierPosition.x - playerPosition.x > limit then
    --local heading = math.deg(mist.getHeading(playerData.mistUnit))
    local heading = playerData.unit:GetHeading()
    
    if(heading > 170) then
      local hint = "Too long downwind. Turn final earlier next time."
      self:_SendMessageToPlayer( hint, 8, playerData )
      local score = -40
      self:_IncreaseScore(playerData, score)
      self:_PrintScore(score, playerData, true)
      self:_AddToSummary(playerData, hint)
      playerData.longDownwindDone = true
    end
  end
end

--- Ninety.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data table.
function CARRIERTRAINER:_Ninety(playerData) 
  local playerPosition = playerData.unit:GetVec3()
  local carrierPosition = self.carrier:GetVec3()

  local diffZ = playerPosition.z - carrierPosition.z
  local diffX = playerPosition.x - carrierPosition.x
  if(diffZ < -3700 or diffX < -3700 or diffX > 0) then
    self:_AbortPattern(playerData)
    return
  end
  
  local limitEast = -1111 --0.6nm
  
  if diffZ > limitEast then
    local idealAltitude = 500
    local altitude = UTILS.Round( UTILS.MetersToFeet( playerPosition.y ) )

    local hint = ""
    local score = 0

    if(altitude > 600) then
      score = 5
      hint = "You're high at the 90."
    elseif(altitude > 550) then
      score = 7
      hint = "You're slightly high at the 90."
    elseif (altitude < 380) then
      score = 5
      hint = "You're low at the 90."
    elseif (altitude < 420) then
      score = 7
      hint = "You're slightly low at the 90."
    else
      score = 10
      hint = "Good altitude at the 90!"
    end

    self:_SendMessageToPlayer( hint, 8, playerData )
    self:_PrintAltitudeFeedback(altitude, idealAltitude, playerData)

    --local aoa = math.deg(mist.getAoA(playerData.mistUnit))
    local aoa = playerData.unit:GetAoA()
    local aoaFeedback = self:_PrintAoAFeedback(aoa, 8.1, playerData)
    
    local onSpeedScore = self:_GetOnSpeedScore(aoa)

    self:_IncreaseScore(playerData, score + onSpeedScore)
    self:_PrintScore(score + onSpeedScore, playerData, true)
    
    self:_AddToSummary(playerData, hint .. " (" .. aoaFeedback .. ")")
    
    playerData.longDownwindDone = true
    playerData.step = 7
  end
end

--- Wake.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data table.
function CARRIERTRAINER:_Wake(playerData) 
  local playerPosition = playerData.unit:GetVec3()
  local carrierPosition = carrier:GetVec3()

  local diffZ = playerPosition.z - carrierPosition.z
  local diffX = playerPosition.x - carrierPosition.x
  if(diffZ < -2000 or diffX < -4000 or diffX > 0) then
    self:_AbortPattern(playerData)
    return
  end
  
  if diffZ > 0 then
    local idealAltitude = 370
    local altitude = UTILS.Round( UTILS.MetersToFeet( playerPosition.y ) )

    local hint = ""
    local score = 0

    if(altitude > 500) then
      score = 5
      hint = "You're high at the wake."
    elseif(altitude > 450) then
      score = 7
      hint = "You're slightly high at the wake."
    elseif (altitude < 300) then
      score = 5
      hint = "You're low at the wake."
    elseif (altitude < 340) then
      score = 7
      hint = "You're slightly low at the wake."
    else
      score = 10
      hint = "Good altitude at the wake!"
    end

    self:_SendMessageToPlayer( hint, 8, playerData )
    self:_PrintAltitudeFeedback(altitude, idealAltitude, playerData)

    --local aoa = math.deg(mist.getAoA(playerData.mistUnit))
    local aoa = playerData.unit:GetAoA()
    local aoaFeedback = self:_PrintAoAFeedback(aoa, 8.1, playerData)
    
    local onSpeedScore = self:_GetOnSpeedScore(aoa)

    self:_IncreaseScore(playerData, score + onSpeedScore)
    self:_PrintScore(score + onSpeedScore, playerData, true)
    self:_AddToSummary(playerData, hint .. " (" .. aoaFeedback .. ")")
    
    playerData.step = 8
  end
end

--- Groove.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data table.
function CARRIERTRAINER:_Groove(playerData) 
  local playerPosition = playerData.unit:GetVec3()
  local carrierPosition = self.carrier:GetVec3()

  local diffX = playerPosition.x - (carrierPosition.x - 100)
  local diffZ = playerPosition.z - carrierPosition.z
  
  if(diffX > 0 or diffX < -4000) then
    self:_AbortPattern(playerData)
    return
  end
  
  if(diffX > -500) then --Reached in close before groove
    local hint = "You're too far left and never reached the groove."
    self:_SendMessageToPlayer( hint, 8, playerData )
    self:_PrintScore(0, playerData, true)
    playerData:AddToSummary(hint)
    playerData.step = 9
  else  
    local limitDeg = 8.0
      
    local fraction = diffZ / (-diffX)
    local asinValue = math.asin(fraction)
    local angle = math.deg(asinValue)
    
    if diffZ > -1300 and angle > limitDeg then
      local idealAltitude = 300
      local altitude = UTILS.Round( UTILS.MetersToFeet( playerPosition.y ) )

      local hint = ""
      local score = 0
      
      if (altitude > 450) then
        score = 5
        hint = "You're high in the groove."
      elseif (altitude > 350) then
        score = 7
        hint = "You're slightly high in the groove."
      elseif (altitude < 240) then
        score = 5
        hint = "You're low in the groove."
      elseif (altitude < 270) then
        score = 7
        hint = "You're slightly low in the groove."
      else
        score = 10
        hint = "Good altitude in the groove!"
      end

      self:_SendMessageToPlayer(hint, 8, playerData)
      self:_PrintAltitudeFeedback(altitude, idealAltitude, playerData)

      --local aoa = math.deg(mist.getAoA(playerData.mistUnit))
      local aoa = playerData.unit:GetAoA() 
      local aoaFeedback = self:_PrintAoAFeedback(aoa, 8.1, playerData)
      
      local onSpeedScore = self:_GetOnSpeedScore(aoa)
      
      self:_IncreaseScore(playerData, score + onSpeedScore)
      self:_PrintScore(score + onSpeedScore, playerData, true)      
      
      local fullHint = hint .. " (" .. aoaFeedback .. ")"

      self:_AddToSummary(playerData, fullHint)
      
      playerData.step = 9
    end
  end
end

--- Trap.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data table.
function CARRIERTRAINER:_Trap(playerData) 
  local playerPosition = playerData.unit:GetVec3()
  local carrierPosition = self.carrier:GetVec3()

  local playerVelocity = playerData.unit:GetVelocityKMH()
  local carrierVelocity = self.carrier:GetVelocityKMH()

  local diffZ = playerPosition.z - carrierPosition.z
  local diffX = playerPosition.x - carrierPosition.x
  
  if(diffZ < -2000 or diffZ > 2000 or diffX < -3000) then
    self:_AbortPattern(playerData)
    return
  end

  if(diffX > playerData.highestCarrierXDiff) then
    playerData.highestCarrierXDiff = diffX
  end
  
  if(playerPosition.y < playerData.lowestAltitude) then
    playerData.lowestAltitude = playerPosition.y
  end
  
  if math.abs(playerVelocity - carrierVelocity) < 0.01 then
    playerData.secondsStandingStill = playerData.secondsStandingStill + 1
  
    if diffX < playerData.highestCarrierXDiff or playerData.secondsStandingStill > 5 then
      
      env.info("Trap identified! diff " .. diffX .. ",  highestCarrierXDiff" .. playerData.highestCarrierXDiff .. ", secondsStandingStill: " .. playerData.secondsStandingStill);
        
      local wire = 1
      local score = -10
      
      if(diffX < -14) then
        wire = 1
        score = -15
      elseif(diffX < -3) then
        wire = 2
        score = 10      
      elseif (diffX < 10) then
        wire = 3
        score = 20
      else
        wire = 4
        score = 7
      end
      
      self:_IncreaseScore(playerData, score)
      
      self:_SendMessageToPlayer( "TRAPPED! " .. wire .. "-wire!", 30, playerData )
      self:_PrintScore(score, playerData, false)

      env.info("Distance! " .. diffX .. " meters resulted in a " .. wire .. "-wire estimation.");
      
      local fullHint = "Trapped catching the " .. wire .. "-wire."
      
      playerData:AddToSummary(fullHint)
      
      self:_PrintFinalScore(playerData, 60, wire)
      self:_HandleCollectedResult(playerData, wire)
      playerData.step = 0
    end
    
  elseif (diffX > 150) then
    
    local wire = 0
    local hint = ""
    local score = 0
    if(playerData.lowestAltitude < 23) then
      hint = "You boltered."
    else
      hint = "You were waved off."
      wire = -1
      score = -10
    end
    
    self:_SendMessageToPlayer( hint, 8, playerData )
    self:_PrintScore(score, playerData, true)
       
    playerData:AddToSummary(hint)
    
    self:_PrintFinalScore(playerData, 60, wire)
    self:_HandleCollectedResult(playerData, wire)
    
    playerData.step = 0
  end 
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MISC functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Send message about altitude feedback.
-- @param #CARRIERTRAINER self
-- @param #number altitude Current altitude of the player.
-- @param #number idealAltitude Ideal altitude.
-- @param #CARRIERTRAINER.PlayerData playerData Player data.
function CARRIERTRAINER:_PrintAltitudeFeedback(altitude, idealAltitude, playerData)
  self:_SendMessageToPlayer( "Alt: " .. altitude .. " (Target: " .. idealAltitude .. ")", 8, playerData )
end

--- Score for correct AoA.
-- @param #CARRIERTRAINER self
-- @param #number AoA Angle of attack.
function CARRIERTRAINER:_GetOnSpeedScore(AoA)
  local score = 0
  if(AoA > 9.5) then --Slow
    score = 0
  elseif(AoA > 9) then --Slightly slow
    score = 5
  elseif(AoA > 7.25) then --On speed
    score = 10
  elseif(AoA > 6.7) then --Slightly fast
    score = 5
  else --Fast
    score = 0
  end
  
  return score
end

--- Print AoA feedback.
-- @param #CARRIERTRAINER self
-- @param #number AoA Angle of attack.
-- @param #number idealAoA Ideal AoA.
-- @param #CARRIERTRAINER.PlayerData playerData Player data.
-- @return #string Feedback hint.
function CARRIERTRAINER:_PrintAoAFeedback(AoA, idealAoA, playerData)

  local hint = ""
  if(AoA > 9.5) then
    hint = "You're slow."
  elseif(AoA > 9) then
    hint = "You're slightly slow."
  elseif(AoA > 7.25) then
    hint = "You're on speed!"
  elseif(AoA > 6.7) then
    hint = "You're slightly fast."
  else
    hint = "You're fast."
  end
  
  local roundedAoA = UTILS.Round(AoA, 2)
  
  self:_SendMessageToPlayer(hint .. " AOA: " .. roundedAoA .. " (Target: " .. idealAoA .. ")", 8, playerData)
  
  return hint
end

--- Send message to playe client.
-- @param #CARRIERTRAINER self
-- @param #string message The message to send.
-- @param #number duration Display message duration.
-- @param #CARRIERTRAINER.PlayerData playerData Player data.
function CARRIERTRAINER:_SendMessageToPlayer(message, duration, playerData)
  if playerData.client then
    MESSAGE:New(message, duration):ToClient(playerData.client)
  end
end

--- Send message to playe client.
-- @param #CARRIERTRAINER self
-- @param #number score Score.
-- @param #CARRIERTRAINER.PlayerData playerData Player data.
function CARRIERTRAINER:_PrintScore(score, playerData, alsoPrintTotalScore)
  if(alsoPrintTotalScore) then
    self:_SendMessageToPlayer( "Score: " .. score .. " (Total: " .. playerData.score .. ")", 8, playerData )
  else
    self:_SendMessageToPlayer( "Score: " .. score, 8, playerData )
  end
end

--- Display final score.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data.
-- @param #number duration Duration for message display.
function CARRIERTRAINER:_PrintFinalScore(playerData, duration, wire)
  local wireText = ""
  if(wire == -2) then
    wireText = "Aborted approach"
  elseif(wire == -1) then
    wireText = "Wave-off"
  elseif(wire == 0) then
    wireText = "Bolter"
  else
    wireText = wire .. "-wire"
  end
  
  MessageToAll( playerData.callsign .. " - Final score: " .. playerData.score .. " / 140 (" .. wireText .. ")", duration, "FinalScore" )
  self:_SendMessageToPlayer( playerData.summary, duration, playerData )
end

--- Collect result.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data.
-- @param #number wire Trapped wire.
function CARRIERTRAINER:_HandleCollectedResult(playerData, wire)
  local newString = ""
  if(wire == -2) then
    newString = playerData.score .. " (Aborted)"
  elseif(wire == -1) then
    newString = playerData.score .. " (Wave-off)"
  elseif(wire == 0) then
    newString = playerData.score .. " (Bolter)"
  else
    newString = playerData.score .. " (" .. wire .."W)"
  end
  
  playerData.totalScore = playerData.totalScore + playerData.score
  playerData.passes = playerData.passes + 1
  
  if(playerData.collectedResultString == "") then
    playerData.collectedResultString = newString
  else
    playerData.collectedResultString = playerData.collectedResultString .. ", " .. newString
    MessageToAll( playerData.callsign .. "'s " .. playerData.passes .. " passes: " .. playerData.collectedResultString .. " (TOTAL: " .. playerData.totalScore .. ")"  , 30, "CollectedResult" )
  end
  
  self:_SendMessageToPlayer( "Return south 4 nm (over the trailing ship), towards WP 1, to restart the pattern.", 20, playerData )
end

--- Pattern aborted.
-- @param #CARRIERTRAINER self
-- @param #CARRIERTRAINER.PlayerData playerData Player data.
function CARRIERTRAINER:_AbortPattern(playerData)
  self:_SendMessageToPlayer( "You're too far from where you should be. Abort approach!", 15, playerData )
  playerData:AddToSummary("Approach aborted.")
  self:_PrintFinalScore(playerData, 30, -2)
  self:_HandleCollectedResult(playerData, -2)
  playerData.step = 0
end

--- Get the formatted score.
-- @param #CARRIERTRAINER self
-- @param #number score Score of player.
-- @param #number maxScore Max score possible.
-- @return #string Formatted score text.
function CARRIERTRAINER:_GetFormattedScore(score, maxScore)
  if(score < maxScore) then
    return " (" .. score .. " points)."
  else
    return " (" .. score .. " points)!"
  end
end

--- Get distance feedback.
-- @param #CARRIERTRAINER self
-- @param #number distance Distance to boat.
-- @param #number idealDistance Ideal distance.
-- @return #string Feedback text.
function CARRIERTRAINER:_GetDistanceFeedback(distance, idealDistance)
  return distance .. " nm (Target: " .. idealDistance .. " nm)"
end


--- Returns the unit of a player and the player name. If the unit does not belong to a player, nil is returned. 
-- @param #CARRIERTRAINER self
-- @param #string _unitName Name of the player unit.
-- @return Wrapper.Unit#UNIT Unit of player or nil.
-- @return #string Name of the player or nil.
function CARRIERTRAINER:_GetPlayerUnitAndName(_unitName)
  self:F2(_unitName)

  if _unitName ~= nil then
  
    -- Get DCS unit from its name.
    local DCSunit=Unit.getByName(_unitName)
    
    if DCSunit then
    
      local playername=DCSunit:getPlayerName()
      local unit=UNIT:Find(DCSunit)
    
      self:T2({DCSunit=DCSunit, unit=unit, playername=playername})
      if DCSunit and unit and playername then
        return unit, playername
      end
      
    end
    
  end
  
  -- Return nil if we could not find a player.
  return nil,nil
end

