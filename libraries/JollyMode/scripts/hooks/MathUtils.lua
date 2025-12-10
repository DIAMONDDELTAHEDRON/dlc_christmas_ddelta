local utils = HookSystem.hookScript(MathUtils)

function utils.renewRandomSeed()
    -- If this isn't here then every .random() call after that will be the same value
    -- And will screw stuffs up so this is here
    -- Get the remainder for extra safety measure since .setRandomSeed only accepts
    -- values from 0 to 2^53 - 1
    -- Ok actually thinking about it again this isnt needed at all but whatever
    love.math.setRandomSeed((os.time() + os.clock() * 10000 + love.math.random() * 100000) % (2 ^ 53))
end

return utils