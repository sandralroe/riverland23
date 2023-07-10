<!--- license goes here --->
<cfsilent>
	<cfset request.layout=false>

	<cfscript>
	    //CF Version
	    port 	= $.event( 'mailSmtpPort' );
	    host 	= $.event( 'mailHost' );
	    user 	= $.event( 'mailUsername' );
	    pwd 	= $.event( 'mailPassword' );
	    useTLS 	= $.event( 'mailUseTLS' );
	    useSSL 	= $.event( 'mailUseSSL' );

	</cfscript>
	
</cfsilent>

<cfoutput>
	<cfscript>

		try {
		    props = createObject( "java", "java.util.Properties" ).init();
		    props.put( "mail.smtp.starttls.enable", useTLS );
		    props.put( "mail.smtp.auth", "true" );
		    props.put("mail.smtp.port", port ); 

		    if( useSSL == true ){
		    	props.put("mail.smtp.socketFactory.port", "465");
		    	props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
		    }

		    mailSession = createObject( "java", "javax.mail.Session" ).getInstance( props, javacast( "null", "" ) );
		    transport = mailSession.getTransport( "smtp" );
		    transport.connect( host, port, user, pwd );
		    transport.close();

		    savecontent variable="myContent" {
		     writeOutput( "<p>Your email settings are valid.</p>" );
		    }

		    WriteOutput( myContent );
		 } 
		catch(javax.mail.MessagingException e) {
		    savecontent variable="myContent" {
		    	WriteOutput("<p>Error: "& e.type &"</p><p>"& e.message & "</p>");
		    }

		    WriteOutput( myContent );
		 }
	</cfscript>
</cfoutput>