local cjson = require "cjson"

local _M = {}

--[[
cjsonPFTable 序列化标准的数据集合，即数据父子的主要数据是一致的，存放在一张表中的情形如地区包含地区
temp 数据库返回的集合
idName 主键
fid 外键
]]--
function _M.cjsonPFTable(srcTable,idName,fidName)

local len = table.getn(srcTable);
local tempSet={};
-- 1 生成类hash表结构 id_name 不可以为null 否则连接成字符时会产生异常
	for i=1,len,1 do   
		local _idName = srcTable[i][idName]; 
		tempSet[''.._idName] = srcTable[i];  
	end   
-- 2 根据原集合中的数据关系进行父子关联
-- 注意 判断父iD是否存在，不存在则说明为当前最高等级集合
	for i=1,len,1 do   
		local _parentId = srcTable[i][fidName];  
		local parent = tempSet[''.._parentId]; 
		if (parent == nil) then  
		else
			--local childSize = parent['childSize'] +1;
			if(parent['childList'] == nil)then
				parent['childList'] = {};
			end
			local childSize = table.getn(parent['childList']) +1;
			parent['childList'][childSize] = tempSet[''..srcTable[i][idName]]; 
		end  
	end 
-- 3 如果父ID在hash table中存在，则进行移除 	 
	local iLen = len;
	while( iLen > 0 )
	do
	   local _parentId = srcTable[iLen][fidName];  
	   local parent = tempSet[''.._parentId];  
		if (parent) then  
			table.remove(srcTable,iLen);
			--tempSet[''..srcTable[iLen][idName]] = nil;
		else
		
		end  
	   iLen = iLen-1;
	end  
	return srcTable; 
end
 
--[[
cjsonPFTable2 序列化标准的数据集合，即数据父子的主要数据是不一致，多对多的条件下的层级创建与导出
@srcTable 源数据
@tableTemp 模板 各级数据所需要的字段
local strjson = '[{"tid":1,"tname":"laoshi1","cid":1,"cname":"banji1","sid":1,"sname":"xuesheng1"},{"tid":1,"tname":"laoshi1","cid":1,"cname":"banji1","sid":2,"sname":"xuesheng2"},{"tid":1,"tname":"laoshi1","cid":2,"cname":"banji2","sid":3,"sname":"xuesheng3"},{"tid":1,"tname":"laoshi1","cid":2,"cname":"banji2","sid":4,"sname":"xuesheng4"}]';
local testtable2 = cjson.decode(strjson);
tempTable1={
	{'tname',idname='tid'},
	{'cname',idname='cid',fkname='tid'},
	{'sname',idname='sid',fkname='cid'},
}; 

--ngx.say("result #3: ",cjson.encode(res));
ngx.say("result #4: ",cjsonPFTable2(testtable2,tempTable1));
]]--
function _M.cjsonPFTable2(srcTable,tableTemp)
	
local len = table.getn(srcTable);
local lent = table.getn(tableTemp);
local hstable = {};
local resulttable = {};
local resulttableTemp ={};  
local elementSize=0;
--1 生成各个层级自身数据集合
	for i=1,len,1 do  --  遍历数据集合 
		local setImpl = srcTable[i]; 
		for j=1,lent,1 do  --遍历模板数组
			local tempImpl = tableTemp[j];
			local _idName = tempImpl["idname"]; 
			local _id = setImpl["".._idName];--取出当前模板下的数据主键
			local newname = _idName.._id;
			-- 判断是否已经创建了 对应类的lua表对象，没有则创建表
			local hsImpl = hstable[""..newname];
			if( hsImpl == nil) then   
				hstable[""..newname] = {};
				hsImpl = hstable[""..newname];
				hsImpl["table_element"] ={}; 
				elementSize = elementSize+1;  
				resulttableTemp[elementSize]={};
				resulttableTemp[elementSize]["ID"]=newname;
				resulttableTemp[elementSize]["typename"]=_idName;
				--判断是否需要插入主键和外键
				hsImpl["table_element"]["".._idName]=setImpl["".._idName];
				local _fkname = tempImpl["fkname"]; 
				if(_fkname) then 
					local _fkName = tempImpl["fkname"];  
					local _pid = setImpl["".._fkName];--取出当前模板下的数据主键
					hsImpl["table_element"]["".._fkname]=setImpl["".._fkname];--sql 原外键初始化到table中
					hsImpl["FID"]=_fkname.._pid;
		 			resulttableTemp[elementSize]["FID"]=_fkname.._pid;
				end
				local lens = table.getn(tempImpl);  
				for k=1,lens,1 do  --遍历模板数组中其他列数据集合，创建相关lua表结构
					if setImpl[""..tempImpl[k]] ~= ngx.null then
						hsImpl["table_element"][""..tempImpl[k]] = setImpl[""..tempImpl[k]];
					end
				end 
				resulttable[elementSize] = hsImpl["table_element"];  
				--hsImpl["typename"]=_idName;
			end 
		end 
	end  
	local resultTableLen=table.getn(resulttable); 
	while( resultTableLen > 0 ) --  遍历数据集合 
	do
		local impl=resulttableTemp[resultTableLen];
		local parentid=impl["FID"]; 
		if(parentid == nil) then
			 
		else
			--查找父类，进行关系查询 
			if(hstable[""..parentid]["table_element"]["childlist"] == nil) then
				hstable[""..parentid]["table_element"]["childlist"]={} 
			end
			local childLen=table.getn(hstable[""..parentid]["table_element"]["childlist"]);
			childLen = childLen+1;
			hstable[""..parentid]["table_element"]["childlist"][childLen]=resulttable[resultTableLen]
			table.remove(resulttable,resultTableLen);
		end
		resultTableLen=resultTableLen-1; 
	end 
	return resulttable;  
end

return _M