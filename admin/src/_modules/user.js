/* License goes here */

userManager = {
	//submitDialogs:[{type:'alert',message:'test1',condition(){return true}},{type:'confirmation',message:'test2',condition(){return true}}],
	submitDialogs:[],
	submitActions:[],
	addSubmitDialog(dialog){
		userManager.submitDialogs.push(dialog)
	},
	addSubmitAction(actionFn){
		userManager.submitActions.push(actionFn)
	},
	submitForm(frm,action){
		var handled=0;
		var cancelled=false;
		var dialogs=userManager.submitDialogs;
		var actions=userManager.submitActions;

		if(action){
			frm.action.value=action;
		}

		function submit(){
			var i;

			if(typeof CKEDITOR != 'undefined'){
				for(i in CKEDITOR.instances){
					CKEDITOR.instances[i].updateElement();
				}
			}

			Mura("textarea.mura-markdown,textarea.markdownEditor").forEach(function(){
				var input=Mura(this);
				if(markdownInstances && typeof markdownInstances[input.attr('name')]){
					if(input.length){
						input.val(markdownInstances[input.attr('name')].getMarkdown())
					}
				}
			})

			for(i=0;i<dialogs.length;i++){
				if(i == handled){
					var dialog=dialogs[i];

					if(dialog.type.toLowerCase()=='confirmation'){
						if(typeof dialog.condition == 'function'){
							if(dialog.condition(dialog)){
								confirmDialog($.extend(dialog,{yesAction(){handled++; submit()}}));

								return false
							} else {
								handled++;
							}
						} else {
							confirmDialog($.extend(dialog,{yesAction(){handled++; submit()}}));

							return false
						}
					} else if (dialog.type.toLowerCase()=='alert'){
						if(typeof dialog.condition == 'function'){
							if(dialog.condition(dialog)){
								alertDialog($.extend(dialog,{okAction(){handled++; submit()}}));

								return false
							} else {
								handled++;
							}
						} else {
							alertDialog($.extend(dialog,{okAction(){handled++; submit()}}));

							return false
						}
					} else if (dialog.type.toLowerCase()=='validation'){
						if(typeof dialog.condition == 'function'){
							if(dialog.condition(dialog)){
								alertDialog($.extend(dialog,{okAction(){handled++;}}));

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
					actions[i]();
				}

				actionModal(function(){frm.submit()});
			}
		}

		if(validateForm(frm)){

			submit();
		}

		return false;
	},
	loadExtendedAttributes(baseID, type, subType, _siteID, _context, _themeAssetPath) {
		var url = 'index.cfm';
		var pars = 'muraAction=cUsers.loadExtendedAttributes&baseID=' + baseID + '&type=' + type + '&subType=' + subType + '&siteID=' + _siteID + '&cacheid=' + Math.random();

		siteID = _siteID;
		context = _context;
		themeAssetPath = _themeAssetPath

		//location.href=url + "?" + pars;
		var d = $('#extendSetsDefault');

		if(d.length) {
			d.html('<div class="load-inline"></div>');
			$.ajax({
				url: url + "?" + pars,
				dataType: 'text',
				success(data) {

					if(data.indexOf('mura-primary-login-token') != -1) {
						location.href = './';
					}
					userManager.setExtendedAttributes(data);
				}
			});
		}

		return false;
	},

	setExtendedAttributes(data) {
		var r = eval("(" + data + ")");
		$("#extendSetsDefault").html(r.extended);
		$("#extendSetsBasic").html(r.basic);

		if(Mura.trim(r.extended) == '') {
			$('#tabExtendedattributesLI,#tabExtendedattributes').addClass('hide');
		} else {
			$('#tabExtendedattributesLI,#tabExtendedattributes').removeClass('hide');
		}
		//checkExtendSetTargeting();
		setHTMLEditors();
		setDatePickers(".tab-content .datepicker", dtLocale);
		setColorPickers(".tab-content .mura-colorpicker");
		setFinders(".tab-content .mura-ckfinder,.tab-content .mura-finder");
		setToolTips(".tab-content");
		setFileSelectors();

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
						var categories = document.form1.categoryID;
						started = true;
					}

					for(var c = 0; c < categories.length; c++) {
						var cat = categories[c];
						var catID = categories[c].value;
						var assignedID = extendSet.getAttribute("categoryid");
						if(!found && catID != null && assignedID.indexOf(catID) > -1) {
							found = true;
							membership = cat.checked;
						}
					}

					if(found) {
						if(membership) {
							userManager.setFormElementsDisplay(extendSet, '');
							extendSet.style.display = '';
							empty = false;
						} else {
							userManager.setFormElementsDisplay(extendSet, 'none');
							extendSet.style.display = 'none';

						}
					} else {
						userManager.setFormElementsDisplay(extendSet, 'none');
						extendSet.style.display = 'none';

					}
				} else {
					userManager.setFormElementsDisplay(extendSet, '');
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

	resetExtendedAttributes(contentHistID, type, subtype, siteID, context, themeAssetPath) {
		this.loadExtendedAttributes(contentHistID, type, subtype, siteID, context, themeAssetPath);
		//alert(dataArray[1]);
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

	}
}
