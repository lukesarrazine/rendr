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

local function rotate_y(x, y, z, angle)
    local rad = math.rad(angle)
    local cos_a, sin_a = math.cos(rad), math.sin(rad)
    local new_x = x * cos_a + z * sin_a
    local new_z = -x * sin_a + z * cos_a
    return new_x, y, new_z
end

local function draw_ascii(vertices, zoom)
    local width, height = 160, 40
    local grid = {}
    for i = 0, height - 1 do grid[i] = string.rep(" ", width) end

    for _, v in ipairs(vertices) do
        local x, y = project_perspective(v.x, v.y, v.z, zoom)
        local shifted_x = math.floor((width / 2) + x)
        local shifted_y = math.floor((height / 2) - y)

        if shifted_x >= 0 and shifted_x < width and shifted_y >= 0 and shifted_y < height then
            local row = grid[shifted_y]
            grid[shifted_y] = row:sub(1, shifted_x) .. "*" .. row:sub(shifted_x + 2)
        end
    end

    os.execute("clear")
    for _, line in ipairs(grid) do print(line) end
end

local function rotate_model(vertices, angle_y)
    local rotated_vertices = {}

    for _, v in ipairs(vertices) do
        local x, y, z = rotate_y(v.x, v.y, v.z, angle_y)

        table.insert(rotated_vertices, { x = x, y = y, z = z })
    end

    return rotated_vertices
end

local filepath = args.filepath
local model = read_obj(filepath)


local angle_y = 0
local time = 0

while time < 500 do
    local rotated_vertices = rotate_model(model.vertices, angle_y)
    draw_ascii(rotated_vertices, 2)
    angle_y = angle_y + 1
    time = time + 1
    os.execute("sleep 0.01")
end
