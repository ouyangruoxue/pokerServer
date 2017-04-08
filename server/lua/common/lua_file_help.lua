--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:lua_file_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
-- 	lua文件帮助文件的封装
--]]

local lfs = require("lfs")
local cjson = require "cjson"

local _M = {}



--[[
-- _M.getCurPath() 
--  获得当前程序的执行目录,主要是lua执行引擎的路径
-- example
	local fileSys = require "common.lua_file_help"
	local curPath = fileSys.getCurPath();

-- @param 无
-- @return 当前执行环境的目录
--]]
_M.getCurPath = function ()
	-- body
	return lfs.currentdir();
end

--[[
-- _M.getType() 
--  获得文件的类型
-- example
	local fileSys = require "common.lua_file_help"
	local curPath = fileSys.getType();

-- @param path
-- @return 当前执行环境的目录
--]]
_M.getType = function (path)
  return lfs.attributes(path).mode
end

--[[
-- _M.getSize() 
--  获得文件的大小
-- example
	local fileSys = require "common.lua_file_help"
	local file_SIZE = fileSys.getSize();

-- @param path
-- @return 返回当前文件的大小
--]]
 _M.getSize = function(path)
  return lfs.attributes(path).size
end

--[[
-- _M.isDir() 
--  获得文件的大小
-- example
	local fileSys = require "common.lua_file_help"
	local _isdir = fileSys.isDir();

-- @param path
-- @return 判断当前文件是否为文件夹,如果为文件夹,则返回true 否则 返回 false
--]]
_M.isDir = function(path)
   return _M.getType(path) == "directory"
end


--[[
-- _M.findx() 
--  查找文件中的最后一个x字符出现的位置
-- example
	local fileSys = require "common.lua_file_help"
	local xIndex = fileSys.findx('/');

-- @param 源字符串
-- @param 查找的字符对象
-- @return 当前执行环境的目录
--]]

_M.findx = function(str,x)
  for i = 1,#str do
      if string.sub(str,-i,-i) == x then
          return -i
      end
  end
end

--[[
-- _M.getName() 
--  获得文件的大小
-- example
  local fileSys = require "common.lua_file_help"
  local fileName = fileSys.getName(str);

-- @param str 文件目录
-- @return 文件名称
--]]
_M.getName = function(str)
      return string.sub(str,_M.findx(str,"/") + 1,-1)
end


_M.getJson = function(path)
local tJson = {}; 
local index = 1;
  for file in lfs.dir(path) do 
    local p = path..'/'..file  
    if file ~= "." and file ~= '..' then
      if _M.isDir(p) then
        tJson[index]={
          name = file, fileType = _M.getType(p)
        }
      else
          tJson[index]={
          name = file, fileType = _M.getType(p), size = _M.getSize(p)
        }
      end  
      index = index + 1   
    end
  end
  return cjson.encode(tJson)
end

return _M
