<!--- license goes here --->
<cfoutput>
<script>
if(typeof $ != 'undefined'){
	$(function(){
		Mura.loader()
		.loadjs("#variables.$.globalConfig('corepath')#/vendor/prettify/run_prettify.js");
	});
}
</script>
</cfoutput>
