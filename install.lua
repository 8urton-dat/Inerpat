local thsfs = fsystem()
local tofs = ""

function start()
 local sid = true
 local text = {
  "Welcome!",
  " ",
  "This program installs the operating systen on",
  "your computer.",
  " ",
  "Select <Next> to continue the installation.",
  "Select <Close> to shutdown your PC."
 }
 for i = 1,#text do
  out(3,3+i,text[i])
 end
 while true do
  if sid then
   inv()
   out(3,14," Next ")
   inv()
   out(9,14," Close ")
  else
   out(3,14," Next ")
   inv()
   out(9,14," Close ")
   inv()
  end
  local e = {pull()}
  if e[1] == "key_down" then
   if e[4] == 203 or e[4] == 205 then
    sid = not sid
   elseif e[4] == 28 then
    if sid then break else halt() end
   end
  end
 end
end

function chsefs()
 local txt = {"Warning!",
 "All data on the selected drive will",
 "be DELETED, without recovery!",
 "Do you want to continue?"}
 local sid = 1
 local lbl = ""
 cls(2,3,49,15)
 out(3,4,"Select the filesystem on which the OS")
 out(3,5,"will be installed:")
 local fses = {}
 for a in component.list("filesystem") do
  table.insert(fses,a)
 end

 local a = ""
 while true do
  for i = 1,#fses do
   fsystem(fses[i])
   a = fses[i]
   lbl= " "..flabel().."("..string.sub(a,1,3)..")"
   if sid == i then
    inv()
    out(3,6+i,lbl..string.rep(" ",46-#lbl))
    inv()
   else
    out(3,6+i,lbl..string.rep(" ",46-#lbl))
   end
  end
  fsystem(thsfs)
  local e = {pull()}
  if e[1] == "key_down" then
   if e[4] == 200 and sid > 1 then
    sid = sid - 1
   elseif e[4] == 208 and sid < #fses then
    sid = sid + 1
   elseif e[4] == 28 then break end
  end
 end
 local fsd = guibool(txt)
 if fsd then
  tofs = fses[sid]
 else
  chsefs()
 end
end

function instprcs()
 local sysdat = {
  {"Formatting...",function() fsystem(tofs)
  local fl = flist("/") for i = 1,#fl do
  fdel("/"..fl[i]) end end},
  {"Copying: /manager.lua...",function()
  fsystem(thsfs) local cd = fcopy("/manager.lua")
  fsystem(tofs) fpaste(cd,"/manager.lua") end},
  {"Copying: /editor.lua...",function()
  fsystem(thsfs) local cd = fcopy("/editor.lua")
  fsystem(tofs) fpaste(cd,"/editor.lua") end},
  {"Copying: init.lua...",function()
  fsystem(thsfs) local cd = fcopy("/init.lua")
  fsystem(tofs) fpaste(cd,"/init.lua") end},
  {"Making directory...",function()
  fsystem(tofs) fmkfolder("/userfiles") end},
  {"Labeling...",function() fsystem(tofs)
  flabel("inerpat") end},
  {"Success! Press any key.",function()
  anykey() end}}

 cls(2,3,49,15)
 local stat,pb = "",0
 out(3,6,"Installation status:")
 out(3,11,string.rep(uch(9617),46))
 local strr = string.rep
 for i = 1,#sysdat do
  stat = sysdat[i][1]..strr(" ",47-#sysdat[i])
  out(3,7,stat)
  pb = math.ceil((46/(#sysdat-1))*(i-1))
  out(3,11,strr(uch(9619),pb))
  sysdat[i][2]()
 end
end

cls()
out(2,1,"Inerpat Installiation")
guiframe(1,2,50,16)
start()
chsefs()
instprcs()
halt()