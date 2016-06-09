--- BASE classes.
-- 
-- @{#BASE} class
-- ==============
-- The @{#BASE} class is the super class for most of the classes defined within MOOSE.
-- 
-- It handles:
-- 
--   * The construction and inheritance of child classes.
--   * The tracing of objects during mission execution within the DCS.log file (under saved games folder).
-- 
-- Note: Normally you would not use the BASE class unless you are extending the MOOSE framework with new classes.
-- 
-- BASE Trace functionality
-- ========================
-- The BASE class contains trace methods to trace progress within a mission execution of a certain object.
-- Note that these trace methods are inherited by each MOOSE class interiting BASE.
-- As such, each object created from derived class from BASE can use the tracing functions to trace its execution.
-- 
-- Trace a function call
-- ---------------------
-- There are basically 3 types of tracing methods available within BASE:
-- 
--   * @{#BASE.F}: Trace the beginning of a function and its given parameters.
--   * @{#BASE.T}: Trace further logic within a function giving optional variables or parameters.
--   * @{#BASE.E}: Trace an execption within a function giving optional variables or parameters. An exception will always be traced.
-- 
-- Tracing levels
-- --------------
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
-- BASE Inheritance support
-- ========================
-- The following methods are available to support inheritance:
-- 
--   * @{#BASE.Inherit}: Inherits from a class.
--   * @{#BASE.Inherited}: Returns the parent class from the class.
-- 
-- Future
-- ======
-- Further methods may be added to BASE whenever there is a need to make "overall" functions available within MOOSE.
-- 
-- ====
-- 
-- @module Base
-- @author FlightControl



local _TraceOn = true
local _TraceLevel = 1
local _TraceAll = false
local _TraceClass = {}
local _TraceClassMethod = {}

--- The BASE Class
-- @type BASE
-- @field ClassName The name of the class.
-- @field ClassID The ID number of the class.
BASE = {
  ClassName = "BASE",
  ClassID = 0,
  Events = {}
}

--- The Formation Class
-- @type FORMATION
-- @field Cone A cone formation.
FORMATION = {
  Cone = "Cone" 
}



--- The base constructor. This is the top top class of all classed defined within the MOOSE.
-- Any new class needs to be derived from this class for proper inheritance.
-- @param #BASE self
-- @return #BASE The new instance of the BASE class.
-- @usage
-- function TASK:New()
--
--     local self = BASE:Inherit( self, BASE:New() )
-- 
--     -- assign Task default values during construction
--     self.TaskBriefing = "Task: No Task."
--     self.Time = timer.getTime()
--     self.ExecuteStage = _TransportExecuteStage.NONE
-- 
--     return self
-- end
-- @todo need to investigate if the deepCopy is really needed... Don't think so.
function BASE:New()
	local Child = routines.utils.deepCopy( self )
	local Parent = {}
	setmetatable( Child, Parent )
	Child.__index = Child
	self.ClassID = self.ClassID + 1
	Child.ClassID = self.ClassID
	--Child.AddEvent( Child, S_EVENT_BIRTH, Child.EventBirth )
	return Child
end

--- This is the worker method to inherit from a parent class.
-- @param #BASE self
-- @param Child is the Child class that inherits.
-- @param #BASE Parent is the Parent class that the Child inherits from.
-- @return #BASE Child
function BASE:Inherit( Child, Parent )
	local Child = routines.utils.deepCopy( Child )
	local Parent = routines.utils.deepCopy( Parent )
	if Child ~= nil then
		setmetatable( Child, Parent )
		Child.__index = Child
	end
	--Child.ClassName = Child.ClassName .. '.' .. Child.ClassID
	self:T( 'Inherited from ' .. Parent.ClassName ) 
	return Child
end

--- This is the worker method to retrieve the Parent class.
-- @param #BASE self
-- @param #BASE Child is the Child class from which the Parent class needs to be retrieved.
-- @return #BASE
function BASE:Inherited( Child )
	local Parent = getmetatable( Child )
--	env.info('Inherited class of ' .. Child.ClassName .. ' is ' .. Parent.ClassName )
	return Parent
end

--- Get the ClassName + ClassID of the class instance.
-- The ClassName + ClassID is formatted as '%s#%09d'. 
-- @param #BASE self
-- @return #string The ClassName + ClassID of the class instance.
function BASE:GetClassNameAndID()
  return string.format( '%s#%09d', self:GetClassName(), self:GetClassID() )
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
-- @param DCSTypes#Event Event
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
-- @return Event#EVENT
function BASE:Event()

  return _EVENTDISPATCHER
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
-- @param DCSTypes#Time EventTime The time stamp of the event.
-- @param DCSObject#Object Initiator The initiating object of the event.
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
-- @param DCSTypes#Time EventTime The time stamp of the event.
-- @param DCSObject#Object Initiator The initiating object of the event.
function BASE:CreateEventCrash( EventTime, Initiator )
	self:F( { EventTime, Initiator } )

	local Event = {
		id = world.event.S_EVENT_CRASH,
		time = EventTime,
		initiator = Initiator,
		}

	world.onEvent( Event )
end

-- TODO: Complete DCSTypes#Event structure.                       
--- The main event handling function... This function captures all events generated for the class.
-- @param #BASE self
-- @param DCSTypes#Event event
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

-- Trace section

-- Log a trace (only shown when trace is on)
-- TODO: Make trace function using variable parameters.

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

--- Trace a function call. Must be at the beginning of the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:F( Arguments, DebugInfoCurrentParam, DebugInfoFromParam )

  if _TraceOn and ( ( _TraceAll == true ) or ( _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName] ) ) then

    local DebugInfoCurrent = DebugInfoCurrentParam and DebugInfoCurrentParam or debug.getinfo( 2, "nl" )
    local DebugInfoFrom = DebugInfoFromParam and DebugInfoFromParam or debug.getinfo( 3, "l" )
    
    local Function = "function"
    if DebugInfoCurrent.name then
      Function = DebugInfoCurrent.name
    end
    
    if _TraceAll == true or _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName].Method[Function] then
      local LineCurrent = DebugInfoCurrent.currentline
      local LineFrom = 0
      if DebugInfoFrom then
        LineFrom = DebugInfoFrom.currentline
      end
      env.info( string.format( "%6d(%6d)/%1s:%20s%05d.%s(%s)" , LineCurrent, LineFrom, "F", self.ClassName, self.ClassID, Function, routines.utils.oneLineSerialize( Arguments ) ) )
    end
  end
end

--- Trace a function call level 2. Must be at the beginning of the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:F2( Arguments )

  local DebugInfoCurrent = debug.getinfo( 2, "nl" )
  local DebugInfoFrom = debug.getinfo( 3, "l" )

  if _TraceLevel >= 2 then
    self:F( Arguments, DebugInfoCurrent, DebugInfoFrom )
  end
  
end

--- Trace a function call level 3. Must be at the beginning of the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:F3( Arguments )

  local DebugInfoCurrent = debug.getinfo( 2, "nl" )
  local DebugInfoFrom = debug.getinfo( 3, "l" )

  if _TraceLevel >= 3 then
    self:F( Arguments, DebugInfoCurrent, DebugInfoFrom )
  end
  
end

--- Trace a function logic. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:T( Arguments, DebugInfoCurrentParam, DebugInfoFromParam )

	if _TraceOn and ( ( _TraceAll == true ) or ( _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName] ) ) then

    local DebugInfoCurrent = DebugInfoCurrentParam and DebugInfoCurrentParam or debug.getinfo( 2, "nl" )
    local DebugInfoFrom = DebugInfoFromParam and DebugInfoFromParam or debug.getinfo( 3, "l" )
		
		local Function = "function"
		if DebugInfoCurrent.name then
			Function = DebugInfoCurrent.name
		end

    if _TraceAll == true or _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName].Method[Function] then
  		local LineCurrent = DebugInfoCurrent.currentline
  		local LineFrom = 0
  		if DebugInfoFrom then
  		  LineFrom = DebugInfoFrom.currentline
  	  end
  		env.info( string.format( "%6d(%6d)/%1s:%20s%05d.%s" , LineCurrent, LineFrom, "T", self.ClassName, self.ClassID, routines.utils.oneLineSerialize( Arguments ) ) )
    end
	end
end

--- Trace a function logic level 2. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:T2( Arguments )

  local DebugInfoCurrent = debug.getinfo( 2, "nl" )
  local DebugInfoFrom = debug.getinfo( 3, "l" )

  if _TraceLevel >= 2 then
    self:T( Arguments, DebugInfoCurrent, DebugInfoFrom )
  end
  
end

--- Trace a function logic level 3. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:T3( Arguments )

  local DebugInfoCurrent = debug.getinfo( 2, "nl" )
  local DebugInfoFrom = debug.getinfo( 3, "l" )

  if _TraceLevel >= 3 then
    self:T( Arguments, DebugInfoCurrent, DebugInfoFrom )
  end
  
end

--- Log an exception which will be traced always. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:E( Arguments )

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


