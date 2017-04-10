 // 添加这个函数，可以在js页面中引入其他js文件
 function include(path){ 
    var a=document.createElement("script");
    a.type = "text/javascript"; 
    a.src=path; 
    var head=document.getElementsByTagName("head")[0];
    head.appendChild(a);
    }

 
 include("/assets/js/json2.js");		 // 引入json2  js文件
 include("/assets/js/verify.js");		 // 引入验证js文件
 include("http://cdn.bootcss.com/blueimp-md5/1.1.0/js/md5.js")
 
 
// 分析url，获取name对应的value值
 function GetQueryString(name){
				 var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
				 var r = window.location.search.substr(1).match(reg);
				 if(r!=null)return  unescape(r[2]); return null;
			}
			
			
// 如果当前文件相对于index.html是同级文件，那么level传0，如果当前文件是index.html文件的下一级文件，比如book文件夹中的，或者js文件夹中的，level传1，最终得到的路径，是index.html的上级目录
	function getRootPath(level){
		 // var level = arguments[level_arg]?arguments[level_arg]:0;
		level+=1
		var	opath=location.href //获取文件当前路径
		var sign_index
		
		do{
			 sign_index=opath.lastIndexOf("/")   //获取最后一个/的index值
			 opath=opath.substr(0,sign_index)  //截取从第一个到最后一个/之间的字符串
			level--;
		} while(level)
			return opath;
		
	}
	
 // 返回tr中指定顺序的元素  banner_index中有使用到
	function rb_tb(tr_id,td_index){
		var row = document.getElementById(tr_id); //只针对 row1这个元素的子节点查找
		var cells = row.getElementsByTagName("td"); // 找到这个tr下的所有td，不能用childNodes 属性，部分浏览器不兼容
		<!-- for(var i=0;i<cells.length;i++){ -->
		<!-- alert("第"+(i+1)+"格的数字是"+cells[i].innerHTML); -->
		<!-- } -->
		return cells[td_index].innerHTML
	}
 
	
	// 获取当前时间，并且以yyyy-mm-dd hh:mm:ss的格式返回
	function getNowFormatDate() {
		var date = new Date();
		var seperator1 = "-";
		var seperator2 = ":";
		var month = date.getMonth() + 1;
		var strDate = date.getDate();
		if (month >= 1 && month <= 9) {
			month = "0" + month;
		}
		if (strDate >= 0 && strDate <= 9) {
			strDate = "0" + strDate;
		}
		var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
				+ " " + date.getHours() + seperator2 + date.getMinutes()
				+ seperator2 + date.getSeconds();
    return currentdate;
}



// ***************************************************以下为分页使用*****************************************************


/**
 * 其中会传入三个参数,另外在代码中有一个方法beginPostTestResult(page),
* 该方法是需要自己写的方法，该方法的作用就是向后台发出请求，得回数据的方法；
 * @param page 当前页
 * @param maxPage 最大页
 * @param divId 你要把这个页分的显示放在哪个div中，传入divId
 */
 function initPageInfo(page,maxPage,divId){
	 $("#"+divId).html("");
	 var kongge = "&nbsp;&nbsp;&nbsp;&nbsp;";
	 var firstPage = "首页";
	 var prePage = "上一页";
	 var endPage = "末页";
	 var nextPage = "下一页";
	if(page < 1){
		page = 1;
	}
	if(page > maxPage ){
		page = maxPage;
	}
	if(page == 1 && page < maxPage){
		endPage = "<a href='javascript:;' onclick='beginPostTestResult("+maxPage+")'>末页</a>";
		nextPage =  "<a href='javascript:;' onclick='beginPostTestResult("+(page+1)+")'>下一页</a>";
	}else if(page >1 && page <maxPage){
		firstPage = "<a href='javascript:;' onclick='beginPostTestResult(1)'>首页</a>";
		prePage = "<a href='javascript:;' onclick='beginPostTestResult("+(page-1)+")'>上一页</a>";
		endPage = "<a href='javascript:;' onclick='beginPostTestResult("+maxPage+")'>末页</a>";
		nextPage ="<a href='javascript:;' onclick='beginPostTestResult("+(page+1)+")'>下一页</a>";
	}else if(page > 1 && page == maxPage){
		firstPage ="<a href=’javascript:;' onclick='beginPostTestResult(1)'>首页</a>";
		prePage ="<a href='javascript:;' onclick='beginPostTestResult("+(page-1)+")'>上一页</a>";
	}
	$("#"+divId).html(firstPage+kongge+prePage+kongge+page+kongge+nextPage+kongge+endPage);
}

// 页面上使用的方法
// function beginPostTestResult(page){
	// $.post(url,{参数},function(data,state,response){
		// TODO你的操作
		// 注意：参数page 都要是整形的，不能是字符型
		// initPageInfo(page,maxPage,divId);
	// },"json");
// }

// *********************************************分页结束***************************************



