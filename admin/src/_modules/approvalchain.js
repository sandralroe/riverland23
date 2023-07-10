chainManager={
	setGroupMembershipSort() {
		$("#groupAvailableListSort, #groupAssignmentListSort").sortable({
			connectWith: ".groupDisplayListSortOptions",
			update(event,ui) {
				event.stopPropagation();
				if(ui.item.parents("ol:first").attr("id") =='groupAssignmentListSort'){
					ui.item.find('input:first').attr('name','groupID');
				} else {
					ui.item.find('input:first').attr('name','availableID');
				}
			}
		}).disableSelection();
	}
};