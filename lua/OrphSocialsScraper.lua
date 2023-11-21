require "wrapped_captures"
require "tprint"
require "wait"
require "json"

dofile(GetInfo(60) .. "aardwolf_colors.lua")

Orphean_social_list = {}
Orphean_socials = {}

function Orphean_get_socials()
  Capture.untagged_output('socials', true, true, true, Orphean_parse_list, false, nil)
end

function Orphean_get_social(social)
  Capture.untagged_output('shelp ' .. social, true, true, true, Orphean_parse_social, false, nil)
end

function Orphean_fetch_socials_co()
  local count = 1
  local total = #Orphean_social_list

  for _, chunk in chunks(Orphean_social_list, 10) do
    for _, v in ipairs(chunk) do
      print("Processing " .. count .. " / " .. total)
      count = count + 1
      Orphean_get_social(v)
      wait.time(1)
    end
  end

  local data = json.encode(Orphean_socials)
  local file = io.open("aard_socials.json", "w")
  file:write(data)
  io.close(file)
  print("Done!")
end

function Orphean_parse_social(lines)
  -- 1 YouNoArg
  -- 2 OthersNoArg
  -- 3 YouArg
  -- 4 OthersArg
  -- 5 Target
  -- 6 YouSelf
  -- 7 OthersSelf

  local youNoArg = ''
  local othersNoArg = ''
  local youArg = ''
  local othersArg = ''
  local target = ''
  local youSelf = ''
  local othersSelf = ''
  local usage = ''
  local playerUsage = ''
  local mobUsage = ''
  local creator = ''
  local name = ''

  for _, v in ipairs(lines) do
    local styled = StylesToColours(v)
    local line = strip_colours(styled)

    if (string.match(line, "^<1>.*")) then
      youNoArg = line
    elseif (string.match(line, "^<2>.*")) then
      othersNoArg = line
    elseif (string.match(line, "^<3>.*")) then
      youArg = line
    elseif (string.match(line, "^<4>.*")) then
      othersArg = line
    elseif (string.match(line, "^<5>.*")) then
      target = line
    elseif (string.match(line, "^<6>.*")) then
      youSelf = line
    elseif (string.match(line, "^<7>.*")) then
      othersSelf = line
    elseif (string.match(line, "^Usage.*")) then
      usage = line
    elseif (string.match(line, "^Created.*")) then
      creator = line
    elseif (string.match(line, "^Social output.*")) then
      name = line
    end
  end

  youNoArg = string.gsub(youNoArg, "<%d> %- ", "")
  othersNoArg = string.gsub(othersNoArg, "<%d> %- ", "")
  youArg = string.gsub(youArg, "<%d> %- ", "")
  othersArg = string.gsub(othersArg, "<%d> %- ", "")
  target = string.gsub(target, "<%d> %- ", "")
  youSelf = string.gsub(youSelf, "<%d> %- ", "")
  othersSelf = string.gsub(othersSelf, "<%d> %- ", "")
  usage = string.gsub(usage, "Usage this reboot : ", "")
  usage = string.gsub(usage, " ~(player/mob~)", "")
  playerUsage = string.gsub(usage, " %d+$", "")
  mobUsage = string.gsub(usage, "^%d+ ", "")
  creator = string.gsub(creator, "Created by        : ", "")
  name = string.gsub(name, "Social output for ", "")
  name = string.gsub(name, "%.", "")

  local social = {
    youNoArg = youNoArg,
    othersNoArg = othersNoArg,
    youArg = youArg,
    othersArg = othersArg,
    target = target,
    youSelf = youSelf,
    othersSelf = othersSelf,
    playerUsage = playerUsage,
    mobUsage = mobUsage,
    creator = creator,
    name = name
  }

  table.insert(Orphean_socials, social)
end

function Orphean_parse_list(lines)
  for _, v in ipairs(lines) do
    local styled = StylesToColours(v)
    local line = strip_colours(styled)

    local end_line = string.match(line, "%d+ socials listed.")

    if (end_line) then
      break
    end

    for social in string.gmatch(line, "([^%s]+)") do
      if (string.len(social) > 15) then
        local social1 = string.sub(social, 1, 15)
        local social2 = social:gsub(social1, "")
        table.insert(Orphean_social_list, social1)
        table.insert(Orphean_social_list, social2)
      else
        table.insert(Orphean_social_list, social)
      end
    end
  end

  Orphean_socials = {}
  wait.make(Orphean_fetch_socials_co)
end

-- an iterator function that will traverse over lst
function chunks(lst, size)
  -- our current index
  local i = 1
  -- our chunk counter
  local count = 0
  return function()
    -- abort if we reached the end of lst
    if i > #lst then return end
    -- get a slice of lst
    local chunk = table.move(lst, i, i + size - 1, 1, {})
    -- next starting index
    i = i + size
    count = count + 1
    return count, chunk
  end
end
