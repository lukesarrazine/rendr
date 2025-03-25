#!/usr/bin/env lua

local argparse = require("argparse")
local parser = argparse("rendr", "A cli tool for rendering")
parser:argument("input", "The input")

local args = parser:parse()
if #args > 0 then
    print("Correct usage: rendr.lua <input>")
    os.exit(0)
end

local input = args.input
print("Your input was " .. input)
