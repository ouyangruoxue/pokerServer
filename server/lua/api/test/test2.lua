--引入lua db的配置文件 
require "db.db_conf"
require "common.init_workflow"
local cjson = require "cjson"
local mysql = require "resty.mysql"


local db = mysql:new()
local ok, err, errcode, sqlstate = db:connect(mysql_master_local)

db:query("SET NAMES UTF8")
-- 0 发起，1 结束，2 审核，3 工作，4 通知，默认节点为发起 ,
-- -- coefficient 操作人存在系数，由其他系统得出,没有的关键字表示默认1.0
local task_note_type={
    node_start=0,
    node_end=1,
    node_review=2,
    node_work=3,
    node_note=4,
}
--下一个节点认为失败的时候对该任务线的操作类型,0 表示不操作,1表示就此失败,2表示失败需要重来,10表示滚回上一步骤,20表示重来无限次,>20表示-20重复的次数
-- 默认0不操作
local task_revert={
    revert_no=0,
    revert_err=1,
    revert_again=2,
    revert_laststep=10,
    revert_again=20,
}


-- 可能忽略的关键字主要有weight和revert 即权重和滚回，权重默认为1.0,滚回的值默认为10 其他关键字表示必须需要有
local task_temp={
    {node_id=1,node_name='开始',node_type=task_note_type.node_start},
    {node_id=2,node_name='工作1',last_nodes={{node_id=1}},node_type=task_note_type.node_work},
    {node_id=3,node_name='审核1_1',last_nodes={{node_id=2}},node_type=task_note_type.node_review},
    {node_id=4,node_name='审核1_2',last_nodes={{node_id=2}},node_type=task_note_type.node_review},
    {node_id=5,node_name='工作2',last_nodes={{node_id=3,weight=0.8},{node_id=4,weight=0.2}},node_type=task_note_type.node_work},
    {node_id=6,node_name='审核2',last_nodes={{node_id=5}},node_type=task_note_type.node_review},
    {node_id=7,node_name='工作3',last_nodes={{node_id=6}},node_type=task_note_type.node_work},
    {node_id=8,node_name='审核3',last_nodes={{node_id=7}},node_type=task_note_type.node_review},
    {node_id=9,node_name='结束',last_nodes={{node_id=8}},node_type=task_note_type.node_end},
}
-- task code
local task_code = 'task_code_3';
node_code_root = 1;
function getNodeCode()
    node_code_root = node_code_root+1;
    return ''..node_code_root;
end
--将函数作为参数传递的例子
function testfunc(getnode)
    ngx.say(getnode());
end
testfunc(getNodeCode);
--[[
function init_task_node(task_temp,task_code)
    local len = table.getn(task_temp);
    local node_resultTable={};
    local hash_table={};
    local nn_resultTable={};
    local nn_index=1;

    ngx.say(len);

    --遍历task_temp 生成需要创建的表结构
        for i=1,len,1 do
            local _node_id=task_temp[i].node_id;
            local _node_name=task_temp[i].node_name;
            local _last_nodes=task_temp[i].last_nodes;
            local _node_type=task_temp[i].note_type;
            local _node_code=getNodeCode();
            -- 创建需要创建的node 记录
            node_resultTable[i]={node_code=_node_code,
                            node_name=_node_name,
                            node_type=_node_type,
                            task_code=task_code,
            }
            hash_table[''.._node_id]=node_resultTable[i];
            if _last_nodes then
                -- 创建node数组
                local nnlen = table.getn(_last_nodes);

                for j=1,nnlen,1 do
                    nn_resultTable[nn_index]={
                        task_last_code='',
                        task_next_code=_node_code,
                        node_temp_last=_last_nodes[j].node_id;
                        task_last_name='',
                        task_next_name=_node_name,
                    }
                    if(_last_nodes[j].weight) then
                        nn_resultTable[nn_index].weight=_last_nodes[j].weight;
                    else
                        nn_resultTable[nn_index].weight=1.0;
                    end
                    nn_index = nn_index+1;
                end

            end
        end

    ngx.say( cjson.encode(node_resultTable));
    ngx.say("");

      local iLen=table.getn(nn_resultTable);

      while(iLen>0) do
         local last_temp_id= nn_resultTable[iLen].node_temp_last;
          if(hash_table[''..last_temp_id]) then
              nn_resultTable[iLen].task_last_code=hash_table[''..last_temp_id].node_code;
              nn_resultTable[iLen].task_last_name=hash_table[''..last_temp_id].node_name;
          else
              table.remove(nn_resultTable,iLen);
          end
          iLen = iLen-1;
      end
    ngx.say( cjson.encode(nn_resultTable));
    --return node_resultTable, nn_resultTable;

end
]]--
nodeT,nnT= init_task_node(task_temp,'task_code_3',getNodeCode);
ngx.say(cjson.encode(nodeT));




-- sql 后续操作
if not ok then
	ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
	return ngx.exit(500)
end
ngx.say("result #1:查询语句 ", ok)

local  begin_time = ngx.now();
--创建查询语句
local sql_str= 'select * from t_project;'
ngx.say("result #2: ", sql_str)
-- 执行查询
 res, err, errcode, sqlstate = db:query(sql_str)

    if not res then
 	ngx.say("result #3: ", err)
        ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errcode, ": ", sqlstate, ".")
        return ngx.exit(500)
    end
--输出查询结果

local request_time = ngx.now() - begin_time
-- ngx.header.content_type="application/json"
ngx.header['Content-Type']="text/html;charset=UTF-8"
ngx.header["X-Server-By"] = 'server by surjur'
ngx.header["Server"] = 'nginx'
ngx.header["X-Server-End"] = request_time
ngx.say("result #3: ",cjson.encode(res)..request_time)

