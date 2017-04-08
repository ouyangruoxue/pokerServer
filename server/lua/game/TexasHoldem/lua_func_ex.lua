--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:lua_func_ex.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  本文件主要用于扩展部分lua未实现的常用方法,扩展lua方法的用户请注意编写函数的说明
    以及使用方法
--]]

--[[
-- 将 来源表格 中所有键及值复制到 目标表格 对象中，如果存在同名键，则覆盖其值
-- example
    local tDest = { a = 1, b = 2 }
    local tSrc = { c = 3, d = 4 }
    table.merge( tDest, tSrc )
    -- tDest = { a = 1, b = 2, c = 3, d = 4 }
    
-- @param tDest 目标表格(t表示是table)
-- @param tSrc 来源表格(t表示是table)
--]]
function table.merge( tDest, tSrc )
	if not tSrc then
		return nil
	end
    for k, v in pairs( tSrc ) do
        tDest[k] = v
    end
end
--[[
-- 将 相同数组结构的两个表进行合并
-- example
    local tDest = { 1,  2 }
    local tSrc = { 3, 4 }
    table.arrayMerge( tDest, tSrc )
    -- tDest = { 1,  2,  3, 4 }
    
-- @param tDest 目标表格(t表示是table)
-- @param tSrc 来源表格(t表示是table)
--]]
function table.arrayMerge( tDest, tSrc )
    if not tSrc then
        return nil
    end
    local dLen = table.getn(tDest);
    local sLen = table.getn(tSrc);
    for i = 1, sLen,1 do
        dLen = dLen + 1;
        tDest[dLen] = tSrc[i];
    end

end

--[[
-- 本函数主要用于将redis map中的数组类数据转换为新的record set 数据结构
-- example
    local tSrc = {‘a’,'haha','b','zheshi bi'} 
    table.convRedis(tSrc)
    -- tDest = { a = 1, b = 2, c = 3, d = 4 }

-- @param tSrc 来源表格(t表示是table)
--]]
function table.array2record( tSrc )
	if not tSrc then
		return nil
	end
	local lenn = table.getn(tSrc)
	local tDest ={}
    for i=1, lenn , 2 do
        tDest[tSrc[i]] = tSrc[i+1];
    end
    return tDest;
end


--[[
-- 本函数主要用于将创建一张新表并将内容复制到新表中,lua中的表之间通过变量是引用,
-- 指向一个lua内存变量
-- example
    local tSrc = {‘a’,'haha','b','zheshi bi'} 
    local  tDest = table.convRedis(tSrc)
    -- tDest = {‘a’,'haha','b','zheshi bi'} 

-- @param tSrc 来源表格(t表示是table)
--]]

function table.clone(tSrc)
    if (type(tSrc) ~= "table") then
        return nil
    end
    local new_tab = {}
    for i,v in pairs(tSrc) do
        local vtyp = type(v)
        if (vtyp == "table") then
            new_tab[i] = table.clone(v)
        elseif (vtyp == "thread") then
            new_tab[i] = v
        elseif (vtyp == "userdata") then
            new_tab[i] = v
        else
            new_tab[i] = v
        end
    end
    return new_tab
end
--[[
-- 本函数主要用于数据库返回的值判断，数据库返回值容易造成空记录,但是系统不会报告错误,通过该函数优化代码结构处理
-- 指向一个lua内存变量
-- example
    local tSrc = {};
    local tSrc1 = {abc="haha"};
    local tSrc2 = nil;
    table.isnull(tSrc) -- nil
    table.isnull(tSrc1) -- true
    table.isnull(tSrc2) -- nil

-- @param tSrc 来源表格(t表示是table)
--]]

function table.isnull(tSrc)
    local res = nil;
    if not tSrc then return nil end;
      for i,v in pairs(tSrc) do
        res = true;
      end
    return res;
end


