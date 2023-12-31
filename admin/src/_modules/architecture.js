/* License goes here */
siteManager = {

	formSubmitted: false,
	layoutmanager:false,
	fileLockConfirmed: false,
	hasFileLock: false,
	nodeLockConfirmed: false,
	hasNodeLock: false,
	dirtyRelatedContent: false,
	currentModuleID: "",
	copyContentID: "",
	copyModuleID: "",
	copySiteID: "",
	reloadURL: "",
	tablist: "",
	//submitDialogs:[{type:'alert',message:'test1',condition(){return true}},{type:'confirmation',message:'test2',condition(){return true}}],
	submitDialogs:[],
	submitActions:[],
	assigningChangeset:false,
	addSubmitDialog(dialog){
		siteManager.submitDialogs.push(dialog)
	},
	addSubmitAction(actionFn){
		siteManager.submitActions.push(actionFn)
	},
	submitContentForm(){
		var handled=0;
		var cancelled=false;
		var dialogs=siteManager.submitDialogs;
		var actions=siteManager.submitActions;

		function submit(){
			var i;

			if(typeof CKEDITOR !='undefined'){
				for(i in CKEDITOR.instances){
					CKEDITOR.instances[i].updateElement();
				}
			}

			Mura("textarea.mura-markdown,textarea.markdownEditor").forEach(function(){
				var input=Mura(this);
				if(markdownInstances && typeof markdownInstances[input.attr('name')] != 'undefined'){
					if(input.length){
						if (!input.hasClass("markdown-lazy-init")){
							input.val(markdownInstances[input.attr('name')].getMarkdown())
						}
					}
				}
			})

			for(i=0;i<dialogs.length;i++){
				if(i == handled){
					var dialog=dialogs[i];

					if(dialog.type.toLowerCase()=='confirmation'){
						if(typeof dialog.condition == 'function'){
							var yesFn = function(){handled++; submit()};
							var noFn = null;

							if(typeof dialog.yesFn == 'function') {
								 yesFn = function(){
								 	if (dialog.yesFn()) { handled++; submit() }
								 }
							}
							if(typeof dialog.noFn == 'function') {
								 noFn = function(){
								 	if (dialog.noFn()) { handled++; submit() }
								 }
							}
							if(typeof dialog.condition == 'function'){
							 	if(dialog.condition(dialog)){

								 	confirmDialog($.extend(dialog,{yesAction:yesFn,noAction:noFn}));

								 	return false
							 	} else {
							 		handled++;
							 	}
							} else {
							 	confirmDialog($.extend(dialog,{yesAction:yesFn,noAction:noFn}));

							 	return false
							}
						} else {
							confirmDialog($.extend(dialog,{yesAction(){handled++; submit()}}));

							return false
						}
					} else if (dialog.type.toLowerCase()=='alert'){
						var okFn = function(){handled++; submit()};

						if(typeof dialog.okFn == 'function') {
							 okFn = function(){
								if (dialog.okFn()) { handled++; submit() }
							 }
						}

						if(typeof dialog.condition == 'function'){
							if(dialog.condition(dialog)){
								alertDialog($.extend(dialog,{okAction:okFn}));

								return false
							} else {
								handled++;
							}
						} else {
							alertDialog($.extend(dialog,{okAction:okFn}));

							return false
						}
					} else if (dialog.type.toLowerCase()=='validation'){
						if(typeof dialog.condition == 'function'){
							if(dialog.condition(dialog)){
								var okFn = function(){handled++; submit()};

								if(typeof dialog.okFn == 'function') {
									 okFn = function(){
										if (dialog.okFn()) { handled++; submit() }
									 }
								}

								alertDialog($.extend(dialog,{okAction:okFn}));

								return false
							} else {
								handled++;
							}
						} else {
							handled++;
						}
					} else {
						handled++;
					}
				}
			}

			if(handled==dialogs.length){
				for(var i=0;i<actions.length;i++){
					var submitAction = actions[i]();
					if (typeof submitAction == "boolean" && !submitAction) {
					 	return false;
					}
				}

				if(siteManager.assigningChangeset){
					$("#changesetID").val(currentChangesetSelection);
					$("#removePreviousChangeset").val(document.getElementById("_removePreviousChangeset").checked);

					if(currentChangesetSelection=='other'){
						$("#changesetname").val($("#_changesetname").val());
					} else {
						$("#changesetname").val('');
					}
				}

				if(document.contentForm.approved.value == 1 && draftremovalnotice != ""){
					confirmDialog(draftremovalnotice, function() {
						if(requiresApproval && (document.contentForm.approved.value || document.contentForm.changesetID.value)){
							Mura.post(Mura.getAPIEndpoint(),{
								method:'hasPendingRequest',
								contentid: document.contentForm.contentid.value,
								changesetid: document.contentForm.changesetID.value
							}).then(function(resp){
								if(resp.data.count){
									confirmDialog(cancelPendingApproval, function() {
										document.contentForm.cancelpendingapproval.value=true;
										siteManager.formSubmitted = true;
										actionModal(function(){document.contentForm.submit()});			
									});
								}
							})
						} else {
							document.contentForm.cancelpendingapproval.value=true;
							siteManager.formSubmitted = true;
							actionModal(function(){document.contentForm.submit()});
						}
					});
				} else {
					if(requiresApproval && (document.contentForm.approved.value || document.contentForm.changesetID.value)){
						Mura.post(Mura.getAPIEndpoint(),{
							method:'hasPendingRequest',
							contentid: document.contentForm.contentid.value,
							changesetid: document.contentForm.changesetID.value
						}).then(function(resp){
							if(resp.data.count){
								confirmDialog(cancelPendingApproval, function() {
									document.contentForm.cancelpendingapproval.value=true;
									siteManager.formSubmitted = true;
									actionModal(function(){document.contentForm.submit()});			
								});
							} else {
								siteManager.formSubmitted = true;
								actionModal(function(){document.contentForm.submit()});	
							}
						})
					} else {
						document.contentForm.cancelpendingapproval.value=true;
						siteManager.formSubmitted = true;
						actionModal(function(){document.contentForm.submit()});	
					}
				}
			}
		}
		submit();
	},

	async validateAltUrls() {
		
		if(!document.querySelectorAll('[name="ismuracontent"]').length){
			return false;
		}

		const inputTextURLs  = Object.values( document.getElementsByClassName('alturl-input') );
		const altStatusCodes = document.querySelectorAll('.altstatuscode select');
		const inputValues = [];
		

		const contentId = document.querySelectorAll('[name="contentid"]')[0].value;

		inputTextURLs.forEach((input => {
			let selectElement = `altstatuscode_${input.name.split('_')[1]}`;
			selectElement     = document.querySelectorAll(`select[name='${selectElement}']`)[0];
			if(selectElement.className === '' && siteManager.isAltURLSelected(input.value)) {
				inputValues.push( { value: input.value, name: input.name, statusCode: selectElement.value } );
			} 
		}));
		
		let isMuraContent = document.querySelector('[name="ismuracontent"]:checked').value;
		
		return await Mura.getEntity('alturl').invoke('validateAltURL', { inputValues: JSON.stringify(inputValues), contentId, isMuraContent  })
		.then((val) => {
			console.log(val);
			if(val.result.haserrors) {
				const errorMessage = Object.values(val.result.errors)[0];
				alertDialog(errorMessage);
			}
			return val.result.haserrors;
		})
		.catch((error) => {
			console.log(error);
			alertDialog("Internal server error");
		});
		
	},

	isAltURLSelected(urlValue) {
		const divCollection = document.getElementById('alturls__selected').children;
		for( const div of divCollection ) {
			if(div.innerText.trim() === urlValue) {
				return true;
			}
		};
		return false;
		

	},

	ckContent(draftremovalnotice,validateOnly) {

		var autosave=false;
		var i;

		if(typeof CKEDITOR !='undefined'){
			for(i in CKEDITOR.instances){
				CKEDITOR.instances[i].updateElement();
			}
		}

		Mura("textarea.mura-markdown,textarea.markdownEditor").forEach(function(){
			var input=Mura(this);
			if(markdownInstances && typeof markdownInstances[input.attr('name')] != 'undefined'){
				if(input.length){
					if (!input.hasClass("markdown-lazy-init")){
						input.val(markdownInstances[input.attr('name')].getMarkdown())
					}
				}
			}
		})

		if(autosave){
			$("#unlockfilewithnew").val("false");
			$("#unlocknodewithpublish").val("false");
			document.contentForm.cancelpendingapproval.value='false';
			document.contentForm.approved.value=0;
		}

		if (typeof(isFormBuilder) != "undefined") {
			var checkComplete = siteManager.saveFormBuilder();
			if(!checkComplete) {
				alertDialog("All fields must have a 'name' before the form can be saved.");
				return false;
			}
		}

		if(typeof(document.contentForm.display) != 'undefined'){
			if(document.contentForm.display.value == '2') {
				var tempStart = $(".datepicker.mura-datepickerdisplayStart").val();
				var tempStop = $(".datepicker.mura-datepickerdisplayStop").val();
				//alert(tempStart);
				if(isDate(tempStart, 'DISPLAY START DATE') == false) {

					alertDialog("Please enter a valid date in the 'Display Start Date' field");
					return false;
				} else if(tempStop != '' && isDate(tempStop, 'DISPLAY STOP DATE') == false) {

					alertDialog("Please enter a valid date in the 'Display Stop Date' field");
					return false;
				}
			} else {
				$(".datepicker.mura-datepickerdisplayStart").val("");
				$(".datepicker.mura-datepickerdisplayStop").val("");
				$("#mura-displayStart").val("");
				$("#mura-displayStop").val("");
			}
		}

		if(document.contentForm.title.value == '') {
			if(document.contentForm.type.value == 'Component') {

				alertDialog("The form field 'Menu Title' is required");
				return false;

			} else if(document.contentForm.type.value == 'Form') {

				alertDialog("The form field 'Title' is required");
				return false;
			} else {

				alertDialog("The form field 'Long Title' is required");
				return false;
			}

		}

		if(document.contentForm.type.value == 'Link' && document.contentForm.body.value == '') {

			alertDialog("The form field 'URL' is required");
			return false;
		}

		if(!validateForm(document.contentForm)){
			return false;
		}

		if(!autosave && typeof(this.hasFileLock) != 'undefined' && !this.fileLockConfirmed && this.hasFileLock && $("input[name='newfile']").val() != '') {
			confirmDialog(this.unlockfileconfirm, function() {
				//alert('true')
				$("#unlockfilewithnew").val("true");
				if(siteManager.ckContent(false)) {
					siteManager.submitContentForm();
				}
			}, function() {
				//alert('false')
				$("#unlockfilewithnew").val("false");
				if(siteManager.ckContent(false)) {
					siteManager.submitContentForm();
				}
			});

			this.fileLockConfirmed = true;
			return false;
		}

		if(!validateOnly){
			if(!autosave && typeof(this.hasNodeLock) != 'undefined' && this.hasNodeLock && !this.nodeLockConfirmed) {
	//			alert('b')
				confirmDialog(this.unlocknodeconfirm, function() {
					//alert('true')
					$("#unlocknodewithpublish").val("true");
					if(siteManager.ckContent(false)) {
						siteManager.submitContentForm();
					}
				}, function() {
					//alert('false')
					$("#unlocknodewithpublish").val("false");
					if(siteManager.ckContent(false)) {
						siteManager.submitContentForm();
					}
				});

				this.nodeLockConfirmed = true;
				return false;
			}

			//alert(document.contentForm.muraPreviouslyApproved)
			//alert(document.contentForm.approved.value)
			//alert(cancelPendingApproval)

			if(!autosave && document.contentForm.muraPreviouslyApproved.value == 0 && document.contentForm.approved.value == 1){
				if(typeof(currentChangesetID) != 'undefined' && currentChangesetID != '') {
					confirmDialog(publishitemfromchangeset, function() {
						siteManager.submitContentForm();
					});
					return false;
				} else {
					siteManager.submitContentForm();
					return false;
				}
			} else {
				if(autosave){
					var data= new FormData(document.contentForm)
					$.ajax({
					    url: $(document.contentForm).attr("action"),
					    type: "post",
					    data: data
					});
				} else {
					siteManager.submitContentForm();
					return false;
				}
			}
		} else {
			return true;
		}
		
	},


	//  DHTML Menu for Site Summary
	DHTML: (document.getElementById || document.all || document.layers),
	lastid: "",
	getObj(name) {
		if(document.getElementById) {
			this.obj = document.getElementById(name);
			this.style = document.getElementById(name).style;
		} else if(document.all) {
			this.obj = document.all[name];
			this.style = document.all[name].style;
		} else if(document.layers) {
			this.obj = document.layers[name];
			this.style = document.layers[name];
		}
	},

	saveFormBuilder() {
		var iscomplete = $("#mura-templatebuilder").templatebuilder('iscomplete');

		if(iscomplete) {
			jQuery("#mura-templatebuilder").templatebuilder('save');
			return true;
		}
		else {
			return false;
		}
	},

	openNewContentMenu(contentid, siteid, topid, parentid, type, moduleid) {

		var w = parseInt(Mura('#mura-content').width()) - 120;
		if(w > 570){w = 570};
		$("#newContentMenuContainer").remove();
		$("body").append('<div id="newContentMenuContainer" title="Loading..." style="display:none"><div id="newContentMenu"><div class="load-inline"></div></div></div>');
		console.log(getDialogPosition());
		$("#newContentMenuContainer").dialog({
			resizable: !1,
			modal: true,
			width: w,
			minWidth: 570,
			title: newContentMenuTitle,
			position: {
        my: "center",
        at: "top+120",
        of: "#mura-content",
        collision: "fit"
    },
    	// original method centers vertically
			//position: getDialogPosition(),
			/*
buttons: {
					Cancel() {
							$( this ).dialog( "close" );
					}
				},
*/
			open() {
				$("#newContentMenuContainer").html('<div class="ui-dialog-content ui-widget-content"><div class="load-inline"></div></div>');
				var url = './';
				var pars = 'muraAction=cArch.loadnewcontentmenu&siteid=' + siteid + '&contentid=' + contentid + '&parentid=' + parentid + '&topid=' + parentid + '&ptype=' + type +  '&moduleid=' + moduleid  + '&cacheid=' + Math.random();
				$('#newContentMenuContainer .load-inline').spin(spinnerArgs2);
				$.get(url + "?" + pars, function(data) {
					$('#newContentMenuContainer .load-inline').spin(false);
					$('#newContentMenuContainer').html(data);
				//	$("#newContentMenuContainer").dialog("option", "position",{ my: "center", at: "center", of: window });
					setToolTips('.add-content-ui');

				});

			},
			close() {
				$(this).dialog("destroy");
				$("#newContentMenuContainer").remove();
			}
		});

		return false;
	},

	showMenu(id, newcontent, obj, contentid, topid, parentid, siteid, type, moduleid) {
		var navperm = newcontent.toLowerCase();

		if(window.innerHeight) {
			var posTop = window.pageYOffset
		} else if(document.documentElement && document.documentElement.scrollTop) {
			var posTop = document.documentElement.scrollTop
		} else if(document.body) {
			var posTop = document.body.scrollTop
		}

		if(window.innerWidth) {
			var posLeft = window.pageXOffset
		} else if(document.documentElement && document.documentElement.scrollLeft) {
			var posLeft = document.documentElement.scrollLeft
		} else if(document.body) {
			var posLeft = document.body.scrollLeft
		}

		var xPos = this.findPosX(obj);
		var yPos = this.findPosY(obj);

		xPos = xPos - 10;

		document.getElementById('newZoom').style.display = 'none';
		document.getElementById('newZoomLink').style.display = 'none';
		document.getElementById('newCopy').style.display = 'none';
		document.getElementById('newCopyLink').style.display = 'none';
		document.getElementById('newCopyAll').style.display='none';
		document.getElementById('newCopyAllLink').style.display = 'none';
		document.getElementById('newPaste').style.display = 'none';
		document.getElementById('newPasteLink').style.display = 'none';
		document.getElementById('newContentLink').style.display = 'none';
		document.getElementById('newContent').style.display = 'none';

		document.getElementById('newZoomLink').onclick = function() {
			siteManager.loadSiteManagerInTab(function() {
				return siteManager.loadSiteManager(siteid, contentid, moduleid, '', '', type, 1);
			});
			return false;
		}
		document.getElementById('newZoom').style.display = '';
		document.getElementById('newZoomLink').style.display = '';

		if(navperm != 'none' && moduleid != '00000000000000000000000000000000099' && type.toLowerCase() != 'module') {

			document.getElementById('newCopyLink').href = 'javascript:siteManager.copyThis(\'' + siteid + '\', \'' + contentid + '\',\'false\')';
			document.getElementById('newCopyAllLink').href = 'javascript:siteManager.copyThis(\'' + siteid + '\', \'' + contentid + '\',\'true\')';
			document.getElementById('newCopy').style.display = '';
			document.getElementById('newCopyLink').style.display = '';
			document.getElementById('newCopyAll').style.display = '';
			document.getElementById('newCopyAllLink').style.display = '';

		}

		// get list of existing action links
		var actionLinks = obj.parentNode.parentNode.getElementsByClassName("actions")[0].getElementsByTagName("ul")[0].getElementsByTagName("li");
		// get list of hidden action links to be inserted 
		var optionList = document.getElementById('newContentOptions');
		// remove old actions links
		var oldLinks = optionList.getElementsByClassName("li-action");
		var l;
		while ((l = oldLinks[0])) {
			l.parentNode.removeChild(l);
		}
		// create new links
		var newZoom = document.getElementById('newZoom');
	  for (var i = 0; i < actionLinks.length; i++ ) {
	  		var listEl = actionLinks[i];
        if(listEl.className.indexOf('disabled') < 0){
	        var item = document.createElement("li");
	        item.innerHTML = listEl.innerHTML;
	        var link = item.getElementsByTagName("a")[0];
	        var titleStr = link.getAttribute("title");
	        // add existing classes of li and a
	        item.className = 'li-action ' + listEl.className + ' ' + link.className;
	        link.removeAttribute("title");
	        link.innerHTML = link.innerHTML + titleStr;
	        // insert edit link before other options
	        if(listEl.className.indexOf('edit') >= 0 && listEl.className.indexOf('edit-') < 0){
	        	optionList.insertBefore(item, newZoom.nextSibling);
					// insert edit layout link directly after edit
	        } else if(listEl.className.indexOf('edit-layout') >= 0){
	        	optionList.insertBefore(item, document.getElementById('newContent'));
	        } else {
	        // append other links after
        		optionList.appendChild(item);
	        }
        }
    }

		if((navperm == 'author' || navperm == 'editor') && moduleid != '00000000000000000000000000000000099') {

			document.getElementById('newContentLink').onclick = function() {
				siteManager.openNewContentMenu(contentid, siteid, topid, parentid, type, moduleid);
				return false;
			};

			//.href='./?muraAction=cArch.edit&contentid=&parentid=' + contentid + '&type=Page&topid=' + topid + '&siteid=' + siteid + '&moduleid=00000000000000000000000000000000000&ptype=' + type;

			//var test=this.copySiteID != "" && this.copyContentID != "" && this.copyModuleID==this.currentModuleID;

			if(this.copySiteID != "" && this.copyContentID != "" && this.copyModuleID==this.currentModuleID) {
				document.getElementById('newPasteLink').href = 'javascript:siteManager.pasteThis(\'' + contentid + '\')';
				document.getElementById('newPaste').style.display = '';
				document.getElementById('newPasteLink').style.display = '';
			}

			//if (type!='File' && type!='Link'){
			document.getElementById('newContentLink').style.display = '';
			document.getElementById('newContent').style.display = '';
			document.getElementById('newCopy').style.border = '';
			/*} else {
				document.getElementById('newCopy').style.border='0';
				document.getElementById('newPaste').style.display='none';
				document.getElementById('newZoom').style.display='none';
			}*/
		}

		document.getElementById(id).style.top = yPos + "px";
		document.getElementById(id).style.left = xPos + "px";

		$("#" + id).removeClass("hide");

		if(this.lastid != "" && this.lastid != id) {
			this.hideMenu(this.lastid);
		}

		// this.navTimer = setTimeout('siteManager.hideMenu(siteManager.lastid);', 100000);
		this.lastid = id;
	},

	findPosX(obj) {
		var curleft = 0;
		if(obj.offsetParent) {
			while(obj.offsetParent) {
				curleft += obj.offsetLeft
				obj = obj.offsetParent;
			}
		} else if(obj.x) curleft += obj.x;
		return curleft;
	},

	findPosY(obj) {
		var curtop = 0;
		if(obj.offsetParent) {
			while(obj.offsetParent) {
				curtop += obj.offsetTop
				obj = obj.offsetParent;
			}
		} else if(obj.y) curtop += obj.y;
		return curtop;
	},

	keepMenu(id) {
//		this.navTimer = setTimeout('hideMenu(lastid);', 100000);
		$('#' + id).removeClass('hide');
		//document.getElementById(id).style.display="block";
	},

	hideMenu(id) {
	//	if(this.navTimer != null) clearTimeout(this.navTimer);
		$('#' + id).addClass('hide');
		//document.getElementById(id).style.display="none";
	}
	,

	deleteDisplayObject(regionid) {
		var selectedObjects = document.getElementById("selectedObjects" + regionid);
		var deleteIndex = selectedObjects.selectedIndex;
		var len = (selectedObjects.options.length > 1) ? selectedObjects.options.length - 1 : 0;
		if(deleteIndex < 0) return;

		selectedObjects.options[deleteIndex] = null;
		this.updateDisplayObjectList(regionid);

		if(selectedObjects.options.length) {
			selectedObjects.options[selectedObjects.options.length - 1].selected = true;
		}

	},

	updateDisplayObjectList(regionid) {
		var selectedObjects = document.getElementById("selectedObjects" + regionid);
		var objectList = document.getElementById("objectList" + regionid)
		objectList.value = "";

		for(var i = 0; i < selectedObjects.options.length; i++) {
			if(objectList.value != "") {
				objectList.value += "^" + selectedObjects.options[i].value;
			} else {
				objectList.value = selectedObjects.options[i].value;
			}
		}

	},

	moveDisplayObjectUp(regionid) {
		var selectedObjects = document.getElementById("selectedObjects" + regionid);
		var moverIndex = selectedObjects.selectedIndex;
		if(moverIndex < 1) return;

		var moveroption = document.createElement("option");
		var movedoption = document.createElement("option");

		moveroption.text = selectedObjects.options[moverIndex].text;
		moveroption.value = selectedObjects.value;
		moveroption.selected = "selected"

		movedoption.text = selectedObjects.options[moverIndex - 1].text;
		movedoption.value = selectedObjects.options[moverIndex - 1].value;

		selectedObjects[moverIndex - 1] = moveroption;
		selectedObjects[moverIndex] = movedoption;

		this.updateDisplayObjectList(regionid);
	},

	moveDisplayObjectDown(regionid) {
		var selectedObjects = document.getElementById("selectedObjects" + regionid);
		var moverIndex = selectedObjects.selectedIndex;
		if(moverIndex == selectedObjects.length - 1) return;

		var moveroption = document.createElement("option");
		var movedoption = document.createElement("option");

		moveroption.text = selectedObjects.options[moverIndex].text;
		moveroption.value = selectedObjects.options[moverIndex].value;
		moveroption.selected = "selected"

		movedoption.text = selectedObjects.options[moverIndex + 1].text;
		movedoption.value = selectedObjects.options[moverIndex + 1].value;


		selectedObjects.options[moverIndex + 1] = moveroption;
		selectedObjects.options[moverIndex] = movedoption;

		this.updateDisplayObjectList(regionid);

	},

	setTargetParams(frm) {
		var hp = (!isNaN(frm.height.value) && frm.height.value > 0) ? ",height=" + frm.height.value : "";
		var wp = (!isNaN(frm.width.value) && frm.width.value > 0) ? ",width=" + frm.width.value : "";
		var tp = (!isNaN(frm.top.value) && frm.top.value > 0) ? ",top=" + frm.top.value : "";
		var lp = (!isNaN(frm.left.value) && frm.left.value > 0) ? ",left=" + frm.left.value : "";
		var tb = (frm.toolbar.value != "") ? ",toolbar=" + frm.toolbar.value : "";
		var loc = (frm.location.value != "") ? ",location=" + frm.location.value : "";
		var dir = (frm.directories.value != "") ? ",directories=" + frm.directories.value : "";
		var st = (frm.status.value != "") ? ",status=" + frm.status.value : "";
		var mb = (frm.menubar.value != "") ? ",menubar=" + frm.menubar.value : "";
		var rs = (frm.resizable.value != "") ? ",resizable=" + frm.resizable.value : "";
		var hist = (frm.copyhistory.value != "") ? ",copyhistory=" + frm.copyhistory.value : "";
		var sb = (frm.scrollbars.value != "") ? ",scrollbars=" + frm.scrollbars.value : "";

		document.forms["contentForm"].targetParams.value = tb + loc + dir + st + mb + rs + hist + sb + wp + hp + tp + lp;
	},

	loadSiteParents(siteid, contentid, parentid, keywords, isNew) {
		$('#mover1').hide();

		var url = './';
		var pars = 'muraAction=cArch.siteParents&compactDisplay=true&siteid=' + siteid + '&contentid=' + contentid + '&parentid=' + parentid + '&keywords=' + keywords + '&isNew=' + isNew + '&cacheid=' + Math.random();
		var d = $('#mover2');

		$.get(url + "?" + pars, function(data) {
			//$('#mover2 .load-inline').spin(false);
			$('#mover2').html(data);
			$('#mover2').show();
		});
	},

	loadAssocImages(siteid, fileid, contentid, keywords, isNew, categoryid) {
		categoryid=categoryid||'';
		var url = './';
		var pars = 'muraAction=cArch.assocImages&compactDisplay=true&siteid=' + siteid + '&fileid=' + fileid + '&contentid=' + contentid + '&keywords=' + keywords + '&isNew=' + isNew + '&categoryid=' + categoryid + '&cacheid=' + Math.random();
		var d = $('#selectAssocImage');
		$.get(url + "?" + pars, function(data) {
			$('#selectAssocImage').html(data);
			$('#selectAssocImageResults').slideDown();
		});
	},

	loadObjectClass(siteid, classid, subclassid, contentid, parentid, contenthistid, instanceid) {
		var url = './';
		var pars = 'muraAction=cArch.loadclass&compactDisplay=true&siteid=' + siteid + '&classid=' + classid + '&subclassid=' + subclassid + '&contentid=' + contentid + '&parentid=' + parentid + '&instanceid=' + instanceid + '&cacheid=' + Math.random();

		if(this.configuratorMode=='backEnd'){
			var d=$('#classList');
			var id= '#classList';
		} else {
			var d = $('#configurator');
			var id = '#configurator';
		}


		d.html('<div class="load-inline"></div>');
		$( id + ' .load-inline').spin(spinnerArgs2);
		$.get(url + "?" + pars, function(data) {
			$( id + ' .load-inline').spin(false);
			$(id).html(data);
			siteManager.availableObjectTemplate = "";
			siteManager.availalbeObjectParams = {};
			siteManager.availableObject = {};
			siteManager.availableObjectValidate = function() {
				return true
			};
		});
		return false;
	},

	getDisplayObjectClass(regionid) {
		var str = $('#selectedObjects' + regionid).val().toString();
		var a = str.split("~");
		return a[0];
	},

	getDisplayObjectID(regionid) {
		var str = $('#selectedObjects' + regionid).val().toString();
		var a = str.split("~");
		return a[2];
	},

	loadNotify(siteid, contentid, parentid) {
		var url = './';
		var pars = 'muraAction=cArch.loadNotify&compactDisplay=true&siteid=' + siteid + '&contentid=' + contentid + '&parentid=' + parentid + '&cacheid=' + Math.random();
		var d = $('#selectNotify');
		if(d.html() == '') {
			d.show();
			d.html('<div class="load-inline"></div>');
			$('#selectNotify .load-inline').spin(spinnerArgs2);
			$.get(url + "?" + pars, function(data) {
				$('#selectNotify .load-inline').spin(false);
				$('#selectNotify').html(data);
			});
		} else {
			d.toggle();
		}

		return false;
	},

	loadExpiresNotify(siteid, contenthistid, parentid) {
		var url = './';
		var pars = 'muraAction=cArch.loadExpireNotify&compactDisplay=true&siteid=' + siteid + '&contenthistid=' + contenthistid + '&parentid=' + parentid + '&cacheid=' + Math.random();
		var d = $('#selectExpiresNotify');
		if(d.html() == '') {
			d.show();
			d.html('<div class="load-inline"></div>');
			$('#selectExpiresNotify .load-inline').spin(spinnerArgs2);
			$.get(url + "?" + pars, function(data) {
				$('#selectExpiresNotify .load-inline').spin(false);
				$('#selectExpiresNotify').html(data);
			});
		} else {
			d.toggle();
		}

		return false;
	},


	bindDelete: function () {
		$('a.delete').click(function(){
			var contentid=$(this).parent().attr('data-contentid');
			$(this).parent().remove();
			siteManager.setupRCResultIcon($('#selectRelatedContent button[value="'+ contentid + '"]'));
			siteManager.updateBuckets();
			siteManager.updateRCForm();
			$('#mura-rc-quickedit').hide();
		});
	},

	bindMouse: function () {
		$(".rcSortable li.item:not(.empty), .rcDraggable li.item").mouseup(function(event){
			// left mouse button only
			if (event.which == 1) {
				siteManager.enableBuckets();

				$(window).unbind('mousemove');
			}
		}).mousedown(function(event){
			// left mouse button only
			var enableHandler = true;
			if (event.which == 1) {
				siteManager.disableBuckets($(this));

				if (typeof frontEndProxy != 'undefined') {
					$(window).bind('mousemove', function (e) {
						if (enableHandler) {
							frontEndProxy.post({cmd:'autoScroll', y: e.pageY});
							enableHandler = false;
						}
					});
				}
			}
			timer = window.setInterval(function(){
    			enableHandler = true;
			}, 100);
		});
	},

	updateBuckets: function () {
		$(".rcSortable").each(function(index){
			if ($(this).find('li.item').length == 1) {
				$(this).find('li.empty').removeClass('noShow');
			} else {
				$(this).find('li.empty').addClass('noShow');
			}
		});
	},

	enableBuckets: function () {
		$(".rcSortable").each(function(index){
			$(this).sortable("enable");
			$(this).parent().removeClass('disabled');
		});
	},

	disableBuckets: function (el) {
		$(".rcSortable").each(function(index){
			// ignore parent container
			if (!($(this).attr('id') == el.parent().attr('id'))) {
				// disable if not in allowed list

				var custom=(el.attr('data-content-type').split('/')[0].toLowerCase()=='custom');
				if (custom && !$(this).attr('data-accept').length || $(this).attr('data-accept').length && $(this).attr('data-accept').indexOf(el.attr('data-content-type')) == -1) {
					$(this).sortable("disable");
					$(this).parent().addClass('disabled');
				}
				/*
				if ($(this).attr('data-accept').length > 0 && $(this).attr('data-accept').indexOf(el.attr('data-content-type')) == -1) {
					$(this).sortable("disable");
					$(this).parent().addClass('disabled');
				}
				*/
				// disable if already in list
				if ($(this).find('[data-contentid="' + el.attr('data-contentid') + '"]').length > 0) {
					$(this).sortable("disable");
					$(this).parent().addClass('disabled');
				}
			}
		});
	},

	loadRelatedContent(contentid, siteid, isNew, values, advSearch,external,relatedcontentsetid) {
		if(typeof external == 'undefined'){
			external =true;
		}

		var entitytype=$('input[name="entitytype"]:checked');
		if(!entitytype.length){
			entitytype=$('input[name="entitytype"]');
		}
		if(entitytype.length){
			entitytype=entitytype.val();
		} else {
			entitytype='content';
		}

		var url = './';
		var pars = 'muraAction=cArch.loadRelatedContent&compactDisplay=true&contentid=' + contentid + '&siteid=' + siteid + '&external=' + external + '&isNew=' + isNew + '&relatedcontentsetid=' + relatedcontentsetid + '&' + values +  '&entitytype=' + entitytype + '&cacheid=' + Math.random();

		var d = $('#selectRelatedContent');
		d.html('<div class="load-inline"></div>');
		$('#selectRelatedContent .load-inline').spin(spinnerArgs2);
		$.get(url + "?" + pars, function(data) {
			if(data.indexOf('mura-primary-login-token') != -1) {
				location.href = './';
			}
			$('#selectRelatedContent .load-inline').spin(false);
			$('#selectRelatedContent').html(data);
			$('.draggableContainmentInternal').on('scroll',function(){$('#mura-rc-quickedit').hide()});

			$(".rcDraggable li.item").draggable({
				connectToSortable: '.rcSortable',
				helper: 'clone',
				revert: 'invalid',
				appendTo: 'body',
				start(event, ui) {
					// bind mouse events to clone
					$('#mura-rc-quickedit').hide();
					siteManager.bindMouse();
				},
				zIndex: 100
			}).disableSelection();

			setDatePickers(".mura-relatedContent-datepicker", dtLocale, dtCh);

			$('#aAdvancedSearch').click(function(e){
				e.preventDefault();
				$('#rcAdvancedSearch').slideToggle('fast');
			});

			if (isNew == 0 && advSearch == true) {
				$('#rcAdvancedSearch').show();
				$('#aAdvancedSearch').addClass('active');
			}

			siteManager.bindMouse();
			setCheckboxTrees();
			siteManager.setupRCQuikEdit();
			setToolTips(".tab-content");

			$('#rcAdvancedSearch').find('ul.categories:not(.checkboxTrees)').css("margin-left", "10px");

			$('.mura-rc-quickoption').each(function(){
				siteManager.setupRCResultIcon($(this));
			});

			$('#rcBtnSearch').click(function(e){
				e.preventDefault();
				var advSearching = $('#rcAdvancedSearch').is(':visible');
				var valueSelector = '#internalContent input';
				// if doing an advanced search, then serialze all elements
				if (advSearching) {
					valueSelector = '#selectRelatedContent input:not([name="entitytype"]), #selectRelatedContent select';
				}
				$('#mura-rc-quickedit').hide();
				siteManager.loadRelatedContent(contentid,siteid, 0, $(valueSelector).serialize(), advSearching,external,relatedcontentsetid);
			});
		});
	},

	loadRelatedContentSets(contentid,contenthistid,type,subtype,siteid,relatedcontentsetid,relateditems,external){
		var url = './';
		relatedcontentsetid=relatedcontentsetid||'';
		relateditems=relateditems||'[]';

		const params          = Mura.getQueryStringParams();
		let templateid        = '';

		if(typeof params.templateid !== 'undefined') {
			templateid = params.templateid;
		}

		if(typeof external == 'undefined'){
			external =true;
		}

		var pars = 'muraAction=cArch.loadSelectedRelatedContent&compactDisplay=true&contenthistid=' + contenthistid + '&type=' + type + '&subtype=' + subtype + '&siteid=' + siteid + '&relatedcontentsetid=' + relatedcontentsetid + '&relateditems=' + encodeURIComponent(relateditems) + '&external=' + external + '&templateid=' + templateid + '&cacheid=' + Math.random();

		var d = $('#selectedRelatedContent');
		d.html('<div class="load-inline"></div>');
		$('#selectedRelatedContent .load-inline').spin(spinnerArgs2);
		$.get(url + "?" + pars, function(data) {
			if(data.indexOf('mura-primary-login-token') != -1) {
				location.href = './';
			}
			$('#selectedRelatedContent .load-inline').spin(false);
			d.html(data);
			siteManager.setupRCSortable(contentid,external,relatedcontentsetid);
		});

	},

	setupRCResultIcon(el){
		if($('#selectedRelatedContent').find('li[data-contentid="'+ el.val() + '"]').length){
			el.find('i').attr('class','mi-check');
		} else {
			el.find('i').attr('class','mi-plus-circle');
		}
	},

	setupRCQuikEdit(){

		$('.mura-rc-quickoption').each(function(){

			$(this).unbind('on').on('click',function(){
				var $contentid=$(this).val();
				var $currentItem=$('#selectRelatedContent').find('li[data-contentid="' + $contentid + '"]');

				$('#mura-rc-quickedit').show();
				$('#mura-rc-quickedit').offset({top:$(this).offset().top});

				$('.mura-rc-quickassign').each(function(){
					var $this=this;
					var $sortable= $('#rcSortable-' + $($this).val());
					var isInSet=function(){return $sortable.find('li[data-contentid="' + $contentid + '"]').length;}

					$('#mura-rc-quickedit').show();

					$($this).attr('disabled',false);

					// ignore parent container
					if (!($sortable.attr('id') == $currentItem.parent().attr('id'))) {
						var custom=($currentItem.attr('data-content-type').split('/')[0].toLowerCase()=='custom');
						if (custom && !$sortable.attr('data-accept').length || $sortable.attr('data-accept').length && $sortable.attr('data-accept').indexOf($currentItem.attr('data-content-type')) == -1) {
							$($this).attr('disabled',true);
						}
					}

					$(this).unbind('change');
					$(this).prop('checked',isInSet());
					$(this).on("change",function(){
						if($(this).prop('checked')){
							$currentItem.clone().appendTo($('#rcSortable-' + $($this).val()));
							$('#rcSortable-' + $($this).val()).find('.mura-rc-quickoption').remove();
							$('#rcSortable-' + $($this).val()).find('li[data-contentid="' + $contentid + '"]').prepend('<a class="delete"></a>');
						} else {
							$('#rcSortable-' + $($this).val()).find('li[data-contentid="' + $contentid + '"]').remove();
						}

						//alert($('#selectRelatedContent button[value="'+ $contentid + '"]').length)
						//alert($('#selectedRelatedContent').find('li[data-contentid="'+ $contentid  + '"]').length)
						siteManager.setupRCResultIcon($('#selectRelatedContent button[value="'+ $contentid + '"]'));
						siteManager.updateBuckets();
						siteManager.bindDelete();
						siteManager.bindMouse();
						siteManager.updateRCForm();
					});
				});
			});

		});
	},

	setupRCSortable(contentid,external,relatedcontentsetid) {
		if(typeof external == 'undefined'){
			external =true;
		}

		$(".rcSortable").sortable({
			connectWith: ".rcSortable",
			revert: 'invalid',
			axis:'y',
			update( event, ui ) {
				siteManager.updateBuckets();
				if (ui.item.find('a.delete').length == 0) {
					ui.item.prepend('<a class="delete"></a>');
				}
				ui.item.attr('style','');
				siteManager.bindDelete();
				siteManager.bindMouse();
				siteManager.setDirtyRelatedContent();
				siteManager.updateRCForm();
				siteManager.setupRCResultIcon($('#selectRelatedContent button[value="'+ ui.item.attr('data-contentid') + '"]'));
			},
			start(){
				console.log($(this)[0].offsetHeight+" >= "+$(this)[0].scrollHeight)
				if ($(this)[0].offsetHeight >= $(this)[0].scrollHeight ){
					$(this).css('overflow','visible');
				}
				siteManager.bindMouse();
			},
			stop(){
				$(this).css('overflow','auto');
				siteManager.enableBuckets()
			},
			cancel: "li.empty"
		}).disableSelection();

		siteManager.loadRelatedContent(contentid,siteid, 1, '', false,external,relatedcontentsetid);
		siteManager.bindDelete();
		siteManager.bindMouse();
		siteManager.updateRCForm();
		siteManager.setupRCQuikEdit();
	},

	updateRCForm() {
		var aBuckets = new Array();

		$(".rcSortable").each(function(){
			var aItems = new Array();
			var bucket = new Object;
			$(this).find('.mura-rc-quickoption').remove();

			$(this).find('li.item:not(.empty)').each(function(){
				if(typeof($(this).attr('data-url')) == 'undefined'){
					if($(this).attr('data-contentid')){
						aItems.push($(this).attr('data-contentid'));
					}
				} else if ($(this).attr('data-url')){
					aItems.push(
						{
							title:$(this).attr('data-title'),
							url:$(this).attr('data-url'),
							contentid:$(this).attr('data-contentid')
						}
					);
				}
			});
			bucket.relatedcontentsetid = $(this).attr('data-relatedcontentsetid')
			bucket.items = aItems;
			aBuckets.push(bucket);
		});
		$("#relatedContentSetData").val(JSON.stringify(aBuckets));
	},


	setDirtyRelatedContent: function () {
		this.dirtyRelatedContent = true;
	},

	form_is_modified(oForm) {
		var i;

		if(typeof CKEDITOR !='undefined'){
			for(i in CKEDITOR.instances){
				CKEDITOR.instances[i].updateElement();
			}
		}

		Mura("textarea.mura-markdown,textarea.markdownEditor").forEach(function(){
			var input=Mura(this);
			if(markdownInstances && typeof markdownInstances[input.attr('name')] != 'undefined'){
				if(input.length){
					if (!input.hasClass("markdown-lazy-init")){
						input.val(markdownInstances[input.attr('name')].getMarkdown())
					}
				}
			}
		})

		for(i = 0; i < oForm.elements.length; i++) {
			var element = oForm.elements[i];
			var type = element.type;
			if(type == "checkbox" || type == "radio") {
				if(element.checked != element.defaultChecked) {
					//console.log(element.outerHTML)
					//console.log(type + ":" + element.name)
					return true;
				}
			} else if(type == "hidden" || type == "password" || type == "text") {
				if(element.value != element.defaultValue) {
					if(element.name != 'sdContent' 
						&& !(
							element.classList.contains('datepicker')
							|| element.classList.contains('mura-repeat-option')
						)
					) {
						//console.log(type + ":" + element.name)
						//console.log(element.value)
						//console.log(element.defaultValue)
						return true;
					}
				}
			} else if (type == "textarea") {
			
				if(element.value != element.defaultValue) {
					if(element.getAttribute('id') 
						&& typeof CKEDITOR.instances[element.getAttribute('id')] != 'undefined'
					){
						if(CKEDITOR.instances[element.getAttribute('id')].checkDirty()){
							return true;
						}
					} else if ( typeof markdownInstances[element.getAttribute('name')]  != 'undefined' ) {
						element.value=markdownInstances[element.getAttribute('name')].getMarkdown();
						//Markdown seems to add difference that don't seem to show in string comparisons?
						if(element.value.replace(/[^0-9a-z]/gi, '') != element.defaultValue.replace(/[^0-9a-z]/gi, '')){
							return true;
						}
					} else {
						return true;
					}
				}
			}
			/*
	        else if (type == "select-one" || type == "select-multiple")
	        {
	            for (var j = 0; j < element.options.length; j++)
	            {
	                if (element.options[j].selected !=
	                    element.options[j].defaultSelected)
	                {
	                    return true;
	                }
	            }
	        }
	        */
		}

		if(typeof(FCKeditorAPI) != 'undefined') {
			if(FCKeditorAPI.GetInstance('body') && FCKeditorAPI.GetInstance('body').IsDirty()) return true;
			if(FCKeditorAPI.GetInstance('summary') && FCKeditorAPI.GetInstance('summary').IsDirty()) return true;
			if(this.dirtyRelatedContent) return true;
		} else if(typeof CKEDITOR != 'undefined' && typeof(CKEDITOR.instances["body"]) != 'undefined') {
			var instance = CKEDITOR.instances["body"];
			if(instance.checkDirty()) {
				console.log('body')
				return true;
			}

		}

		return false;
	},

	copyThis(siteID, contentID, _copyAll) {
		var url = './';
		var pars = 'muraAction=cArch.saveCopyInfo&siteid=' + siteID + '&contentid=' + contentID  + '&moduleid=' +  siteManager.currentModuleID + '&copyAll=' + _copyAll + '&cacheid=' + Math.random();

		$.get(url + "?" + pars);

		this.copyContentID = contentID;
		this.copySiteID = siteID;
		this.copyModuleID = siteManager.currentModuleID;
		this.copyAll = _copyAll;

		this.hideMenu('newContentMenu');
	},

	pasteThis(parentID) {
		if(this.copyModuleID != this.currentModuleID){
			alert("Pasting between modules is not supported.");
		} else {
			var url = './';
			var pars = 'muraAction=cArch.copy&compactDisplay=true&siteid=' + this.copySiteID + '&copyAll=' + this.copyAll + '&contentid=' + this.copyContentID + '&parentid=' + parentID + '&cacheid=' + Math.random();
			var d = $('#newPasteLink');
			d.css('background', 'url(assets/images/ajax-loader.gif) no-repeat 1px 5px;');
			this.reloadURL = $('#newZoomLink').attr("href");

			actionModal(function(){
				$.get(url + "?" + pars, function(data) {
					$('#action-modal').remove();
					siteManager.loadSiteManagerInTab(
					function() {
						siteManager.loadSiteManager(siteManager.copySiteID, parentID, siteManager.currentModuleID, '', '', '', 1);
					});
				});
			});
		}
	},

	reloadPage() {
		if(reloadURL == '') {
			window.location.reload();
		} else {
			location.href = this.reloadURL;
		}
	},

	loadExtendedAttributes(contentid,contentHistID, type, subType, _siteID, _context, _themeAssetPath) {
		var url = './';
		var pars = 'muraAction=cArch.loadExtendedAttributes&contentHistID=' + contentHistID + '&type=' + type + '&subType=' + subType + '&siteID=' + _siteID + '&tablist=' + siteManager.tablist + '&cacheid=' + Math.random();
	
		siteID = _siteID;
		context = _context;
		themeAssetPath = _themeAssetPath;

		//location.href=url + "?" + pars;
		$('.extendset-container').each(
		function() {
			if($(this).html() != '') {
				$(this).html('<div class="load-inline"></div>');
				$(this).find('.load-inline').spin(spinnerArgs2);
			}
		});

		siteManager.loadRelatedContentSets(contentid,contentHistID,type,subType,_siteID);

		$.ajax({
			url:url + "?" + pars,
			dataType: 'text',
			success(data) {
				siteManager.setExtendedAttributes(data);
			}
		});

		return false;
	},

	setExtendedAttributes(data) {
		
		//console.log(data);
		var r = eval("(" + data + ")");

		$('#tabExtendedAttributes').addClass('hide');
		$('#tabExtendedAttributesLI').addClass('hide');
 
		$.each(r, function(name, value) {

			// debug tab assignment			
			// if (value.length){
			// 	console.log(name + ": " + value);
			// }
			$('#extendset-container-' + name + ' .load-inline').spin(false);
			$('#extendset-container-' + name).html(value);

			if (name == 'primary' && value.length > 0){
				$(".block-constrain#mura-content-body-block > .tab-content").addClass("shrink");
				$("#mura-content-body-render .mura-content-body-inner").addClass("shrink");
			}

		});

		defaultTabs =	['default','extendedattributes','advanced','layoutobjects','listdisplayoptions','mobile','seo'];
		
		$('#tabExtendedAttributes').addClass('hide');
		
		defaultTabs.forEach((item, index) => {
			if(r[item]){
				$('#tabExtendedAttributes').removeClass('hide');
			}
		})	

		if(!r.hassummary) {
			if(typeof hideSummaryEditor != 'undefined') {
				hideSummaryEditor();
			}
		} else {
			if(typeof showSummaryEditor != 'undefined') {
				showSummaryEditor();
			}
		}

		if(!r.hasbody) {
			if(typeof hideBodyEditor != 'undefined') {
				hideBodyEditor();
			}
		} else {
			if(typeof showBodyEditor != 'undefined') {
				showBodyEditor();
			}
		}

		if(!r.hasassocfile) {
			$('#assocFileContainer').hide();
			$("input[name='newfile']").val('');
			$('#tabAssoc').hide();
		} else {
			$('#assocFileContainer').show();
			$('#tabAssoc').show();
		}

		this.checkExtendSetTargeting();
		setHTMLEditors("textarea.mura-html, textarea.htmlEditor");
		setCodeEditors("textarea.mura-code, textarea.codeEditor");
		setMarkdownEditors("textarea.mura-markdown, textarea.markdownEditor");
		setDatePickers("#mura-content-body-block .datepicker,#mura-content-body-block .mura-datepicker", dtLocale);
		setColorPickers("#mura-content-body-block .mura-colorpicker");
		setFinders("#mura-content-body-block .mura-ckfinder, #mura-content-body-block .mura-finder");
		setToolTips("#mura-content-body-block");
		setFileSelectors();

		var niceSelects=$('.extendset-container select:not([multiple=multiple])');
		
		if(niceSelects.niceSelect){
			niceSelects.each(function(){
				var self=$(this);
				if(typeof self.data('niceselect') == 'undefined' || self.data('niceselect')){
					if(self.attr('name')){
						self.addClass('ns-' + self.attr('name'));
					}
					self.niceSelect();
				}
			})

		}

		$(window).trigger('resize');
	},

	checkExtendSetTargeting() {
		var extendSets = $('.extendset');
		var found = false;
		var started = false;
		var empty = true;

		if(extendSets.length) {
			for(var s = 0; s < extendSets.length; s++) {
				var extendSet = extendSets[s];

				if(extendSet.getAttribute("categoryid") != undefined && extendSet.getAttribute("categoryid") != "") {
					if(!started) {
						var categories = $('categoryContainer').getElementsByTagName('select');
						started = true;
					}

					for(var c = 0; c < categories.length; c++) {
						var cat = categories[c];
						var catID = categories[c].getAttribute("categoryid");
						var assignedID = extendSet.getAttribute("categoryid");
						if(!found && catID != null && assignedID.indexOf(catID) > -1) {
							found = true;
							membership = cat.value;
						}
					}

					if(found) {
						if(membership != "") {
							this.setFormElementsDisplay(extendSet, '');
							extendSet.style.display = '';
							empty = false;
						} else {
							this.setFormElementsDisplay(extendSet, 'none');
							extendSet.style.display = 'none';

						}
					} else {
						this.setFormElementsDisplay(extendSet, 'none');
						extendSet.style.display = 'none';

					}
				} else {
					this.setFormElementsDisplay(extendSet, '');
					extendSet.style.display = '';
					empty = false;


				}


				found = false;
			}

			if(empty) {
				$('#extendMessage').show();
				$('#extendDL').hide();
			} else {
				$('#extendMessage').hide();
				$('#extendDL').show();
			}

		}

	},

	resetExtendedAttributes(contentid,contentHistID, str, _siteID, _context, _themeAssetPath) {
		var dataArray = str.split("^");
		this.loadExtendedAttributes(contentid,contentHistID, dataArray[0], dataArray[1], _siteID, _context, _themeAssetPath);
		//alert(dataArray[1]);
		document.contentForm.type.value = dataArray[0];
		document.contentForm.subtype.value = dataArray[1];
	},

	setFormElementsDisplay(container, display) {
		var inputs = container.getElementsByTagName('input');
		//alert(inputs.length);
		if(inputs.length) {
			for(var i = 0; i < inputs.length; i++) {
				inputs[i].style.display = display;
				//alert(inputs[i].style.display);
			}
		}

		inputs = container.getElementsByTagName('textarea');

		if(inputs.length) {
			for(var i = 0; i < inputs.length; i++) {
				inputs[i].style.display = display;
			}
		}

		inputs = container.getElementsByTagName('select');

		if(inputs.length) {
			for(var i = 0; i < inputs.length; i++) {
				inputs[i].style.display = display;
			}
		}

	},

	loadCategoryFeatureStartStop(id, display, siteID) {
		var cat = $("#" + id);
		if(cat.html().length > 10) {
			cat.toggle();
		} else if(display == true) {
			var url = './';
			var idParam = id;
			var pars = 'muraAction=cArch.loadCategoryFeatureStartStop&id=' + idParam.replace(/editDates/, "") + '&siteID=' + siteID + '&cacheid=' + Math.random();
			cat.show();
			$.get(url + "?" + pars, function(data) {
				$("#" + id).html(data);
				setDatePickers("#" + id + " .datepicker,#" + id + " .mura-datepicker", dtLocale);
				setToolTips("#" + id);
			});

		}
	},

	activeQuickEdit: false,

	loadSiteManager(siteid, topid, moduleid, sortby, sortdirection, ptype, startrow, sortedContent) {
		var url = './';
		var pars = 'muraAction=cArch.loadSiteManager&siteid=' + siteid + '&topid=' + topid + '&moduleid=' + moduleid + '&sortby=' + sortby + '&sortdirection=' + sortdirection + '&ptype=' + ptype + '&startrow=' + startrow + '&cacheid=' + Math.random();
		$('#newContentMenu').addClass('hide');
		//$('#viewTabs a[href="#tabArchitectural"]').tab('show');
		//location.href=url + "?" + pars;
		siteManager.currentModuleID=moduleid;

		var d = $('#gridContainer');
		if(!this.activeQuickEdit) {
			d.html('<div class="load-inline"></div>').show();
			$('#gridContainer .load-inline').spin(spinnerArgs2);

		}

		$('.site-manager-mod').removeClass('active');
		$('.site-manager-mod[data-moduleid="' + moduleid +'"]').addClass('active');

		if(moduleid=='00000000000000000000000000000000000'){
			$('#gridContainer').addClass('site-tree');
		} else {
			$('#gridContainer').removeClass('site-tree');
		}

		// return false;
		$.ajax({
			url: url + "?" + pars,
			dataType: 'text',
			success(data) {
				try {
					var r = eval("(" + data + ")");
					if(!siteManager.activeQuickEdit) {
						d.hide()
						$('#gridContainer .load-inline').spin(false);
					}
					d.html(r.html);
					$('#newContentMenu').addClass('hide');
					stripe('stripe');
					siteManager.updateSortOrder(sortedContent);
					siteManager.initQuickEdits();
					initDraftPrompt();
					setToolTips("#gridContainer");
					if(r.perm.toLowerCase() == "editor" && r.sortby.toLowerCase() == 'orderno') {


						$("#sortableKids").sortable({
							helper:'clone',
							stop(event, ui) {
								stripe('stripe'); 
								$(ui.item).removeClass('ui-draggable-dragging');
							},
							// show button only if changed
							change(event, ui) {
								siteManager.setAsSorted();
							},
							start(event, ui) {
								$(ui.item).addClass('ui-draggable-dragging');

							},
							// reduce sensitivity
							axis: "y",
							distance: 5
						});
						

						$("#sortableKids").disableSelection();
					}

				} catch(err) {
					console.log(err)
					if(data.indexOf('mura-primary-login-token') != -1) {
						location.href = './';
					}
					d.html(data);
				}

				if(!siteManager.activeQuickEdit) {
					d.hide().animate({
						'opacity': 'show'
					}, 1000);
				}
				siteManager.activeQuickEdit = false;
			},
			error(jqXHR, textStatus, errorThrown) {
		        console.log("error " + textStatus);

		    }
		});


		return false;
	},

	sectionLoading: false,

	loadSiteFlatByFilter() {
		var typeString=$("#contentTypeFilter").val();

		if(typeString != ''){
			var typeArray=typeString.split('^');
			flatViewArgs.type = typeArray[0];
			flatViewArgs.subtype = typeArray[1];
		} else {
			flatViewArgs.type = '';
			flatViewArgs.subtype = '';
		}
		var categoryid = [];


		$(".categories :checked").each(

		function() {
			categoryid.push($(this).val());
		});

		flatViewArgs.categoryid = categoryid.toString();

		var tags = [];

		$("input[name='tags']").each(
			function() {
				tags.push($(this).val());
			}
		);

		flatViewArgs.tags=tags.toString();

		if(customtaggroups.length){
			for(var g=0;g < customtaggroups.length; g++){
				tags = [];

				$("input[name='" + customtaggroups[g] + "tags']").each(
					function() {
						if($(this).val().length){
							tags.push($(this).val());
						}
					}
				);

				flatViewArgs[customtaggroups[g] + "tags"]=tags.toString();
			}
		}

		flatViewArgs.keywords = $("#contentKeywords").val();
		flatViewArgs.page = 1;
		flatViewArgs.filtered = true;
		this.loadSiteFlat(flatViewArgs);

	},

	loadSiteManagerInTab(loader) {
		archViewLoaded = true;
		window.scrollTo(0, 0);
		$('#gridContainer').html('<div class="load-inline"></div>');
		$('#viewTabs a[href="#tabArchitectural"]').tab('show');
		loader();
		//document.getElementById("newContentMenu").style.visibility="hidden";
		return false;
	},

	loadSiteFlat(args) {
		var url = './';
		var pars = 'muraAction=cArch.loadSiteFlat&cacheid=' + Math.random();

		//location.href=url + "?" + pars;
		var d = $('#flatViewContainer');

		d.html('<div class="load-inline"></div>');

		$('#flatViewContainer .load-inline').spin(spinnerArgs2);

		$('#newContentMenu').addClass('hide');

		$.post(url + "?" + pars, args, function(data) {

			if(data.indexOf('mura-primary-login-token') != -1) {
				location.href = './';
			}
			$('#flatViewContainer .load-inline').spin(false);

			d.html(data);
			stripe('stripe');
			setCheckboxTrees();
			setToolTips(".mura-table-grid");

			$.ajax({
				url:'?muraAction=carch.loadtagarray&siteid=' + siteid,
				dataType: 'text',
				success(data){
					var tagArray=[];
					if(data){
						var tagArray=eval('(' + data + ')');
					}
					$('#tags').tagSelector(tagArray, 'tags');
				}
			});


			if(customtaggroups.length){
				for(var g=0;g < customtaggroups.length; g++){

					if(window[customtaggroups[g]]){
						$('#' + customtaggroups[g] + 'tags').tagSelector(window[customtaggroups[g]], customtaggroups[g] + 'tags');
					}else{
						$.ajax({url:'?muraAction=carch.loadtagarray&siteid=' + siteid + '&taggroup=' + customtaggroups[g],
							context:{taggroup:customtaggroups[g]},
							dataType: 'text',
							success(data){
								window[this.taggroup]=eval('(' + data + ')');
								$('#' + this.taggroup + 'tags').tagSelector(window[this.taggroup], this.taggroup + 'tags');
							}
						});
					}

				}
			}

			$(".navSort a").click(

			function(event) {
				event.preventDefault();

				$(".sortNav .active").toggleClass('active');
				$(this).toggleClass('active');

				var sortby = $(this).attr("data-sortby");

				if(sortby == flatViewArgs.sortby) {
					if(flatViewArgs.sortdirection == "asc") {
						flatViewArgs.sortdirection = "desc";
					} else {
						flatViewArgs.sortdirection = "asc";
					}
				} else {
					flatViewArgs.sortby = sortby;

					switch(flatViewArgs.sortby) {
					case "menutitle":
						flatViewArgs.sortdirection = "asc";
						break;
					case "created":
					case "lastupdate":
					case "releasedate":
						flatViewArgs.sortdirection = "desc";
					}
				}

				flatViewArgs.page = 1;

				siteManager.loadSiteFlat(flatViewArgs)

			});

			$("#navReports a").click(

			function(event) {
				event.preventDefault();

				$(".navReports .active").toggleClass('active');
				$(this).toggleClass('active');

				var report = $(this).attr("data-report");

				if(
				(flatViewArgs.report == "mylockedfiles" || flatViewArgs.report == "lockedfiles") && !(report == "mylockedfiles" || report == "lockedfiles")) {
					flatViewArgs.type = "";
				}

				flatViewArgs.report = report;

				if(flatViewArgs.report == "mylockedfiles" || flatViewArgs.report == "lockedfiles") {
					flatViewArgs.type = "File";
				}

				flatViewArgs.page = 1;

				siteManager.loadSiteFlat(flatViewArgs)

			});

			$("#tabFlat .moreResults a").click(

			function(event) {
				event.preventDefault();

				$("#tabFlat .moreResults a").toggleClass('active');
				$(this).toggleClass('active');

				flatViewArgs.page = $(this).attr("data-page");

				siteManager.loadSiteFlat(flatViewArgs)

			});
			initDraftPrompt();

			d.hide().animate({
				'opacity': 'show'
			}, 1000);
		});

		return false;
	},

	loadSiteSection(node, startrow) {

		var clearTimer=function(){
			$("#mura-section-loading").spin(false);
			$("#mura-section-loading").remove();
			$('#mura-grid-loader').remove();
			clearTimeout(startTimer);
		};

		clearTimer();

		if(!this.sectionLoading) {

			this.sectionLoading = true;
			var url = './index.cfm';
			var pars = 'muraAction=cArch.loadSiteSection&siteid=' + node.attr("data-siteid") + '&contentID=' + node.attr("data-contentid") + '&moduleid=' + node.attr("data-moduleid") + '&sortby=' + node.attr("data-sortby") + '&sortdirection=' + node.attr("data-sortdirection") + '&ptype=' + node.attr("data-type") + '&startrow=' + startrow + '&cacheid=' + Math.random();

			//location.href=url + "?" + pars;
			var icon = node.find("span:first");

			if(icon.hasClass('hasChildren closed')) {

				var startTimer=setTimeout(
					function(){
					//if(siteManager.sectionLoading){
						node.prepend('<div id="mura-section-loading" class="spinner-wrap"></div>');
						$('.mura-grid').prepend('<div id="mura-grid-loader"></div>');
						$("#mura-section-loading").spin(spinnerArgs3);
						//}
					},
					1000
				);

				icon.removeClass('hasChildren closed');
				icon.addClass('hasChildren open');

				//d.find(".loadProgress").show();
				$.ajax({
					url: url + "?" + pars,
					dataType: 'text',
					success(data) {
						try {
							var r = eval("(" + data + ")");

							node.find('.mura-section:first').remove();

							node.append(r.html);

							$('#newContentMenu').addClass('hide');
							stripe('stripe');
							initDraftPrompt();
							siteManager.initQuickEdits();

							//The fadeIn in ie8 causes a rendering issue
							if(!(document.all && document.querySelector && !document.addEventListener)) {
								node.find('.mura-section:first').hide().fadeIn("slow");
							}
						} catch(err) {
							if(data.indexOf('mura-primary-login-token') != -1) {
								location.href = './';
							}

							node.append(data);
						}

						clearTimer();
						siteManager.sectionLoading = false;
					}
				});
			} else {

				icon.removeClass('hasChildren open');
				icon.addClass('hasChildren closed');

				$.get(url + "?" + pars);

				node.find('.mura-section:first').fadeOut("fast", function() {
					node.find('.mura-section:first').remove();
					stripe('stripe');
					$('#newContentMenu').addClass('hide');
					siteManager.sectionLoading = false;
				});



			}
		}
		return false;
	},

	refreshSiteSection(node, startrow) {
		if(!this.sectionLoading) {
			this.sectionLoading = true;
			var url = './';
			var pars = 'muraAction=cArch.refreshSiteSection&siteid=' + node.attr("data-siteid") + '&contentID=' + node.attr("data-contentid") + '&moduleid=' + node.attr("data-moduleid") + '&sortby=' + node.attr("data-sortby") + '&sortdirection=' + node.attr("data-sortdirection") + '&ptype=' + node.attr("data-type") + '&startrow=' + startrow + '&cacheid=' + Math.random();

			$.ajax({
				url:url + "?" + pars,
				dataType: 'text',
				success(data) {
					try {
						var r = eval("(" + data + ")");

						//d.find(".loadProgress").remove();
						node.find('.mura-section:first').remove();
						node.append(r.html);

						$('#newContentMenu').addClass('hide');
						stripe('stripe');
						initDraftPrompt();
						siteManager.initQuickEdits();
					} catch(err) {
						if(data.indexOf('mura-primary-login-token') != -1) {
							location.href = './';
						}
						node.append(data);
					}

					siteManager.activeQuickEdit = false;
					siteManager.sectionLoading = false;
				}
			});

		}
		return false;
	},

	updateSortOrder(sortedContent){
		if (sortedContent){
			let ul = $("#sortableKids");
			let cloneLI = ul.clone();
			ul.empty();
			sortedContent.each(function (i,val) {
				let li = $(val);
				let found = cloneLI.find("li[data-contentid='"+li.attr("data-contentid")+"']");
				ul.append(found);
			});
			// same as in setAsSorted() but show() instead of fadeIn()
			$('#sorted').val('true');
			$('#sitemgr-reorder').show();
		}
	},

	setAsSorted() {
		$('#sorted').val('true');
		$('#sitemgr-reorder').fadeIn();
	},

	initQuickEdits() {

		$(".mura-quickEditItem").off("click").click(function(event)
		    {

			event.preventDefault();
			//verify if quickEdit is open
			let selected = $("#selected");
			if (selected.length > 0){
				//update clicked data for the closing quickEdit
				let clickedItem = selected.find("a.mura-quickEditItem");
				clickedItem.data("clicked", !clickedItem.data("clicked"));				
			}

		    $(this).data('clicked',!$(this).data('clicked'));

		    if ($(this).data('clicked'))
		        {
		        	if(!this.activeQuickEdit) {

					var attribute = $(this).attr("data-attribute");
					var node = $(this).parents("li:first");
					var url = './';
					var pars = 'muraAction=cArch.loadQuickEdit&siteid=' + siteid + '&contentID=' + node.attr("data-contentid") + '&attribute=' + attribute  + '&cacheid=' + Math.random();

					//location.href='?' + pars;
					//images/icons/template_24x24.png
					$("#mura-quickEditor").remove();
					$("#selected").attr("id", "");
					$('#selectedIcon').attr("id", "").attr("src", "assets/images/icons/template_24x24.png");
					$(this).parent().prepend(quickEditTmpl);

					var dd = $("#mura-quickEditor").parents("dd:first");
					dd.attr("id", "selected");

					$.get(url + "?" + pars, function(data) {
						if(data.indexOf('mura-primary-login-token') != -1) {
							location.href = './';
						}
						$("#mura-quickEditor").html(data);
						$("#mura-quickEditor").find("input, select").bind('mousedown.ui-disableSelection selectstart.ui-disableSelection', function(e) {
							e.stopImmediatePropagation();
						});

						setDatePickers(".mura-quickEdit-datepicker", dtLocale, dtCh);
						setToolTips(".mura-quickEdit-datepicker");

						setDatePickers("#mura-datepicker-displayStart", dtLocale, dtCh);
						setDatePickers("#mura-datepicker-displayStop", dtLocale, dtCh);
						setDatePickers("#displayIntervalEndOn", dtLocale, dtCh);

						if($("#hasDraftsMessage").length) {
							dd.addClass("hasDraft");
						}

						if(attribute == 'template') {
							var img = dd.find("img:first");
							if(img.length) {
								img.attr("id", "selectedIcon").attr("src", "assets/images/icons/template_24x24-on.png")
							}
						}

					});
				}
		    }
		 });

	/*
		$(".mura-quickEditItem").toggle(

		function(event) {

			event.preventDefault();
			if(!this.activeQuickEdit) {

				var attribute = $(this).attr("data-attribute");
				var node = $(this).parents("li:first");
				var url = './';
				var pars = 'muraAction=cArch.loadQuickEdit&siteid=' + siteid + '&contentID=' + node.attr("data-contentid") + '&attribute=' + attribute + '&cacheid=' + Math.random();

				//location.href='?' + pars;
				//images/icons/template_24x24.png
				$("#mura-quickEditor").remove();
				$("#selected").attr("id", "");
				$('#selectedIcon').attr("id", "").attr("src", "assets/images/icons/template_24x24.png");
				$(this).parent().prepend(quickEditTmpl);

				var qe = $("#mura-quickEditor")
				var dd = qe.parents("dd:first");

				dd.attr("id", "selected");

				$.get(url + "?" + pars, function(data) {
					if(data.indexOf('mura-primary-login-token') != -1) {
						location.href = './';
					}
					$("#mura-quickEditor").html(data);

					setDatePickers(".mura-quickEdit-datepicker", dtLocale, dtCh);
					setToolTips(".mura-quickEdit-datepicker");
					if($("#hasDraftsMessage").length) {
						dd.addClass("hasDraft");
					}

					if(attribute == 'template') {
						var img = dd.find("img:first");
						if(img.length) {
							img.attr("id", "selectedIcon").attr("src", "assets/images/icons/template_24x24-on.png")
						}
					}

				});
			}
		}, function(event) {
			event.preventDefault();
			siteManager.closeQuickEdit();
		});
*/
	},

	saveQuickEdit() {
		this.activeQuickEdit = true;
		var attribute = $("#mura-quickEditor").parent().find(".mura-quickEditItem:first").attr("data-attribute");
		var node = $("#mura-quickEditor").parents("li:first");
		var url = './';

		var basePars = {
			'muraAction': 'cArch.saveQuickEdit',
			'siteID': siteID,
			'contentID': node.attr("data-contentid"),
			'attribute': attribute
		}

		if(attribute == 'isnav') {
			var attributeParams = {
				'isnav': $("#mura-quickEdit-isnav").val()
			}
		} else if(attribute == 'inheritObjects') {
			var attributeParams = {
				'inheritObjects': $("#mura-quickEdit-inheritobjects").val()
			}
		} else if(attribute == 'template') {
			var attributeParams = {
				'template': $("#mura-quickEdit-template").val(),
				'childTemplate': $("#mura-quickEdit-childtemplate").val()
			}
		} else if(attribute == 'display') {
			/* per schedule should not be here */
			var attributeParams = {
				'display': $("#mura-display").val()
			}
		}

		var pars = $.extend({}, basePars, attributeParams);
		let sortedContent = null;

		if (document.forms.viewUpdate["sorted"].value == 'true'){
			//store unsaved order
			sortedContent = $("ul#sortableKids > li");
		}

		$("#mura-quickEditor").html('<img class="loader" src="assets/images/ajax-loader-alt.gif" />');

		$.ajax({
			  type: "POST",
			  url: "./index.cfm?" + node.attr("data-csrf"),
			  data: pars,
			  success(data) {
					if(data.indexOf('mura-primary-login-token') != -1) {
						location.href = './';
					}
					var parentNode = node.parents("li:first");

					if(parentNode.parents('li:first').length) {
						siteManager.refreshSiteSection(parentNode, 1);
					} else {
						var topNode = $("#top-node").parents("li:first");
						siteManager.loadSiteManager(topNode.attr("data-siteid"), topNode.attr("data-contentid"), topNode.attr("data-moduleid"), topNode.attr("data-sortby"), topNode.attr("data-sortdirection"), topNode.attr("data-type"), 1, sortedContent);
					}
				},
			 error( jqXHR, textStatus,errorThrown) {
				alert(jqXHR.responseText);
				},
			  dataType: 'text'
			});

		/*
		$.post('./', pars, function(data) {
			if(data.indexOf('mura-primary-login-token') != -1) {
				location.href = './';
			}
			var parentNode = node.parents("li:first");

			if(parentNode.parents('li:first').length) {
				siteManager.refreshSiteSection(parentNode, 1)
			} else {
				var topNode = $("#top-node").parents("li:first");
				siteManager.loadSiteManager(topNode.attr("data-siteid"), topNode.attr("data-contentid"), topNode.attr("data-moduleid"), topNode.attr("data-sortby"), topNode.attr("data-sortdirection"), topNode.attr("data-type"), 1);
			}
		});
		*/

	},

	closeQuickEdit() {
		let selected = $('#selected');
		let clickedItem = selected.find("a.mura-quickEditItem");
		clickedItem.data("clicked", !clickedItem.data("clicked"));
		selected.attr("id", "");
		$('#selectedIcon').attr("id", "").attr("src", "assets/images/icons/template_24x24.png");
		$('.mura-quickEdit').remove();
	},

	initCategoryAssignments() {
		$(".mura-quickEditItem").click(

		function(event) {
			event.preventDefault();

			//$(this).data('clicked',!$(this).data('clicked'));

			/*
		    if ($(this).data('clicked'))
		        {
				*/
				var node = $(this).parents("li:first");
				var cattrim = node.attr("data-cattrim");

				var categoryAssignment = {
					muraAction: 'cArch.loadCategoryAssignment',
					cattrim: node.attr("data-cattrim"),
					siteID: node.attr("data-siteid"),
					categoryID: node.attr("data-categoryid"),
					categoryAssignment: $('#categoryAssign' + cattrim).val(),
					featureStart: '',
					startHour: '',
					startMinute: '',
					startDayPart: '',
					featureStop: '',
					stopHour: '',
					stopMinute: '',
					stopDayPart: ''
				};

				if(categoryAssignment.categoryAssignment == '2') {
					$.extend(
					categoryAssignment, {
						featureStart: $('#featureStart' + cattrim).val(),
						startHour: $('#startHour' + cattrim).val(),
						startMinute: $('#startMinute' + cattrim).val(),
						startDayPart: $('#startDayPart' + cattrim).val(),
						featureStop: $('#featureStop' + cattrim).val(),
						stopHour: $('#stopHour' + cattrim).val(),
						stopMinute: $('#stopMinute' + cattrim).val(),
						stopDayPart: $('#stopDayPart' + cattrim).val()
					});
					//alert(JSON.stringify(categoryAssignment))
				}

				$("#mura-quickEditor").remove();
				$("#selected").attr("id", "");
				$('#selectedIcon').attr("id", "").attr("src", "assets/images/icons/template_24x24.png");
				$(this).parent().prepend(quickEditTmpl);

				var dd = $("#mura-quickEditor").parents("dd:first");
				$(dd).attr("id", "selected");

				$.ajax({
				  type: "POST",
				  url: "./index.cfm",
				  data: categoryAssignment,
				  success(data) {
					if(data.indexOf('mura-primary-login-token') != -1) {
						location.href = './';
					}
					$("#mura-quickEditor").html(data);
					setDatePickers(".mura-quickEdit-datepicker", dtLocale, dtCh);
					setToolTips(".mura-quickEdit-datepicker");
					},
				 error( jqXHR, textStatus,errorThrown) {
					alert(errorThrown);
					},
				  dataType: 'text'
				});

			/*
			} else {
				siteManager.closeQuickEdit();
			}
			*/
		});
	},

	saveCategoryAssignment() {
		var cattrim = $('#mura-quickEdit-cattrim').val();

		var categoryAssignment = {
			muraAction: 'cArch.loadCategoryFeatureStartStop',
			cattrim: cattrim,
			categoryAssignment: $('#mura-quickEdit-display').val(),
			featureStart: $('#mura-quickEdit-featureStart').val(),
			startHour: $('#mura-quickEdit-startHour').val(),
			startMinute: $('#mura-quickEdit-startMinute').val(),
			startDayPart: ($('#mura-quickEdit-startDayPart').length) ? $('#mura-quickEdit-startDayPart').val() : '',
			featureStop: $('#mura-quickEdit-featureStop').val(),
			stopHour: $('#mura-quickEdit-stopHour').val(),
			stopMinute: $('#mura-quickEdit-stopMinute').val(),
			stopDayPart: ($('#mura-quickEdit-stopDayPart').length) ? $('#mura-quickEdit-stopDayPart').val() : '',
			siteid: siteid
		};

		$("#mura-quickEditor").html('<img class="loader" src="assets/images/ajax-loader-alt.gif" />');

		$.ajax({
		  type: "POST",
		  url: "./index.cfm",
		  data: categoryAssignment,
		  success(data) {
			if(data.indexOf('mura-primary-login-token') != -1) {
				location.href = './';
			}
			$('#categoryLabelContainer' + cattrim).html(data);
			siteManager.closeCategoryAssignment();
			setToolTips(".mura-quickEdit-datepicker");
			siteManager.initCategoryAssignments();
			},
		 error( jqXHR, textStatus,errorThrown) {
			alert(errorThrown);
			},
		  dataType: 'text'
		});


	},

	closeCategoryAssignment() {
		$('#selected').attr("id", "");
		$('.mura-quickEdit').remove();
	},

	availableObjectTemplate: "",
	availalbeObjectParams: {},
	availableObject: {},
	availableObjectValidate() {
		return true
	},

	getDisplayObjectConfig(regionid) {
		var selectedObjects = $('#selectedObjects' + regionid);
		var str = selectedObjects.val().toString();
		var a = str.split("~");
		var data = {};

		data.object = a[0];
		data.name = a[1];
		data.objectid = a[2];

		if(a.length > 3) {
			data.params = a[3];
		}

		data.regionid = regionid;
		data.context = context;
		data.siteid = siteid;
		data.contentid = contentid;
		data.contenthistid = contenthistid;
		data.parentid = parentid;

		return data;
	},


	addDisplayObject(objectToAdd, regionid, configure, isUpdate) {
		var tmpObject = "";
		var tmpValue = "";
		var tmpText = "";

		isUpdate= isUpdate || false;

		//If it's not a js object then it must be an id of a form input or select
		if(typeof(objectToAdd) == "string") {

			// return error if the id does not exist.
			if(document.getElementById(objectToAdd) == null) {

				alertDialog("Please select a display object.");

				return false;
			}

			if(document.getElementById(objectToAdd).tagName.toLowerCase() == "select") {

				if(document.getElementById(objectToAdd).selectedIndex == -1) {
					alertDialog("Please select a display object.");

					return false;
				}
				//alert("Please select a display object."); return false;}
				var addIndex = document.getElementById(objectToAdd).selectedIndex;

				if(addIndex < 0) return false;

				var addoption = document.getElementById(objectToAdd).options[addIndex];

				tmpText = addoption.text;
				tmpValue = addoption.value;

			} else if(document.getElementById(objectToAdd).tagName.toLowerCase() == "input") {

				var addoption = document.getElementById(objectToAdd);
				tmpValue = addoption.value;

			} else {
				//If it's not a select box then the value must be json object.
				addoption = document.getElementById(objectToAdd);
			}

			try {
				tmpObject = eval('(' + addoption.value + ')');
			} catch(err) {
				tmpObject = addoption.value
			}

		} else {
			//If it's not a select box then the value must be json object.
			tmpObject = objectToAdd;
		}

		//if the tmpValue evaluated into a js object pull out it's values
		var checkSelection = false;

		if(typeof(tmpObject) == "object") {
			//object^name^objectID^params
			tmpObject.regionid = regionid;
			tmpObject.context = context;
			tmpObject.siteid = siteid;
			tmpObject.contentid = contentid;
			tmpObject.contenthistid = contenthistid;
			tmpObject.parentid = parentid;

			if(tmpObject.object == 'feed') {
				if(configure) {
					//alert(JSON.stringify(tmpObject));
					tmpObject.regionid = regionid;
					if(this.initFeedConfigurator(tmpObject)) {
						return false;
					}
				}
				checkSelection = true;
			}

			if(tmpObject.object == 'feed_slideshow') {
				if(configure) {
					tmpObject.regionid = regionid;
					this.initSlideShowConfigurator(tmpObject)
					return false;
				}
				checkSelection = true;
			}

			if(tmpObject.object == 'tag_cloud' && siteManager.customtaggroups.length) {
				if(configure) {
					tmpObject.regionid = regionid;
					this.initTagCloudConfigurator(tmpObject)
					return false;
				}
				checkSelection = true;
			}

			if(siteManager.allowopenfeeds && tmpObject.object == 'category_summary') {
				if(configure) {
					tmpObject.regionid = regionid;
					this.initCategorySummaryConfigurator(tmpObject)
					return false;
				}
				checkSelection = true;
			}

			if((tmpObject.object == 'related_content' || tmpObject.object == 'related_section_content')) {
				if(configure) {
					tmpObject.regionid = regionid;
					this.initRelatedContentConfigurator(tmpObject);
					return false;
				}
				checkSelection = true;
			}

			if(tmpObject.object == 'site_map') {
				if(configure) {
					tmpObject.regionid = regionid;
					this.initSiteMapConfigurator(tmpObject)
					return false;
				}
				checkSelection = true;
			}

			if(tmpObject.object == 'plugin') {
				if(configure){
					if(tmpObject.objectid && tmpObject.objectid.toLowerCase() != 'none'){

						var configurator = this.getPluginConfigurator(tmpObject.objectid);

						if(configurator != '') {
							window[configurator](tmpObject);
							return false;
						} else if(siteManager.layoutmanager){
							this.initGenericConfigurator(tmpObject);
							return false;
						}

					} else if(siteManager.layoutmanager){
						this.initGenericConfigurator(tmpObject);
					}
				}

				checkSelection = true;
			}

			if(siteManager.layoutmanager){

				if(configure) {
					if(siteManager.objectHasConfigurator(tmpObject)){
						siteManager.configuratorMap[tmpObject.object].initConfigurator(tmpObject);
					} else {
						this.initGenericConfigurator(tmpObject);
					}
				}

				checkSelection = true;
			}


			tmpValue = tmpObject.object;
			tmpValue = tmpValue + "~" + tmpObject.name;
			tmpValue = tmpValue + "~" + tmpObject.objectid;

			if(typeof(tmpObject.params) == "string") {
				tmpValue = tmpValue + "~" + tmpObject.params;
			} else if(typeof(tmpObject.params) == "object") {
				tmpValue = tmpValue + "~" + JSON.stringify(tmpObject.params);
			}

			if(!isUpdate && checkSelection && document.getElementById('selectedObjects' + regionid).selectedIndex != -1) {
				var currentSelection = this.getDisplayObjectConfig(regionid);

				if(currentSelection) {
					if(currentSelection.objectid == tmpObject.objectid || currentSelection.objectid == tmpObject.originid) {
						isUpdate = true
					}
				}

			}

			tmpText = tmpObject.name;

		}

		if(tmpValue == "") {

			alertDialog("Please select a display object.");

			return false;
		}

		//get reference to the select where it will go.
		var selectedObjects = document.getElementById("selectedObjects" + regionid);

		//double check that it's not already there
		if(selectedObjects.options.length) {
			for(var i = 0; i < selectedObjects.options.length; i++) {
				if(selectedObjects.options[i].value == tmpValue) {
					selectedObjects.selectedIndex = i;
					return false;
				}
			}
		}


		// add it.

		if(isUpdate && selectedObjects.selectedIndex != -1) {
			myoption = selectedObjects.options[selectedObjects.selectedIndex];
			myoption.text = tmpText;
			myoption.value = tmpValue;
		} else {
			var myoption = document.createElement("option");
			selectedObjects.appendChild(myoption);
			myoption.text = tmpText;
			myoption.value = tmpValue;
			myoption.selected = "selected"
		}

		this.updateDisplayObjectList(regionid);
		return true

	},

	initTagCloudConfigurator(data) {
		this.initConfigurator(data, {
			url: './',
			pars: 'muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + siteid + '&classid=tag_cloud&contentid=' + contentid + '&parentid=' + parentid + '&contenthistid=' + contenthistid + '&regionid=' + data.regionid + '&objectid=' + data.objectid + '&instanceid=' + data.instanceid + '&cacheid=' + Math.random(),
			title: tagCloudConfiguratorTitle
		});

		return true;
	},

	initSiteMapConfigurator(data) {
		this.initConfigurator(data, {
			url: './',
			pars: 'muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + siteid + '&classid=site_map&contentid=' + contentid + '&parentid=' + parentid + '&contenthistid=' + contenthistid + '&regionid=' + data.regionid + '&objectid=' + data.objectid + '&instanceid=' + data.instanceid + '&cacheid=' + Math.random(),
			title:siteMapConfiguratorTitle
		});

		return true;
	},

	initCategorySummaryConfigurator(data) {

		if(typeof(data.object) != 'undefined') {
			if(data.object != 'category_summary') {
				return false;
			}
		}

		this.initConfigurator(data, {
			url: './',
			pars: 'muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + siteid + '&classid=category_summary&contentid=' + contentid + '&parentid=' + parentid + '&contenthistid=' + contenthistid + '&regionid=' + data.regionid + '&objectid=' + data.objectid + '&instanceid=' + data.instanceid + '&cacheid=' + Math.random(),
			title: categorySummaryConfiguratorTitle
		});

		return true;
	},

	initFeedConfigurator(data) {

		/*
		if(typeof(data.object) !='undefined'){
			if(data.object !='feed'){
				return false;
			}
		}
		*/

		this.initConfigurator(data, {
			url: './',
			pars: 'muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + siteid + '&classid=feed&contentid=' + contentid + '&parentid=' + parentid + '&contenthistid=' + contenthistid + '&regionid=' + data.regionid + '&feedid=' + data.objectid + '&instanceid=' + data.instanceid + '&cacheid=' + Math.random(),
			title: "Loading...",
			init(data, config) {
				if(typeof data.type == 'string' && data.type.toLowerCase() == 'remote') {
					if(siteManager.configuratorMode=='frontEnd'){
						$("#configuratorHeader").html(remoteFeedConfiguratorTitle);
					} else {
						$("#configuratorContainer").dialog('option','title',remoteFeedConfiguratorTitle);
					}
				} else {
					if(siteManager.configuratorMode=='frontEnd'){
						$("#configuratorHeader").html(localIndexConfiguratorTitle);
					} else {
						$("#configuratorContainer").dialog('option','title',localIndexConfiguratorTitle);
					}
				}

				if($("#availableListSort").length) {
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

							if(siteManager.layoutmanager){
								siteManager.updateObjectPreview();
							} else {
								siteManager.updateAvailableObject();
							}
						}
					}).disableSelection();
				}
			}
		});
		//location.href=url + "?" + pars;
		return true;
	},

	initFolderConfigurator(data) {

		/*
		if(typeof(data.object) !='undefined'){
			if(data.object !='feed'){
				return false;
			}
		}
		*/

		this.initConfigurator(data, {
			url: './',
			pars: 'muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + siteid + '&classid=folder&contentid=' + contentid + '&parentid=' + parentid + '&contenthistid=' + contenthistid + '&regionid=' + data.regionid + '&feedid=' + data.objectid + '&instanceid=' + data.instanceid + '&cacheid=' + Math.random(),
			title: "Loading...",
			init(data, config) {
				//alert(JSON.stringify(data));
				folderConfiguratorTitle="Folder";

				if(siteManager.configuratorMode=='frontEnd'){
					$("#configuratorHeader").html(folderConfiguratorTitle);
				} else {
					$("#configuratorContainer").dialog('option','title',folderConfiguratorTitle);
				}


				if($("#availableListSort").length) {
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

							if(siteManager.layoutmanager){
								siteManager.updateObjectPreview();
							} else {
								siteManager.updateAvailableObject();
							}
						}
					}).disableSelection();
				}
			}
		});
		//location.href=url + "?" + pars;
		return true;
	},
	initSlideShowConfigurator(data) {

		/*
		if(typeof(data.object) !='undefined'){
			if(data.object !='feed_slideshow'){
				return false;
			}
		}
		*/

		this.initConfigurator(data, {
			url: './',
			pars: 'muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + siteid + '&classid=feed_slideshow&contentid=' + contentid + '&parentid=' + parentid + '&contenthistid=' + contenthistid + '&regionid=' + data.regionid + '&feedid=' + data.objectid + '&instanceid=' + data.instanceid + '&cacheid=' + Math.random(),
			title: slideShowConfiguratorTitle,
			init(data, config) {
				$("#availableListSort, #displayListSort").sortable({
					connectWith: ".displayListSortOptions",
					update(event) {
						event.stopPropagation();
						$("#displayList").val("");
						$("#displayListSort > li").each(function() {
							var current = $("#displayList").val();

							if(current != '') {
								$("#displayList").val(current + "," + $(this).html());
							} else {
								$("#displayList").val($(this).html());
							}

						});

						if(siteManager.layoutmanager){
							siteManager.updateObjectPreview();
						} else {
							siteManager.updateAvailableObject();
						}
					}
				}).disableSelection();
			}
		});

		return true;
	},

	initRelatedContentConfigurator(data) {

		this.initConfigurator(
		data, {
			url: './',
			pars: 'muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + siteid + '&classid=' + data.object + '&contentid=' + contentid + '&parentid=' + parentid + '&contenthistid=' + contenthistid + '&regionid=' + data.regionid + '&objectid=' + data.objectid + '&instanceid=' + data.instanceid + '&cacheid=' + Math.random(),
			title: relatedContentConfiguratorTitle,
			init(data, config) {
				$("#availableListSort, #displayListSort").sortable({
					connectWith: ".displayListSortOptions",
					update(event) {
						event.stopPropagation();
						$("#displayList").val("");
						$("#displayListSort > li").each(function() {
							var current = $("#displayList").val();

							if(current != '') {
								$("#displayList").val(current + "," + $(this).html());
							} else {
								$("#displayList").val($(this).html());
							}

						});

						if(siteManager.layoutmanager){
							siteManager.updateObjectPreview();
						} else {
							siteManager.updateAvailableObject();
						}

					}
				}).disableSelection();
			}
		});
		return true;
	},

	initGenericConfigurator(data) {
		this.resetAvailableObject();

		if(this.configuratorMode=='backEnd'){
			this.resetConfiguratorContainer();
		}

		if(siteManager.layoutmanager){
			this.initConfigurator(
			data, {
				url: './',
				pars: 'muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + siteid + '&classid=' + data.object + '&contentid=' + contentid + '&parentid=' + parentid + '&contenthistid=' + contenthistid + '&regionid=' + data.regionid + '&objectid=' + data.objectid + '&instanceid=' + data.instanceid + '&cacheid=' + Math.random(),
				title: data.title || data.name,
				iconclass: data.iconclass,
				init(data, config) {

				}
			});
		} else {
			$("#configuratorContainer").dialog({
				resizable: true,
				modal: true,
				width: 400,
				title: data.title || data.name,
				position: getDialogPosition(),
				buttons: {
					Cancel() {
						$(this).dialog("close");
					}
				},
				open() {
					//$("#ui-dialog-title-configuratorContainer").html(genericConfiguratorTitle);
					$("#configurator").html('<div class="ui-dialog-content ui-widget-content">' + genericConfiguratorMessage + '</div>');
				},
				close() {
					$(this).dialog("destroy");
				}
			});

		}

		return true;
	},


	updateAvailableObject() {
		var availableObjectParams = {};
		
		Mura(".objectParam, .objectparam").each(

		function() {
			var item = Mura(this);
		
			if(item.is('SELECT') && item.hasClass('ns-' + item.attr('name'))){
				var selected=Mura('div.nice-select.ns-' + item.attr('name'));
				if(selected.length){
					selected=selected.find('li.selected');
				}
				if(selected.length){
					item.val(selected.attr('data-value'));
				}
			}
			
			if(item.val() != null && ( item.attr("type") != "radio" || (item.attr("type") == "radio"  && item.is(':checked')) ) ) {
				
				if(item.data("param")){
					var param=item.data("param");
				} else {
					var param=item.attr("name");
				}

				if(typeof CKEDITOR != 'undefined' && item.attr('id') && typeof CKEDITOR.instances[item.attr('id')] != 'undefined'){
					CKEDITOR.instances[item.attr('id')].updateElement();
				}

				if(param){
					if(typeof availableObjectParams[param] == 'undefined') {
						if(item.attr("type") == "checkbox" && !item.is(":checked")){
							availableObjectParams[param] = '';
						} else {
							availableObjectParams[param] = item.val();
						}
					} else if (!(item.attr("type") == "checkbox" && !item.is(":checked")) ){
						availableObjectParams[param] = availableObjectParams[param] + ',' + item.val();
					}
				}
			}

			/*
			if(typeof param != 'undefined' && availableObjectParams[param]==''){
				delete availableObjectParams[param];
			}*/
		});

		var scope={};

		var sections=['object','meta','content'];
		var sizes=['xl','lg','md','sm','xs'];
		for(var n in sections){
			var section=sections[n];
			for(var s in sizes){
				var size=sizes[s];
				if(size=='xl'){
					var variablePrefix=section;
				} else {
					var variablePrefix=section + '_' + size + '_';
				}
				var variable=variablePrefix + 'styles';
				scope[variable]={};
				Mura('.' + variablePrefix + 'Style, .' + variablePrefix + 'style').each(
					function() {
						var item = Mura(this)
						if(item.val() != null && ( item.attr("type") != "radio" || (item.attr("type") == "radio"  && item.is(':checked')) ) ) {
							if(item.data("param")){
								var param=item.data("param");
							} else {
								var param=item.attr("name");
							}
							
							if(param){
								if(typeof scope[variable][param] == 'undefined') {
									if(item.attr("type") == "checkbox" && !item.is(":checked")){
										scope[variable][param] = '';
									} else {
										scope[variable][param] = item.val();
										//console.log(variable + '.' +  param + '=' + item.val() )
									}
								} else if (!(item.attr("type") == "checkbox" && !item.is(":checked")) ){
									scope[variable][param] = scope[variable][param] + ',' + item.val();
								}
							}

							if(typeof scope[variable][param] != 'undefined' && scope[variable][param]==''){
								delete scope[variable][param];
							}
						}
				})
			}
		}

		var stylesupport={};
		
		Mura(".styleSupport, .stylesupport").each(

		function() {
			var item = Mura(this);
			if(item.val() != null && ( item.attr("type") != "radio" || (item.attr("type") == "radio"  && item.is(':checked')) ) ) {
				if(item.data("param")){
					var param=item.data("param");
				} else {
					var param=item.attr("name");
				}
				if(param){
					if(typeof stylesupport[param] == 'undefined') {
						if(item.attr("type") == "checkbox" && !item.is(":checked")){
							stylesupport[param] = '';
						} else {
							stylesupport[param] = item.val();
						}
					} else if (!(item.attr("type") == "checkbox" && !item.is(":checked")) ){
						stylesupport['stylesupport'][param] = stylesupport[param] + ',' + item.val();
					}
				}

				if(typeof stylesupport[param] != 'undefined' && stylesupport[param]==''){
					delete stylesupport[param];
				}
			}
		})
		
		this.availableObject = Mura.extend({}, this.availableObjectTemplate);
	
		this.availableObject.params = availableObjectParams;
	
		stylesupport.objectstyles=scope.objectstyles || {};
		stylesupport.object_lg_styles=scope.object_lg_styles || {};
		stylesupport.object_md_styles=scope.object_md_styles || {};
		stylesupport.object_sm_styles=scope.object_sm_styles || {};
		stylesupport.object_xs_styles=scope.object_xs_styles || {};

		if(typeof this.availableObject.params.label != 'undefined' 
			&& this.availableObject.params.label){
			stylesupport.metastyles=scope.metastyles || {};
			stylesupport.meta_lg_styles=scope.meta_lg_styles || {};
			stylesupport.meta_md_styles=scope.meta_md_styles || {};
			stylesupport.meta_sm_styles=scope.meta_sm_styles || {};
			stylesupport.meta_xs_styles=scope.meta_xs_styles || {};
		} else {
			stylesupport.metastyles={};
			stylesupport.meta_lg_styles={};
			stylesupport.meta_md_styles={};
			stylesupport.meta_sm_styles={};
			stylesupport.meta_xs_styles={};
		}

		stylesupport.contentstyles=scope.contentstyles || {};
		stylesupport.content_lg_styles=scope.content_lg_styles || {};
		stylesupport.content_md_styles=scope.content_md_styles || {};
		stylesupport.content_sm_styles=scope.content_sm_styles || {};
		stylesupport.content_xs_styles=scope.content_xs_styles || {};

		//console.log(stylesupport)
		/*
		{"objectminheightuom":"px","objectmarginuom":"px","objectpaddinguom":"px","objectbackgroundimageurl":"http://localhost:8080/sites/default/assets/Image/2012-10-27_1201.png","objectBackgroundPositionY":"top","objectBackgroundPositionX":"left","metamarginuom":"px","metapaddinguom":"px","contentwidthuom":"%","contentminheightuom":"px","contentmarginuom":"px","contentpaddinguom":"px","objectstyles":{"backgroundImage":"url('http://localhost:8080/sites/default/assets/Image/2012-10-27_1201.png')","backgroundSize":"auto","backgroundRepeat":"no-repeat","backgroundAttachment":"scroll"},"metastyles":{},"contentstyles":{}}
		*/
		if(typeof stylesupport.objectstyles != 'undefined'){
			if(typeof stylesupport.objectstyles.minHeight == 'undefined'){
				delete stylesupport.objectminheightuom;
				delete stylesupport.objectminheightnum;
			}
		}

		if(typeof stylesupport.contentstyles != 'undefined'){
			if(typeof stylesupport.contentstyles.width == 'undefined'){
				delete stylesupport.contentwidthuom;
				delete stylesupport.contentwidthnum;
			}

			if(typeof stylesupport.contentstyles.minHeight == 'undefined'){
				delete stylesupport.contentminheightuom;
				delete stylesupport.contentminheightnum;
			}
		}

		//console.log(stylesupport);

		for(var size in sizes){
			if(sizes[size]=='xl'){
				size='';
			} else {
				size='_' + sizes[size] +'_';
			}

			if(typeof stylesupport['object' + size + 'styles'] != 'undefined'){
				if(typeof stylesupport['object' + size + 'styles'].minHeight == 'undefined'){
					delete stylesupport['object' + size + 'minheightuom'];
					delete stylesupport['object' + size + 'minheight'];
				}
				if(typeof stylesupport['object' + size + 'styles'].width == 'undefined'){
					delete stylesupport['object' + size + 'widthuom'];
				}
				if(typeof stylesupport['object' + size + 'styles'].backgroundImage == 'undefined'){
					delete stylesupport['object' + size + 'backgroundimageurl'];
					delete stylesupport['object' + size + 'BackgroundPositionX'];
					delete stylesupport['object' + size + 'BackgroundPositionY'];
					delete stylesupport['object' + size + 'styles'].backgroundRepeat;
					delete stylesupport['object' + size + 'styles'].backgroundSize;
					delete stylesupport['object' + size + 'styles'].backgroundAttachment;
				}
			}
			if(typeof stylesupport['meta' + size + 'styles'] != 'undefined'){
				if(typeof stylesupport['meta' + size + 'styles'].minHeight == 'undefined'){
					delete stylesupport['meta' + size + 'minheightuom'];
					delete stylesupport['meta' + size + 'minheight'];
				}
				if(typeof stylesupport['meta' + size + 'styles'].width == 'undefined'){
					delete stylesupport['meta' + size + 'widthuom'];
				}
				if(typeof stylesupport['meta' + size + 'styles'].backgroundImage == 'undefined'){
					delete stylesupport['meta' + size + 'backgroundimageurl'];
					delete stylesupport['meta' + size + 'BackgroundPositionX'];
					delete stylesupport['meta' + size + 'BackgroundPositionY'];
					delete stylesupport['meta' + size + 'styles'].backgroundRepeat;
					delete stylesupport['meta' + size + 'styles'].backgroundSize;
					delete stylesupport['meta' + size + 'styles'].backgroundAttachment;
				}
			}
			if(typeof stylesupport['content' + size + 'styles'] != 'undefined'){
				if(typeof stylesupport['content' + size + 'styles'].minHeight == 'undefined'){
					delete stylesupport['content' + size + 'minheightuom'];
					delete stylesupport['content' + size + 'minheight'];
				}
				if(typeof stylesupport['content' + size + 'styles'].width == 'undefined'){
					delete stylesupport['content' + size + 'widthuom'];
				}
				if(typeof stylesupport['content' + size + 'styles'].backgroundImage == 'undefined'){
					delete stylesupport['content' + size + 'backgroundimageurl'];
					delete stylesupport['content' + size + 'BackgroundPositionX'];
					delete stylesupport['content' + size + 'BackgroundPositionY'];
					delete stylesupport['content' + size + 'styles'].backgroundRepeat;
					delete stylesupport['content' + size + 'styles'].backgroundSize;
					delete stylesupport['content' + size + 'styles'].backgroundAttachment;
				}
			}
			
			if(typeof stylesupport['object' + size + 'styles'] != 'undefined'){
				if(!(stylesupport['object' + size + 'styles'].marginTop || stylesupport['object' + size + 'styles'].marginLeft || stylesupport['object' + size + 'styles'].marginBottom|| stylesupport['object' + size + 'styles'].marginRight)){
					delete stylesupport['object' + size + 'marginuom'];
				}
				
				if(!(stylesupport['object' + size + 'styles'].paddingTop || stylesupport['object' + size + 'styles'].paddingLeft || stylesupport['object' + size + 'styles'].paddingBottom|| stylesupport['object' + size + 'styles'].paddingRight)){
					delete stylesupport['object' + size + 'paddinguom']
				}
			}	
			
			if(typeof stylesupport['meta' + size + 'styles'] != 'undefined'){
				if(!(stylesupport['meta' + size + 'styles'].marginTop || stylesupport['meta' + size + 'styles'].marginLeft || stylesupport['meta' + size + 'styles'].marginBottom|| stylesupport['meta' + size + 'styles'].marginRight)){
					delete stylesupport['meta' + size + 'marginuom'];
				}
		
				if(!(stylesupport['meta' + size + 'styles'].paddingTop || stylesupport['meta' + size + 'styles'].paddingLeft || stylesupport['meta' + size + 'styles'].paddingBottom|| stylesupport['meta' + size + 'styles'].paddingRight)){
					delete stylesupport['meta' + size + 'paddinguom']
				}
			}

			if(typeof stylesupport['content' + size + 'styles'] != 'undefined'){
				if(!(stylesupport['content' + size + 'styles'].marginTop || stylesupport['content' + size + 'styles'].marginLeft || stylesupport['content' + size + 'styles'].marginBottom|| stylesupport['content' + size + 'styles'].marginRight)){
					delete stylesupport['content' + size + 'marginuom'];
				}
		
				if(!(stylesupport['content' + size + 'styles'].paddingTop || stylesupport['content' + size + 'styles'].paddingLeft || stylesupport['content' + size + 'styles'].paddingBottom|| stylesupport['content' + size + 'styles'].paddingRight)){
					delete stylesupport['content' + size + 'paddinguom'];
				}
			}
		}	

		

		var bgoptions=[
		'backgroundImage',
		'backgroundAttachment',
		'backgroundRepeat',
		'backgroundSize'];

		if(!stylesupport.objectbackgroundimageurl){
			var bgsupportoptions=[
			'objectbackgroundimageurl',
			'objectBackgroundPositionY',
			'objectbackgroundpositiony',
			'objectBackgroundPositionX',
			'objectbackgroundpositionx',
			'objectbackgroundimageurl'
			];


			for(var p=0;p<bgsupportoptions.length;p++){
				if(typeof stylesupport[bgsupportoptions[p]] != 'undefined'){
					delete stylesupport[bgsupportoptions[p]];
				}
			}
			for(var p=0;p<bgoptions.length;p++){
				if(typeof stylesupport.objectstyles[bgoptions[p]] != 'undefined'){
					delete stylesupport.objectstyles[bgoptions[p]];
				}
			}
		}

		if(!stylesupport.metabackgroundimageurl){
			var bgsupportoptions=[
			'metabackgroundimageurl',
			'metaBackgroundPositionY',
			'metabackgroundpositiony',
			'metaBackgroundPositionX',
			'metabackgroundpositionx',
			'metabackgroundimageurl'
			];


			for(var p=0;p<bgsupportoptions.length;p++){
				if(typeof stylesupport[bgsupportoptions[p]] != 'undefined'){
					delete stylesupport[bgsupportoptions[p]];
				}
			}
			for(var p=0;p<bgoptions.length;p++){
				if(typeof stylesupport.metastyles[bgoptions[p]] != 'undefined'){
					delete stylesupport.metastyles[bgoptions[p]];
				}
			}
		}

		if(!stylesupport.contentbackgroundimageurl){
			var bgsupportoptions=[
			'contentbackgroundimageurl',
			'contentBackgroundPositionY',
			'contentbackgroundpositiony',
			'contentBackgroundPositionX',
			'contentbackgroundpositionx',
			'contentbackgroundimageurl'
			];


			for(var p=0;p<bgsupportoptions.length;p++){
				if(typeof stylesupport[bgsupportoptions[p]] != 'undefined'){
					delete stylesupport[bgsupportoptions[p]];
				}
			}
			for(var p=0;p<bgoptions.length;p++){
				if(typeof stylesupport.contentstyles[bgoptions[p]] != 'undefined'){
					delete stylesupport.contentstyles[bgoptions[p]];
				}
			}
		}

		for(var o in stylesupport){
			if(stylesupport.hasOwnProperty(o) 
			&& typeof stylesupport[o] == 'object'
			&& !Array.isArray(stylesupport[o])
			&& Object.entries(stylesupport[o]).length === 0){
				delete stylesupport[o];
			}
		}
		
		this.availableObject.params.stylesupport=JSON.stringify(stylesupport);

		if(typeof originParams == 'object'){
			this.availableObject.params=$.extend(originParams,this.availableObject.params);
		}
	
		if(!this.availableObject.params.label){
			//console.log(this.availableObject.params.labeltag)
			this.availableObject.params.labeltag='';
		}

		this.updateConfiguratorConditionals(this.availableObject.params)


	},
	updateConfiguratorConditionals:function(params){
		params = params || availableObject.params || {};
		let evalBooleanWithinContext = function(context, code){
			return (function(code) { return eval(code); }).apply(context, [code.toString().replace(/params\./g, 'this.').replace(/props\./g, 'this.')]);
		};

		Mura(".mura-control-group[data-condition], .mura-control-group[data-condition]").each(
			function(){
				let item=Mura(this);

				if(item.data('condition')){
					(function(params){
						try{
							var show=evalBooleanWithinContext(params, item.data('condition'));
							if(show){
								item.show();
							} else {
								item.hide();
							}
						} catch(e){
							console.log('error evaluating param',e);
							item.show();
						}
					})(params)
				}
			}
		);
	},
	configuratorMap:{
			'container':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'collection':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'text':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'embed':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'feed':{condition(){return true;},'initConfigurator'(data){siteManager.initFeedConfigurator(data);}},
			'form':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'component':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'folder':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'gallery':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'calendar':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'form_responses':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'plugin':{
				'condition'(){
					return true;
				},
				'initConfigurator'(data){
					if(data.objectid && data.objectid.toLowerCase() != 'none' && siteManager.getPluginConfigurator(data.objectid)){
						var configurator = siteManager.getPluginConfigurator(data.objectid);
						window[configurator](data)
					} else {
						siteManager.initGenericConfigurator(data);
					}
				}
			},
			'feed_slideshow':{condition(){return true;},'initConfigurator'(data){siteManager.initSlideShowConfigurator(data);}},
			'tag_cloud':{condition(){return siteManager.customtaggroups.length;},'initConfigurator'(data){siteManager.initTagCloudConfigurator(data);}},
			'category_summary':{condition(){return true;},'initConfigurator'(data){if(siteManager.allowopenfeeds){siteManager.initCategorySummaryConfigurator(data);} else {siteManager.initGenericConfigurator(data);}}},
			'archive_nav':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'calendar_nav':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'category_summary_rss':{condition(){return siteManager.allowopenfeeds;},'initConfigurator'(data){siteManager.initCategorySummaryConfigurator(data);}},
			'site_map':{condition(){return true;},'initConfigurator'(data){siteManager.initSiteMapConfigurator(data);}},
			'related_content':{condition(){return true;},'initConfigurator'(data){siteManager.initRelatedContentConfigurator(data);}},
			'related_section_content':{condition(){return true;},'initConfigurator'(data){siteManager.initRelatedContentConfigurator(data);}},
			'system':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'comments':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'favorites':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'forward_email':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'event_reminder_form':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'rater':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'user_tools':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'goToFirstChild':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'navigation':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'sub_nav':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'peer_nav':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'standard_nav':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'portal_nav':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'folder_nav':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'multilevel_nav':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'seq_nav':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'top_nav':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'mailing_list':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}},
			'mailing_list_master':{condition(){return true;},'initConfigurator'(data){siteManager.initGenericConfigurator(data);}}
	},
	customtaggroups:[],
	allowopenfeeds:false,
	objectHasConfigurator(displayObject){
		return (displayObject.object in this.configuratorMap) && this.configuratorMap[displayObject.object].condition();
	},
	initDisplayObjectConfigurators() {
		var self=this;
		$(".displayRegions").dblclick(function() {
			var regionid = $(this).attr("data-regionid");
			var data = self.getDisplayObjectConfig(regionid);

			if(self.objectHasConfigurator(data)){
				self.configuratorMap[data.object].initConfigurator(data);
			} else {
				self.initGenericConfigurator(data);
			}
		});
	},

	resetAvailableObject() {
		this.availableObjectTemplate = "";
		//availalbeObjectParams={};
		this.availableObject = {};
		this.availableObjectValidate = function() {
			return true
		};
	},

	resetConfiguratorContainer() {
		//$(instance).dialog("destroy");
		$("#configuratorContainer").remove();
		$("body").append('<div id="configuratorContainer" title="Loading..." style="display:none"></div>');

		/*
		if(siteManager.layoutmanager){
			var html='<div class="clearfix">'
			    html+='<div id="configurator" style="float: left; width: 70%;"><div class="load-inline"></div></div>';
			    html+='<div style="float: right; width: 30%;"><h2>Preview</h2>';
			    html+='<iframe id="configuratorPreview" style="width:100%;height:700px;" marginheight="0" marginwidth="0" frameborder="0" src=""></iframe>';
			    html+='</div>';
				html+='</div>';
		} else {
		*/
			var html='<div id="configurator"><div class="load-inline"></div></div>';
		//}

		$('#configuratorContainer').html(html);

		$("#configuratorContainer .load-inline").spin(spinnerArgs2);
	},

	getConfiguratorTargets(){
		var styleTargets=[];

		['.object','.meta','.content'].forEach((section)=>{
			styleTargets.push(section + 'style');
			styleTargets.push(section + 'Style');

			['_lg_','_md_','_sm_','_xs_'].forEach((sub)=>{
				styleTargets.push(section + sub + 'style');
				styleTargets.push(section + sub + 'Style');
			});
		});

		return ".objectParam, .objectparam, .styleSupport, .stylesupport," + styleTargets.join();
		  
	},

	initConfiguratorParams() {
		this.updateAvailableObject();
		$(this.getConfiguratorTargets()).bind("change", function() {	
			siteManager.updateAvailableObject();
		});
	},

	setContentDisplayListSort() {
		$("#contentAvailableListSort, #contentDisplayListSort").sortable({
			connectWith: ".contentDisplayListSortOptions",
			update(event) {
				event.stopPropagation();
				$("#contentDisplayList").val("");
				$("#contentDisplayListSort > li").each(function() {
					var current = $("#contentDisplayList").val();

					if(current != '') {
						$("#contentDisplayList").val(current + "," + $.trim($(this).html()));
					} else {
						$("#contentDisplayList").val($.trim($(this).html()));
					}

				});
			}
		}).disableSelection();
	},

	//CONFIG: URL,PARS,TITLE,INIT
	configuratorMode: 'backEnd',
	previewURL:'',
	loadObjectPreview(configOptions){

		var src="core/utilities/objectpreview/";
		src+= '?siteid=';
		src+= configOptions.siteid;
		src+= '&contenthistid=';
		src+= configOptions.contenthistid;
		src+= '&parentid=';
		src+= configOptions.parentid;
		src+= '&object=';
		src+= configOptions.object;
		src+= '&compactDisplay=true';
		src+= '&objectid=';
		src+= configOptions.objectid;
		src+= '&params=';
		src+= escape(configOptions.params);

		if(src != siteManager.previewURL){
			var iframe=$("#configuratorPreview");
			if(iframe.length){
				siteManager.previewURL=src;
				iframe.attr('src',siteManager.previewURL);
			}
		}
	},
	updateObjectPreview(){
		siteManager.updateAvailableObject();
		configOptions.params=JSON.stringify(siteManager.availableObject.params);
		siteManager.loadObjectPreview(configOptions);
	},
	initConfigurator(data, config) {

		this.resetAvailableObject();
		this.previewURL='';

		if(typeof(config.validate) != 'undefined') {
			this.availableObjectValidate = config.validate;
		}

		data.configuratorMode = this.configuratorMode;

		if(typeof(data.object) == 'undefined') {
			return false;
		}

		if(siteManager.layoutmanager){
			data.layoutmanager=true;
		}

		if(this.configuratorMode == 'backEnd') {

			if(siteManager.layoutmanager){
				configOptions=$.extend({},data);
				configOptions.params=configOptions.params || {};
			}

			this.resetConfiguratorContainer();

			var originid=data.objectid;

			$("#configuratorContainer").dialog({
				resizable: true,
				modal: true,
				width: 600,
				position: getDialogPosition(),
				buttons: {
					Save() {
						siteManager.updateAvailableObject();

						var availableObjectSelector=$('#availableObjectSelector');

						if(availableObjectSelector.length){
							var selectedObject=eval('(' + availableObjectSelector.val() + ')');

							siteManager.availableObject.name=selectedObject.name;
							siteManager.availableObject.object=selectedObject.object;
							siteManager.availableObject.objectid=selectedObject.objectid;
							siteManager.availableObject.originid=originid;

							delete selectedObject.name;
							delete selectedObject.object;
							delete selectedObject.objectid;

							$.extend(siteManager.availableObject.params,selectedObject);


						}

						if(siteManager.availableObjectValidate(siteManager.availableObject.params)) {

							if(typeof(config.destroy) != 'undefined') {
								config.destroy(data, config);
							}

							$(this).dialog("destroy");


							//for some reason the availableObject sometimes has methods from the string.prototype.
							for(var p in siteManager.availableObject){
								if(typeof siteManager.availableObject[p] == 'function'){
									delete siteManager.availableObject[p];
								}
							}

							configure=(siteManager.availableObject.objectid != 'none' && originid!=siteManager.availableObject.objectid && siteManager.getPluginConfigurator(siteManager.availableObject.objectid));

							siteManager.addDisplayObject(siteManager.availableObject, data.regionid, configure,true);
						}

					},
					Cancel() {
						if(typeof(config.destroy) != 'undefined') {
							config.destroy(data, config);
						}

						$(this).dialog("destroy");

					}
				},
				close() {
					if(typeof(config.destroy) != 'undefined') {
						config.destroy(data, config);
					}

					$(this).dialog("destroy");
				}

			});

			var url=config.url + "?" + config.pars + '&contenttype=' + document.contentForm.type.value + '&contentsubtype=' + document.contentForm.subtype.value;
		} else {
			var url=config.url + "?" + config.pars;
		}

		$.ajax({
			url: url,
			dataType: 'text',
			data: data,
			type: 'post',
			success(_resp) {
				
				let resp=_resp;
			
				if(typeof resp=='string'){
					try {
						resp =JSON.parse.call(null,Mura.trim(_resp));
					} catch(err) {
						if(_resp.indexOf('mura-primary-login-token') != -1) {
							location.href = './';
						}
						resp = _resp;
					}
				}
			
				if(typeof(resp) == 'object') {
					$("#configurator").html(resp.html);
				} else if(typeof(resp) == 'xml') {
					$("#configurator").html(resp.toString());
				} else {
					$("#configurator").html(resp);
				}
			
				$('.form-actions').show();

				niceSelects=$('.mura #configurator select');;

				if(niceSelects.niceSelect){
					niceSelects.each(function(){
						var self=$(this);
						if(typeof self.data('niceselect') == 'undefined' || self.data('niceselect')){
							if(self.attr('name')){
								self.addClass('ns-' + self.attr('name'));
							}
							self.niceSelect();
						}
					})

				}


				//$("#configuratorContainer").parent().find("span.ui-dialog-title").html(test);

				if(siteManager.configuratorMode=='frontEnd'){

					setTimeout(function(){
						wireupExterndalUIWidgets();
					
						$('.mura-html:not(textarea').each(function(){
							var self=$(this);
							self.click(function(){
								siteManager.openDisplayObjectModal('object/html.cfm',self.data());
							});
						})
	
						$('.mura-markdown:not(textarea').each(function(){
							var self=$(this);
							self.click(function(){
								siteManager.openDisplayObjectModal('object/markdown.cfm',self.data());
							});
						})
	
						$('.mura-associmage').each(function(){
							var self=$(this);
							self.click(function(){
								siteManager.openDisplayObjectModal('object/associmage.cfm',self.data());
							});
						})
						
					},1);
				
					//if(siteManager.layoutmanager){
						if(config.title.indexOf("<i class=") > -1){
							$("#configuratorHeader").html(config.title);
						} else {
							config.iconclass=config.iconclass || 'mi-cog';
							$("#configuratorHeader").html('<i class="' + config.iconclass + '"></i> ' + config.title);
						}

					//}
				} else {
					$("#configuratorContainer").dialog('option','title',config.title);
				}

				if(siteManager.availableObjectTemplate == "") {
					var availableObjectContainer = $("#availableObjectParams");

					siteManager.availableObjectTemplate = {
						object: availableObjectContainer.attr("data-object"),
						objectid: availableObjectContainer.attr("data-objectid"),
						name: availableObjectContainer.attr("data-name")
					};

					siteManager.availableObjectTemplate.object=siteManager.availableObjectTemplate.object || data.object;
					siteManager.availableObjectTemplate.objectid=siteManager.availableObjectTemplate.objectid || data.objectid;
					siteManager.availableObjectTemplate.name=siteManager.availableObjectTemplate.name || data.name;

					siteManager.availableObject = $.extend({}, siteManager.availableObjectTemplate);
				}

				if(typeof(config.init) != 'undefined') {
					if(typeof(resp) == 'object') {
						data = $.extend(data, resp);
					}
				
					config.init(data, config);
				}

				if(siteManager.layoutmanager){
					setTabs();
					siteManager.updateAvailableObject();
					//$('#configurator').change(siteManager.updateAvailableObject);
					//$('#availableObjectSelector').change(siteManager.updateAvailableObject);
				} else {
					siteManager.updateAvailableObject();
				}

				if(siteManager.configuratorMode == 'backEnd') {
					$("#configuratorContainer").dialog("option", "position", getDialogPosition());
				} else if(siteManager.configuratorMode == 'frontEnd') {
					$("#actionButtons").show();
					$("#configuratorNotices").show();
				}
				window.configuratorInited=false;

				//initConfiguratorParams();
			}
		});

		return true;
	},

	getPluginConfigurator(objectid) {
		for(var i = 0; i < pluginConfigurators.length; i++) {
			if(pluginConfigurators[i].objectid == objectid) {
				return pluginConfigurators[i].init;
			}
		}

		return "";
	},

	openContentDiff(contenthistid1, contenthistid2, siteid) {

		$("#contentDiffContainer").remove();
		$("body").append('<div id="contentDiffContainer" title="Loading..." style="display:none"><div class="ui-dialog-content ui-widget-content"><div class="load-inline"></div></div></div>');
		$('#contentDiffContainer .load-inline').spin(spinnerArgs2);
		$("#contentDiffContainer").dialog({
			resizable: false,
			modal: true,
			width: 990,
			title: 'Version History Comparison: Code & Attribute Diff',
			position: getDialogPosition(),

			open() {
				//$("#ui-dialog-title-contentDiffContainer").html('Code Diff');
				$("#contentDiffContainer").html('<div class="ui-dialog-content ui-widget-content"><div class="load-inline"></div></div>');
				var url = './index.cfm';
				var pars = 'muraAction=cArch.loaddiff&compactDisplay=true&siteid=' + siteid + '&contenthistid1=' + contenthistid1 + '&contenthistid2=' + contenthistid2 + '&cacheid=' + Math.random();
				$.ajax(url + "?" + pars)
					.done(function(data) {
						if(data.indexOf('mura-primary-login-token') != -1) {
							location.href = './';
						}
						$('#contentDiffContainer .load-inline').spin(false);
						$('#contentDiffContainer').html(data);
						$("#contentDiffContainer").dialog("option", "position", "center");
						$(".ui-widget-overlay").css('height',$(document).height());

					})
					.fail(function(data){
						if(data.responseText.indexOf('mura-primary-login-token') != -1) {
							location.href = './';
						}
						$('#contentDiffContainer .load-inline').spin(false);
						$('#contentDiffContainer').html(data.responseText);
						$("#contentDiffContainer").dialog("option", "position", "center");
						//$(".ui-widget-overlay").css('height',window.height);
					});

			},
			close() {
				$(this).dialog("destroy");
				$("#contentDiffContainer").remove();
			}
		});

		return false;
	},
	openDisplayObjectModal(view,params){
		params=params || {};

		var $params=Mura.getQueryStringParams(location.search);
		Mura.deepExtend(Mura.setLowerCaseKeys($params),Mura.setLowerCaseKeys(params));
		$params.sourceframe='modal';
		$params.muraaction="carch.displayobjectmodal";
		$params.view=view;
		//console.log($params);
		var src='?';

		for(var p in $params){
			src=src + "&" + p + "=" + encodeURIComponent($params[p]);
		}

		src=src + '&cacheid=' + Math.random();

		frontEndProxy.post({
			cmd:'openModal',
			src:src
			}
		);
	},
	setDisplayObjectModalWidth(width){
		width=width || 'standard';
		$(function(){
			if($("#ProxyIFrame").length){
				$("#ProxyIFrame").load(
					function(){
						frontEndProxy.post({cmd:'setWidth',width:width});
					}
				);
			} else {
				frontEndProxy.post({cmd:'setWidth',width:width});
			}
		});
	},
	updateDisplayObjectParams(params,complete){
		params=params || {};
		complete =(typeof complete != 'undefined')? complete :true;

		var url=Mura.setLowerCaseKeys(Mura.getQueryStringParams(location.search));

		if(complete){
			params=Mura.extend({},siteManager.availableObject.params,params);
		} else {
			params=Mura.extend({},params);
		}

		$(function(){
			if($("#ProxyIFrame").length){
				$("#ProxyIFrame").load(
					function(){
						frontEndProxy.post({
							cmd:'setObjectParams',
							reinit:(url.sourceframe=='sidebar') ? false :true,
							instanceid:url.instanceid,
							params:params,
							complete:complete
							});
					}
				);
			} else {
				frontEndProxy.post({
					cmd:'setObjectParams',
					reinit:(url.sourceframe=='sidebar') ? false :true,
					instanceid:url.instanceid,
					params:params,
					complete:complete
					});
			}
		});



	},
	requestDisplayObjectParams(fn,targetFrame,doNotAutowire){
		targetFrame=targetFrame || 'modal';
		var callback=fn;
		siteManager.frontEndProxyListeners.push(
			{
				cmd:'customObjectParamsRequest',
				fn(params){

					if(doNotAutowire){
						siteManager.initConfiguratorParams();
						callback(params);
					} else {
						$(".objectParam, .objectparam").each(function(){
							var item=$(this);

							if(typeof item.attr('name') =='string'){
								var p=item.attr('name').toLowerCase();

								if(typeof params[p] != 'undefined'){

									if(item.is(':radio')){
										if(item.val().toString()==params[p].toString()){
											item.attr('checked',true);
										}

									} else {
										if(typeof params[p]=='object'){
											item.val(JSON.stringify(params[p]));
										} else {
											item.val(params[p].toString());
										}

										if(item.is('SELECT')){
											item.niceSelect('update');
										}

										if(typeof CKEDITOR !='undefined' && item.attr('id') && typeof CKEDITOR.instances[item.attr('id')] != 'undefined'){
											CKEDITOR.instances[item.attr('id')].setData(item.val());
										}
									}

								}
							}

						});
						//alert(JSON.stringify(params))
						siteManager.initConfiguratorParams();
						callback(params);
					}
				}
			}
		);

		var url=Mura.getQueryStringParams(location.search);

		$(function(){
			if($("#ProxyIFrame").length){
				$("#ProxyIFrame").load(
					function(){
						frontEndProxy.post({
							cmd:'requestObjectParams',
							instanceid:url.instanceid,
							targetFrame:targetFrame,
							callback:'customObjectParamsRequest'
							}
						);
					}
				);
			} else {
				frontEndProxy.post({
					cmd:'requestObjectParams',
					instanceid:url.instanceid,
					targetFrame:targetFrame,
					callback:'customObjectParamsRequest'
					}
				);
			}
		});

	},

	requestCustomConfigurator(target,fn){
		var callback=fn;
		siteManager.frontEndProxyListeners.push(
			{
				cmd:'customObjectConfiguratorRequest',
				target:target,
				fn(configurator){
					callback(configurator);
				}
			}
		);

		var url=Mura.getQueryStringParams(location.search);

		$(function(){
			if($("#ProxyIFrame").length){
				$("#ProxyIFrame").load(
					function(){
						frontEndProxy.post({
							cmd:'requestObjectConfigurator',
							instanceid:url.instanceid,
							target:target,
							callback:'customObjectConfiguratorRequest'
							}
						);
					}
				);
			} else {
				frontEndProxy.post({
					cmd:'requestObjectConfigurator',
					instanceid:url.instanceid,
					target:target,
					callback:'customObjectConfiguratorRequest'
					}
				);
			}
		});

	},

	frontEndProxyListener(messageEvent){
		var parameters=messageEvent.data;
		var listeners=siteManager.frontEndProxyListeners;

		for (var i=0; i < listeners.length; i++){
			if(listeners[i].cmd==parameters.cmd){
				if(parameters.params){
					listeners[i].fn(parameters.params);
				} else {
					listeners[i].fn(parameters);
				}
				listeners[i].cmd='void';
			}
		}

	},

	frontEndProxyListeners:[]

};


quickEditTmpl = '<div class="mura-quickEdit" id="mura-quickEditor">';
quickEditTmpl += '<img class="loader" src="assets/images/ajax-loader-alt.gif" />';
quickEditTmpl += '</div>';

function initConfigurator(data, config) {
	return siteManager.initConfigurator(data, config);
}

$(document).ready(function() {
		siteManager.initDisplayObjectConfigurators();
	});
