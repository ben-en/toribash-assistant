-- ta.lua
-- Toribash Assistant
-- by dotproduct/Tinyboss Games

local commandName = "ta"
local playerName = get_master().master.nick
local debug_on = playerName == "dotproduct" or "ennben" and true
local version = "0.4"
local colorBPBlue = {.09,.55,1,1}
local moveButtonWidth = 124

-- predefines:
local moveSaveButtons0, moveSaveButtons1, lblSave0, lblSave1, moveButton, btnLastOpen
local getPosition, setPosition, setKeyBindings
local animals, verbings, adjectives, weapons, bodyparts, transverbs, firstWords, secondWords
local CC, HC, EC

local function dbg(str)
  if debug_on then echo(CC.."["..EC.."D"..CC.."] "..tostring(str)) end
end
local oldEcho = echo
local function echo(str)
  oldEcho(CC.."["..HC.."TA"..CC.."] "..tostring(str))
end

local function choose(t,suffix) 
  suffix = suffix or " "
  return t[math.random(#t)]..suffix
end

local function twoRandomWords()
  local valid = false
  local str
  while not valid do
    local first, second, t
    t = firstWords[math.random(#firstWords)]
    first = t[math.random(#t)]
    t = secondWords[math.random(#secondWords)]
    second = t[math.random(#t)]
    str = first.." "..second
    valid = get_string_length(str, 1) < moveButtonWidth - 12
  end
  return str
end

local function moveName()
  local m = math.random(21)
  if m == 1 then return choose(verbings)..choose(weapons) 
  elseif m == 2  then return choose(verbings)..choose(animals)..choose(bodyparts)
  elseif m == 3  then return choose(adjectives)..choose(animals)..choose(weapons)
  elseif m == 4  then return choose(adjectives)..choose(weapons).."of the "..choose(animals)
  elseif m == 5  then return choose(animals).." and "..choose(animals)
  elseif m == 6  then return choose(verbings)..choose(animals)
  elseif m == 7  then return choose(bodyparts).."of the "..choose(animals)
  elseif m == 8  then return choose(verbings)..choose(weapons)
  elseif m == 9  then return choose(adjectives)..choose(animals)..choose(moves)
  elseif m == 10 then return choose(animals).."breath "..choose(moves)
  elseif m == 11 then return choose(adjectives)..choose(verbings)..choose(moves)
  elseif m == 12 then return choose(animals)..choose(bodyparts)..choose(moves)
  elseif m == 13 then return choose(numbers)..choose(objects)..choose(moves)
  elseif m == 14 then return choose(verbings)..choose(objects)
  elseif m == 15 then return choose(adjectives)..choose(objects)..choose(bodyparts)
  elseif m == 16 then return choose(numbers)..choose(verbings)..choose(objects,"s")
  elseif m == 17 then return choose(animals)..choose(transverbs).."the "..choose(animals)
  elseif m == 18 then return choose(weapons)..choose(moves)
  elseif m == 19 then return choose(animals)..choose(moves)
  elseif m == 20  then return choose(adjectives)..choose(animals)
  elseif m == 21 then return choose(adjectives)..choose(bodyparts)..choose(moves)
  end
end

function serialize(o, indent)
  local indent = indent or ""
  local str = ""
  if type(o) == "number" then
    str = str..o
  elseif type(o) == "string" then
    str = str..string.format("%q", o)
  elseif type(o) == "boolean" then
    if o then str = str.."true" else str = str.."false" end
  elseif type(o) == "function" then
    str = str.."function() supported=false end"
  elseif type(o) == "table" then
    str = str.."{\n"
    for k,v in pairs(o) do
      str = str..indent.."  ["..serialize(k).."] = "..serialize(v, indent.."  ")..",\n"
    end
    str = str..indent.."}"
  else
    str = "cannot serialize a " .. type(o)
  end
  return str
end

function copyTable(t)
  -- Return a copy of table t.
  -- This is only for tables with no cycles!
  local copy = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      copy[k] = copyTable(v)
    else
      copy[k] = v
    end
  end
  return copy
end
	


-- Chat colors:
CC = "^28"  -- chat color
HC = "^61"  -- highlight color
EC = "^41"  -- error color

local playerPlaying = false
local canControl = false
local dragging = false
local guiMoving = false
local guiMoveX, guiMoveY
local paintState, jointHover, jointHoverInfo
local moveTimerEnd = 0
local spaceGuard = 0
local spaceGuardActivated
local committedMove
local commitMargin = 0.5    -- seconds before timer ends to restore the last committed move

local winWidth, winHeight = get_window_size()

local gui = {}
gui.visible = true
gui.mx = 0
gui.my = 0
gui.tick = 0
gui.padding = 5

local jointButtons = {}   -- populated in the draw2d callback function
local grabButtons = {}   -- populated in the draw2d callback function
local miscButtons = {}
local labels = {}

local match = {}
match.moves = {}
match.started = false

local data = {}   -- All persistent data goes here.

local function saveData()
  txt = io.open("tadata.lua","w") 
  txt:write("function tadata() return "..serialize(data).."\n end \n")
  txt:close()
end

-- Restore saved data:
txt = io.open("tadata.lua","r")
if txt == nil then
  saveData()
else
  txt:close()
end
chunk, err = loadfile("tadata.lua")
if err then dbg("error code "..err) else 
  chunk()
  data = tadata()
end

-- Default values:
local function setDefault(key, value) 
  if not data[key] then 
    data[key] = value 
  end 
end
defaultMoves = {
  [1] = {
    ["created"] = 1418682409,
    ["name"] = "The Shoveler",
    ["copiedFrom"] = "dotproduct",
    ["buttonX"] = 104,
    ["buttonY"] = 224,
    ["moves"] = {
      [6] = "3331223223333322112211",
      [1] = "3331213213333333333311",
      [3] = "3331223223333322112211",
      [7] = "3331223223333322112211",
      [8] = "3331223223333322112211",
      [4] = "3331223223333322112211",
      [9] = "3331223223333311221100",
      [2] = "3331223223333322112211",
      [5] = "3331223223333322112211",
    },
  },
  [2] = {
    ["created"] = 1418686951,
    ["name"] = "Judo Kick",
    ["copiedFrom"] = "dotproduct",
    ["buttonX"] = 104,
    ["buttonY"] = 256,
    ["moves"] = {
      [1] = "4221244144442221441401",
    },
  },
}

setDefault("version", 40)
setDefault("sequences", defaultMoves)
setDefault("guiX", winWidth/2)
setDefault("guiY", winHeight - 600)
setDefault("keyCommit", string.byte("q"))
setDefault("settings", {})
-- Default settings:
--if data.settings.moveNames == nil then 
  --data.settings.moveNames = {
    --value = 5,
    --type = "number",
    --desc = "Your character "..HC.."/emote"..CC.."s a random kung-fu sounding move name every "..
           --HC.."moveNames"..CC.." turns. Set to zero to disable."
  --}
--end
if data.settings.guiSize == nil then 
  data.settings.guiSize = {
    value = 60,
    type = "number",
    desc = "The size of the joint layout. Recommended between 50 and 80."
  }  
end
gui.pos = {}
gui.pos.x, gui.pos.y = data.guiX, data.guiY
saveData()

local function adjustButton(i, x, y)
    assert(type(i) == "number")
    assert(type(x) == "number")
    assert(type(y) == "number")
    local seq = data.sequences[i]
    dbg('seq is type(' .. type(seq) .. ')')
    seq.buttonX, seq.buttonY = x, y
end

local function checkPos(x, y)
    local count = 0
    assert(type(x) == "number")
    assert(type(y) == "number")
    dbg('(' .. x .. ', ' .. y .. ')')
    for i, s in pairs(data.sequences) do
        assert(type(s.buttonX) == "number")
        assert(type(s.buttonY) == "number")
        if s.buttonX == x then if s.buttonY == y then 
            dbg(s.name .. ' matches, c = ' .. count)
            count = count + 1 
        end end
    end
    if count > 1 then 
        dbg('count was greater than 1; ' .. count)
        return true 
    else 
        dbg('count was 1 or less; ' .. count)
        return false 
    end
end

local function findOverlaps()
    local overlapping = {}
    for index, seq in pairs(data.sequences) do
        assert(type(seq.buttonX) == "number")
        assert(type(seq.buttonY) == "number")
        dbg("checking " .. seq.name)
        if checkPos(seq.buttonX, seq.buttonY) then 
            dbg(index .. ': ' .. seq.name .. " pos overlapping")
            table.insert(overlapping, index, seq)
        end
    end
    return overlapping
end

local function cleanData()
    local overlaps = findOverlaps()
    local c = 0
    for i, v in pairs(overlaps) do
        assert(type(i) == "number")
        assert(type(v) == "table")
        c = c + 1
        local y, x
        y = 300 + (c * 40)
        x = 300 
        local name = data.sequences[i].name
        dbg('adjusting index ' .. i .. ': ' .. name .. ' to ' .. x .. ', ' .. y)
        adjustButton(i, x, y)
    end
    dbg(c .. " overlaps were found and moved") 
end

cleanData()
saveData()

local jointButtonWidth = data.settings.guiSize.value
local jointButtonHeight = data.settings.guiSize.value

local jointData = {
  -- table index is the Toribash joint index
  -- labels are descriptive of states 1, 2. 
  -- states 3, 4 are always hold, relax.
  -- Position is the (logical) position of this joint in the 2D layout
  -- Five columns (0..4) and eight rows (0..7)
  -- rev indicates to swap the two force options because they make more sense that way
  [0] = {name="Neck", labels={"F","B"}, position={x=2,y=0}},
  [1] = {name="Chest", labels={"R","L"}, position={x=2,y=1}, rev=1},
  [2] = {name="Lumbar", labels={"R","L"}, position={x=2,y=2}, rev=1},
  [3] = {name="Abs", labels={"F","B"}, position={x=2,y=3}},
  [4] = {name="R.Pec", labels={"E","C"}, position={x=4,y=0}, rev=1},
  [5] = {name="R.Shld", labels={"L","R"}, position={x=5,y=1}},
  [6] = {name="R.Elbow", labels={"E","C"}, position={x=5,y=2}, rev=1},
  [7] = {name="L.Pec", labels={"E","C"}, position={x=0,y=0}},
  [8] = {name="L.Shld", labels={"L","R"}, position={x=-1,y=1}, rev=1},
  [9] = {name="L.Elbow", labels={"E","C"}, position={x=-1,y=2}},
  [10]= {name="R.Wrist", labels={"E","C"}, position={x=5,y=3}, rev=1},
  [11]= {name="L.Wrist", labels={"E","C"}, position={x=-1,y=3}},
  [12]= {name="R.Glute", labels={"C","E"}, position={x=3,y=4}},
  [13]= {name="L.Glute", labels={"C","E"}, position={x=1,y=4}, rev=1},
  [14]= {name="R.Hip", labels={"C","E"}, position={x=4,y=5}},
  [15]= {name="L.Hip", labels={"C","E"}, position={x=0,y=5}, rev=1},
  [16]= {name="R.Knee", labels={"E","C"}, position={x=4,y=6}, rev=1},
  [17]= {name="L.Knee", labels={"E","C"}, position={x=0,y=6}},
  [18]= {name="R.Ankle", labels={"C","E"}, position={x=4,y=7}},
  [19]= {name="L.Ankle", labels={"C","E"}, position={x=0,y=7}, rev=1},
}
local keyList = {
  {code="neck", name="Neck", rec="Numpad *"},
  {code="chest", name="Chest", rec="Numpad 8"},  
  {code="lumbar", name="Lumbar", rec="Numpad 5"},  
  {code="abs", name="Abs", rec="Numpad 2"},  
  {code="lpec", name="Left Pec/Glute", rec="Numpad /"},
  {code="rpec", name="Right Pec/Glute", rec="Numpad -"},
  {code="lsho", name="Left Shoulder/Hip", rec="Numpad 7"},  
  {code="rsho", name="Right Shoulder/Hip", rec="Numpad 9"},  
  {code="lelb", name="Left Elbow/Knee", rec="Numpad 4"},  
  {code="relb", name="Right Elbow/Knee", rec="Numpad 6"},  
  {code="lwri", name="Left Wrist/Ankle", rec="Numpad 1"},  
  {code="rwri", name="Right Wrist/Ankle", rec="Numpad 3"},  
  {code="lowmod", name="Lower body modifier", rec="Numpad +"},  
  {code="holdmod", name="Hold/relax modifier", rec="Numpad 0"},  
  {code="grab", name="Grab left/right", rec="Numpad Del"},  
}
local keybindInProgress

local activeSequence  -- the sequence we're executing now, if any
local sequencePos

local function centerText(text, x, y, font)
  draw_text(text, x-get_string_length(text, font)/2, y, font)
end

local function backColor()
  set_color(.8,.8,.8,1)
  --set_color(.55,.85,1,1)
end
local function hoverColor()
  set_color(.7,.7,.7,1)
end
local function clickColor()
  set_color(.6,.6,.8,1)
end
local function hilightColor()
  set_color(1,.4,.4,1)
  --set_color(1,.6,.2,1)
end
local function lockColor()
  set_color(.4,1,.4,1)
end
local function fracColor()
  set_color(.5,.5,1,1)
end
local function dmColor()
  set_color(1,.1,.1,1)
end

local function player()
  -- return current player index
  if get_world_state().selected_player == 1 then return 1 else return 0 end
end
local function opponent()
  -- return current opponent index
  if get_world_state().selected_player == 1 then return 0 else return 1 end
end

local function multiPlayer()
  -- Return whether we're in a multiplayer game
  return get_world_state().game_type == 1
end

local function getTimeLimit()
  if multiPlayer() then return get_world_state().turn_timelimit else return 1000000 end
end

function addButton(x, y, w, h, text, func)
  local btn = {}
  btn.x = x
  btn.y = y
  btn.w = w
  btn.h = h
  btn.text = text
  btn.func = func
  btn.visible = true
  btn.timestamp = os.clock()
  table.insert(miscButtons, btn)
  return btn
end
function mouseInButton(btn)
  return gui.mx>btn.x and gui.my>btn.y and gui.mx<btn.x+btn.w and gui.my<btn.y+btn.h
end

function addLabel(text, x, y, font, color)
  local lbl = {}
  lbl.x = x
  lbl.y = y
  lbl.text = text
  lbl.font = font
  lbl.color = color
  lbl.visible = true
  table.insert(labels, lbl)
  return lbl
end
function drawLabel(lbl)
  if lbl.visible then
    set_color(lbl.color[1], lbl.color[2], lbl.color[3], lbl.color[4])
    draw_text(lbl.text, lbl.x, lbl.y+1, lbl.font)
  end
end

local moveButtonsVisible
local function showMoveButtons(vis)
  if vis then moveButtonsVisible=true else moveButtonsVisible=false end
  for _, btn in pairs(miscButtons) do
    if btn.isMoveButton then btn.visible = moveButtonsVisible end
  end
end

local function posToStr(pos)
  local str = ""
  for i = 0, 21 do str = str..pos[i] end
  return str
end

local function strToPos(str)
  local pos = {}
  for i = 1, string.len(str) do 
    local state = tonumber(string.sub(str, i, i))
    pos[i-1] = state 
  end
  return pos
end

local function drawJointGui(index)
  -- Draw the GUI for a single joint:
  local joint = jointData[index]
  local state = get_joint_info(player(), index).state
  local fractured = get_joint_fracture(player(), index)
  local dismembered = get_joint_dismember(player(), index)
  -- Handle reversed labels:
  local l1, l2 = 1, 2
  if joint.rev then l1, l2 = 2, 1 end
  local w, h = jointButtonWidth, jointButtonHeight
  local jx, jy = joint.position.x, joint.position.y
  local x, y = gui.pos.x + (jx-2.5)*(gui.padding+w/2), gui.pos.y + jy*(gui.padding+h)
  local mx, my = gui.mx, gui.my
  if mx>x and my>y and mx<x+w and my<y+h then hoverColor() else 
    if fractured then fracColor() elseif dismembered then dmColor() else backColor() end
  end
  draw_quad(x, y, w, h)
  jointButtons[index] = {}
  jointButtons[index].x = x
  jointButtons[index].y = y
  jointButtons[index].w = w
  jointButtons[index].h = h
  if not (fractured or dismembered) then
    -- Indicate current state:
    if state == 3 then 
      set_color(0,0,0,1)
      draw_quad(x-1, y-1, w+2, h+2)
      if mx>x and my>y and mx<x+w and my<y+h then hoverColor() else backColor() end
      draw_quad(x+3, y+3, w-6, h-6)
    elseif state == l1 then
      hilightColor()
      draw_quad(x,y,w/2.5,20)
    elseif state == l2 then
      hilightColor()
      draw_quad(x+w-w/2.5,y,w/2.5,20)
    end
  end
  local function tcolor(st)
    if state == st then set_color(1,1,1,1) else set_color(0,0,0,0.5) end
  end
  if not (fractured or dismembered) then
    tcolor(3)
    centerText("X", x+10, y+h-18, 1)
    tcolor(4)
    centerText("O", x+w-10, y+h-18, 1)
    tcolor(l1)
    centerText(joint.labels[l1], x+10, y+2, 1)
    tcolor(l2)
    centerText(joint.labels[l2], x+w-10, y+2, 1)
  end
  set_color(0,0,0,1)
  centerText(joint.name, x+w/2, y+h/2-9, 1)
end

local function hookDraw3d()
  -- Have to find screen coordinates of the joint in the draw3d event, doesn't work from draw2d:
  if jointHover then
    if canControl then
      local jx, jy, jz = get_joint_pos(player(), jointHover)
      local sx, sy = get_screen_pos(jx, jy, jz)
      jointHoverInfo = {sx=sx,sy=sy,jx=jx,jy=jy,jz=jz}
      set_color(0,1,0,.75)
      draw_sphere(jx, jy, jz, 1.1*get_joint_radius(player(), jointHover))
    end
  else
    jointHoverInfo = nil
  end
end

local function hookDraw2d()
  -- Handle timing stuff:
  local timeRemaining = moveTimerEnd - os.clock()
  if timeRemaining > 0 then
    if canControl and committedMove and timeRemaining < commitMargin then
      -- Time is running out and a committed move exists. Revert to it and disable control:
      setPosition(player(), committedMove)
      canControl = false
      echo(CC.."Reverting to committed move.")
    else
      set_color(0,0,0,math.max(0, 1-timeRemaining/10))
      local w = 40*timeRemaining
      draw_quad(gui.pos.x+100-w/2, gui.pos.y-100, w, 10)
    end
  else
    canControl = false
  end
  -- Draw the GUI:
  for _, lbl in pairs(labels) do drawLabel(lbl) end
  local mx, my = gui.mx, gui.my
  guiDrawn = false
  if player() ~= -1 then
    if gui.visible then
      if match.started and playerPlaying then
        guiDrawn = true
        -- Draw the joint buttons:
        for i=0, #jointData do drawJointGui(i) end
        -- Draw the grab buttons:
        local w, h = jointButtonWidth, jointButtonHeight
        local handSize = jointButtonWidth*0.7
        -- Left hand:
        local jx, jy = -3.5, 4
        local x, y = gui.pos.x-2+jx*(gui.padding+jointButtonWidth/2), gui.pos.y + jy*(gui.padding+jointButtonHeight)
        local lock = get_grip_lock(player(), BODYPARTS.L_HAND)
        local grab = get_grip_info(player(), BODYPARTS.L_HAND)
        if grab==1 then
          set_color(0,0,0,1)
          draw_quad(x, y, handSize, handSize)
        end
        if lock==1 then lockColor() else 
          if mx>x and my>y and mx<x+handSize and my<y+handSize then hoverColor() else backColor() end
        end
        draw_quad(x+2, y+2, handSize-4, handSize-4)
        set_color(0,0,0,1)
        local gb = {}
        gb.x, gb.y, gb.w, gb.h = x, y, handSize, handSize
        gb.index = BODYPARTS.L_HAND
        grabButtons[1] = gb    
        -- Right hand:
        local jx, jy = 7, 4
        local x, y = gui.pos.x-3+(jx-2.5)*(gui.padding+jointButtonWidth/2)-handSize-gui.padding, gui.pos.y + jy*(gui.padding+jointButtonHeight)
        local lock = get_grip_lock(player(), BODYPARTS.R_HAND)
        local grab = get_grip_info(player(), BODYPARTS.R_HAND)
        if grab==1 then
          set_color(0,0,0,1)
          draw_quad(x, y, handSize, handSize)
        end
        if lock==1 then lockColor() else 
          if mx>x and my>y and mx<x+handSize and my<y+handSize then hoverColor() else backColor() end
        end
        draw_quad(x+2, y+2, handSize-4, handSize-4)
        local gb = {}
        gb.x, gb.y, gb.w, gb.h = x, y, handSize, handSize
        gb.index = BODYPARTS.R_HAND
        grabButtons[2] = gb    
      end
    end
  end
  for _, btn in pairs({btnCopy, btnPaste, btnMirror, btnDrag}) do btn.visible = guiDrawn end
  -- Draw miscellaneous buttons:
  for _, btn in pairs(miscButtons) do
    if btn.visible then
      if btn.isMoving then btn.x, btn.y = 8*math.floor((gui.mx+btn.offx)/8), 8*math.floor((gui.my+btn.offy)/8) end
      backColor()
      if gui.mx>btn.x and gui.my>btn.y and gui.mx<btn.x+btn.w and gui.my<btn.y+btn.h then
        if dragging then clickColor() else hoverColor() end
      else
        backColor()
      end
      draw_quad(btn.x, btn.y, btn.w, btn.h)
      set_color(0,0,0,1)
      centerText(btn.text, btn.x+btn.w/2, btn.y+btn.h/2-9, 1)
      if btn.isMoveButton and btn.index<0 then
        -- This is a special move button, so distinguish it:
        set_color(0,0,0,1)
        local lw = 0.1
        local inset = 3
        draw_line(btn.x+inset, btn.y+inset, btn.x+btn.w-inset, btn.y+inset, lw)
        draw_line(btn.x+inset, btn.y+inset, btn.x+inset, btn.y+btn.h-inset, lw)
        draw_line(btn.x+btn.w-inset, btn.y+btn.h-inset, btn.x+btn.w-inset, btn.y+inset, lw)
        draw_line(btn.x+btn.w-inset, btn.y+btn.h-inset, btn.x+inset, btn.y+btn.h-inset, lw)
      end
      -- Help text for the drag button:
      if btn.text == "+" and not data.hasRepositioned then
        set_color(.40,.7,1,1)
        draw_disk(btn.x+btn.w/2, btn.y+btn.h/2, 15, 20, 32, 1, 0, 360, 0)
        draw_text("Click and drag to reposition", btn.x-150, btn.y+30, 2)
      end
    end
  end
end

local function jointButtonAtXY(x, y)
  -- Return an index if (x,y) is inside a joint button, nil otherwise
  for i = 0, #jointButtons do
    local jb = jointButtons[i]
    if jb then if x>jb.x and x<=jb.x+jb.w and y>jb.y and y<=jb.y+jb.h then return i end end
  end
  return nil
end

-- Mouse clicks:
local function hookMouseDown(btn, x, y)
  --dbg("click: "..x..","..y)
  -- btn: 1=left, 2=middle, 3=right
  dragging = true 
  if canControl then  -- only process these when control is enabled
    -- Check whether a joint button was clicked:
    i = jointButtonAtXY(x, y)
    if i then
      -- A joint button was clicked:
      if not (get_joint_fracture(player(),i) or get_joint_dismember(player(),i)) then
        local jb = jointButtons[i]
        local joint = jointData[i]
        -- Handle reversed labels:
        local l1, l2 = 1, 2
        if joint.rev then l1, l2 = 2, 1 end
        rx, ry = x-jb.x, y-jb.y   -- click position relative to button
        newState = 0
        if rx<jb.w/2 and ry<jb.h/2 then newState = l1 paintState = 1 end
        if rx>jb.w/2 and ry<jb.h/2 then newState = l2 paintState = 2 end
        if rx<jb.w/2 and ry>jb.h/2 then newState = 3 paintState = 3 end
        if rx>jb.w/2 and ry>jb.h/2 then newState = 4 paintState = 4 end
        --dbg(newState)
        if newState > 0 then set_joint_state(player(), i, newState) set_ghost(2) end
      end
    end
    -- Check whether a grab button was clicked:
    for _, gb in ipairs(grabButtons) do
      if x>gb.x and x<=gb.x+gb.w and y>gb.y and y<=gb.y+gb.h then
        local currentState = get_grip_info(player(), gb.index)
        if currentState == 0 then
          set_grip_info(player(), gb.index, 1)
        else
          set_grip_info(player(), gb.index, 0)
        end
      end
    end  
  end
  -- Check whether a miscellaneous button was clicked:
  for _, mb in pairs(miscButtons) do
    --if mb.visible and x>mb.x and x<=mb.x+mb.w and y>mb.y and y<=mb.y+mb.h then
    if mb.visible and mouseInButton(mb) then
      if mb.isMoving then 
        if os.clock()-mb.timestamp > 0.2 then 
          mb.isMoving = false 
          if mb.isMoveButton then
            -- Save the location of this move button:
            if mb.index == -1 then
              data.lastOpenX, data.lastOpenY = mb.x, mb.y
            elseif mb.index == -2 then
              data.lastOppOpenX, data.lastOppOpenY = mb.x, mb.y
            else
              local seq = data.sequences[mb.index]
              seq.buttonX, seq.buttonY = mb.x, mb.y
            end
            saveData()
          end
        end
      else 
        -- Mouse button clicked inside a button:
        mb.clicking = true
        if mb.text == "+" then mb.func() end  -- kind of a hack to make the GUI drag button work
        if mb.isMoveButton then 
          mb.oldmx, mb.oldmy = gui.mx, gui.my
          mb.oldx, mb.oldy = mb.x, mb.y
         end
      end
    end
  end
end

local function hookMouseUp(btn, x, y)
  dragging = false
  paintState = nil
  if guiMoving then
    -- GUI was dragged, so save the position:
    data.guiX, data.guiY = gui.pos.x, gui.pos.y
    saveData()
  else
    for _, mb in pairs(miscButtons) do
      if mb.clicking and x>mb.x and x<=mb.x+mb.w and y>mb.y and y<=mb.y+mb.h and mb.text~="+" then
        -- Mouse button released inside the same button it was pressed down on:
        if mb.isMoving then 
          mb.isMoving=false
          dbg("ismoving=false")
          if mb.isMoveButton then
            if mouseInButton(btnDelete) then
              if mb.index < 0 then
                -- Can't delete the last opener buttons!
                mb.isMoving = false
                mb.x, mb.y = mb.oldx, mb.oldy
              else
                -- Delete this move:
                table.remove(data.sequences, mb.index)
                -- Remove the button:
                mb.visible = false
                mb.isMoveButton = false
                -- Readjust indices of other buttons:
                for _, btn in pairs(miscButtons) do
                  if btn.isMoveButton and btn.index>mb.index then 
                    btn.index=btn.index-1 
                    btn.func = function() moveButton(btn.index) end
                  end
                end
              end
            else
              -- Save the new location:
              if mb.index == -1 then
                data.lastOpenX, data.lastOpenY = mb.x, mb.y
              elseif mb.index == -2 then
                data.lastOppOpenX, data.lastOppOpenY = mb.x, mb.y
              else
                local seq = data.sequences[mb.index]
                seq.buttonX, seq.buttonY = mb.x, mb.y
              end
            end
            saveData() 
          end
        else 
          mb.func() 
        end
      end
      mb.clicking = false
      mb.oldmx, mb.oldmy = nil, nil
    end
  end
  guiMoving = false
  btnDelete.visible = false
  for _, btn in pairs(miscButtons) do
    if os.clock()-btn.timestamp > 0.2 then btn.isMoving = false else dbg("too new to release") end
  end
end

local function hookMouseMove(x, y)
  gui.mx, gui.my = x, y
  local i = jointButtonAtXY(x, y)
  jointHover = i
  --if jointHover then dbg("hover "..jointHover) end
  if dragging and canControl and paintState then
    if i then   -- hovering over a joint button
      local joint = jointData[i]
      local newState = paintState
      if joint.rev then if newState==1 then newState=2 elseif newState==2 then newState=1 end end
      if get_joint_info(player(), i).state ~= newState then 
        set_joint_state(player(), i, newState)
        set_ghost(2)
      end
    end
  end
  if dragging and guiMoving then
    data.hasRepositioned = true
    local dx = gui.mx - guiMoveX
    local dy = gui.my - guiMoveY
    gui.pos.x = gui.pos.x + dx
    gui.pos.y = gui.pos.y + dy
    for _, btn in pairs({btnCopy, btnPaste, btnMirror, btnDrag}) do
      btn.x = btn.x + dx
      btn.y = btn.y + dy
    end
    guiMoveX, guiMoveY = gui.mx, gui.my
  end
  for _, btn in pairs(miscButtons) do
    -- Draggable move buttons
    if btn.oldmx and btn.oldmy then
      if not btn.isMoving and (math.abs(gui.mx-btn.oldmx)>16 or math.abs(gui.my-btn.oldmy)>16) then 
        btn.isMoving = true 
        btn.offx, btn.offy = btn.x-gui.mx, btn.y-gui.my
        btn.offx, btn.offy = -btn.w/2, -btn.h/2
        btnDelete.visible = true
      end
    end
  end
end

local function hookEnterFreeze()
  --dbg("Enter freeze.")
  -- Save both players' positions:
  --dbg("saving player moves...")
  match.moves[0][match.round] = getPosition(0)
  match.moves[1][match.round] = getPosition(1)
  -- If the first round just ended, save the openers:
  if match.round == 1 and playerPlaying then
    dbg("saving openers")
    data.lastOpener = getPosition(player())
    data.lastOppOpener = getPosition(opponent())
  end
  lblSave0.visible = true
  lblSave1.visible = true
  for i = 1, match.round do
    if moveSaveButtons1[i] then moveSaveButtons1[i].visible = true end
    if moveSaveButtons0[i] then 
      moveSaveButtons0[i].visible = true 
      moveSaveButtons0[i].x = winWidth - 300 - 25*(math.min(10,match.round)-1-i)
    end
  end
  lblSave0.x = moveSaveButtons0[1].x -- - 10 - get_string_length(lblSave0.text, 1)
  lblSave0.y = lblSave1.y
  committedMove = nil
  if playerPlaying then 
    if activeSequence then
      sequencePos = sequencePos + 1
      if data.sequences[activeSequence].moves[sequencePos] then
        setPosition(player(), data.sequences[activeSequence].moves[sequencePos])
        echo(CC.."Advancing to move "..sequencePos.." of sequence "..activeSequence)
      else
        echo(CC.."Sequence "..activeSequence.." completed!")
        activeSequence = nil
      end
    end
    --if data.settings.moveNames.value > 0 then
      --if match.round % data.settings.moveNames.value == 1 then run_cmd("emote "..moveName().."\n") end
    --end
  end
  match.round = match.round + 1
  --dbg("Starting round "..match.round)
  if playerPlaying then
    moveTimerEnd = os.clock()+getTimeLimit()
    canControl = true
  else
    moveTimerEnd = 0
  end
end

local function hookExitFreeze()
  -- This event doesn't seem to fire in multiplayer.
  --dbg("Exit freeze.")
end

local function hookMatchBegin()
  --dbg("Match beginning, starting round 1.")
  match.started = true
  match.round = 1
  match.player = {}
  match.moves = {}
  match.moves[0] = {}
  match.moves[1] = {}
  committedMove = nil
  playerPlaying = false
  for i = 0, 1 do
    local pinfo = get_player_info(i)
    match.player[i] = pinfo
    if string.find(pinfo.name, playerName) then playerPlaying = true end
    --dbg("Player "..i.." information:")
    --for k,v in pairs(pinfo) do dbg("   "..k..": "..v) end
  end
  lblSave0.visible = false
  lblSave1.visible = false
  for i, btn in ipairs(moveSaveButtons0) do btn.visible = false end
  for i, btn in ipairs(moveSaveButtons1) do btn.visible = false end
  activeSequence = nil
  if playerPlaying then
    moveTimerEnd = os.clock()+getTimeLimit()
    canControl = true
    spaceGuard = os.clock()+1
  else
    moveTimerEnd = 0
  end
  math.randomseed(os.clock()*1000)
end

function getPosition(player)
  local pos = {}
  for i = 0, 19 do
    pos[i] = get_joint_info(player, i).state
  end
  pos[20] = get_grip_info(player, BODYPARTS.L_HAND)
  pos[21] = get_grip_info(player, BODYPARTS.R_HAND)
  return posToStr(pos)
end

function setPosition(player, pos)
  if pos == nil then return 0 end
  pos = strToPos(pos)
  for i = 0, 19 do
    set_joint_state(player, i, pos[i])
  end
  set_grip_info(player, BODYPARTS.L_HAND, pos[20])
  set_grip_info(player, BODYPARTS.R_HAND, pos[21])
  set_ghost(2)
end

function mirrorPosition(spos)
  local pos = strToPos(spos)
  local mpos = {}
  -- Mirror the left/right symmetrical parts:
  local mirrorPairs = {{4,7}, {5,8}, {6,9}, {10,11}, 
    {12,13}, {14,15}, {16,17}, {18,19}, {20, 21}}
  for _, p in ipairs(mirrorPairs) do mpos[p[1]], mpos[p[2]] = pos[p[2]], pos[p[1]] end
  -- Neck and abs are unchanged:
  mpos[0], mpos[3] = pos[0], pos[3]
  -- Change direction of chest and lumbar:
  mpos[1], mpos[2] = pos[1], pos[2]
  if mpos[1]==1  then mpos[1]=2 elseif mpos[1]==2 then mpos[1]=1 end
  if mpos[2]==1  then mpos[2]=2 elseif mpos[2]==2 then mpos[2]=1 end
  return posToStr(mpos)
end

local function copyPos()
  data.savedPos = getPosition(player())
  saveData()
end

local function pastePos()
  if data.savedPos ~= nil then
    setPosition(player(), data.savedPos)
  else
    echo(CC.."No saved position to paste!")
  end
end

-- This function receives every command entered, and responds to the ones meant for BodyPlan:
local function hookCommand(cmdString)
  if cmdString:sub(1, 1+string.len(commandName)) == commandName.." " then
    local s = cmdString:sub(4)
		--dbg("bodyplan got command: ^07"..s)
    if s:sub(1, 4) == "set " then
      dbg("set")
      s = s:sub(5)
      for settingName, settingData in pairs(data.settings) do
        if string.lower(s:sub(1, 1+string.len(settingName))) == string.lower(settingName).." " then
          dbg(settingName)
          local value = s:sub(2+string.len(settingName))
          if settingData.type == "number" then 
            value = tonumber(value)
            if value == nil then
              echo(settingName.." must be a number.")
              return 1
            end
          end
          -- If we get here, then we have a valid settingName and value.
          settingData.value = value
          saveData()
          echo(HC..settingName..CC.." is now "..HC..value..CC..".")
        end
      end
    elseif s == "save" then
      copyPos()
    elseif s == "load" then
      pastePos()
    elseif s == "ser" then
      echo(serialize(copyTable({[0]=9,1,2,3,{5,6,7}})))
    elseif s:sub(1, 2)=="do" then
      -- no error checking, this is only for testing!
      local i = tonumber(s:sub(4))
      --dbg("do "..i)
      local r = match.round
      activeSequence = i
      sequencePos = 1
      -- Load the first move
      setPosition(player(), data.sequences[i][1])
      echo(CC.."Sequence "..i.." activated!")
    elseif s:sub(1, 4)=="stop" then
      echo(CC.."Stopping active sequence.")
      activeSequence = nil
    elseif s:sub(1, 4)=="time" then
      echo(tostring(os.clock()))
    elseif s:sub(1, 3)=="pos" then
      local p = strToPos(data.savedPos)
      for i=0,21 do echo(i..": "..p[i]) end
    elseif s:sub(1, 7)=="setkeys" then setKeyBindings()
    elseif s:sub(1, 5)=="rname" then for i=1,10 do echo(twoRandomWords()) end
    elseif s:sub(1, 5)=="name " then
      local newName = s:sub(6)
      if renameButton then
        local seq = data.sequences[renameButton.index]
        if seq then
          seq.name = newName
          renameButton.text = newName
          saveData()
        end
      end
    elseif s:sub(1, 8)=="resetpos" then
      dbg("resetting position")
      -- Reposition the GUI so the repositioning button is near the center of the screen
      dx, dy = winWidth/2-gui.pos.x, winHeight/2-7*jointButtonHeight-gui.pos.y
      gui.pos.x, gui.pos.y = gui.pos.x+dx, gui.pos.y+dy
      btnCopy.x, btnCopy.y = btnCopy.x+dx, btnCopy.y+dy
      btnPaste.x, btnPaste.y = btnPaste.x+dx, btnPaste.y+dy
      btnMirror.x, btnMirror.y = btnMirror.x+dx, btnMirror.y+dy
      btnDrag.x, btnDrag.y = btnDrag.x+dx, btnDrag.y+dy
      data.hasRepositioned = nil
    elseif s:sub(1, 4)=="help" then
      echo("Press "..HC.."M"..CC.." to show/hide saved moves.")
      echo("Click and drag move buttons to rearrange them.")
      echo("Press "..HC.."Q"..CC.." to commit a move.")
      echo("More information here:")
      echo("http://forum.toribash.com/showthread.php?t=492156")
    end
    return 1
  end
end

local function hookEndGame()
  --dbg("Match ended.")
  match.started = false
  activeSequence = nil
end

function moveButton(index)
  -- A move button was clicked
  if index == -1 then
    -- This is the "last opener" button
    dbg("loading last opener")
    if data.lastOpener then setPosition(player(), data.lastOpener) else dbg("no last opener to load") end
  elseif index == -2 then
    -- Last opponent opener:
    dbg("loading last opponent's opener")
    if data.lastOppOpener then setPosition(player(), data.lastOppOpener) else dbg("no last opponent's opener to load") end
  else
    activeSequence = index
    sequencePos = 1
    -- Load the first move
    dbg("index is "..index)
    setPosition(player(), data.sequences[index].moves[1])
    echo("Sequence "..HC..data.sequences[index].name..CC.." activated!")
  end
end

local function saveSequence(playerIndex, numMoves)
  -- Save a player's moves:
  local seq = {moves={}}
  for i = 1, numMoves do table.insert(seq.moves, match.moves[playerIndex][i]) end
  seq.name = twoRandomWords()
  seq.copiedFrom = get_player_info(playerIndex).name
  seq.created = os.time()
  table.insert(data.sequences, seq)
  saveData()
  -- Make a new button for this sequence:
  local index = #data.sequences
  local btn = addButton(gui.mx-40, gui.my-15, moveButtonWidth, 28, seq.name, function() moveButton(index) end)
  btn.isMoveButton = true
  btn.index = index
  btn.isMoving = true
  btn.offx, btn.offy = btn.x-gui.mx, btn.y-gui.my
  showMoveButtons(true)
end

local function hookEnterFrame()
  --canControl = false
end

local function mirPos()
  setPosition(player(), mirrorPosition(getPosition(player())))
end

local function guiDrag()
  guiMoving = true
  guiMoveX, guiMoveY = gui.mx, gui.my
end

local function keyBindPrompt()
  local k = keyList[keyBindInProgress]
  if k then
    echo("Press key for "..HC..k.name..CC.." (recommended: "..HC..k.rec..CC..")")
  else
    echo("Key bind setting complete! If you want to")
    echo("change your bindings later, type "..HC.."/"..commandName.." setkeys"..CC..".")
    echo("Type "..HC.."/"..commandName.." help"..CC.." for help.")
    keyBindInProgress = nil
    saveData()
  end
end

local firstBind = true
local lowerBodyMod, holdRelaxMod, grabMode
local function hookKeyUp(k)
  -- Capture key for keybind setting if that's going on:
  if keyBindInProgress then
    if firstBind then firstBind=false return 1 end    -- hack to avoid the keyUp from the enter key being detected:
    kb = keyList[keyBindInProgress]
    data.bind[k] = kb.code
    keyBindInProgress = keyBindInProgress + 1
    keyBindPrompt()
    return 1
  end
  -- If SpaceGuard prevented the keyDown event, prevent the corresponding keyUp one:
  if k==string.byte(" ") and spaceGuardActivated then
    spaceGuardActivated = false
    return 1
  end
  -- Check for modifier keys being released:
  local code = data.bind[k]
  if code then
    if code == "lowmod" then lowerBodyMod = false end
    if code == "holdmod" then holdRelaxMod = false end
    return 1
  end
  if k==string.byte("b") then 
    -- Show/hide move buttons:
    showMoveButtons(not moveButtonsVisible) 
    return 1
  elseif k==string.byte("n") then
    -- Rename a move:
    local rbtn
    for _, btn in pairs(miscButtons) do
      if btn.isMoveButton and gui.mx>btn.x and gui.my>btn.y and gui.mx<btn.x+btn.w and gui.my<btn.y+btn.h then
        rbtn = btn
      end
    end
    if rbtn then
      echo("To rename "..data.sequences[rbtn.index].name.." type "..HC.."/"..commandName.." name <new name>")
      renameButton = rbtn
    else
      if renameButton then echo("Renaming canceled.") end
      renameButton = nil
    end
  end
end

local function hookKeyDown(k)
  --dbg("Got key "..k)
  -- If we're setting keybinds, ignore this and capture the keyUp event:
  if keyBindInProgress then return 1 end
  if k == string.byte(" ") and os.clock() < spaceGuard then
    -- Disable spacebar when match is starting:
    echo(CC.."SpaceGuard prevented ending turn!")
    spaceGuardActivated = true
    return 1
  end
  if k == data.keyCommit and canControl then
    if get_shift_key_state() == 0 then
      -- Commit key pressed, so commit current move:
      committedMove = getPosition(player())
      echo(CC.."Committed move.")
    else
      -- Shift+commit key pressed, so revert to previously committed move:
      if committedMove then
        echo(CC.."Reverting to committed move.")
        setPosition(player(), committedMove)
      else
        echo(CC.."No committed move to revert to!")
      end
    end
  end
  -- Check to see if it's another bound key:
  local code = data.bind[k]
  if code then
    local joint
    if code == "lowmod" then lowerBodyMod = true
    elseif code == "holdmod" then holdRelaxMod = true
    elseif code == "neck" then joint = 0
    elseif code == "chest" then joint = 1
    elseif code == "lumbar" then joint = 2
    elseif code == "abs" then joint = 3
    elseif code == "lpec" then if lowerBodyMod then joint = 13 else joint =  7 end
    elseif code == "rpec" then if lowerBodyMod then joint = 12 else joint =  4 end
    elseif code == "lsho" then if lowerBodyMod then joint = 15 else joint =  8 end
    elseif code == "rsho" then if lowerBodyMod then joint = 14 else joint =  5 end
    elseif code == "lelb" then if lowerBodyMod then joint = 17 else joint =  9 end
    elseif code == "relb" then if lowerBodyMod then joint = 16 else joint =  6 end
    elseif code == "lwri" then if lowerBodyMod then joint = 19 else joint = 11 end
    elseif code == "rwri" then if lowerBodyMod then joint = 18 else joint = 10 end
    elseif code == "grab" then
      if canControl then
        if holdRelaxMod then
          set_grip_info(player(), BODYPARTS.R_HAND, 1)
          set_grip_info(player(), BODYPARTS.L_HAND, 1)
        elseif lowerBodyMod then
          set_grip_info(player(), BODYPARTS.R_HAND, 0)
          set_grip_info(player(), BODYPARTS.L_HAND, 0)
        else
          if grabMode then
            set_grip_info(player(), BODYPARTS.R_HAND, 1)
            set_grip_info(player(), BODYPARTS.L_HAND, 0)
          else
            set_grip_info(player(), BODYPARTS.L_HAND, 1)
            set_grip_info(player(), BODYPARTS.R_HAND, 0)
          end
          grabMode = not grabMode
        end
        set_ghost(2)
      end
    end
    if joint then
      if canControl then
        local str = code
        if holdRelaxMod then str = "hold "..str end
        if lowerBodyMod then str = "lower "..str end
        dbg(CC.."key: "..str)
        local currentState = get_joint_info(player(), joint).state
        local newState
        if holdRelaxMod then
          if currentState == 3 then newState = 4 else newState = 3 end
        else
          if currentState == 1 then newState = 2 else newState = 1 end
        end
        set_joint_state(player(), joint, newState)
        set_ghost(2)
      end
    end
    return 1
  end
end
--[[ 
Note: when you return 1 from an event hook like key up/down, 
mouse button, etc, it stops any other processing of that event.
--]]

function setKeyBindings()
  -- Ask the user for key bindings:
  data.bind = {}
  keyBindInProgress = 1
  firstBind = true
  keyBindPrompt()
end

local btnx, btny = gui.pos.x + (-.5)*(gui.padding+jointButtonWidth/2), gui.pos.y + (-.7)*(gui.padding+jointButtonHeight)
btnPaste = addButton(btnx, btny, jointButtonWidth, 30, "Paste", pastePos)
local btnx, btny = gui.pos.x + (-2.5)*(gui.padding+jointButtonWidth/2), gui.pos.y + (-.7)*(gui.padding+jointButtonHeight)
btnCopy = addButton(btnx, btny, jointButtonWidth, 30, "Copy", copyPos)
local btnx, btny = gui.pos.x + (1.5)*(gui.padding+jointButtonWidth/2), gui.pos.y + (-.7)*(gui.padding+jointButtonHeight)
btnMirror = addButton(btnx, btny, jointButtonWidth, 30, "Mirror", mirPos)
btnDrag = addButton(gui.pos.x, gui.pos.y+8*jointButtonHeight, 20, 20, "+", guiDrag)
btnDelete = addButton(winWidth/2-100, 75, 200, 75, "Drag here to delete", function() end)
btnDelete.visible = false

-- Add the move saving buttons:
moveSaveButtons0 = {}
moveSaveButtons1 = {}
lblSave1 = addLabel("Save moves 1 to", 200, 20, 1, colorBPBlue)
lblSave1.visible = false
for i = 1, 10 do
  local w, h = 22, 20
  if i<10 then label=tostring(i) else label="All" end
  moveSaveButtons1[i] = addButton(200+(w+3)*(i-1), 45, w, h, label, function() saveSequence(1, i) end)
  moveSaveButtons1[i].visible = false
end
lblSave0 = addLabel("Save moves 1 to", 5, 80, 1, colorBPBlue)
lblSave0.visible = false
for i = 1, 10 do
  local w, h = 22, 20
  if i<10 then label=tostring(i) else label="All" end
  moveSaveButtons0[i] = addButton(0, 45, w, h, label, function() saveSequence(0, i) end)
  moveSaveButtons0[i].visible = false
end

function notifyEvent(event)
  add_hook(event, "bpNotify"..event, function() dbg("Event "..event.." fired.") end)
end

-- Recreate move buttons:
for index, seq in pairs(data.sequences) do
  local btn = addButton(seq.buttonX, seq.buttonY, moveButtonWidth, 28, seq.name, function() moveButton(index) end)
  btn.isMoveButton = true
  btn.index = index
end
local lx, ly = data.lastOpenX, data.lastOpenY
if lx==nil then lx = 200 end
if ly==nil then ly = 200 end
btnLastOpen = addButton(lx, ly, moveButtonWidth, 28, "Last Opener", function() moveButton(-1) end)
btnLastOpen.isMoveButton = true
btnLastOpen.index = -1
lx, ly = data.lastOppOpenX, data.lastOppOpenY
if lx==nil then lx = 200 end
if ly==nil then ly = 232 end
btnLastOppOpen = addButton(lx, ly, moveButtonWidth, 28, "Last Opp. Open", function() moveButton(-2) end)
btnLastOppOpen.isMoveButton = true
btnLastOppOpen.index = -2
showMoveButtons(true)

-- Register callbacks:
add_hook("command", "bpHookCommand", hookCommand)
add_hook("draw2d", "bpHookDraw2d", hookDraw2d)
add_hook("draw3d", "bpHookDraw3d", hookDraw3d)
add_hook("mouse_move","bpHookMouseMove", hookMouseMove)
add_hook("mouse_button_down","bpHookMouseDown", hookMouseDown)
add_hook("mouse_button_up","bpHookMouseUp", hookMouseUp)
add_hook("enter_freeze", "bpHookEnterFreeze", hookEnterFreeze)
add_hook("exit_freeze", "bpHookExitFreeze", hookExitFreeze)
add_hook("match_begin", "bpHookMatchBegin", hookMatchBegin)
add_hook("end_game", "bpHookEndGame", hookEndGame)
add_hook("enter_frame", "bpHookEnterFrame", hookEnterFrame)
add_hook("key_up", "bpHookKeyUp", hookKeyUp)
add_hook("key_down", "bpHookKeyDown", hookKeyDown)


echo("Toribash Assistant "..version.." by "..HC.."dotproduct"..CC..".")
echo("This is an alpha, there may be bugs!")
echo(CC.."Type "..HC.."/"..commandName.." help"..CC.." for help.")
--for i = 0, 9 do dbg("This is ^0"..i.." color "..i) end
--for i = 10, 99 do dbg("This is ^"..i.." color "..i) end

if data.bind == nil then
  -- Need to do first-time keybinding setup:
  echo(CC.."We need to set up keys for keyboard joint control.")
  echo(CC.."This only needs to be done one time.")
  setKeyBindings()
end

animals = {"dog", "crane", "mantis", "tiger", "ox", "rooster", "cat", "snake", "viper", "dragon",
  "turtle", "cricket", "rabbit", "rat", "horse", "ram", "phoenix", "eagle", "panda", "hawk", "deer", 
  "koi", "eel", "hummingbird", "dragonfly", "bear", "bull", "cow", "sheep", "pig", "falcon", "yak", 
  "frog", "silkworm", "butterfly", "moth", "elephant", "firefly", "peacock", "leopard", "scorpion", }
verbings = {"flying", "crouching", "offering", "walking", "rising", "falling", "reaching", "sitting",
  "yielding", "stunning", "shattering", "crushing", "whirling", "roaring", "screaming", "whispering",
  "thundering", "creeping", "deceiving", "constricting", "twisting", "grasping", "turning", "swimming", 
  "sticking", "following", "erupting", "meditating", }
weapons = {"staff", "sword", "pole", "blade", "stick", "knife", "spear", "hammer", "chain",
  "sickle", "scythe", "axe", "arrow", "fan", "club", "bow", "whip", "lance", "hatchet", "pike", 
  "spike", "corkscrew", "hook", "lasso", "boot", }
bodyparts = {"hand", "foot", "wrist", "fist", "palm", "knee", "shin", "leg", "heel", "knuckle", "forehead", "claw",
  "elbow", "beak", "tooth", "tail", "horn", }
adjectives = {"twice-cooked", "wushu", "celestial", "great", "rapid", "quick", "powerful", "shaolin", "kung-fu", 
  "fortunate", "glorious", "honorable", "mighty", "lucky", "dreaded", "invisible", "jade", "magnificent",
  "masterful", "dancing", "confusing", "ancient", "splendid", "drunken", "hungry", "eager", "swift", 
  "hard", "majestic", "formidable", "unyielding", "solid", "heavy", "aggressive", "focusing", "splintering", 
  "generous", "joyous", "plentiful", "bountiful", "wise", "sexy", "blinding", "sacred", "holy", "enlightening",
  "blessed", "harmonious", "heavenly", "thoughtful", "ultimate", "golden", "shining", "red", "black", "white",
  "green", "yellow", "blue", "orange", "brown", "gray", "purple", "big", "bright", "dark", }
transverbs = {"eats", "strikes", "hides", "defeats", "chases", "bites", "lifts", "steals", "throws",
  "turns away", "twists", "tames", "breaks", "deflects", "avoids", "attacks", "rends", "kills", "approaches",
  "flees", "sweeps", "instructs", "commands", "rebukes", "awakens", "brings", "summons", "enlightens", }
moves = {"tackle", "spin", "stance", "style", "form", "strike", "sweep", "kick", "punch", "cut", "wheel", 
  "throw", "attack", "defense", "charge", "rebuke", "riposte", "counter", "slap", "feint", "shield", "spiral", 
  "technique", "slash", "thrust", "dance", "flip", "chop", "smash", "backhand", "push", "shove", "suplex",
  "slam", "choke", "piledriver", "drop", "leap", "hold", "escape", "counter", "reversal", "bash", "block", }
numbers = {"two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "hundred", 
  "thousand", "10,000", "infinite", "many", "double", "triple", "forty", "twenty", "nineteen", "seventy-two", 
  "over 9,000", }
objects = {"bowl", "cherry blossom", "lotus flower", "chrysanthemum", "star", "moon", "willow", "plum blossom",
  "demon", "coin", "dumpling", "virgin", "buddha", "sage", "scholar", "wind", "mountain", "pond", "river", 
  "scroll", "feather", "banner", "flower", "vine", "plank", "philosopher", "apprentice", "fountain", "mirror", 
  "peasant", "student", "bandit", "wave", "monk", "priest", }
wordLists = {animals, verbings, weapons, bodyparts, adjectives, transverbs, moves, numbers, objects}
firstWords = {animals, verbings, weapons, bodyparts, adjectives, moves, numbers, objects}
secondWords = {animals, weapons, bodyparts, transverbs, moves, objects}

--[[
  TODO LIST
    - Color the center for contract, edges for extend, left for left, top for raise, etc.
    ? green color for active hold is not working
    - save buttons for previous match
    - queue review
    x mirroring
    x prevent joint manipulation after enter freeze
    x click-drag across joints to extend/contract a whole limb
    - disable time limit for free play
    - Plan your opener while waiting for your turn

  SINCE 0.1
    x indicate fractures and dismembers
    x hovering over joint button should highlight the joint on the tori
    x spacebar protection (disable for N seconds after enter_freeze)
    x commit a "good enough" move, then start playing around with joints. if time runs out, last committed move is activated.
  SINCE 0.2
    x keyboard control with minisnake layout
    
CHANGELOG
  0.31 - fixed canControl bug with keyboard controls
  0.32 - removed timer from single player mode
  0.33 - fixed playerName bug
  0.4  - framework for user-accessible settings through /ta set
       - ability to change frequency of (or disable) kung-fu names
       - nicer echo() and moved debugging echoes to dbg()
       - one-time help text for reposition button
       - hover and click feedback for buttons
       - overhaul move saving GUI
  0.5  - "Previous opener" button
--]]

dbg("Debugging enabled.")
