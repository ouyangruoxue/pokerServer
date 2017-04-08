--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:file_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  提供关于文件下相关的信息查询 包括获取文件的文件名,扩展名,文件路径,文件大小,文件md5编码,文件sha1编码等
--]]
local _M={};

-- _M.__index=_M;

function _M.getMD5( _file_ )
	-- body
end

function _M.getSHA1( _file_ )
	-- body
end

function _M.getSize( _file_ )
	-- body
end

--获取文件名
function _M.getFileName(_file_)
    local idx = _file_:match(".+()%.%w+$")
    if(idx) then
        return _file_:sub(1, idx-1)
    else
        return _file_
    end
end 
--获取扩展名
function _M.getExtension(_file_)
    return _file_:match(".+%.(%w+)$")
end 

--获取扩展名
function _M.getPath(str)
	return string.match(str, "(.+)[/\\][^/^\\]*%.%w+$") --*nix system  
    --return string.match(str, “(.+)\\[^\\]*%.%w+$”) — windows  
     
end

return _M