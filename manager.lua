local root = "/userfiles/"
local path = "/userfiles/"
local osfsa = computer.getBootAddress()
local fsl,fsli = fslist(),1
local sid,of = 1,0
local labl,fles,ffles,clpb = "",{},{},{}

function drwbox()
  cls()
  guiframe(1,2,50,16)
  out(2,14,string.rep(uch(9472),48))
  for i = 3,13 do
    out(40,i,uch(9474))
  end
  out(40,2,uch(9572))
  out(1,14,uch(9500))
  out(40,14,uch(9524))
  out(50,14,uch(9508))
end

function infopage()
  local memu = math.ceil(component.invoke(fsystem(),"spaceUsed")/1024)
  local memt = math.ceil(component.invoke(fsystem(),"spaceTotal")/1024)
  local bw = math.ceil((46*memu)/memt)
  local mems = tostring(memu).."/"..tostring(memt).." KB"
  cls()
  guiframe(1,2,50,16)
  out(2,1,"Information")
  out(3,4,"INERPAT")
  out(3,5,"Version "..ipv())
  out(3,6,"Created by 8urton, 2019")
  out(3,8,"RAM: "..tostring(computer.totalMemory()/1024).." KB")
  out(3,10,"HDD Addr: "..fsystem())
  out(3,11,"HDD label: "..flabel())
  out(3,13,"HDD space used:")
  out(49-#mems,13,mems)
  out(3,14,string.rep(uch(9617),46))
  out(3,14,string.rep(uch(9619),bw))
  anykey()
end

function getname(q,isf)
  local nm,chr = "","0123456789_-AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz"
  guiframe(6,6,45,10)
  out(26-(#q/2),7,q)
  if isf then
    out(43,9,"/")
    inv()
    nm = input(8,9,35,chr)
  else
    out(40,9,".lua")
    inv()
    --out(8,9,string.rep(" ",32))
    nm = input(8,9,32,chr)
  end
  inv()
  if nm ~= "" then
    if isf then
      return nm 
    else
      return nm..".lua"
    end
  else
    return nil
  end
end

function updlist()
  local t,fz = "",0
  sid,of = 1,0
  labl = flabel()
  fles = flist(path)
  ffles = {}
  table.insert(fles,1,"..")
  --for i = 1,6 do table.insert(fles,tostring(math.random(0,63))..".lua") end
  for i = 1,#fles do
    if i == 1 then
      t = "        "
    elseif fisfolder(path..fles[i]) then
      t = " Folder "
    else
      fz = fsize(path..fles[i])
      if fz >= 1024 then
        t = tostring(math.floor(fz/1024)).." KB "
      else
        t = tostring(fz).." B "
      end
      t = string.rep(" ",8-#t) .. t
    end
    ffles[i] = " "..fles[i]..string.rep(" ",37-#fles[i])..uch(9474).." "..t
  end
end

function filemenu()
  local r = guilist("File Menu:",{"Edit","Copy","Rename","Delete","Back"})
  local r2
  if r == 1 then
    efile(fsystem(),path..fles[sid])
    fsystem(osfsa)
    frun("/editor.lua")
  elseif r == 2 then
    clpb = fcopy(path..fles[sid])
  elseif r == 3 then
    r2 = getname("Enter the file name:")
    if r2 then fmove(path..fles[sid],path..r2) end
  elseif r == 4 then
    r2 = guibool({"Do you want to delete?",fles[sid]})
    if r2 then fdel(path..fles[sid]) end
  end
end

function fldrmenu()
  local r = guilist("Folder Menu:",{"Rename","Delete","Back"})
  local r2
  if r == 1 then
    r2 = getname("Enter the folder name:",true)
    if r2 then fmove(path..fles[sid],path..r2) end
  elseif r == 2 then
    r2 = guibool({"Do you want to delete?",fles[sid]})
    if r2 then fdel(path..fles[sid]) end
  end
end

function sysmenu()
  local r = guilist("System Menu:",{"Back to Manager","New File","New Folder","Paste","Information","Shutdown"})
  local r2
  if r == 2 then
    r2 = getname("Enter the file name:")
    if r2 then
      efile(fsystem(),path..r2)
      fsystem(osfsa)
      frun("/editor.lua")
    end
  elseif r == 3 then
    r2 = getname("Enter the folder name:",true)
    if r2 then fmkfolder(path..r2) end
  elseif r == 4 then
    if #clpb == 2 then
      for i = #clpb[2],1,-1 do 
        if string.sub(clpb[2],i,i) == "/" then
          r2 = string.sub(clpb[2],i+1)
          break
        end
      end
      fpaste(clpb,path..r2)
    end
  elseif r == 5 then
    infopage()
  elseif r == 6 then
    r = guibool({"Do you want to shutdown?"})
    if r then halt() end
  end
end

function main()
  updlist()
  drwbox()
  local mem,ms,mi = {0,0,0,0},"",1
  while true do
    mem[mi] = math.ceil(computer.freeMemory()/1024)
    mi = mi + 1
    if mi == 4 then
      mi = 0
      for i = 1,4 do mi = mi + mem[i] end
      ms = "   "..tostring(math.ceil(mi/4)).." KB"
      out(50-#ms,1,ms)
      mi = 1
    end
    out(2,1,"Manager - "..labl.." ("..string.sub(fsystem(),1,3)..")")
    out(3,15,path..string.rep(" ",46-#path))
    for i = 1,math.min(#ffles,11) do
      if sid == i+of then
        inv()
        out(2,2+i,ffles[i+of])
        inv()
      else
        out(2,2+i,ffles[i+of])
      end
    end
    local e = {pull()}
    if e[1] == "key_down" then
      if e[4] == 200 and sid > 1 then
        sid = sid - 1
        if sid < 1+of then of = of - 1 end
      elseif e[4] == 208 and sid < #ffles then
        sid = sid + 1
        if sid > 11+of then of = of + 1 end
      elseif e[4] == 28 then
        if sid == 1 then
          if path ~= root then
            for i = #path-1,1,-1 do
              if string.sub(path,i,i) == "/" then 
                path = string.sub(path,1,i)
                break
              end
            end
            updlist()
            drwbox()
          end
        elseif fisfolder(path..fles[sid]) then
          path = path .. fles[sid]
          updlist()
          drwbox()
        else
          --cls()
          frun(path..fles[sid])
          cls()
          updlist()
          drwbox()
        end
      elseif e[4] == 56 or e[4] == 184 then
        sysmenu()
        updlist()
        drwbox()
      elseif e[4] == 29 or e[4] == 157 then
        if sid ~= 1 then
          if fisfolder(path..fles[sid]) then
            fldrmenu()
          else
            filemenu()
          end
        updlist()
        drwbox()
        end
      elseif e[4] == 15 then
        if #fsl == 0 or fsli == #fsl then
          fsl = fslist()
          fsli = 1
        else
          fsli = fsli + 1
        end
        fsystem(fsl[fsli])
        if fhasos() then
          root = "/userfiles/"
          path = "/userfiles/"
        else
          root = "/"
          path = "/"
        end
        updlist()
        drwbox()
      end
    end
  end
end

--for i = 1,16,2 do
--  out(1,i,string.rep("*-",25))
--  out(1,i+1,string.rep("-*",25))
--end
main()
--guilist("File Menu:",{"Edit","Copy","Rename","Delete","Back"})
--guilist("Folder Menu:",{"Rename","Delete","Back"})
--guilist("System Menu:",{"Back to Manager","New File","New Folder","Information","Shutdown"})
--guibool("Do you want to shutdown?") --"0123456789abcdef0123456789abcdef.lua","Do you want to Delete?")
--getname("Enter the file name:",false)
--getname("Enter the folder name:",true)