local gpu = component.list("gpu")()
local scr = component.list("screen")()
local fs = computer.getBootAddress()

if not gpu or not scr then error("no gpu or screen",0) end

component.invoke(gpu,"setResolution",50,16)
ipchrs = " !"..string.char(34).."#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ["..string.char(92).."]^_`abcdefghijklmnopqrstuvwxyz{|}~"
iperror = {"An error occurred in the operating system",
          " ",
          "First, try restarting the system.",
          "If the error persists, check for the main PC",
          "components and restart the system.",
          "If nothing helps, contact the system developer",
          "for bug fixes and system enhancements."," ",
          "Error description:"}

local ipem = {"",""}

--==============================================--

function halt() computer.shutdown() end

function cls(x,y,x2,y2)
  x = x or 1
  y = y or 1
  x2 = x2 or 50
  y2 = y2 or 16
  component.invoke(gpu,"fill",x,y,x2-x+1,y2-y+1," ")
end

function out(x,y,text)
  component.invoke(gpu,"set",x,y,text)
end

function uch(c) return unicode.char(c) end

function inv()
  if component.invoke(gpu,"getForeground") == 0xFFFFFF then
    component.invoke(gpu,"setBackground",0xFFFFFF)
    component.invoke(gpu,"setForeground",0x000000)
  else
    component.invoke(gpu,"setBackground",0x000000)
    component.invoke(gpu,"setForeground",0xFFFFFF)
  end
end

function anykey()
  while true do
    local e = computer.pullSignal()
    if e == "key_down" then break end
  end
end

