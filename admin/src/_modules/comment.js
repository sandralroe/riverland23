/* License goes here */

commentManager = {
	reload:false,
	loadSearch(values){
		var url = './';
		var pars = 'muraAction=cComments.loadComments&siteid=' + siteid + '&' + values + '&cacheid=' + Math.random();
		commentManager.reload=false;
		var d = $('#commentSearch');
		d.html('<div class="load-inline"></div>');
		$('#commentSearch .load-inline').spin(spinnerArgs2);
		$.get(url + "?" + pars, function(data) {
			$('#commentSearch').html(data);

			setDatePickers(".mura-custom-datepicker", dtLocale, dtCh);

			setCheckboxTrees();

			$('#advancedSearch').find('ul.categories:not(.checkboxTrees)').css("margin-left", "10px");

			commentManager.bindEvents();
		});
	},

	bulkEdit(){
		var values = $('#frmUpdate').serialize();
		var url = './';
		var pars = 'muraAction=cComments.bulkEdit&siteid=' + siteid + '&' + values + '&cacheid=' + Math.random();

		$.get(url + "?" + pars, function(){commentManager.submitSearch();});
	},

	singleEdit(commentid, updateaction){
		var url = './';
		var pars = 'muraAction=cComments.singleEdit&siteid=' + siteid + '&commentid=' + commentid + '&updateaction=' + updateaction + '&cacheid=' + Math.random();
		commentManager.reload=true;
		$.get(url + "?" + pars, function(){$('.modal').modal('hide');});
	},

	submitSearch(){
		commentManager.loadSearch($('#commentSearch input, #commentSearch select').serialize());
	},

	setSort(k){
		$('#sortBy').val(k.attr('data-sortby'));
		$('#sortDirection').val(k.attr('data-sortdirection'));

		commentManager.submitSearch();
	},

	setNextN(k){
		$('#nextN').val(k.attr('data-nextn'));

		commentManager.submitSearch();
	},

	setPageNo(k){
		$('#pageNo').val(k.attr('data-pageno'));

		commentManager.submitSearch();
	},

	bindEvents(){

		$('#btnSearch').click(function(e){
			e.preventDefault();
			commentManager.submitSearch();
		});

		$('#frmSearch').submit(function(e){
			e.preventDefault();
			commentManager.submitSearch();
		});

		$('a.sort').click(function(e){
			e.preventDefault();
			commentManager.setSort($(this));
		});

		$('a.nextN').click(function(e){
			e.preventDefault();
			commentManager.setNextN($(this));
		});

		$('a.pageNo').click(function(e){
			e.preventDefault();
			commentManager.setPageNo($(this));
		});

		// CHECKBOXES
		$('#checkall').click(function (e) {
			e.preventDefault();
			var checkBoxes = $(':checkbox.checkall');
			checkBoxes.prop('checked', !checkBoxes.prop('checked'));
		});

		// APPROVE
		$('a.bulkEdit').click(function(e) {
			e.preventDefault();
			var k = $(this);
			confirmDialog(
				k.attr('data-alertmessage'),
				function(){
					$('#bulkedit').val(k.attr('data-action'));
					commentManager.bulkEdit();
				}
			)
		});

		// PURGE
		$('a#purge-comments').click(function(e) {
			e.preventDefault();
			var k = $(this);
			console.log('request to purge');
			confirmDialog(
				k.attr('data-alertmessage'),
				function(){
					console.log('purge approved');
					actionModal(function(){commentManager.purgeDeletedComments();});
				}
			)
		});

		$('a.singleEdit').click(function(e) {
			e.preventDefault();
			var k = $(this);
			commentManager.singleEdit(k.attr('data-commentid'), k.attr('data-action'));

		});

		$('.modal').on('show.bs.modal', function(){
			var k = $(this);

			var params = {
				contentID: k.attr('data-contentid'),
				commentID: k.attr('data-commentid')
			};

			k.find('div.modal-body').html('<div class="load-inline"></div>');
			k.find('div.modal-body .load-inline').spin(spinnerArgs2);

			commentManager.loadPage(params).then(function(data){
				k.find('div.modal-body').html(data);

				var elem = $('#detail-' + k.attr('data-commentid'));
					elem.fadeIn();

				k.find('div.modal-body').animate({ scrollTop: elem.position().top}, 'slow');

				commentManager.bindAjaxEvents(k);
			})
		});

		$('.modal').on('hidden.bs.modal', function(){
			if(commentManager.reload){
				commentManager.submitSearch();
			} else {
				var k = $(this);
				k.find('#commentsPage').remove();
				k.find('div.modal-body').html('<div class="load-inline"></div>');
				k.find('div.modal-body .load-inline').spin(spinnerArgs2);
			}
		});

	},

	bindAjaxEvents(k) {
		k.find('#moreCommentsUp').unbind('click').on('click', function(e){
			e.preventDefault();
			var params = {
				contentID: k.attr('data-contentid'),
				upperID: $(this).attr('data-upperid')
			};

			commentManager.loadPage(params).then(function(data){
				k.find('#moreCommentsUpContainer').remove();
				//k.find('#commentsPage').prepend(data);
				$(data).prependTo(k.find('#commentsPage')).hide().fadeIn();
				commentManager.bindAjaxEvents(k);
			});
		});

		k.find('#moreCommentsDown').unbind('click').on('click', function(e){
			e.preventDefault();
			var params = {
				contentID: k.attr('data-contentid'),
				lowerID: $(this).attr('data-lowerid')
			};

			commentManager.loadPage(params).then(function(data){
				k.find('#moreCommentsDownContainer').remove();
				//k.find('#commentsPage').append(data);
				$(data).appendTo(k.find('#commentsPage')).hide().fadeIn();
				commentManager.bindAjaxEvents(k);
			});
		});

		k.find('.inReplyTo').on('click',function(e){
			e.preventDefault();

			var parentid = $(this).attr('data-parentid');

			if($('#detail-' + parentid).length) {
				commentManager.scrollToID($('#detail-' + parentid));
			} else {
				var params = {
					contentID: k.attr('data-contentid'),
					upperID: $(this).attr('data-parentid')
				};

				commentManager.loadPage(params).then(function(data){
					k.find('#moreCommentsUpContainer').remove();
					//k.find('#commentsPage').prepend(data);
					$(data).prependTo(k.find('#commentsPage')).hide().fadeIn();
					commentManager.bindAjaxEvents(k);
					commentManager.scrollToID($('#detail-' + parentid));
				});
			}

		});

	},

	scrollToID(elem) {
		$('html, body').animate({
			scrollTop: elem.offset().top - 50
		}, 500, function(){
			elem.fadeTo('fast', 0.5, function() {
				elem.fadeTo('fast', 1);
			});
		});
	},

	loadPage(ext) {
		var params = {
			muraAction: "ccomments.loadcommentspage",
			sortDirection: 'asc',
			siteid: siteid
		};

		$.extend(params, ext);

		return $.ajax({
			url: './',
			data: params,
			cache: false
		});
	},

	purgeDeletedComments(){
		var url = './';
		var pars = 'muraAction=cComments.purgeDeletedComments&siteid=' + siteid + '&cacheid=' + Math.random();
		$.get(url + "?" + pars, function(){
			$('#action-modal').remove();
			commentManager.submitSearch();
		});
	}
}
