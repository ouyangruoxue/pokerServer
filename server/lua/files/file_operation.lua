--[[
--  作者:左笑林 
--  日期:2017-03-02
--  文件名:file_operation.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  本文件主要用于文件相关操作语句的扩展函数
--]]
local lfs = require("lfs")

local _M ={}

_M.__index = _M;

function _M.new()
  return setmetatable({},_M)
end

function getType(path)
  return lfs.attributes(path).mode
end

function getSize(path)
  return lfs.attributes(path).size
end

function isDir(path)
   return getType(path) == "directory"
end

function findx(str,x)
  for i = 1,#str do
      if string.sub(str,-i,-i) == x then
          return -i
      end
  end
end

function getName(str)
      return string.sub(str,findx(str,"/") + 1,-1)
end

function getJson(path)
  local table = "{"
  for file in lfs.dir(path) do
    p = path .. "/" .. file
    if file ~= "." and file ~= '..' then
      if isDir(p) then
        s = "{'text':'".. file .. "','type':'" .. getType(p) .. "','path':'" .. p .. "','children':[]},"
      else
        s = "{'text':'".. file .. "','type':'" .. getType(p) .. "','path':'" .. p .. "','size':" .. getSize(p) .. ",'leaf':true},"
      end  
      table = table .. s    
    end
  end
  table = table .. "}"
  return table
end

return _M