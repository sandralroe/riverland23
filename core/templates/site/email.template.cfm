<!--- License goes here --->
<!---

		NOTE:
		This is the 'Default' email template for the email broadcaster. 
		You can create custom email templates under your Theme at: /{themeName}/templates/emails/yourCustomFile.cfm.

--->
<cfoutput>
<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title>Message from #HTMLEditFormat(rsEmail.site)#</title>
</head>
<body>
	#bodyHtml#
	<p>To unsubscribe, <a href="#unsubscribe#">please click here</a>.</p>
	#trackOpen#
</body>
</html>
</cfoutput>