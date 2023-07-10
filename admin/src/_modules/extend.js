/* License goes here */

extendManager = {

	showSaveSort(id) {
		$('#showSort').hide();
		$('#saveSort').show();

		$(".handle").each(

		function(index) {
			$(this).show();
		});

		this.setSortable(id);

	},

	showSort(id) {
		$('#showSort').show();
		$('#saveSort').hide();

		$(".handle").each(

		function(index) {
			$(this).hide();
		});

		$("#" + id).sortable('destroy');
		$("#" + id).enableSelection();

	},

	showRelatedSaveSort(id) {
		$('#showRelatedSort').hide();
		$('#saveRelatedSort').show();

		$(".handleRelated").each(

		function(index) {
			$(this).show();
		});

		this.setSortable(id);

	},

	showRelatedSort(id) {
		$('#showRelatedSort').show();
		$('#saveRelatedSort').hide();

		$(".handleRelated").each(

		function(index) {
			$(this).hide();
		});

		$("#" + id).sortable('destroy');
		$("#" + id).enableSelection();

	},

	saveAttributeSort(id) {
		var attArray = new Array();

		$("#" + id + ' > li').each(

		function(index) {
			attArray.push($(this).attr("attributeID"));
		});

		var url = "index.cfm";
		var pars = 'muraAction=cExtend.saveAttributeSort&attributeID=' + attArray.toString() + '&cacheID=' + Math.random();

		//location.href=url + "?" + pars;
		$.get(url + "?" + pars);
		this.showSort(id)
	},

	saveExtendSetSort(id) {
		var setArray = new Array();

		$("#" + id + ' > li').each(

		function(index) {
			setArray.push($(this).attr("extendSetID"));
		});

		var url = "index.cfm";
		var pars = 'muraAction=cExtend.saveExtendSetSort&extendSetID=' + setArray.toString() + '&cacheID=' + Math.random();

		//location.href=url + "?" + pars;
		$.get(url + "?" + pars);
		this.showSort(id);
	},

	saveRelatedSetSort(id) {
		var setArray = new Array();

		$("#" + id + ' > li').each(

		function(index) {
			setArray.push($(this).attr("relatedContentSetID"));
		});

		var url = "index.cfm";
		var pars = 'muraAction=cExtend.saveRelatedSetSort&relatedContentSetID=' + setArray.toString() + '&cacheID=' + Math.random();

		//location.href=url + "?" + pars;
		$.get(url + "?" + pars);
		this.showRelatedSort(id);
	},

	setSortable(id) {
		$("#" + id).sortable();
		$("#" + id).disableSelection();
	},

	setBaseInfo(str) {
		var dataArray = str.split("^");

		document.subTypeFrm.type.value = dataArray[0];

		if(dataArray.length > 1) {
			document.subTypeFrm.baseTable.value = dataArray[1];
			document.subTypeFrm.baseKeyField.value = dataArray[2];
			document.subTypeFrm.dataTable.value = dataArray[3];
		}
		if(dataArray[0] == "") {
			$(".hasRow1Container").hide();
			$(".subTypeContainer").hide();
			$(".SubTypeIconSelect").hide();
			$(".hasSummaryContainer").hide();
			$(".hasBodyContainer").hide();
			$(".hasConfiguratorContainer").hide();
			$(".availableSubTypesContainer").hide();
			$(".hasAssocFileContainer").hide();
			$(".adminOnlyContainer").hide();
		} else if(dataArray[0] == "Site") {
			$(".hasRow1Container").hide();
			$(".subTypeContainer").hide();
			$(".SubTypeIconSelect").hide();
			$(".hasSummaryContainer").hide();
			$(".hasBodyContainer").hide();
			$(".hasConfiguratorContainer").hide();
			$(".hasAssocFileContainer").hide();
			$(".adminOnlyContainer").hide();
			$("#subType").val("Default");
		} else if(dataArray[0] == "1" || dataArray[0] == "2" || dataArray[0] == "Address" || dataArray[0] == "Custom" || dataArray[0] == "Base") {
			$(".hasRow1Container").hide();
			$(".subTypeContainer").show();
			$(".SubTypeIconSelect").hide();
			$(".hasSummaryContainer").hide();
			$(".hasBodyContainer").hide();
			$(".hasConfiguratorContainer").hide();
			$(".availableSubTypesContainer").hide();
			$(".hasAssocFileContainer").hide();
			$(".adminOnlyContainer").hide();
		} else if(dataArray[0] == "File" || dataArray[0] == "Link") {
			$(".hasRow1Container").show();
			$(".subTypeContainer").show();
			$(".SubTypeIconSelect").show();
			$(".hasSummaryContainer").show();
			$(".hasBodyContainer").hide();
			$(".hasConfiguratorContainer").hide();
			$(".availableSubTypesContainer").show();
			if(dataArray[0] == "File"){
				$(".hasAssocFileContainer").hide();
			} else {
				$(".hasAssocFileContainer").show();
			}
			$(".adminOnlyContainer").show();
		} else if(dataArray[0] == "Folder" || dataArray[0] == "Gallery" || dataArray[0] == "Calendar") {
			$(".hasRow1Container").show();
			$(".subTypeContainer").show();
			$(".SubTypeIconSelect").show();
			$(".hasSummaryContainer").show();
			$(".hasBodyContainer").show();
			if ( $("input[name='isnew']").val() === '1' ) {
				$('#hasConfiguratorYes').prop('checked', true);
			}
			$(".hasConfiguratorContainer").show();
			$(".availableSubTypesContainer").show();
			$(".hasAssocFileContainer").show();
			$(".adminOnlyContainer").show();
		} else if(dataArray[0] == "Form" || dataArray[0] == "Component" || dataArray[0] == "Variation") {

			$(".subTypeContainer").show();
			$(".SubTypeIconSelect").show();

			if(dataArray[0] == "Variation"){
				$(".hasRow1Container").hide();
				$(".hasAssocFileContainer").hide();
				$(".hasBodyContainer").hide();
			} else {
				$(".hasRow1Container").show();
				$(".hasBodyContainer").show();
				$(".hasAssocFileContainer").hide();
			}

			//$(".hasRow1Container").hide();

			$(".hasSummaryContainer").hide();

			if ( $("input[name='isnew']").val() === '1' ) {
				$('#hasConfiguratorYes').prop('checked', true);
			}

			$(".hasConfiguratorContainer").hide();
			$(".availableSubTypesContainer").show();
			$(".adminOnlyContainer").show();
		} else {
			$(".hasRow1Container").show();
			$(".subTypeContainer").show();
			$(".SubTypeIconSelect").show();
			$(".hasSummaryContainer").show();
			$(".hasBodyContainer").show();
			$(".hasConfiguratorContainer").hide();
			$(".availableSubTypesContainer").show();
			$(".hasAssocFileContainer").show();
			$(".adminOnlyContainer").show();
		}

	}
}
