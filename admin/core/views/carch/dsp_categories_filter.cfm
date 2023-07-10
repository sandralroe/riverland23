<cfparam name="$" default="#application.serviceFactory.getBean('MuraScope')#">
<cfparam name="attributes.divlabel" default="">
<cfparam name="attributes.siteid" default="#$.event('siteID')#">
<cfparam name="attributes.divid" default="mura-list-tree">
<cfparam name="attributes.divclass" default="">
<cfparam name="attributes.placeholder" default="#application.rbFactory.getKeyValue(session.rb,'sitemanager.categoryfilter')#">

<cfscript>
	if(server.coldfusion.productname != 'ColdFusion Server'){
		backportdir='';
		include "/mura/backport/backport.cfm";
	} else {
		backportdir='/mura/backport/';
		include "#backportdir#backport.cfm";
	}
</cfscript>

<cfif $.getBean("categoryManager").getCategoryCount($.event("siteID"))>
<cfoutput>
	<div id="#attributes.divid#" class="category-select<cfif len(trim(attributes.divclass))> #attributes.divclass#</cfif>">
		<cfif len(trim(attributes.divlabel))>
			<label>#attributes.divlabel#</label>
		</cfif>
		<div id="category-select-control"></div>
		<div id="category-select-list">
			<cf_dsp_categories_nest siteID="#attributes.siteid#" parentID="" nestLevel="0" categoryid="#$.event('categoryid')#">
		</div>
	</div>

<script type="text/javascript">
	setCheckboxTrees(checkParents=0,checkChildren=0,uncheckChildren=0,initialState="default",hideChildren=0);
	// console.log('setting trees');

	 var serializeCatCheckboxes = function(){
		var catContainer = $('##category-select-control');
		$(catContainer).find('.tag').remove();
		$('##category-select-list input[type=checkbox]:checked').each(function(){
  		var thisText = $(this).parent('li').clone().children().remove().end().text();
  		var selCat = '<span class="tag">' + thisText + '</span>';
  		$(selCat).appendTo(catContainer);
		});
	}
	$('##category-select-list input[type=checkbox]').on('click',function(){
			serializeCatCheckboxes();
	}); 
	serializeCatCheckboxes();

	$('##category-select-list').hide();
	$('##category-select-control').on('click', function(){
		$('##category-select-list').slideToggle('fast');
	});

	$('##category-select-list ul > li:has(input[type="checkbox"])').on('click', function(event){

		if ($(event.target).is('li')){				
			// $(this).find("> :checkbox").prop('checked', function(){
			// 	return !this.checked;
			// });
			$(this).find("> :checkbox").trigger('click');				
		}
		event.stopPropagation();
	});

	$('##category-select-list').prepend('<a href="##" id="mura-nodes-clear">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.clear'))#</a>');

	$(document).on('click', '##mura-nodes-clear', function(e){
		e.preventDefault();
		$(this).next('##mura-nodes').find('li input[type=checkbox]:checked').trigger('click');
		$(this).next('##mura-nodes').find('> li > ul').fadeOut('fast');
	});

	$('.assocFilterControls input.filesearch').on('keyup', function (e) {
    if (e.keyCode === 13) {

  		$(this).siblings('.assocFilterSubmit').trigger('click');
   		e.preventDefault();
    }
});


</script>

<!---  placeholder text --->
<style type="text/css">
		##category-select-control:empty:after{
			content: "#esapiEncode('html', attributes.placeholder)#" !important;
		}

</style>

</cfoutput>
</cfif>