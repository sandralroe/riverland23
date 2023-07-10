/* license goes here */
initMuraComments=function(config){
	config=config || {};

	var $editor = jQuery('#mura-comment-post-comment');
	var $commentsProxyPath = config.proxyPath || Mura.corepath + "/modules/v1/comments/ajax/commentsProxy.cfc";
	var $newcommentid = jQuery("#mura-comment-post-comment [name=commentid]").val();
	var $name = jQuery("#mura-comment-post-comment [name=name]").val();
	var $url = jQuery("#mura-comment-post-comment [name=url]").val();
	var $email = jQuery("#mura-comment-post-comment [name=email]").val();
	var $currentedit = "";
	var $nextN = 3;
	var params = {
			// empty
	};

	 var initPage=function() {

		loadPage(params).done(function(data){
			data=Mura.setLowerCaseKeys(data);
			if (data.count > 0) {
				jQuery('#mura-comments-page').html(data.htmloutput);
				jQuery('#mura-comments-sort').show();
			} else {
				jQuery('#mura-comments-sort').hide();
			}
			bindEvents();
			handleHash();
		})

	}

	var handleHash=function() {
		var hash = window.location.hash;

		//Only do this if there is a valid hash and it's not hash based filenames
		if (hash.length > 0 && hash.indexOf("#/")==-1 && hash.indexOf("=")==-1) {
			if (jQuery('' + hash).length != 0) {
				scrollToID(jQuery(hash));
			} else {
				/* load comments, then scroll to */
				var params = {
					pageNo: jQuery("#mura-more-comments").attr('data-pageno'),
					commentID: hash.replace('#mura-comment-', '')
				};

				loadPage(params).done(function(data){
					data=Mura.setLowerCaseKeys(data);
					jQuery("#mura-more-comments").parent().remove();
					jQuery(data.htmloutput).appendTo('#mura-comments-page').hide().fadeIn();
					bindEvents();
					if (jQuery(hash).length != 0) {
						scrollToID(jQuery(hash));
					}
				});
			}
		}
	}

	var loadPage=function(ext) {

		var params = {
			method: "renderCommentsPage",
			contentID: jQuery('#mura-comments-page').attr('data-contentid'),
			siteID: jQuery('#mura-comments-page').attr('data-siteid'),
			sortDirection: jQuery('#mura-sort-direction-selector').val(),
			nextN: $nextN
		};

		jQuery.extend(params, ext);

		return jQuery.ajax({
			dataType: "json",
			url: $commentsProxyPath,
			data: params,
			cache: false
		});
	}

	var scrollToID=function(elem) {
		$('html, body').animate({
			scrollTop: elem.offset().top - 50
		}, 500, function(){
			elem.fadeTo('fast', 0.5, function() {
				elem.fadeTo('fast', 1);
			});
		});
	}

	var bindEvents=function(){

		if(typeof customCommentsPageInit == 'function'){
			customCommentsPageInit();
		}

		jQuery("a.mura-in-reply-to").on('click', function( event ) {
			event.preventDefault();
			var a = jQuery(this);
			var parentid = a.attr('data-parentid');

			if (jQuery('#mura-comment-' + parentid).length != 0) {
				scrollToID(jQuery('#mura-comment-' + parentid));
			} else {
				/* load comments, then scroll to */
				var params = {
					pageNo: jQuery("#mura-more-comments").attr('data-pageno'),
					commentID: parentid,
					siteID: jQuery("#mura-more-comments").attr('data-siteid')
				};

				loadPage(params).done(function(data){
					data=Mura.setLowerCaseKeys(data);
					jQuery("#mura-more-comments").parent().remove();
					jQuery(data.htmloutput).appendTo('#mura-comments-page').hide().fadeIn();
					bindEvents();
					if (jQuery('#mura-comment-' + parentid).length != 0) {
						scrollToID(jQuery('#mura-comment-' + parentid));
					}
				})
			}
		});

		jQuery("a.mura-comment-flag-as-spam").on('click', function( event ) {
			event.preventDefault();
			var a = jQuery(this);
			var id = a.attr('data-id');
			var siteid = a.attr('data-siteidid')

			var actionURL = $commentsProxyPath + "?method=flag&commentID=" + id + "&siteid=" + siteid;
			jQuery.get(
				actionURL,
				function(data){
					a.html('Flagged as Spam');
					a.unbind('click');
					a.on('click', function( event ) {
						event.preventDefault();
					});
				}
			);
		});

		jQuery("#mura-more-comments").on('click', function( event ) {
			event.preventDefault();
			var a = jQuery(this);
			var pageNo = a.attr('data-pageno');
			var contentID = jQuery('#mura-comments-page').attr('data-contentid');
			var params = {
				pageNo: pageNo
			};

			loadPage(params).done(function(data){
				data=Mura.setLowerCaseKeys(data);
				a.parent().remove();
				jQuery(data.htmloutput).appendTo('#mura-comments-page').hide().fadeIn();
				bindEvents();
				jQuery(".mura-comment-reply-wrapper").hide();
			})

		});

		jQuery("#mura-sort-direction-selector").on('change', function( event ) {
			var params = {
				// empty
			};

			loadPage(params).done(function(data){
				data=Mura.setLowerCaseKeys(data);
				jQuery('#mura-comments-page').html(data.htmloutput);
				bindEvents();
			})

		});

		jQuery(document).on('click', '.mura-comment-reply a', function( event ) {
			var id = jQuery(this).attr('data-id');
			jQuery(".mura-comment-reply-wrapper").hide();
			if($.currentedit != ''){
				jQuery($currentedit).show();
				$currentedit='';
			}

			event.preventDefault();
			$editor.hide();
			$editor.detach();
			jQuery("#mura-comment-post-comment-" + id).append($editor).show();
			jQuery("#mura-comment-post-a-comment").changeElementType('div').hide();
			jQuery("#mura-comment-edit-comment").changeElementType('div').hide();
			jQuery("#mura-comment-reply-to-comment").changeElementType('legend').show();
			jQuery("#mura-comment-post-comment-" + id + " [name=name]").val($name);
			jQuery("#mura-comment-post-comment-" + id + " [name=email]").val($email);
			jQuery("#mura-comment-post-comment-" + id + " [name=url]").val($url);
			jQuery("#mura-comment-post-comment-" + id + " [name=comments]").val("");
			jQuery("#mura-comment-post-comment-" + id + " [name=parentid]").val(id);
			jQuery("#mura-comment-post-comment-" + id + " [name=commentid]").val($newcommentid);
			jQuery("#mura-comment-post-comment-" + id + " [name=commenteditmode]").val("add");
			jQuery("#mura-comment-post-comment-comment").show();
			$editor.slideDown();
		});

		jQuery(document).on('click', '.mura-comment-edit-comment', function( event ) {
			event.preventDefault();
			jQuery(".mura-comment-reply-wrapper").hide();
			var id = jQuery(this).attr('data-id');
			var siteid = jQuery(this).attr('data-siteid');
			var actionURL=$commentsProxyPath + "?method=get&commentID=" + id + "&siteid=" + siteid;
			jQuery.get(
				actionURL,
				function(data){
					data=eval("(" + data + ")" );

					if($.currentedit != ''){
						 jQuery($currentedit).show();
						 $currentedit='';
					}

					$editor.hide();
					$editor.detach();
					jQuery("#mura-comment-post-comment-" + id).append($editor).show();
					jQuery("#mura-comment-post-a-comment").changeElementType('div').hide();
					jQuery("#mura-comment-edit-comment").changeElementType('legend').show();
					jQuery("#mura-comment-reply-to-comment").changeElementType('div').hide();

					jQuery("#comment-" + id + " .comment").hide();
					$currentedit="#comment-" + id + " .comment";

					jQuery("#mura-comment-post-comment-" + id + " [name=parentid]").val(data.parentid);
					jQuery("#mura-comment-post-comment-" + id + " [name=name]").val(data.name);
					jQuery("#mura-comment-post-comment-" + id + " [name=email]").val(data.email);
					jQuery("#mura-comment-post-comment-" + id + " [name=url]").val(data.url);
					jQuery("#mura-comment-post-comment-" + id + " [name=comments]").val(data.comments);
					jQuery("#mura-comment-post-comment-" + id + " [name=commentid]").val(data.commentid);
					jQuery("#mura-comment-post-comment-" + id + " [name=commenteditmode]").val("edit");
					jQuery("#mura-comment-post-comment-comment").show();
					$editor.slideDown();
				},
				'text'
			);
		});

		jQuery("#mura-comment-post-comment-comment").on('click', function( event ) {
			jQuery("#mura-comment-post-comment-comment").hide();
			jQuery(".mura-comment-reply-wrapper").hide();
			if($.currentedit != ''){
				 jQuery($currentedit).show();
				 $currentedit='';
			}

			event.preventDefault();
			$editor.hide();
			$editor.detach();
			jQuery("#mura-comment-post-comment-form").append($editor).show();
			jQuery("#mura-comment-post-a-comment").changeElementType('legend').show();
			jQuery("#mura-comment-edit-comment").changeElementType('div').hide();
			jQuery("#mura-comment-reply-to-comment").changeElementType('div').hide();
			jQuery("#mura-comment-post-comment [name=parentid]").val("");
			jQuery("#mura-comment-post-comment [name=name]").val($name);
			jQuery("#mura-comment-post-comment [name=email]").val($email);
			jQuery("#mura-comment-post-comment [name=url]").val($url);
			jQuery("#mura-comment-post-comment [name=comments]").val("");
			jQuery("#mura-comment-post-comment [name=commentid]").val($newcommentid);
			jQuery("#mura-comment-post-comment [name=commenteditmode]").val("add");
			$editor.slideDown();
		});
	}

	initPage();

}