function input(x,y,len,ch)
  ch = ch or ipchrs
  local str = ""
  while true do
    out(x,y,string.rep(" ",len))
    if #str == len then
      out(x,y,str)
    else
      out(x,y,str.."_")
    end
    local e = {computer.pullSignal()}
    if e[1] == "key_down" then
      if e[4] == 14 and str ~= "" then
        str = string.sub(str,1,#str-1)
      elseif e[4] == 28 then
        return str
      else
        if len and #str < len then
          for i = 1,#ch do
            if string.char(e[3]) == string.sub(ch,i,i) then str = str .. string.char(e[3]) end
          end
        end
      end
    end
  end
end

function pull(t)
  return computer.pullSignal(t)
end

--------------------------------------------------

function fslist()
  local fss = {}
  for a in component.list("filesystem") do table.insert(fss,a) end
  return fss
end

function fsystem(f)
  if f then
    fs = f
  else
    return fs
  end
end

function flabel(s)
  if s then
    component.invoke(fs,"setLabel",s)
  else
    return component.invoke(fs,"getLabel") or "not labeled"
  end
end

function fopen(path,m)
  return component.invoke(fs,"open",path,m)
end

function fclose(f)
  component.invoke(fs,"close",f)
end

function fread(f,s)
  s = s or math.huge
  return component.invoke(fs,"read",f,s)
end

function fwrite(f,v)
  return component.invoke(fs,"write",f,v)
end

function frun(path)
  local f = fopen(path,"r")
  local prt,dat = "",""
  repeat
    prt = fread(f)
    dat = dat .. (prt or "")
  until not prt
  fclose(f)
  local s,e = pcall(load(dat))
  if not s then
--    error(e,0)
    component.invoke(gpu,"setBackground",0x000000)
    component.invoke(gpu,"setForeground",0xffffff)
    cls()
    inv()
    out(18,2," Inerpat Error! ")
    inv()
    for i = 1,#iperror do
      out(26-(#iperror[i]/2),3+i,iperror[i])
    end
    local a = 0
    while #e > 48 do
      out(2,13+a,string.sub(e,1,48))
      e = string.sub(e,49)
      a = a + 1
    end
    out(26-(#e/2),13+a,e)
    out(35,16,"Press any key")
    computer.beep(55,0.15)
    anykey()
--    halt()
  end
end

function fsize(path)
  return component.invoke(fs,"size",path)
end

function fmove(fr,to)
  component.invoke(fs,"rename",fr,to)
end

function fcopy(path)
  return {fsystem(),path}
end

function fpaste(copydata,path)
  local tofs,dat = fsystem(),""
  local f = component.invoke(copydata[1],"open",copydata[2],"r")
  local f2 = component.invoke(tofs,"open",path,"w")
  repeat
    dat = component.invoke(copydata[1],"read",f,math.huge)
    component.invoke(tofs,"write",f2,dat or "")
  until not dat
  component.invoke(copydata[1],"close",f)
  component.invoke(tofs,"close",f2)
end

function fdel(path)
  component.invoke(fs,"remove",path)
end

function flist(path)
  return component.invoke(fs,"list",path)
end

function fisfolder(path)
  return component.invoke(fs,"isDirectory",path)
end

function fmkfolder(path)
  component.invoke(fs,"makeDirectory",path)
end

function fexists(path)
  return component.invoke(fs,"exists",path)
end

function fhasos()
  if fexists("/init.lua") and fexists("/manager.lua") and fexists("/editor.lua") and fexists("/userfiles/") then
    return true
  end
  return false
end

--------------------------------------------------

function efile(fsa,path)
  if not fsa and not path then
    return ipem[1],ipem[2]
  else
    ipem = {fsa,path}
  end
end

function ipv() return "1.0" end

--------------------------------------------------

function guiframe(x,y,x2,y2)
  cls(x,y,x2,y2)
  for i = x+1,x2-1 do
    out(i,y,uch(9552)) --9552
    out(i,y2,uch(9472))
  end
  for i = y+1,y2-1 do 
    out(x,i,uch(9474))
    out(x2,i,uch(9474))
  end -- 9553
  out(x,y,uch(9554)) -- 9556
  out(x2,y,uch(9557)) -- 9559
  out(x,y2,uch(9492)) -- 9562
  out(x2,y2,uch(9496)) -- 9565
end

function guibool(qst)
  local ch = true
  local yl = #qst+3
  local gy,gy2 = 8-(yl/2),9+(yl/2)
  guiframe(6,gy,45,gy2)
  for i = 1,#qst do
    out(26-(#qst[i]/2),gy+i,qst[i])
  end
  while true do
    if ch then
      inv()
      out(16,gy2-2,"        Yes         ")
      inv()
      out(16,gy2-1,"         No         ")
    else
      out(16,gy2-2,"        Yes         ")
      inv()
      out(16,gy2-1,"         No         ")
      inv()
    end
    local e = {pull()}
    if e[1] == "key_down" then
      if e[4] == 200 then
        ch = true
      elseif e[4] == 208 then
        ch = false
      elseif e[4] == 28 then
        return ch
      end
    end
  end
end

function guilist(title,arr)
  local sel = 1
  local ml = #title
  yl = #arr+2
  local ofs = ""
  for i = 1,#arr do
    if #arr[i] > ml then ml = #arr[i] end
  end
  for i = 1,#arr do
    ofs = string.rep(" ",((ml+2)/2)-(#arr[i]/2))
    arr[i] = ofs..arr[i]..string.rep(" ",(ml+2/2)-(#arr[i]+#ofs)+1)
  end
  gx,gy = 24-ml,8-(yl/2)
  guiframe(gx,gy,27+ml,9+(yl/2))
  out(26-(#title/2),gy+1,title)
  while true do
    for i = 1,#arr do
      if sel == i then
        inv()
        out(gx+(ml/2)+1,gy+2+i,arr[i])
        inv()
      else
        out(gx+(ml/2)+1,gy+2+i,arr[i])
      end
    end
    local e = {pull()}
    if e[1] == "key_down" then
      if e[4] == 200 and sel > 1 then
        sel = sel - 1
      elseif e[4] == 208 and sel < #arr then
        sel = sel + 1
      elseif e[4] == 28 then
        return sel
      end
    end
  end
end

--==============================================--

local ipl0 = {
0,52,54,54,54,54,54,34,54,54,54,22,52,54,34,54,22,52,54,34,22,52,34,22,
0,253,11,252,183,252,163,223,73,161,223,233,23,252,203,125,162,222,233,87,8,253,11,1,
52,47,48,15,48,15,62,37,4,62,1,62,49,15,0,0,62,1,62,1,48,15,0,0}
local ipl1 = {8,13,4,17,15,0,19}

cls()
local s = ""
for i = 1,#ipl1 do s = s .. uch(0xff21 + ipl1[i]) end
out(19,6,s)
guiframe(15,11,36,13)
out(17,12,"Loading system...")
out(1,16,"Version "..ipv())

--anykey()
for i = 1,16 do
  for j = 1,50 do
    out(j,i,component.invoke(gpu,"get",j,i))
  end
end

if fexists("/userfiles/startup.lua") then frun("/userfiles/startup.lua") end
frun("/manager.lua")
halt()