/* License goes here */
feedManager = {
	loadSiteFilters(siteid, keywords, isNew, contentPoolID) {
		var url = 'index.cfm';
		var pars = 'muraAction=cFeed.loadSite&compactDisplay=true&siteid=' + siteid + '&keywords=' + keywords + '&isNew=' + isNew + '&contentPoolID=' + contentPoolID +'&cacheid=' + Math.random();
		var d = $('#selectFilter');
		d.html('<div class="load-inline"></div>');
		$('#selectFilter .load-inline').spin(spinnerArgs2);
		$.get(url + "?" + pars, function(data) {
			$('#selectFilter').html(data);
			// Check items by default
			$('#contentResults').find('tbody > tr').each(function() {
				var id = $(this).attr('id').replace('add-','del-');
				if($('#contentFilters').find('#' + id).length > 0) {
					$(this)
						.find('li.add')
						.addClass('disabled')
						.find('i')
						.removeClass('mi-plus-circle')
						.addClass('mi-check-circle')
				}
			 });
		});
	},

	addContentFilter(contentID, contentType, sourceID) {
		// Check items by default
		$(this)
			.parent()
			.addClass('disabled')
			.children()
			.find('i')
			.removeClass('mi-plus-circle')
			.addClass('mi-check-circle');

		var tbody = document.getElementById('contentFilters').getElementsByTagName("TBODY")[0];
		var row = document.createElement("TR");
		row.id = "del-" + contentID;

		var name = document.createElement("TD");
		name.className = "var-width";
		$(name).html($('#' + decodeURI(sourceID)).html());

		var type = document.createElement("TD");
		$(type).html(decodeURI(contentType));

		var admin = document.createElement("TD");
		admin.className = "actions";

		var deleteLink = document.createElement("A");
		deleteLink.setAttribute("href", "javascript:void(0);");
		deleteLink.setAttribute("title", "Delete");
		deleteLink.onclick = function() { feedManager.removeFilter(contentID); }
		var deleteIcon = document.createElement("I");
		deleteIcon.setAttribute("class", "mi-trash");

		deleteLink.appendChild(deleteIcon);

		var deleteUL = document.createElement("UL");
		deleteUL.className = "clearfix";
		var deleteLI = document.createElement("LI");
		deleteLI.className = "delete";
		deleteLI.appendChild(deleteLink);
		deleteUL.appendChild(deleteLI);

		var content = document.createElement("INPUT");
		content.setAttribute("type", "hidden");
		content.setAttribute("name", "contentID");
		content.setAttribute("value", contentID);
		admin.appendChild(content);
		admin.appendChild(deleteUL);
		row.appendChild(admin);
		row.appendChild(name);
		row.appendChild(type);
		tbody.appendChild(row);
		if($('#noFilters').length) $('#noFilters').hide();

		stripe('stripe');

	},

	removeFilter(id) {
		$("#del-" + id).remove();
		$("#add-" + id)
			.find('li.add')
			.removeClass('disabled')
			.find('i')
			.removeClass('mi-check-circle')
			.addClass('mi-plus-circle');

		stripe('stripe');
		return false;
	},


	loadSiteParents(siteid, parentid, keywords, isNew) {
		var url = 'index.cfm';
		var pars = 'muraAction=cFeed.siteParents&compactDisplay=true&siteid=' + siteid + '&parentid=' + parentid + '&keywords=' + keywords + '&isNew=' + isNew + '&cacheid=' + Math.random();
		var d = $('#move');
		d.html('<div class="load-inline"><inut type=hidden name=parentid value=' + parentid + ' ></div>');
		$('#move .load-inline').spin(spinnerArgs2);
		$.get(url + "?" + pars, function(data) {
			$("#move").html(data);
		});
	},

	confirmImport() {

		$("#alertDialogMessage").html('Import Selections?');
		$("#alertDialog").dialog({
			resizable: false,
			modal: true,
			buttons: {
				'Yes'() {
					$(this).dialog('close');
					submitForm(document.forms.contentForm, 'Import');
				},
				'No'() {
					$(this).dialog('close');
				}
			}
		});

		return false;
	},

	setDisplayListSort() {
		$("#availableListSort, #displayListSort").sortable({
			connectWith: ".displayListSortOptions",
			update(event) {
				event.stopPropagation();
				$("#displayList").val("");
				$("#displayListSort > li").each(function() {
					var current = $("#displayList").val();

					if(current != '') {
						$("#displayList").val(current + "," + $.trim($(this).html()));
					} else {
						$("#displayList").val($.trim($(this).html()));
					}

				});
			}
		}).disableSelection();
	},

	updateInstanceObject() {
		var availableObjectParams = {};
		$("#tabDisplay").find(":input").each(

		function() {
			var item = $(this);
			if(item.attr("type") != "radio" || (item.attr("type") == "radio" && item.is(':checked'))) {
				availableObjectParams[item.attr("data-displayobjectparam")] = item.val();
			}
		})
		$("#instanceParams").val(JSON.stringify(availableObjectParams));
	}
}
