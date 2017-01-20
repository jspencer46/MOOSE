--- This module contains the BASE class.
-- 
-- 1) @{#BASE} class
-- =================
-- The @{#BASE} class is the super class for all the classes defined within MOOSE.
-- 
-- It handles:
-- 
--   * The construction and inheritance of child classes.
--   * The tracing of objects during mission execution within the **DCS.log** file, under the **"Saved Games\DCS\Logs"** folder.
-- 
-- Note: Normally you would not use the BASE class unless you are extending the MOOSE framework with new classes.
-- 
-- ## 1.1) BASE constructor
-- 
-- Any class derived from BASE, must use the @{Core.Base#BASE.New) constructor within the @{Core.Base#BASE.Inherit) method. 
-- See an example at the @{Core.Base#BASE.New} method how this is done.
-- 
-- ## 1.2) BASE Trace functionality
-- 
-- The BASE class contains trace methods to trace progress within a mission execution of a certain object.
-- Note that these trace methods are inherited by each MOOSE class interiting BASE.
-- As such, each object created from derived class from BASE can use the tracing functions to trace its execution.
-- 
-- ### 1.2.1) Tracing functions
--
-- There are basically 3 types of tracing methods available within BASE:
-- 
--   * @{#BASE.F}: Trace the beginning of a function and its given parameters. An F is indicated at column 44 in the DCS.log file.
--   * @{#BASE.T}: Trace further logic within a function giving optional variables or parameters. A T is indicated at column 44 in the DCS.log file.
--   * @{#BASE.E}: Trace an exception within a function giving optional variables or parameters. An E is indicated at column 44 in the DCS.log file. An exception will always be traced.
-- 
-- ### 1.2.2) Tracing levels
--
-- There are 3 tracing levels within MOOSE.  
-- These tracing levels were defined to avoid bulks of tracing to be generated by lots of objects.
-- 
-- As such, the F and T methods have additional variants to trace level 2 and 3 respectively:
--
--   * @{#BASE.F2}: Trace the beginning of a function and its given parameters with tracing level 2.
--   * @{#BASE.F3}: Trace the beginning of a function and its given parameters with tracing level 3.
--   * @{#BASE.T2}: Trace further logic within a function giving optional variables or parameters with tracing level 2.
--   * @{#BASE.T3}: Trace further logic within a function giving optional variables or parameters with tracing level 3.
-- 
-- ### 1.2.3) Trace activation.
-- 
-- Tracing can be activated in several ways:
-- 
--   * Switch tracing on or off through the @{#BASE.TraceOnOff}() method.
--   * Activate all tracing through the @{#BASE.TraceAll}() method.
--   * Activate only the tracing of a certain class (name) through the @{#BASE.TraceClass}() method.
--   * Activate only the tracing of a certain method of a certain class through the @{#BASE.TraceClassMethod}() method.
--   * Activate only the tracing of a certain level through the @{#BASE.TraceLevel}() method.
-- ### 1.2.4) Check if tracing is on.
-- 
-- The method @{#BASE.IsTrace}() will validate if tracing is activated or not.
-- 
-- ## 1.3 DCS simulator Event Handling
-- 
-- The BASE class provides methods to catch DCS Events. These are events that are triggered from within the DCS simulator, 
-- and handled through lua scripting. MOOSE provides an encapsulation to handle these events more efficiently.
-- Therefore, the BASE class exposes the following event handling functions:
-- 
--   * @{#BASE.EventOnBirth}(): Handle the birth of a new unit.
--   * @{#BASE.EventOnBaseCaptured}(): Handle the capturing of an airbase or a helipad.
--   * @{#BASE.EventOnCrash}(): Handle the crash of a unit.
--   * @{#BASE.EventOnDead}(): Handle the death of a unit.
--   * @{#BASE.EventOnEjection}(): Handle the ejection of a player out of an airplane.
--   * @{#BASE.EventOnEngineShutdown}(): Handle the shutdown of an engine.
--   * @{#BASE.EventOnEngineStartup}(): Handle the startup of an engine.
--   * @{#BASE.EventOnHit}(): Handle the hit of a shell to a unit.
--   * @{#BASE.EventOnHumanFailure}(): No a clue ...
--   * @{#BASE.EventOnLand}(): Handle the event when a unit lands. 
--   * @{#BASE.EventOnMissionStart}(): Handle the start of the mission.
--   * @{#BASE.EventOnPilotDead}(): Handle the event when a pilot is dead.
--   * @{#BASE.EventOnPlayerComment}(): Handle the event when a player posts a comment.
--   * @{#BASE.EventOnPlayerEnterUnit}(): Handle the event when a player enters a unit.
--   * @{#BASE.EventOnPlayerLeaveUnit}(): Handle the event when a player leaves a unit.
--   * @{#BASE.EventOnBirthPlayerMissionEnd}(): Handle the event when a player ends the mission. (Not a clue what that does).
--   * @{#BASE.EventOnRefueling}(): Handle the event when a unit is refueling. 
--   * @{#BASE.EventOnShootingEnd}(): Handle the event when a unit starts shooting (guns).
--   * @{#BASE.EventOnShootingStart}(): Handle the event when a unit ends shooting (guns). 
--   * @{#BASE.EventOnShot}(): Handle the event when a unit shot a missile.
--   * @{#BASE.EventOnTakeOff}(): Handle the event when a unit takes off from a runway.
--   * @{#BASE.EventOnTookControl}(): Handle the event when a player takes control of a unit.
-- 
-- The EventOn() methods provide the @{Core.Event#EVENTDATA} structure to the event handling function. 
-- The @{Core.Event#EVENTDATA} structure contains an enriched data set of information about the event being handled.
-- 
-- Find below an example of the prototype how to write an event handling function: 
--
--      CommandCenter:EventOnPlayerEnterUnit(
--        --- @param #COMMANDCENTER self
--        -- @param Core.Event#EVENTDATA EventData
--        function( self, EventData )
--          local PlayerUnit = EventData.IniUnit
--          for MissionID, Mission in pairs( self:GetMissions() ) do
--            local Mission = Mission -- Tasking.Mission#MISSION
--            Mission:JoinUnit( PlayerUnit )
--            Mission:ReportDetails()
--          end
--        end
--        )
-- 
-- Note the function( self, EventData ). It takes two parameters:
-- 
--   * self = the object that is handling the EventOnPlayerEnterUnit.
--   * EventData = the @{Core.Event#EVENTDATA} structure, containing more information of the Event.
-- 
-- ## 1.4) Class identification methods
-- 
-- BASE provides methods to get more information of each object:
-- 
--   * @{#BASE.GetClassID}(): Gets the ID (number) of the object. Each object created is assigned a number, that is incremented by one.
--   * @{#BASE.GetClassName}(): Gets the name of the object, which is the name of the class the object was instantiated from.
--   * @{#BASE.GetClassNameAndID}(): Gets the name and ID of the object.
-- 
-- ## 1.5) All objects derived from BASE can have "States"
-- 
-- A mechanism is in place in MOOSE, that allows to let the objects administer **states**. 
-- States are essentially properties of objects, which are identified by a **Key** and a **Value**.
-- The method @{#BASE.SetState}() can be used to set a Value with a reference Key to the object.
-- To **read or retrieve** a state Value based on a Key, use the @{#BASE.GetState} method.
-- These two methods provide a very handy way to keep state at long lasting processes.
-- Values can be stored within the objects, and later retrieved or changed when needed.
-- There is one other important thing to note, the @{#BASE.SetState}() and @{#BASE.GetState} methods
-- receive as the **first parameter the object for which the state needs to be set**.
-- Thus, if the state is to be set for the same object as the object for which the method is used, then provide the same
-- object name to the method.
-- 
-- ## 1.10) BASE Inheritance (tree) support
-- 
-- The following methods are available to support inheritance:
-- 
--   * @{#BASE.Inherit}: Inherits from a class.
--   * @{#BASE.GetParent}: Returns the parent object from the object it is handling, or nil if there is no parent object.
--   
-- ====
-- 
-- # **API CHANGE HISTORY**
-- 
-- The underlying change log documents the API changes. Please read this carefully. The following notation is used:
-- 
--   * **Added** parts are expressed in bold type face.
--   * _Removed_ parts are expressed in italic type face.
-- 
-- YYYY-MM-DD: CLASS:**NewFunction**( Params ) replaces CLASS:_OldFunction_( Params )
-- YYYY-MM-DD: CLASS:**NewFunction( Params )** added
-- 
-- Hereby the change log:
-- 
-- ===
-- 
-- # **AUTHORS and CONTRIBUTIONS**
-- 
-- ### Contributions: 
-- 
--   * None.
-- 
-- ### Authors: 
-- 
--   * **FlightControl**: Design & Programming
-- 
-- @module Base



local _TraceOnOff = true
local _TraceLevel = 1
local _TraceAll = false
local _TraceClass = {}
local _TraceClassMethod = {}

local _ClassID = 0

--- The BASE Class
-- @type BASE
-- @field ClassName The name of the class.
-- @field ClassID The ID number of the class.
-- @field ClassNameAndID The name of the class concatenated with the ID number of the class.
BASE = {
  ClassName = "BASE",
  ClassID = 0,
  Events = {},
  States = {}
}

--- The Formation Class
-- @type FORMATION
-- @field Cone A cone formation.
FORMATION = {
  Cone = "Cone" 
}



-- @todo need to investigate if the deepCopy is really needed... Don't think so.
function BASE:New()
  local self = routines.utils.deepCopy( self ) -- Create a new self instance
	local MetaTable = {}
	setmetatable( self, MetaTable )
	self.__index = self
	_ClassID = _ClassID + 1
	self.ClassID = _ClassID

	
	return self
end

function BASE:_Destructor()
  --self:E("_Destructor")

  --self:EventRemoveAll()
end

function BASE:_SetDestructor()

  -- TODO: Okay, this is really technical...
  -- When you set a proxy to a table to catch __gc, weak tables don't behave like weak...
  -- Therefore, I am parking this logic until I've properly discussed all this with the community.
  --[[
  local proxy = newproxy(true)
  local proxyMeta = getmetatable(proxy)

  proxyMeta.__gc = function ()
    env.info("In __gc for " .. self:GetClassNameAndID() )
    if self._Destructor then
        self:_Destructor()
    end
  end

  -- keep the userdata from newproxy reachable until the object
  -- table is about to be garbage-collected - then the __gc hook
  -- will be invoked and the destructor called
  rawset( self, '__proxy', proxy )
  --]]
end

--- This is the worker method to inherit from a parent class.
-- @param #BASE self
-- @param Child is the Child class that inherits.
-- @param #BASE Parent is the Parent class that the Child inherits from.
-- @return #BASE Child
function BASE:Inherit( Child, Parent )
	local Child = routines.utils.deepCopy( Child )
	--local Parent = routines.utils.deepCopy( Parent )
  --local Parent = Parent
	if Child ~= nil then
		setmetatable( Child, Parent )
		Child.__index = Child
		
		Child:_SetDestructor()
	end
	--self:T( 'Inherited from ' .. Parent.ClassName ) 
	return Child
end

--- This is the worker method to retrieve the Parent class.
-- @param #BASE self
-- @param #BASE Child is the Child class from which the Parent class needs to be retrieved.
-- @return #BASE
function BASE:GetParent( Child )
	local Parent = getmetatable( Child )
--	env.info('Inherited class of ' .. Child.ClassName .. ' is ' .. Parent.ClassName )
	return Parent
end

--- Get the ClassName + ClassID of the class instance.
-- The ClassName + ClassID is formatted as '%s#%09d'. 
-- @param #BASE self
-- @return #string The ClassName + ClassID of the class instance.
function BASE:GetClassNameAndID()
  return string.format( '%s#%09d', self.ClassName, self.ClassID )
end

--- Get the ClassName of the class instance.
-- @param #BASE self
-- @return #string The ClassName of the class instance.
function BASE:GetClassName()
  return self.ClassName
end

--- Get the ClassID of the class instance.
-- @param #BASE self
-- @return #string The ClassID of the class instance.
function BASE:GetClassID()
  return self.ClassID
end

--- Set a new listener for the class.
-- @param self
-- @param Dcs.DCSTypes#Event Event
-- @param #function EventFunction
-- @return #BASE
function BASE:AddEvent( Event, EventFunction )
	self:F( Event )

	self.Events[#self.Events+1] = {}
	self.Events[#self.Events].Event = Event
	self.Events[#self.Events].EventFunction = EventFunction
	self.Events[#self.Events].EventEnabled = false

	return self
end

--- Returns the event dispatcher
-- @param #BASE self
-- @return Core.Event#EVENT
function BASE:Event()

  return _EVENTDISPATCHER
end

--- Remove all subscribed events
-- @param #BASE self
-- @return #BASE
function BASE:EventRemoveAll()

  _EVENTDISPATCHER:RemoveAll( self )
  
  return self
end

--- Subscribe to a S_EVENT\_SHOT event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnShot( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_SHOT )
  
  return self
end

--- Subscribe to a S_EVENT\_HIT event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnHit( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_HIT )
  
  return self
end

--- Subscribe to a S_EVENT\_TAKEOFF event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnTakeOff( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_TAKEOFF )
  
  return self
end

--- Subscribe to a S_EVENT\_LAND event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnLand( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_LAND )
  
  return self
end

--- Subscribe to a S_EVENT\_CRASH event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnCrash( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_CRASH )
  
  return self
end

--- Subscribe to a S_EVENT\_EJECTION event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnEjection( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_EJECTION )
  
  return self
end


--- Subscribe to a S_EVENT\_REFUELING event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnRefueling( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_REFUELING )
  
  return self
end

--- Subscribe to a S_EVENT\_DEAD event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnDead( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_DEAD )
  
  return self
end

--- Subscribe to a S_EVENT_PILOT\_DEAD event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnPilotDead( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_PILOT_DEAD )
  
  return self
end

--- Subscribe to a S_EVENT_BASE\_CAPTURED event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnBaseCaptured( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_BASE_CAPTURED )
  
  return self
end

--- Subscribe to a S_EVENT_MISSION\_START event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnMissionStart( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_MISSION_START )
  
  return self
end

--- Subscribe to a S_EVENT_MISSION\_END event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnPlayerMissionEnd( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_MISSION_END )
  
  return self
end

--- Subscribe to a S_EVENT_TOOK\_CONTROL event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnTookControl( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_TOOK_CONTROL )
  
  return self
end

--- Subscribe to a S_EVENT_REFUELING\_STOP event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnRefuelingStop( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_REFUELING_STOP )
  
  return self
end

--- Subscribe to a S_EVENT\_BIRTH event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnBirth( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_BIRTH )
  
  return self
end

--- Subscribe to a S_EVENT_HUMAN\_FAILURE event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnHumanFailure( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_HUMAN_FAILURE )
  
  return self
end

--- Subscribe to a S_EVENT_ENGINE\_STARTUP event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnEngineStartup( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_ENGINE_STARTUP )
  
  return self
end

--- Subscribe to a S_EVENT_ENGINE\_SHUTDOWN event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnEngineShutdown( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_ENGINE_SHUTDOWN )
  
  return self
end

--- Subscribe to a S_EVENT_PLAYER_ENTER\_UNIT event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnPlayerEnterUnit( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_PLAYER_ENTER_UNIT )
  
  return self
end

--- Subscribe to a S_EVENT_PLAYER_LEAVE\_UNIT event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnPlayerLeaveUnit( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_PLAYER_LEAVE_UNIT )
  
  return self
end

--- Subscribe to a S_EVENT_PLAYER\_COMMENT event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnPlayerComment( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_PLAYER_COMMENT )
  
  return self
end

--- Subscribe to a S_EVENT_SHOOTING\_START event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnShootingStart( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_SHOOTING_START )
  
  return self
end

--- Subscribe to a S_EVENT_SHOOTING\_END event.
-- @param #BASE self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @return #BASE
function BASE:EventOnShootingEnd( EventFunction )

  _EVENTDISPATCHER:OnEventGeneric( EventFunction, self, world.event.S_EVENT_SHOOTING_END )
  
  return self
end







--- Enable the event listeners for the class.
-- @param #BASE self
-- @return #BASE
function BASE:EnableEvents()
	self:F( #self.Events )

	for EventID, Event in pairs( self.Events ) do
		Event.Self = self
		Event.EventEnabled = true
	end
	self.Events.Handler = world.addEventHandler( self )

	return self
end


--- Disable the event listeners for the class.
-- @param #BASE self
-- @return #BASE
function BASE:DisableEvents()
	self:F()
  
	world.removeEventHandler( self )
	for EventID, Event in pairs( self.Events ) do
		Event.Self = nil
		Event.EventEnabled = false
	end

	return self
end


local BaseEventCodes = {
   "S_EVENT_SHOT",
   "S_EVENT_HIT",
   "S_EVENT_TAKEOFF",
   "S_EVENT_LAND",
   "S_EVENT_CRASH",
   "S_EVENT_EJECTION",
   "S_EVENT_REFUELING",
   "S_EVENT_DEAD",
   "S_EVENT_PILOT_DEAD",
   "S_EVENT_BASE_CAPTURED",
   "S_EVENT_MISSION_START",
   "S_EVENT_MISSION_END",
   "S_EVENT_TOOK_CONTROL",
   "S_EVENT_REFUELING_STOP",
   "S_EVENT_BIRTH",
   "S_EVENT_HUMAN_FAILURE",
   "S_EVENT_ENGINE_STARTUP",
   "S_EVENT_ENGINE_SHUTDOWN",
   "S_EVENT_PLAYER_ENTER_UNIT",
   "S_EVENT_PLAYER_LEAVE_UNIT",
   "S_EVENT_PLAYER_COMMENT",
   "S_EVENT_SHOOTING_START",
   "S_EVENT_SHOOTING_END",
   "S_EVENT_MAX",
}
 
--onEvent( {[1]="S_EVENT_BIRTH",[2]={["subPlace"]=5,["time"]=0,["initiator"]={["id_"]=16884480,},["place"]={["id_"]=5000040,},["id"]=15,["IniUnitName"]="US F-15C@RAMP-Air Support Mountains#001-01",},}
-- Event = {
--   id = enum world.event,
--   time = Time,
--   initiator = Unit,
--   target = Unit,
--   place = Unit,
--   subPlace = enum world.BirthPlace,
--   weapon = Weapon
-- }

--- Creation of a Birth Event.
-- @param #BASE self
-- @param Dcs.DCSTypes#Time EventTime The time stamp of the event.
-- @param Dcs.DCSWrapper.Object#Object Initiator The initiating object of the event.
-- @param #string IniUnitName The initiating unit name.
-- @param place
-- @param subplace
function BASE:CreateEventBirth( EventTime, Initiator, IniUnitName, place, subplace )
	self:F( { EventTime, Initiator, IniUnitName, place, subplace } )

	local Event = {
		id = world.event.S_EVENT_BIRTH,
		time = EventTime,
		initiator = Initiator,
		IniUnitName = IniUnitName,
		place = place,
		subplace = subplace
		}

	world.onEvent( Event )
end

--- Creation of a Crash Event.
-- @param #BASE self
-- @param Dcs.DCSTypes#Time EventTime The time stamp of the event.
-- @param Dcs.DCSWrapper.Object#Object Initiator The initiating object of the event.
function BASE:CreateEventCrash( EventTime, Initiator )
	self:F( { EventTime, Initiator } )

	local Event = {
		id = world.event.S_EVENT_CRASH,
		time = EventTime,
		initiator = Initiator,
		}

	world.onEvent( Event )
end

-- TODO: Complete Dcs.DCSTypes#Event structure.                       
--- The main event handling function... This function captures all events generated for the class.
-- @param #BASE self
-- @param Dcs.DCSTypes#Event event
function BASE:onEvent(event)
  --self:F( { BaseEventCodes[event.id], event } )

	if self then
		for EventID, EventObject in pairs( self.Events ) do
			if EventObject.EventEnabled then
				--env.info( 'onEvent Table EventObject.Self = ' .. tostring(EventObject.Self) )
				--env.info( 'onEvent event.id = ' .. tostring(event.id) )
				--env.info( 'onEvent EventObject.Event = ' .. tostring(EventObject.Event) )
				if event.id == EventObject.Event then
					if self == EventObject.Self then
						if event.initiator and event.initiator:isExist() then
							event.IniUnitName = event.initiator:getName()
						end
						if event.target and event.target:isExist() then
							event.TgtUnitName = event.target:getName()
						end
						--self:T( { BaseEventCodes[event.id], event } )
						--EventObject.EventFunction( self, event )
					end
				end
			end
		end
	end
end

--- Set a state or property of the Object given a Key and a Value.
-- Note that if the Object is destroyed, nillified or garbage collected, then the Values and Keys will also be gone.
-- @param #BASE self
-- @param Object The object that will hold the Value set by the Key.
-- @param Key The key that is used as a reference of the value. Note that the key can be a #string, but it can also be any other type!
-- @param Value The value to is stored in the object.
-- @return The Value set.
-- @return #nil The Key was not found and thus the Value could not be retrieved.
function BASE:SetState( Object, Key, Value )

  local ClassNameAndID = Object:GetClassNameAndID()

  self.States[ClassNameAndID] = self.States[ClassNameAndID] or {}
  self.States[ClassNameAndID][Key] = Value
  self:T2( { ClassNameAndID, Key, Value } )
  
  return self.States[ClassNameAndID][Key]
end


--- Get a Value given a Key from the Object.
-- Note that if the Object is destroyed, nillified or garbage collected, then the Values and Keys will also be gone.
-- @param #BASE self
-- @param Object The object that holds the Value set by the Key.
-- @param Key The key that is used to retrieve the value. Note that the key can be a #string, but it can also be any other type!
-- @param Value The value to is stored in the Object.
-- @return The Value retrieved.
function BASE:GetState( Object, Key )

  local ClassNameAndID = Object:GetClassNameAndID()

  if self.States[ClassNameAndID] then
    local Value = self.States[ClassNameAndID][Key] or false
    self:T2( { ClassNameAndID, Key, Value } )
    return Value
  end
  
  return nil
end

function BASE:ClearState( Object, StateName )

  local ClassNameAndID = Object:GetClassNameAndID()
  if self.States[ClassNameAndID] then
    self.States[ClassNameAndID][StateName] = nil
  end
end

-- Trace section

-- Log a trace (only shown when trace is on)
-- TODO: Make trace function using variable parameters.

--- Set trace on or off
-- Note that when trace is off, no debug statement is performed, increasing performance!
-- When Moose is loaded statically, (as one file), tracing is switched off by default.
-- So tracing must be switched on manually in your mission if you are using Moose statically.
-- When moose is loading dynamically (for moose class development), tracing is switched on by default.
-- @param #BASE self
-- @param #boolean TraceOnOff Switch the tracing on or off.
-- @usage
-- -- Switch the tracing On
-- BASE:TraceOnOff( true )
-- 
-- -- Switch the tracing Off
-- BASE:TraceOnOff( false )
function BASE:TraceOnOff( TraceOnOff )
  _TraceOnOff = TraceOnOff
end


--- Enquires if tracing is on (for the class).
-- @param #BASE self
-- @return #boolean
function BASE:IsTrace()

  if debug and ( _TraceAll == true ) or ( _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName] ) then
    return true
  else
    return false
  end
end

--- Set trace level
-- @param #BASE self
-- @param #number Level
function BASE:TraceLevel( Level )
  _TraceLevel = Level
  self:E( "Tracing level " .. Level )
end

--- Trace all methods in MOOSE
-- @param #BASE self
-- @param #boolean TraceAll true = trace all methods in MOOSE.
function BASE:TraceAll( TraceAll )
  
  _TraceAll = TraceAll
  
  if _TraceAll then
    self:E( "Tracing all methods in MOOSE " )
  else
    self:E( "Switched off tracing all methods in MOOSE" )
  end
end

--- Set tracing for a class
-- @param #BASE self
-- @param #string Class
function BASE:TraceClass( Class )
  _TraceClass[Class] = true
  _TraceClassMethod[Class] = {}
  self:E( "Tracing class " .. Class )
end

--- Set tracing for a specific method of  class
-- @param #BASE self
-- @param #string Class
-- @param #string Method
function BASE:TraceClassMethod( Class, Method )
  if not _TraceClassMethod[Class] then
    _TraceClassMethod[Class] = {}
    _TraceClassMethod[Class].Method = {}
  end
  _TraceClassMethod[Class].Method[Method] = true
  self:E( "Tracing method " .. Method .. " of class " .. Class )
end

--- Trace a function call. This function is private.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:_F( Arguments, DebugInfoCurrentParam, DebugInfoFromParam )

  if debug and ( _TraceAll == true ) or ( _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName] ) then

    local DebugInfoCurrent = DebugInfoCurrentParam and DebugInfoCurrentParam or debug.getinfo( 2, "nl" )
    local DebugInfoFrom = DebugInfoFromParam and DebugInfoFromParam or debug.getinfo( 3, "l" )
    
    local Function = "function"
    if DebugInfoCurrent.name then
      Function = DebugInfoCurrent.name
    end
    
    if _TraceAll == true or _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName].Method[Function] then
      local LineCurrent = 0
      if DebugInfoCurrent.currentline then
        LineCurrent = DebugInfoCurrent.currentline
      end
      local LineFrom = 0
      if DebugInfoFrom then
        LineFrom = DebugInfoFrom.currentline
      end
      env.info( string.format( "%6d(%6d)/%1s:%20s%05d.%s(%s)" , LineCurrent, LineFrom, "F", self.ClassName, self.ClassID, Function, routines.utils.oneLineSerialize( Arguments ) ) )
    end
  end
end

--- Trace a function call. Must be at the beginning of the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:F( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 1 then
      self:_F( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end  
end


--- Trace a function call level 2. Must be at the beginning of the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:F2( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 2 then
      self:_F( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end  
end

--- Trace a function call level 3. Must be at the beginning of the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:F3( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 3 then
      self:_F( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end  
end

--- Trace a function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:_T( Arguments, DebugInfoCurrentParam, DebugInfoFromParam )

	if debug and ( _TraceAll == true ) or ( _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName] ) then

    local DebugInfoCurrent = DebugInfoCurrentParam and DebugInfoCurrentParam or debug.getinfo( 2, "nl" )
    local DebugInfoFrom = DebugInfoFromParam and DebugInfoFromParam or debug.getinfo( 3, "l" )
		
		local Function = "function"
		if DebugInfoCurrent.name then
			Function = DebugInfoCurrent.name
		end

    if _TraceAll == true or _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName].Method[Function] then
      local LineCurrent = 0
      if DebugInfoCurrent.currentline then
        LineCurrent = DebugInfoCurrent.currentline
      end
  		local LineFrom = 0
  		if DebugInfoFrom then
  		  LineFrom = DebugInfoFrom.currentline
  	  end
  		env.info( string.format( "%6d(%6d)/%1s:%20s%05d.%s" , LineCurrent, LineFrom, "T", self.ClassName, self.ClassID, routines.utils.oneLineSerialize( Arguments ) ) )
    end
	end
end

--- Trace a function logic level 1. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:T( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 1 then
      self:_T( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end    
end


--- Trace a function logic level 2. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:T2( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 2 then
      self:_T( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end
end

--- Trace a function logic level 3. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:T3( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 3 then
      self:_T( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end
end

--- Log an exception which will be traced always. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:E( Arguments )

  if debug then
  	local DebugInfoCurrent = debug.getinfo( 2, "nl" )
  	local DebugInfoFrom = debug.getinfo( 3, "l" )
  	
  	local Function = "function"
  	if DebugInfoCurrent.name then
  		Function = DebugInfoCurrent.name
  	end
  
  	local LineCurrent = DebugInfoCurrent.currentline
    local LineFrom = -1 
  	if DebugInfoFrom then
  	  LineFrom = DebugInfoFrom.currentline
  	end
  
  	env.info( string.format( "%6d(%6d)/%1s:%20s%05d.%s(%s)" , LineCurrent, LineFrom, "E", self.ClassName, self.ClassID, Function, routines.utils.oneLineSerialize( Arguments ) ) )
  end
  
end