// **************************************Path***************************************************
	// 此处为path的配置，是从html页面跳转到另一个html页面（实际是lua的映射的结果），这样处理是为了后期文件夹路径变更后能统一处理（而不是打开每个文件去找）
	// 根据功能模块来划分
	//除了菜单里的是跳转，其他的都返回路劲
	//登录界面
	// 跳转到lua登录
	function login_path(){
		return getRootPath(1)+"/user/login"
	} 
	 // 跳转到home界面
	function home_path(){
		return getRootPath(1)+"/html/client_management/home/home"
	} 
	
	// anchor 主播 6+1
	function sider_anchor_index_path(){
		window.location.href=getRootPath(2)+"/client_management/anchor/anchor_index"
	 } 
	function anchor_index_path(){
		return getRootPath(2)+"/client_management/anchor/anchor_index"
	} 
	function anchor_gift_list_path(){
		return getRootPath(2)+"/client_management/anchor/anchor_gift_list"
	}
	function anchor_add_path(){
		return getRootPath(2)+"/client_management/anchor/anchor_add"
	}
	function anchor_add_after_path(){
		return getRootPath(2)+"/client_management/anchor/anchor_add_after"
	}
	function anchor_edit_path(){
		return getRootPath(2)+"/client_management/anchor/anchor_edit"
	}
	function anchor_edit_after_path(){
		return getRootPath(2)+"/client_management/anchor/anchor_edit_after"
	}
	//删除对应的主播
	function anchor_delete_path(){  
		return getRootPath(3)+"/anchor/delete_anchor"
	}
	 
	 
	 
	// banner 3+2
	function sider_banner_index_path(){
		window.location.href=getRootPath(2)+"/client_management/banner/banner_index"
	 } 
	 function banner_index_path(){
		return getRootPath(2)+"/client_management/banner/banner_index"
	 } 
	function banner_add_path(){
		 return getRootPath(2)+"/client_management/banner/banner_add"
	} 
	function banner_edit_path(){
		return getRootPath(2)+"/client_management/banner/banner_edit"
	} 
	// 保存banner
	function banner_save_path(){
		return getRootPath(3)+"/banner/add"
	}
	// 删除banner
	function banner_delete_path(){
		return getRootPath(3)+"/banner/delete"
	}
	 
	 
	// bonus_pool 奖金池 3+1
	function sider_bonus_pool_index_path(){
		window.location.href=getRootPath(2)+"/client_management/bonus_pool/bonus_pool_index"
	} 
	function bonus_pool_index_path(){
		return getRootPath(2)+"/client_management/bonus_pool/bonus_pool_index"
	} 
	function bonus_pool_opt_path(){
		return getRootPath(2)+"/client_management/bonus_pool/bonus_pool_opt"
	} 
	function bonus_pool_opt_after_path(){
		return getRootPath(2)+"/client_management/bonus_pool/bonus_pool_opt_after"
	} 
	function bonus_pool_delete_path(){
		return getRootPath(3)+"/bonus_pool/bonus_pool_history_delete"
	}

	 
	 
	// gift	礼物类型 3+2
	function sider_gift_index_path(){
		window.location.href=getRootPath(2)+"/client_management/gift/gift_index"
	} 
	function gift_index_path(){
		return getRootPath(2)+"/client_management/gift/gift_index"
	} 
	function gift_add_path(){
		return getRootPath(2)+"/client_management/gift/gift_add"
	} 
	function gift_edit_path(){
		return getRootPath(2)+"/client_management/gift/gift_edit"
	} 
	//删除礼物
	function gift_delete_path(){
		return getRootPath(3)+"/gift/delete_gifttype"
	}
	// 保存礼物
	function gift_save_path(){
		return getRootPath(3)+"/gift/save_gifttype"
	}
	 
	
	// minitor	用户监控 1
	function sider_minitor_index_path(){
		window.location.href=getRootPath(2)+"/client_management/minitor/minitor_index"
	}
	function minitor_index_path(){
		return getRootPath(2)+"/client_management/minitor/minitor_index"
	}
	
	// note	公告 4+2
	function sider_note_index_path(){
		window.location.href=getRootPath(2)+"/client_management/note/note_index"
	}
	function note_index_path(){
		return getRootPath(2)+"/client_management/note/note_index"
	}
	function note_add_path(){
		return getRootPath(2)+"/client_management/note/note_add"
	}
	function note_edit_path(){
		return getRootPath(2)+"/client_management/note/note_edit"
	}
	function note_set_index_path(){
		return getRootPath(2)+"/client_management/note/note_set_index"
	}
	//保存公告
	function note_save_path(){
		return getRootPath(3)+"/note/save_note"
	}
	//删除公告
	function note_delete_path(){
		return getRootPath(3)+"/note/delete_note"
	}
	
	
	
	
	// room	房间筹码
	function sider_room_index_path(){
		window.location.href=getRootPath(2)+"/client_management/room/room_index"
	}
	function room_index_path(){
		return getRootPath(2)+"/client_management/room/room_index"
	}
	function room_add_path(){
		return getRootPath(2)+"/client_management/room/room_add"
	}
	function room_edit_path(){
		return getRootPath(2)+"/client_management/room/room_edit"
	}
	function room_chip_index_path(){
		return getRootPath(2)+"/client_management/room/room_chip_index"
	}
	function room_chip_add_path(){
		return getRootPath(2)+"/client_management/room/room_chip_add"
	}
	function room_chip_edit_path(){
		return getRootPath(2)+"/client_management/room/room_chip_edit"
	}
	// 保存房间
	function room_save_path(){
		return getRootPath(3)+"/anchor/save_room"
	}
	// 删除房间
	function room_delete_path(){
		return getRootPath(3)+"/anchor/delete_room"
	}
	// 保存房间筹码
	function room_chip_save_path(){
		return getRootPath(3)+"/chip/save_chip"
	}
	// 删除房间筹码
	function room_chip_delete_path(){
		return getRootPath(3)+"/chip/delete_chip"
	}


// **********************************Path END ***************************************************