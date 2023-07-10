/* License goes here */

var emailManager = {

	openScheduler() {
		var s = $('#scheduler');
		var c = $('#controls');
		var i = $('.toggle');
		c.css('display', 'none');
		s.css('display', 'block');
		i.css('opacity', '.30');
		i.attr('disabled','disabled');

		return false;

	},

	closeScheduler() {
		var s = $('#scheduler');
		var c = $('#controls');
		var i = $('.toggle');
		s.css('display', 'none');
		c.css('display', 'inline');
		i.css('opacity', '1');
		i.removeAttr('disabled');

		document.forms.form1.deliveryDate.value = '';

		$('.mura-datepickerdeliveryDate').val('');
		$('#mura-deliveryDateHour option')[7].selected = true;
		$('#mura-deliveryDateMinute option')[0].selected = true;
	
		if($('#mura-deliveryDateDayPart option').length){
			$('#mura-deliveryDateDayPart option')[0].selected = true;	
		}
		return false;

	},

	showMessageEditor() {
		var selObj = document.getElementById('messageFormat');
		var selIndex = selObj.selectedIndex;
		var h = $('#htmlMessage');
		var t = $('#textMessage');

		if(selObj.options[selIndex].value == "HTML") {
			h.css('display', 'inline');
			t.css('display', 'none');
		}
		if(selObj.options[selIndex].value == "Text") {
			h.css('display', 'none');
			t.css('display', 'inline');
		}
		if(selObj.options[selIndex].value == "HTML & Text") {
			h.css('display', 'inline');
			t.css('display', 'inline');
		}

	},

	validateEmailForm(formAction, errorMessage) {
		document.forms.form1.action.value = formAction;
		confirmDialog(errorMessage, function() {
			if(!emailManager.checkContentLength()) {
				return false;
			}

			submitForm(document.forms.form1);
		});


		return false;
	},

	validateScheduler(formAction, errorMessage, formField) {
		var f = $("#" + formField);
		document.forms.form1.action.value = formAction;
		if(f.val() == '') {
			alertDialog(errorMessage);
			f.focus();
		} else {
			submitForm(document.forms.form1);
		}

		return false;

	},

	checkContentLength() {
		/*
	var bodyHTML =FCKeditorAPI.GetInstance('bodyHTML').GetXHTML();
	var bodyHTMLLength = bodyHTML.length;
	var pageSize=32000;
			
			if(bodyHTMLLength > pageSize ){
		
			alert("The 'HTML' content length must be less than 32000 characters.");
			return false;
			}
			
			var bodyText =document.forms.form1.bodyText.value.length;
			var bodyTextLength = bodyText.length;
			
			if(bodyTextLength > pageSize ){
		
			alert("The 'Text' content length must be less than 32000 characters.");
			return false;
			}
			
		*/
		return true;
	}
}