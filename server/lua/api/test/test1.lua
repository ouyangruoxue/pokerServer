--引入lua db的配置文件 

local cjson = require "cjson"
local mysql = require "resty.mysql"
require "db.db_conf"
require "common.jsonHelp"
local db = mysql:new()
local ok, err, errcode, sqlstate = db:connect(mysql_master_local)
db:query("SET NAMES UTF8")
--ngx.exit(200)
if not ok then
	ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
	return ngx.exit(500)
end

local  begin_time = ngx.now();
--创建查询语句
local sql_str= 'call pro_show_childlist(-1);'
--ngx.say("result #2: ", sql_str)
-- 执行查询
 res, err, errcode, sqlstate = db:query(sql_str)

    if not res then
 	ngx.say("result #3: ", err)
        ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errcode, ": ", sqlstate, ".")
        return ngx.exit(500)
    end
ngx.say("result #3: ",cjsonPFTable(res,'id','parent_id'));

-- 返回结果的集合模板，其中每个数组说明了该结构的字段名称，用于创建相对应的数据集合，fkname说明了该分类的父类外键名称，同时也说明了该对象的对应关系
local strjson = '[{"tid":1,"tname":"laoshi1","cid":1,"cname":"banji1","sid":1,"sname":"xuesheng1"},{"tid":1,"tname":"laoshi1","cid":1,"cname":"banji1","sid":2,"sname":"xuesheng2"},{"tid":1,"tname":"laoshi1","cid":2,"cname":"banji2","sid":3,"sname":"xuesheng3"},{"tid":1,"tname":"laoshi1","cid":2,"cname":"banji2","sid":4,"sname":"xuesheng4"}]';
local testtable2 = cjson.decode(strjson);
tempTable1={
	{'tname',idname='tid'},
	{'cname',idname='cid',fkname='tid'},
	{'sname',idname='sid',fkname='cid'},
}; 

--ngx.say("result #3: ",cjson.encode(res));
ngx.say("result #4: ",cjsonPFTable2(testtable2,tempTable1));

local request_time = ngx.now() - begin_time
-- ngx.header.content_type="application/json"
--ngx.header['Content-Type']="text/html;charset=UTF-8"
--ngx.header["X-Server-By"] = 'server by surjur'
--ngx.header["Server"] = 'nginx'
--ngx.header["X-Server-End"] = request_time
--cjson.encode(res)..
ngx.say("result #3: ",request_time)


