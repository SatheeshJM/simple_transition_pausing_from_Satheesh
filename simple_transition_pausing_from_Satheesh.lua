-- A very Simple Pausable Transition
-- Author: Satheesh
-- Release date: 2011-11-27
-- Version: 1.0
-- License: MIT
-- Web: http:www.timeplusq.com
--
-- USAGE:
--  	Import the module :
--     		require "simple_transition_pausing_from_Satheesh"
--
--  	Create transitions as usual
--      	transition.to(object,params}
--
--		transition.pause(object)	pauses all transitions of object
--		transition.resume(object)	resumes all transitions of object
--
--
--
-- PROS
--		No extra code. Just use transitions as you used before
--
-- CONS 
-- 		Delta transitions,easing not supported
--				(to be frank, i have no idea what they do :P)
-- 		May have minor bugs, since i haven't tested completely.
--				(works fine for my requirements though.. if you find any bug please commment)





--The transition.to and transiion.cancel functions are duplicated
local transitionToCopy = transition.to
local transitionCancelCopy = transition.cancel

--I override transition.to function with my function myTransitionFunction
--the duplicate i create is used to call the transition
local myTransitionFunction = function(object,params)
	if not object.destination then
		object.destination = {}
	end
	if not object.startTime then
		object.startTime = {}
	end
	if not object.transition then
		object.transition = {}
	end
		

	--object.destination - table storing transition parameters of each transition of the object
	
	local transitionNo = #object.destination+1
	object.destination	[transitionNo] = {}
	
	local destination = object.destination[transitionNo]
			
	destination.x = params.x
	destination.y = params.y
	destination.xScale = params.xScale
	destination.yScale = params.yScale
	destination.time = params.time
	destination.delay = params.delay
	destination.onComplete = params.onComplete
	destination.onStart = params.onStart
	destination.alpha = params.alpha
	destination.width = params.width
	destination.height = params.height
	destination.rotation = params.rotation
	destination.xOrigin = params.xOrigin
	destination.yOrigin = params.yOrigin
	destination.maskX = params.maskX
	destination.maskY = params.maskY
	destination.maskScaleX = params.maskScaleX
	destination.maskScaleY = params.maskScaleY
	destination.maskRotation = params.maskRotation
	destination.xReference = params.xReference
	destination.yReference = params.yReference
	
	if destination.delay== nil then
		destination.delay=0
	end
	
	
	--on transition complete, deletes the corresponding table values for that particular transition 
	--and calls the onComplete function which was specified by the user
	
	local onComplete = params.onComplete
	params.onComplete = function(obj)	
		local localDestination = object.destination
		for i =1,#localDestination do	
			if localDestination[i]==destination then
				table.remove(object.destination,i)
				table.remove(object.startTime,i)
				table.remove(object.transition,i)
				break
			end
		end		
		if onComplete then
			onComplete(obj)
		end
	end
	
	
	--object.startTime  - table storing starting times of each transition of the object
	--object.transition - table storing transition handles of each transition of the object
	
	object.transition[transitionNo] = transitionToCopy(object,params)
	object.transition[transitionNo].object = object
	object.startTime[transitionNo] = system.getTimer()
	
	return object.transition[transitionNo] 

end


--Function that pauses all transitions of an object

local pause = function(object)

	--object.pausedDestination - table storing transition parameters of each transition with time and delay adjusted after pause
	object.pauedDestination = {}
	
	--for each transition
	for i =1,#object.startTime do
		local object = object
		local destination = object.destination[i]
		local objTransition = object.transition[i]
		local startTime = object.startTime[i]
		
		object.pauedDestination[i] = destination
		local pauedDestination = object.pauedDestination[i]
		
				
		local currentTime = system.getTimer()
		local delay = destination.delay
		
		--time and delay adjustment
		if (startTime+delay) > currentTime then
			pauedDestination.delay = (startTime+delay)-currentTime			
		else
			local timeRemaining = (startTime+delay+destination.time) - currentTime
			pauedDestination.delay = nil
			pauedDestination.time = timeRemaining
		end
		
		--cancel transition		
		transition.cancel(objTransition)
	end
	
	--remove all transition properties of the object from the respective tables
	object.destination = nil
	object.objTransition = nil
	object.startTime = nil
end
	
--resumes all paused transitions of the object
local resume = function(object)

	--pausedDestination holds all transition parameters with adjustments for time and delay
	local pauedDestination = object.pauedDestination
	for i =1,#pauedDestination do
		myTransitionFunction(object,pauedDestination[i])
	end
end

--I override transition.cancel function with my function cancel
--the duplicate i created is used to cencel the transition
local cancel = function(transition)
	local object = transition.object
	local localTransition= object.transition
	for i =1,#localTransition do	
		if localTransition[i]==transition then
			table.remove(object.destination,i)
			table.remove(object.startTime,i)
			table.remove(object.transition,i)
			break
		end
	end	
	transitionCancelCopy(transition)
end

--overriding transition.to and transition.cancel
--assigning transition.pause and transition.resume
transition.to=myTransitionFunction
transition.pause = pause
transition.resume = resume
transition.cancel = cancel