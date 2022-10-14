local partCast = {}
partCast.__index = partCast

--[[

partCast Modes (as of v1)

 - 0. Humanoid Mode - 
Solely returns the player Humanoid that has collided with the castHitbox;
if there's no player Humanoid detected the functionArg will not be run.
 
 - 1. Part Mode -
Returns all hit parts to the functionArg until the cast is terminated with
cast:Terminate() if no part/collision is detected nothing happens.

 - 2. Query Mode -
Runs a query check and depending on the result of the queryFunction() [Must have a return function of a boolean!]; 
it will run one of two functions. successFunc() runs if the verdict is true; failedFunc runs
if the verdict is false. [Note that nil objects will not trigger the function]

]]--

function partCast.new()
	return setmetatable(require(script:WaitForChild("methods")), partCast)
end

return partCast