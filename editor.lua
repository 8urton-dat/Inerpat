local cnt = {""}
local cx,cy,of = 1,1,0
local sm,smk = false,true
--local osfs = computer.getBootAddress()
local fsy,pth = efile()

fsystem(fsy)

--for i = 1,24 do
--  table.insert(cnt,"")
--  for j = 1,math.random(2,50) do
--    local a = math.random(1,#ipchrs)
--    cnt[i] = cnt[i] .. string.sub(ipchrs,a,a)
--  end
--end

local function endp()
  return math.min(50,#cnt[cy]+1)
end

function sav()
  local f = fopen(pth,"w")
  local a
  for i = 1,#cnt do
    if i ~= #cnt then
      a = fwrite(f,cnt[i].."\n")
    else
      a = fwrite(f,cnt[i])
    end
  end
  fclose(f)
end

function loa()
  if fexists(pth) then
    local f = fopen(pth,"r")
    local lni,nl = 1,1
    local dt,pdt = "",fread(f)
    while pdt do
      dt = dt .. (pdt or "")
      pdt = fread(f)
    end
    fclose(f)
    for i = 1,#dt do
      if string.byte(string.sub(dt,i,i)) == 10 then
        cnt[lni] = string.sub(dt,nl,i-1)
        table.insert(cnt,"")
        lni = lni + 1
        nl = i + 1
      end
    end
    cnt[lni] = string.sub(dt,nl)
    dt,pdt = "",""
  end
end

function drwbar()
  local lns = "Ln "..tostring(cy)
  local sz = 0
  if sm then
    for i = 1,#cnt do sz = sz + #cnt[i] end
    out(1,1,uch(9474)..string.rep(" ",45-#tostring(sz))..tostring(sz).." B "..uch(9474))
    if smk then
      inv()
      out(3,1," Save ")
      inv()
      out(9,1," Exit ")
    else
      out(3,1," Save ")
      inv()
      out(9,1," Exit ")
      inv()
    end
  end
  out(1,1+((sm and 1) or 0),uch(9492)..string.rep(uch(9472),47-#lns)..lns..uch(9472)..uch(9496))
end

function main()
  local c,li = "",""
  while true do
    drwbar()
    if cy-of > 15 then 
      of = of + 1
    elseif cy < of+1 then
      of = of - 1
    end
    if not sm then
      for i = 1,15 do
        li = cnt[i+of] or ""
        out(1,1+i,li..string.rep(" ",50-#li))
      end
      inv()
      c = string.sub(cnt[cy],cx,cx)
      if c == "" then c = " " end
      out(cx,1+cy-of,c)
      inv()
    end
    local e = {pull()}
    if e[1] == "key_down" then
      if e[4] == 29 or e[4] == 157 then
        sm = not sm
      elseif e[4] == 203 then
        if sm then
          smk = true
        else
          if cx > 1 then cx = cx - 1 end
        end
      elseif e[4] == 205 then
        if sm then
          smk = false
        else
          if cx < endp() then cx = cx + 1 end
        end
      elseif e[4] == 200 then
        if cy > 1 then 
          cy = cy - 1
          cx = math.min(cx,#cnt[cy]+1)
        end
      elseif e[4] == 208 then
        if cy < #cnt then 
          cy = cy + 1
          cx = math.min(cx,#cnt[cy]+1)
        end
      elseif e[4] == 28 then
        if sm then 
          if smk then
            out(3,1,"Saving...   ")
            sav()
            sm = false
          else
            break
          end
        else
          table.insert(cnt,cy+1,string.sub(cnt[cy],cx))
          cnt[cy] = string.sub(cnt[cy],1,cx-1)
          cx,cy = 1,cy + 1
        end
      elseif e[4] == 14 then
        if cx == 1 and cnt[cy] == "" and cy > 1 then
          table.remove(cnt,cy)
          cy = cy - 1
          cx = endp()
        elseif cx == 1 and #cnt[cy] > 0 and cnt[cy-1] == "" and cy > 1 then
          table.remove(cnt,cy-1)
          cy = cy - 1
        elseif cx > 1 then
          cnt[cy] = string.sub(cnt[cy],1,cx-2)..string.sub(cnt[cy],cx)
          cx = cx - 1
        end
      elseif e[4] == 15 then
        if #cnt[cy] < 50 then
          cnt[cy] = string.sub(cnt[cy],1,cx-1).." "..string.sub(cnt[cy],cx)
          cx = math.min(50,cx+1)
        end
      elseif e[4] == 211 then
        cnt[cy] = string.sub(cnt[cy],1,cx-1)..string.sub(cnt[cy],cx+1)
      elseif e[4] == 199 then
        cx = 1
      elseif e[4] == 207 then
        cx = endp()
      else
        for i = 1,#ipchrs do
          if string.char(e[3]) == string.sub(ipchrs,i,i) and #cnt[cy] < 50 then
            cnt[cy] = string.sub(cnt[cy],1,cx-1)..string.char(e[3])..string.sub(cnt[cy],cx)
            cx = math.min(50,cx+1)
          end
        end
      end
    end
  end
end

cls()
loa()
main()