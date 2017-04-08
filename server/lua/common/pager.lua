--[[
	与页面配合使用的封装方法，页面需要最大页和当前页，lua脚本需要开始和结束的clum 现已知总的clum数进行封装

]]--


local _M = {}          
local mt = { __index = _M }            


function _M.new()
    return setmetatable({}, mt)    
end


	-- 通用函数  从数据库查询的数据中截取第一条，根据key获取value
	function GetNodeWithKey(table, key)
		-- 这里之所以有个临时的temp，是因为从数据库中查询出来的不是一个table，而是一个array table，切记，即使是只查询出来一条，也是array table. 雷区拍照留念
		local temp={}
		temp=table[1]
	return temp[key]
	end

--[[
	@param all_clum数据库查询出来的所有字段数
	@param pageSize 规定每页展示多少条记录，没有默认为20条
	@param curr_page 当前页，由前台传到lua脚本中，再传到这里，用于计算limt 两端值

	@result  lim_sta 分页开始的地方
	@result	 lim_end 分页结束的地方
	@result  c_page 当前页面 返回给前台


]]--
function  _M.newPager(all_clum,pageSize,curr_page)
	-- ngx.log(ngx.ERR,"all_clum **"..all_clum.." **pageSize** "..pageSize.." **curr_page ** "..curr_page)
	local c_page  		--返回给前台使用的当前页面
	local lim_sta		--开始limit位置
	local lim_end		--结束limit位置
	local max_page=0
	-- 如果没有给定页面size,那么规定每页显示20条
	if not pageSize or pageSize<=0 then 
		pageSize=20
	end

	if not curr_page then 
		c_page=1
	else
		c_page=curr_page
	end

	-- 如果all_clum不存在,或者all_clum不是table，那么默认总的页数为1
	if not all_clum or type(all_clum)~="string" then 
		max_page=1
	end

	-- 如果总页数小于页面size,那么最大页为1，否则按照除法来
	if tonumber(all_clum) <= tonumber(pageSize) then 
		max_page=1
	else
		local t1,t2=math.modf(tonumber(all_clum)/tonumber(pageSize))
		if tonumber(all_clum)%tonumber(pageSize)==0 then 
			max_page=t1
		else
			max_page=t1+1
		end

	end
 

	lim_sta=(tonumber(curr_page)-1)*tonumber(pageSize)
	lim_end=tonumber(curr_page)*tonumber(pageSize)
	return lim_sta,lim_end,max_page,c_page
end



return _M