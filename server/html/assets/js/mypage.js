// 参数定义
// all_count 数据库查询出来的总的记录条数
// page_size 每页显示的条数
// page_count 总的页面数
// cur_page 当前页面数,比如当前是第5页





// 根据总的记录数获取总页数  page_count
function build_index(all_count,page_size){
	var page_count
	if(all_count<=page_size){
		page_count=1
	}else{
		page_count=all_count/page_size
		if (all_count%page_size!=0){
			page_count=page_count+1
		}
	}
	var tempstr=""
	for(var i=0;i<page_count,i++){
		// 生成页码数
		if(""==tempstr){
			tempstr="<li><a id='index_"+i+"'>"+i+"</a></li>"
		}else{
			tempstr=tempstr+"<li><a id='index_"+i+"'>"+i+"</a></li>"
		}
	}
	document.getElementById("index_div").innerHtml(tempstr)
}




// var header1 = document.getElementById("header"); 
// var p = document.createElement("p"); // 创建一个元素节点 
// insertAfter(p,header1); // 因为js没有直接追加到指定元素后面的方法 所以要自己创建一个方法 
// function insertAfter(newElement, targetElement){ // newElement是要追加的元素 targetElement 是指定元素的位置 
	// var parent = targetElement.parentNode; // 找到指定元素的父节点 
	// if(parent.lastChild == targetElement){ // 判断指定元素的是否是节点中的最后一个位置 如果是的话就直接使用appendChild方法 
		// parent.appendChild( newElement,targetElement ); 
	// }else{
		// parent.insertBefore( newElement,targetElement.nextSibling ); 
	// }
// }