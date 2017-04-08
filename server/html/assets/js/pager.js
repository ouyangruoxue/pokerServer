  // 添加这个函数，可以在js页面中引入其他js文件
 function include(path){ 
    var a=document.createElement("script");
    a.type = "text/javascript"; 
    a.src=path; 
    var head=document.getElementsByTagName("head")[0];
    head.appendChild(a);
    }

 
 include("jquery-3.1.1.min.js");		 // 引入json2  js文件
 
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
		endPage = "<a href='javascript:;' onclick=’beginPostTestResult("+maxPage+")'>末页</a>";
		nextPage =  "<a href='javascript:;' onclick='beginPostTestResult("+(page+1)+")'>下一页</a>";
	}else if(page >1 && page < maxPage){
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