<!--- License goes here --->
<cfset local = {} />
<cfset variables.fbManager = $.getBean('formBuilderManager') />

<cfset pageIndex = $.event('pageindex') />

<cfparam name="arguments.isNested" default="false">
<cfparam name="arguments.prefix" default="">

<cfif not isNumeric( pageIndex )>
	<cfset pageIndex = 1 />
</cfif>

<cfset local.frmID		= "frm" & replace(arguments.formID,"-","","ALL") />
<cfset local.frmID		= "frm" & replace(arguments.formID,"-","","ALL") />

<cfset local.prefix		= "" />

<cfif arguments.isNested>
	<cfset local.nestedForm		= $.getBean('content').loadBy( contentID=arguments.formid,siteid=session.siteid ) />
	<cfset arguments.formJSON	= local.nestedForm.getBody() />
	<cfset local.frm			= variables.fbManager.renderFormJSON( arguments.formJSON ) />
	<cfset local.prefix			= arguments.prefix />
<cfelse>
	<cfset local.frm			= variables.fbManager.renderFormJSON( arguments.formJSON ) />
</cfif>

<cfif len(local.prefix)>
	<cfset local.prefix = local.prefix & "_">
</cfif>

<cfset local.frmForm		= local.frm.form />
<cfset local.frmData		= local.frm.datasets />
<cfif not structKeyExists(local.frm.form,"formattributes")>
	<cfset local.frm.form.formattributes = structNew() />
</cfif>
<cfif not structKeyExists(local.frm.form.formattributes,"class")>
	<cfset local.frm.form.formattributes.class = "" />
</cfif>
<cfset local.attributes		= local.frm.form.formattributes />
<cfset local.frmFields		= local.frmForm.fields />
<cfset local.dataset		= "" />
<cfset local.isMultipart	= false />

<!--- start with fieldsets closed --->
<cfset request.fieldsetopen = false />

<cfif not StructKeyExists(local.frmForm,"pages")>
	<cfset local.frmForm.pages = ArrayNew(1) />
	<cfset local.frmForm.pages[1] = local.aFieldOrder />
</cfif>

<cfset local.aFieldOrder = local.frmForm.pages[pageIndex] />

<cfset local.frmFieldContents = "" />
<cfset local.pageCount = ArrayLen(local.frmForm.pages) />

<script>

$(function() {
	self = this;
<cfoutput>
	currentpage = #pageIndex#;
	pagecount = #local.pageCount#;
</cfoutput>

	if(Mura.formdata == undefined) {
		Mura.formdata = {};
	}

<cfoutput>
	if(Mura.formdata['#arguments.formID#'] == undefined) {
		Mura.formdata['#arguments.formID#'] = {};
	}
</cfoutput>

	leRenderPaging(<cfoutput>'#local.frmID#','#arguments.formID#',currentpage</cfoutput> );

	Mura("#btn-next").click( function() {
		leChangePage( <cfoutput>'#local.frmID#','#arguments.formID#'</cfoutput>,currentpage+1 );
	});

	Mura("#btn-back").click( function() {
		leChangePage( <cfoutput>'#local.frmID#','#arguments.formID#'</cfoutput>,currentpage-1 );
	});

	Mura("#btn-submit").click( function() {
		processFields(<cfoutput>'#local.frmID#','#arguments.formID#'</cfoutput>);
	});

});

	function leChangePage( formDiv,formid,pageIndex ) {
		var multi = {};
		var formdata = Mura.formdata[formid];
		var forminputs = {};

		$("#"+formDiv+" :input").each( function() {

			if( $(this).is(':checkbox') ) {
				if ( multi[$(this).attr('name')] == undefined  || forminputs[$(this).attr('name')] == undefined ) {
					multi[$(this).attr('name')] = [];
					delete formdata[$(this).attr('name')];
					forminputs[$(this).attr('name')] = true;
				}

				if( $(this).is(':checked') ) {
					multi[$(this).attr('name')].push( $(this).val() );
				}
			}
			else if( $(this).is(':radio')) {
				if($(this).is(':checked') )
					formdata[ $(this).attr('name') ] = $(this).val();
			}
			else {
				if( $(this).attr('name') != 'linkservid' )
					formdata[ $(this).attr('name') ] = $(this).val();
			}

		});

		for(var i in multi) {
			console.log('go');
			console.log(multi[i]);
			formdata[ i ] = multi[ i ].join(',');
		}

		Mura.formdata[formid] = formdata;

		Mura( "[data-objectid='" + formid +  "']" ).attr('data-pageIndex',pageIndex);
		Mura.processObject( Mura( "[data-objectid='" + formid +  "']" ) );
	}

	function leRenderPaging(formDiv,formid,pageIndex) {
		self = this;
		var formdata = Mura.formdata[formid];

		Mura("#" + formDiv + " #btn-next").hide();
		Mura("#" + formDiv + " #btn-back").hide();
		Mura("#" + formDiv + " #btn-submit").hide();

		if(self.pagecount == 1) {
			self.pagecount("#" + formDiv + " #btn-next").hide();
			Mura("#" + formDiv + " #btn-back").hide();
			Mura("#" + formDiv + " #btn-submit").show();
		}
		else {
			if(self.pagecount == 1) {
				Mura("#" + formDiv + " #btn-next").show();
			} else {

				if (pageIndex > 1) {
					Mura("#" + formDiv + " #btn-back").show();
				}

				if(pageIndex < self.pagecount) {
					Mura("#" + formDiv + " #btn-next").show();
				}
				else {
					Mura("#" + formDiv + " #btn-submit").show();
				}
			}
		}

		$("#"+formDiv+" :input").each( function() {

			if( formdata[ $(this).attr('name') ] != undefined) {
				if ($(this).is(':checkbox') && formdata[$(this).attr('name')].indexOf($(this).val()) > -1) {
					$(this).prop('checked', 'checked');
				}
				else if ( $(this).is(':radio') && $(this).val() == formdata[$(this).attr('name')]) {
					$(this).prop('checked', 'checked');
				}
				else if (!$(this).is(':checkbox') && !$(this).is(':radio')){
					$(this).val(formdata[$(this).attr('name')]);
				}
			}
		});
	}

	function processFields(formDiv,formid) {

		var formdata = Mura.formdata[formid];
		console.log('go');

		$("#"+formDiv).submit();
	}


