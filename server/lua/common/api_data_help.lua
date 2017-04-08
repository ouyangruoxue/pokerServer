
--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:err_redirect.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
-- 本文件主要用于初始化系统api的数据返回接口数据的初始化
-- 比如系统默认返回的数据为json格式，本格式主要用于包含返回编号
-- 解释信息，以及需要返回的数据结体
--]]
 
 
require "init.error_ex"
local _M = {}
local _SUCCESS_DATA = {code = ZS_ERROR_CODE.RE_SUCCESS,	msg = "data success",data = {}};
local _FAILED_DATA = {code = ZS_ERROR_CODE.RE_FAILED,	msg = "data failed",data = {}};


--[[
-- _M.new(_msg, _data ) 创建一个用于api级别的返回数据结构
--  如果不存在指定文件,将结果加入返回的数据表中
-- example

-- @param err_code 系统错误编号 参考init.error_ex.lua 文件的预定义,用户可以自定义自己的参数,起始数字为444
-- @param _data 	返回消息的主体
-- @param _msg 	描述信息

--]]
function _M.new(err_code, _data , _msg )
	local tDes = nil;
	if err_code == ZS_ERROR_CODE.RE_SUCCESS then
		tDes = table.clone( _SUCCESS_DATA );
	else
		tDes = table.clone( _FAILED_DATA );
	end  
	if err_code then tDes.code = err_code; end
	if _data then tDes.data = _data; end
	if _msg  then tDes.msg = _msg; end 
	return tDes; 
end
--[[
-- _M.new_success(_data , _msg ) 创建一个用于api级别的返回成功的数据结构
--  如果不存在指定文件,将结果加入返回的数据表中
-- example
 
-- @param _data 	返回消息的主体
-- @param _msg 	描述信息

--]]
function _M.new_success(_data , _msg )
	local tDes = table.clone( _SUCCESS_DATA );
	if _data then tDes.data = _data; end
	if _msg  then tDes.msg = _msg; end 

	return tDes; 
	 
end

--[[
-- _M.new_failed(_data , _msg ) 创建一个用于api级别的返回标准错误的数据结构
--  如果不存在指定文件,将结果加入返回的数据表中
-- example
 
-- @param _data 	返回消息的主体
-- @param _msg 	描述信息

--]]
function _M.new_failed(_data , _msg )
	local tDes = table.clone( _FAILED_DATA );
	if _data then tDes.data = _data; end
	if _msg  then tDes.msg = _msg; end
	return tDes;
end

return _M	