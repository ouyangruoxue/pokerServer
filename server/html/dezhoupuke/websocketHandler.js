

function sendMessage(msg) {
    if (ws != null && ws.readyState == 1) {
        msg = 'addddd';
        ws.send(msg);
    }
}

var wsUrl = "ws://localhost:80/socket/ws";
var ws = null;

function initWebSocket() {
    try {
        if (typeof MozWebSocket == 'function')
            WebSocket = MozWebSocket;

        if (ws && ws.readyState == 1)
            ws.close();

        // 初始化 WebSocket
        ws = new WebSocket(wsUrl);

        ws.onopen = function (event) {
            alert("已连接")
        };
        ws.onclose = function (event) {
            alert("已断开")
        };
        ws.onmessage = function (event) {
            handleWebSocketMsg(event.data);
        };
        ws.onerror = function (event) {
            alert(event.data)
        };
    } catch (exception) {
    
    }
}

function stopWebSocket() {
    if (ws)
        ws.close();
}

function checkSocket() {
    if (ws != null) {
        var stateStr;
        switch (ws.readyState) {
            case 0: {
                stateStr = "CONNECTING";
                break;
            }
            case 1: {
                stateStr = "OPEN";
                break;
            }
            case 2: {
                stateStr = "CLOSING";
                break;
            }
            case 3: {
                stateStr = "CLOSED";
                break;
            }
            default: {
                stateStr = "UNKNOW";
                break;
            }
        }
        debug("WebSocket state = " + ws.readyState + " ( " + stateStr + " )");
    } else {
        debug("WebSocket is null");
    }
}

//{"DeviceType":8,"Param":{"PointNum":2,"Status":5},"PointData":[17.040000915527344,17.389999389648438]}

function handleWebSocketMsg(data) {
   // var value = JSON.parse(data);

    alert(data);

    //switch(value.MsgID){
    //    case 1:                                                 //todo -- 实时刷新
    //        switch(value.DeviceType){
    //            case 1:                                                 //光纤测温
    //                setOpticalFiberInfo(value);
    //                break;
    //
    //            case 3:                                                 //接地环流
    //                setGroundingCurrentInfo(value);
    //                break;
    //            case 4:                                                 //局部放电
    //                setPartialDischargeInfo(value);//数据
    //                setPartialDischargeCanvas(value);//谱图
    //                break;
    //            case 5:                                                 //加电流(电流单元)
    //
    //                break;
    //            case 6:                                                 //串联谐振(电压单元)
    //                setSeriesResonanceInfo(value);
    //                break;
    //            case 7:                                                 //刀闸
    //                break;
		//		case 8:                                                 //内置测温
    //                setInsideTemperatureInfo(value);
    //                break;
    //            default :
    //                break;
    //        }
    //        break;
    //    case 2:                                                 //todo -- 请求返回
    //        setHistoryInfo(value);                              //历史数据返回，可能包含故障报警记录
    //        break;
    //
		//case 3:
    //        changeLoopImg(value.Param);                               //todo -- 修改首页回路图片
		//	break;
    //    default :
    //        break;
    //}

}


window.onload = function(){
    initWebSocket();
};
