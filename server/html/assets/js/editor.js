/**
 * 创建文本编辑器工具
 * 	依赖jquery
 */
var ctx = '';
if($('script[editor-ctx]').length > 0) {
	ctx = $('script[editor-ctx]').attr('editor-ctx');
}
var scriptLoaded = false;
/**
 * 并联加载指定的脚本
 * 并联加载[同步]同时加载，不管上个是否加载完成，直接加载全部
 * 全部加载完成后执行回调
 * @param array|string 指定的脚本们
 * @param function 成功后回调的函数
 * @return array 所有生成的脚本元素对象数组
 */ 
function parallelLoadScripts(scripts, callback) {
	if (typeof (scripts) != "object") var scripts = [ scripts ];
	var HEAD = document.getElementsByTagName("head").item(0) || document.documentElement, s = new Array(), loaded = 0;
	for (var i = 0; i < scripts.length; i++) {
		s[i] = document.createElement("script");
		s[i].setAttribute("type", "text/javascript");
		s[i].onload = s[i].onreadystatechange = function() { //Attach handlers for all browsers
			if (!/*@cc_on!@*/0 || this.readyState == "loaded" || this.readyState == "complete") {
				loaded++;
				this.onload = this.onreadystatechange = null;
				this.parentNode.removeChild(this);
				if (loaded == scripts.length && typeof (callback) == "function") {
					callback();
				}
			}
		};
		s[i].setAttribute("src", scripts[i]);
		HEAD.appendChild(s[i]);
	}
}
// 扩展jquery,检查元素是否在屏幕中显示
$.fn.isOnScreen = function(){
	var win = $(window);
	
	var viewport = {
		top : win.scrollTop(),
		left : win.scrollLeft()
	};
	viewport.right = viewport.left + win.width();
	viewport.bottom = viewport.top + win.height();
	
	var bounds = this.offset();
	bounds.right = bounds.left + this.outerWidth();
	bounds.bottom = bounds.top + this.outerHeight();
	
	return (!(viewport.right < bounds.left || viewport.left > bounds.right || viewport.bottom < bounds.top || viewport.top > bounds.bottom));
};
var editor = function($dom, toolbar) {
	function init($dom, toolbar) {
		$dom.css({
			width: 640,
			height: 320
		});
		var editor = new baidu.editor.ui.Editor();
		var id = $dom.attr('id');
		editor.render(id);
		
		editor.addListener('afterExecCommand', function(ev) {
			setTimeout(function() {
				$($('.edui-default iframe').get(0).contentWindow.document.body).find('img').each(function() {
					if(typeof($(this).attr('width')) === 'undefined' || $(this).attr('width') <= 0) {
						$(this).attr({
							'width': $(this).get(0).naturalWidth,
							'height': $(this).get(0).naturalHeight
						})
					}
				});
			}, 2000);
		})
		
		return editor;
	}
	
	// 创建位置参考元素
	var refer = document.createElement('font');
	$dom.before(refer);
	var $refer = $(refer);
	
	// 初始化编辑器
	var editor = false;
	if(scriptLoaded) {
		editor = init($dom, toolbar);
	} else {
		var scripts = [ctx + '/static/plugin/ueditor/ueditor.all.min.js', ctx + '/static/plugin/ueditor/ueditor.config.js'];
		parallelLoadScripts(scripts, function() {
			scriptLoaded = true;
			editor = init($dom, toolbar);
		});
	}
	
	// 监听滚动条,以控制工具栏位置
	setTimeout(function() {
		var $ueditor = $dom.siblings('.edui-default');
		var $toolbar = $ueditor.find('.edui-editor-toolbarbox');
		$(window).scroll(function() {
			if($refer.isOnScreen()) {
				$toolbar.css({
					'z-index': 9999,
					'position': 'relative',
				});
			} else {
				$toolbar.css({
					'position': 'fixed',
					'top': 0,
					'z-index': 9999,
					'width': $ueditor.width()
				});
			}
		});
	}, 1000);
	
	return editor;
}
var setEditorText = function($editor, value) {
	if($editor) {
		if(!value) {
			value = '';
		}
		var id = $editor.attr('id');
		if(typeof(UE) !== 'undefined') {// 脚本已加载完成
			UE.getEditor(id).setContent(value, false);
		} else {
			setTimeout(function() {
				UE.getEditor(id).setContent(value, false);
			}, 2000);
		}
		
		// 防止编辑器高多过高
		setTimeout(function() {
			UE.getEditor(id).setContent(value, false);
		}, 500);
		
		// 防止自动生成多个编辑器
		var editors = $editor.siblings('.edui-default');
		var length = editors.length;
		if(length > 1) {
			$(editors[length-1]).show();
			for(var i=0; i<=length-2; i++) {
				editors[i].remove();
			}
		}
	}
}