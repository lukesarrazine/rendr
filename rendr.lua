#!/usr/bin/env lua

local argparse = require("argparse")
local parser = argparse("rendr", "A cli tool for rendering")
parser:argument("filepath", "The path to the file input")

local args = parser:parse()
if not args.filepath then
    print("Correct usage: rendr.lua <file>")
    os.exit(1)
end

local function read_obj(filename)
    local vertices = {}

    local file = io.open(filename, "r")
    if not file then
        print("Failed to open file: " .. filename)
        os.exit(1)
    end

    for line in file:lines() do
        local type, a, b, c, d = line:match("(%S+)%s+([%d.-]+)%s+([%d.-]+)%s*([%d.-]*)%s*([%d.-]*)")

        if type == "v" then
            table.insert(vertices, { x = tonumber(a), y = tonumber(b), z = tonumber(c or 0) })
        end
    end
    file:close()

    return { vertices = vertices }
end

local function project_perspective(x, y, z, f)
    if z == 0 then z = 0.01 end
    local X = (x / z) * f
    local Y = (y / z) * f
    return X, Y
end

local function draw_ascii(vertices, zoom)
    local width, height = 160, 40
    local grid = {}
    for i = 0, height - 1 do grid[i] = string.rep(" ", width) end

    for _, v in ipairs(vertices) do
        local x, y = project_perspective(v.x, v.y, v.z, zoom)
        local shifted_x = math.floor((width / 2) + x)
        local shifted_y = math.floor((height / 2) + y)

        if shifted_x >= 0 and shifted_x < width and shifted_y >= 0 and shifted_y < height then
            local row = grid[shifted_y]
            grid[shifted_y] = row:sub(1, shifted_x) .. "*" .. row:sub(shifted_x + 2)
        end
    end

    os.execute("clear") -- Clear terminal
    for _, line in ipairs(grid) do print(line) end
end

local filepath = args.filepath
local model = read_obj(filepath)
draw_ascii(model.vertices, 5)
