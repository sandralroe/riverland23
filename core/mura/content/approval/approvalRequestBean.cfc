/* license goes here */
component extends="mura.bean.beanORM"  table="tapprovalrequests" entityname="approvalRequest" bundleable=true hint="This provides approval chain request functionality"{

	property name="requestID" fieldtype="id";
    property name="created" type="timestamp";
    property name="status" type="String" default="Pending";
    property name="approvalChain" fieldtype="one-to-one" cfc="approvalChain" fkcolumn="chainID";
    property name="content" fieldtype="one-to-one" cfc="content" fkcolumn="contentHistID";
    property name="user" fieldtype="many-to-one" cfc="user" fkcolumn="userID";
    property name="site" fieldtype="many-to-one" cfc="site" fkcolumn="siteID";
    property name="group" fieldtype="many-to-one" cfc="user"  loadkey="userid" fkcolumn="groupID";
    property name="actions" singularname="action" fieldtype="one-to-many" cfc="approvalAction" orderby="created asc" cascade="delete";

    function init(){
        setValue('created',now());
        super.init(argumentCollection=arguments);
    }

	function isApprover(){
		var sessionData=getSession();
		var Mura=getBean('Mura').init(get('siteid'));
		return (listfindNoCase(sessionData.mura.membershipids,this.getGroupID()) or Mura.currentUser().isAdminUser() or Mura.currentUser().isSuperUser())
	}

	function isRequester(){
		return this.getUserID() eq getCurrentUser().get('userid');
	}

    remote function approve(comments='',requestid='',siteid){
		if(request.muraAPIRequest){
			loadBy(requestid=arguments.requestid,siteid=arguments.siteid);
			if(!isApprover()){
				throw(type="authorization");
			}
		}

		if(getValue('status') eq 'Pending'){
			getBean('approvalAction').loadBy(requestID=getValue('requestID'), groupID=getValue('groupID'))
				.setComments(arguments.comments)
				.setActionType('Approval')
				.setUserID(getCurrentUser().getUserID())
				.setChainID(getValue('chainID'))
				.save();

			var memberships=getBean('approvalChain').loadBy(chainID=getValue('chainID')).getMembershipsIterator();

			if(memberships.hasNext()){

				do {
					var membership=memberships.next();

					//writeLog(text=membership.getGroupID() & ' ' & getValue('groupID'));

					if(membership.getGroupID() eq getValue('groupID')){

						if(memberships.hasNext()){
							setValue('groupID',memberships.next().getGroupID());
							save();

						} else {
							setValue('status','Approved');
							save();

							var content=getBean('content').loadBy(contentHistID=getValue('contentHistID'));
							var sourceid=getValue('contentHistID');
							if(not len(content.getChangesetID())){
								setValue(
									'contentHistID',
									content
										.setApproved(1)
										.setLastUpdateBy(content.getLastUpdateBy())
										.setLastUpdateByID(content.getLastUpdateByID())
										.setApprovingChainRequest(true)
										.save()
										.getContentHistID()
								);
								save();

								var source=getBean('content').loadBy(contenthistid=sourceid);

								if(not source.getIsNew()){
									source.deleteVersion();
								}

							}

						}

						var content=getBean('content').loadBy(contenthistid=getValue('contenthistid'),siteid=getValue('siteid'));
						getBean('contentManager').purgeContentCache(contentBean=content);

						break;
					}
				} while (memberships.hasNext());

			} else {
				setValue('status','Approved');
				save();

				var content=getBean('content').loadBy(contentHistID=getValue('contentHistID'));

				if(not len(content.getChangesetID())){

					setValue(
							'contentHistID',
							content
							.setApproved(1)
							.setApprovingChainRequest(true)
							.save()
							.getContentHistID()
						);
					save();

				}
			}

			sendActionMessage(content,getValue('status'),arguments.comments);
		}

		if(request.muraAPIRequest){
			return stripSystemKeys(getAll());
		} else {
			return this;
		}
    	
    }

    remote function reject(comments='',requestid='',siteid=''){
		request.muraPermissionsOverride=true;

		if(request.muraAPIRequest){
			loadBy(requestid=arguments.requestid,siteid=arguments.siteid);
			if(!isApprover()){
				throw(type="authorization");
			}
			if(!len(arguments.comments)){
				throw(type="invalidParameters");
			}
		}

		if(getValue('status') eq 'Pending'){
			getBean('approvalAction').loadBy(requestID=getValue('requestID'), groupID=getValue('groupID'))
				.setComments(arguments.comments)
				.setActionType('Rejection')
				.setUserID(getCurrentUser().getUserID())
				.setChainID(getValue('chainID'))
				.save();

			setValue('status','Rejected');
			save();
			var content=getBean('content').loadBy(contenthistid=getValue('contenthistid'),siteid=getValue('siteid'));
			getBean('contentManager').purgeContentCache(contentBean=content);

			sendActionMessage(content,getValue('status'),arguments.comments);
		}

		if(request.muraAPIRequest){
			return stripSystemKeys(getAll());
		} else {
			return this;
		}
    }

    remote function cancel(comments='',requestid='',siteid=''){
		request.muraPermissionsOverride=true;

		if(request.muraAPIRequest){
			loadBy(requestid=arguments.requestid,siteid=arguments.siteid);
			if(!isRequester()){
				throw(type="authorization");
			}
		}
		
	    if(getValue('status') eq 'Pending'){
	    	getBean('approvalAction').loadBy(requestID=getValue('requestID'), groupID=getValue('groupID'))
		    	.setComments(arguments.comments)
		    	.setActionType('Cancelation')
		    	.setUserID(getCurrentUser().getUserID())
		    	.setChainID(getValue('chainID'))
		    	.save();

			setValue('status','Canceled');
	    	save();
	    	var content=getBean('content').loadBy(contenthistid=getValue('contenthistid'),siteid=getValue('siteid'));
	    	getBean('contentManager').purgeContentCache(contentBean=content);

	    	sendActionMessage(content,getValue('status'),arguments.comments);
 		}
		
		if(request.muraAPIRequest){
			return stripSystemKeys(getAll());
		} else {
			return this;
		}
    }

    function save(){
    	if(not len(getValue('groupID'))){
	    	var memberships=getBean('approvalChain').loadBy(chainID=getValue('chainID')).getMembershipsIterator();

	    	if(memberships.hasNext()){
	    		setValue('groupID',memberships.next().getGroupID());
	    		var content=getBean('content').loadBy(contenthistid=getValue('contenthistid'),siteid=getValue('siteid'));
	    		sendActionMessage(content,'Pending');
	    	}
    	}
    	return super.save();
    }

    function sendActionMessage(contentBean,actionType,comments=''){
		if(listFindNoCase('Approved,Rejected,Pending,Canceled',arguments.actionType)){
			var $=getBean('$').init(arguments.contentBean.getSiteID());
			
			$.event('actionType',arguments.actionType);
			$.event('approvalRequest',this);
			$.event('contentBean',arguments.contentBean);
			$.event('content',arguments.contentBean);
			$.event('requester',getBean('user').loadBy(userID=getValue('userid')));
			$.event('group',getBean('user').loadBy(userID=getValue('groupid')));
			$.event('approver',$.getCurrentUser());
			$.event('comments',arguments.comments);
		
			$.announceEvent('beforeApprovalChainActionMessageSend');

			if((isBoolean($.event('messageSent')) && $.event('messageSent')) || !getBean('configBean').getValue(property='ApprovalChainMessages',defaultValue=true)){
				return;
			}
			
			var script='';
			var subject="";

			if(actionType == 'Approved'){
				script=$.siteConfig('ContentApprovalScript');
				subject=$.getBean('resourceBundle').messageFormat($.siteConfig().getRBFactory().getKey('approvalrequest.approved'),$.siteConfig('site'));
			} else if(actionType == 'Rejected'){
				script=$.siteConfig('ContentRejectionScript');
				subject=$.getBean('resourceBundle').messageFormat($.siteConfig().getRBFactory().getKey('approvalrequest.rejected'),$.siteConfig('site'));
			} else if(actionType == 'Canceled'){
				script=$.siteConfig('ContentCanceledScript');
				subject=$.getBean('resourceBundle').messageFormat($.siteConfig().getRBFactory().getKey('approvalrequest.canceled'),$.siteConfig('site'));
			} else if(actionType == 'Pending'){
				script=$.siteConfig('ContentPendingScript');
				subject=$.getBean('resourceBundle').messageFormat($.siteConfig().getRBFactory().getKey('approvalrequest.pending'),$.siteConfig('site'));
			}

			if(script neq '' ){

				var returnURL=contentBean.getURL(complete=true,queryString='previewid=#contentBean.getContentHistID()#');
				var contentName=contentBean.getMenuTitle();
				var contentType=contentBean.getType() & '/' & contentBean.getSubType();
				var approvalHistory = '';

				var actions=contentBean.getApprovalRequest().getActionsIterator();
				
				if (actions.getRecordCount() > 0){
					approvalHistory = "<h3>Approval History</h3>"
				}

				while(actions.hasNext()){
					var action = actions.next();

					approvalHistory &= '#UCase(action.getActionType())# "#action.getComments()#" <em><strong>#$.siteConfig().getRBFactory().getKey("approvalchains.by", $.siteConfig('site'))# #esapiEncode('html',action.getUser().getFullName())# #$.siteConfig().getRBFactory().getKey("approvalchains.on", $.siteConfig('site'))# #LSDateFormat(parseDateTime(action.getCreated()),session.dateKeyFormat)# #$.siteConfig().getRBFactory().getKey("approvalchains.at", $.siteConfig('site'))# #LSTimeFormat(parseDateTime(action.getCreated()),"short")#</strong></em></br>';
				}

				var finder=refind('##.+?##',script,1,"true");

				while (finder.len[1]) {
					try{
						script=replace(script,mid(script, finder.pos[1], finder.len[1]),'#trim(evaluate(mid(script, finder.pos[1], finder.len[1])))#');
					} catch(any e){
						script=replace(script,mid(script, finder.pos[1], finder.len[1]),'');
					}
					finder=refind('##.+?##',script,1,"true");
				}

				if(listFindNoCase('Canceled,Rejected,Approved',arguments.actionType)){
					//try{
						getBean('mailer').sendHTML(
							$.setDynamicContent(script),
							$.event('requester').getEmail(),
							$.siteConfig('site'),
							subject,
							$.event('siteid'),
							$.event('approver').getEmail()
						);
					//} catch (any e){}
				} else if (arguments.actionType=='Pending'){
					//try{
						if(isValid('email',$.event('group').getEmail())){
							getBean('mailer').sendHTML(
								$.setDynamicContent(script),
								$.event('group').getEmail(),
								$.siteConfig('site'),
								subject,
								$.event('siteid'),
								$.event('approver').getEmail()
							);
						} else {
							var members=$.event('group').getMembersIterator();

							if(members.hasNext()){
								var emailtext=$.setDynamicContent(script);

								while(members.hasNext()){
									getBean('mailer').sendHTML(
										emailtext,
										members.next().getEmail(),
										$.siteConfig('site'),
										subject,
										$.event('siteid'),
										$.event('approver').getEmail()
									);
								}
							}
						}
					//} catch (any e){}
				}

			}
		}

	}


}