</script>

<cfsavecontent variable="frmFieldContents">
<cfoutput>

<cfloop from="1" to="#ArrayLen(local.aFieldOrder)#" index="iix">
	<cfif StructKeyExists(local.frmFields,local.aFieldOrder[iix])>
		<cfset local.field = local.frmFields[local.aFieldOrder[iix]] />
		<!---<cfif iiX eq 1 and field.fieldtype.fieldtype neq "section">
			<ol>
		</cfif>--->
		<cfif local.field.fieldtype.isdata eq 1 and len(local.field.datasetid)>
			<cfset local.dataset = variables.fbManager.processDataset( variables.$,local.frmData[local.field.datasetid] ) />
		</cfif>
		<cfif local.field.fieldtype.fieldtype eq "file">
			<cfset local.isMultipart = true />
		</cfif>
		<cfif local.field.fieldtype.fieldtype eq "hidden">
		#variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_#local.field.fieldtype.fieldtype#.cfm',
			field=local.field,
			dataset=local.dataset,
			prefix=local.prefix,
			objectparams=objectparams
			)#
		<cfelseif local.field.fieldtype.fieldtype neq "section">
			<div class="mura-form-#local.field.fieldtype.fieldtype#<cfif local.field.isrequired> req</cfif> #this.formBuilderFieldWrapperClass#<cfif structKeyExists(local.field,'wrappercssclass')> #local.field.wrappercssclass#</cfif>">
			#variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_#local.field.fieldtype.fieldtype#.cfm',
				field=local.field,
				dataset=local.dataset,
				prefix=local.prefix,
			objectparams=objectparams
				)#
			</div>
		<cfelseif local.field.fieldtype.fieldtype eq "section">
			<!---<cfif iiX neq 1>
				</ol>
			</cfif>--->
			#variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_#local.field.fieldtype.fieldtype#.cfm',
				field=local.field,
				dataset=local.dataset,
				prefix=local.prefix,
			objectparams=objectparams
				)#
			<!---<ol>--->
		<cfelse>
		#variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_#local.field.fieldtype.fieldtype#.cfm',
			field=local.field,
			dataset=local.dataset,
			prefix=local.prefix,
			objectparams=objectparams
			)#
		</cfif>
		<!---#$.dspObject_Include('formbuilder/fields/dsp_#field.fieldtype.fieldtype#.cfm')#--->
	<cfelse>
		<!---<cfthrow data-message="ERROR 9000: Field Missing: #aFieldOrder[iiX]#">--->
	</cfif>
</cfloop>

<cfif request.fieldsetopen eq true></fieldset><cfset request.fieldsetopen = false /></cfif>
<!---</ol>--->
</cfoutput>
</cfsavecontent>
<cfset local.frmFieldContents = frmFieldContents />
<cfoutput>
<cfif not arguments.isNested>


<form id="#local.frmID#" onsubmit="return false;" class="<cfif structKeyExists(local.attributes,"class") and len(local.attributes.class)>#local.attributes.class# </cfif>mura-form-builder" method="post"<cfif local.isMultipart>enctype="multipart/form-data"</cfif>>
</cfif>
	#local.frmFieldContents#
<cfif not arguments.isNested>
	<cfif local.pageCount eq pageIndex>
	#variables.$.dspObject_Include(thefile='/form/dsp_form_protect.cfm')#
	</cfif>
	<div class="#this.formBuilderButtonWrapperClass#"><br>
	<button type="button" class="btn" id="btn-next">Next</button>
	<button type="button" class="btn" id="btn-back">Back</button>
	<div class="#this.formBuilderButtonWrapperClass#"><br><button type="button" class="btn" id="btn-submit">#$.rbKey('form.submit')#</button></div>
	</div>
</form>

</cfif>
</cfoutput>
