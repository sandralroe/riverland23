<!--- License goes here --->
<cfheader name="Content-disposition" value="attachment;filename=#rc.zipTitle#.zip">
<cfcontent file="#rc.zipFileLocation#" type="application/zip">
