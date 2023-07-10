//  license goes here 
/**
 * This provides image processing functionality
 */
component extends="mura.baseobject" output="false" hint="This provides image processing functionality" {

	public function init(configBean, settingsManager) {
		variables.configBean=arguments.configBean;
		variables.settingsManager=arguments.settingsManager;
		variables.instance.imageInterpolation=arguments.configBean.getImageInterpolation();
		variables.fileWriter=getBean("fileWriter");
		variables.instance.imageQuality=arguments.configBean.getImageQuality();
		if ( StructKeyExists(SERVER,"bluedragon") && !listFindNoCase("bicubic,bilinear,nearest",variables.instance.imageInterpolation) ) {
			variables.instance.imageInterpolation="bicubic";
		}
		variables.imageFileLookup={};
		return this;
	}

	public function touchDir(required string dir, string mode="#variables.configBean.getDefaultfilemode()#") output=false {
		//  Skip if using Amazon S3 
		//  fileExists will return true with Lucee s3 mapping  
		if ( !(directoryExists(dir) || fileExists(dir)) && !ListFindNoCase('s3', Left(arguments.dir, 2)) ) {
			if ( variables.configBean.getUseFileMode() ) {
				cfdirectory( mode=arguments.mode, directory=dir, action="create" );
			} else {
				cfdirectory( directory=dir, action="create" );
			}
		}
		return this;
	}

	public function doesImageFileExist(filePath, attempt="1") output=false {
		if(!variables.configBean.getValue(property="ImageFileLookups", defaultValue=true)){
			return true;
		}
		if ( variables.configBean.getValue(property="cacheImageFileLookups", defaultValue=false) ) {
			cfparam( default=structNew(), name="variables.imageFileLookup" );
			try {
				if ( arguments.attempt != 1 ) {
					structDelete(variables.imageFileLookup,'#arguments.filepath#');
				}
				if ( !structKeyExists(variables.imageFileLookup,'#arguments.filepath#') ) {
					if ( fileExists(arguments.filePath) ) {
						variables.imageFileLookup['#arguments.filepath#']=true;
						return true;
					} else {
						return false;
					}
				} else {
					return true;
				}
			} catch (any cfcatch) {
				return fileExists(arguments.filePath);
			}
		} else {
			return fileExists(arguments.filePath);
		}
	}

	public function resetImageFileLookUp() output=false {
		variables.imageFileLookup={};
	}

	public function getCustomImage(required Image, Height="AUTO", Width="AUTO", size="", siteID="", attempt="1") output=false {
		var NewImageSource = "";
		var NewImageLocal = "";
		var ReturnImageHTML = "";
		var OriginalImageFilename = "";
		var OriginalImageType = "";
		var OriginalImageFile = trim(arguments.Image);
		var OriginalImagePath = GetDirectoryFromPath(OriginalImageFile);
		var customImageSize="";
		if ( !len(arguments.image)
			or !listFindNoCase("png,gif,jpg,jpeg,webp",listLast(arguments.image,".")) ) {
			return "";
		}
		if ( !doesImageFileExist(OriginalImageFile,arguments.attempt) ) {
			OriginalImageFile = expandPath(OriginalImageFile);
			OriginalImagePath = GetDirectoryFromPath(OriginalImageFile);
		}
		OriginalImageType = listLast(OriginalImageFile,".");
		OriginalImageFilename = Replace(OriginalImageFile, ".#OriginalImageType#", "", "all");
		if ( len(arguments.size) ) {
			NewImageSource = "#OriginalImageFilename#_#lcase(arguments.size)#.#OriginalImageType#";
			NewImageLocal = Replace(OriginalImageFile, ".#OriginalImageType#", "_#lcase(arguments.size)#.#OriginalImageType#");
		} else {
			if ( arguments.Width == "AUTO" && arguments.Height == "AUTO" ) {
				NewImageSource = OriginalImageFile;
				NewImageLocal = arguments.Image;
			} else {
				arguments.Width = trim(replaceNoCase(arguments.Width,"px","","all"));
				arguments.Height = trim(replaceNoCase(arguments.Height,"px","","all"));
				NewImageSource = "#OriginalImageFilename#_W#arguments.Width#_H#arguments.Height#.#OriginalImageType#";
				NewImageLocal = Replace(OriginalImageFile, ".#OriginalImageType#", "_W#arguments.width#_H#arguments.height#.#OriginalImageType#");
			}
		}
		NewImageLocal = listLast(replace(NewImageLocal,"\","/","all"),'/');
		if ( !doesImageFileExist(NewImageSource,arguments.attempt) ) {
			OriginalImageFile = Replace(OriginalImageFile, ".#OriginalImageType#", "_source.#OriginalImageType#", "all");
			if ( !doesImageFileExist(OriginalImageFile,arguments.attempt) ) {
				OriginalImageFile = Replace(OriginalImageFile, "_source.#OriginalImageType#", ".#OriginalImageType#", "all");
			}
			//  If the original file does not exist then it can't create the custom image.
			if ( !doesImageFileExist(OriginalImageFile,arguments.attempt) ) {
				return NewImageLocal;
			}
			if ( len(arguments.size) ) {
				customImageSize=getBean('imageSize').loadBy(name=arguments.size,siteID=arguments.siteID);
				arguments.Width = customImageSize.getWidth();
				arguments.Height = customImageSize.getHeight();
			}
			//  If the custom image size is not valid return the small 
			if ( !isNumeric(arguments.Width) && !isNumeric(arguments.Height) ) {
				return "";
			}
			try {
				variables.fileWriter.copyFile(source=OriginalImageFile,destination=NewImageSource,mode="744");
				resizeImage(height=arguments.height,width=arguments.width,image=NewImageSource);
				if ( listFirst(expandPath(NewImageSource),':') == 's3' && len(arguments.siteID) && getBean('settingsManager').getSite(arguments.siteid).getContentRenderer().directImages ) {
					try {
						storeSetACL(expandPath(NewImageSource),[{group="all", permission="read"}]);
					} catch (any cfcatch) {
					}
				}
				if ( !doesImageFileExist(NewImageSource,arguments.attempt) ) {
					variables.fileWriter.copyFile(source=OriginalImageFile,destination=NewImageSource,mode="744");
				}
			} catch (any cfcatch) {
				if ( arguments.attempt == 1 ) {
					arguments.attempt=2;
					getCustomImage(argumentCollection=arguments);
				} else {
					rethrow;
				}
			}
		}
		return NewImageLocal;
	}

	public function resizeImage(required Image, Height="AUTO", Width="AUTO") output=false {
		var ThisImage=imageRead(arguments.image);
		var ImageAspectRatio=0;
		var NewAspectRatio=0;
		var CropX=0;
		var CropY=0;
		/* 
			This a workaround to ensure jpegs can be process 
			https://luceeserver.atlassian.net/browse/LDEV-1874
		*/
		if ( listFindNoCase('jpg,jpeg,webp',listLast(ThisImage.source,'.')) ) {
			var origImage=ThisImage;
			ThisImage = imageNew("", ThisImage.width, ThisImage.height, "rgb");
			imagePaste(ThisImage, origImage, 0, 0);
		}
		if ( arguments.Width == "AUTO" ) {
			if ( ThisImage.height > arguments.height ) {
				ImageResize(ThisImage,'',arguments.height,variables.instance.imageInterpolation);
				ImageWrite(ThisImage,arguments.image,variables.instance.imageQuality);
			}
		} else if ( arguments.Height == "AUTO" ) {
			if ( ThisImage.width > arguments.width ) {
				ImageResize(ThisImage,arguments.width,'',variables.instance.imageInterpolation);
				ImageWrite(ThisImage,arguments.image,variables.instance.imageQuality);
			}
		} else {
			ImageAspectRatio = ThisImage.Width / ThisImage.height;
			NewAspectRatio = arguments.Width / arguments.height;
			if ( ImageAspectRatio == NewAspectRatio ) {
				if ( ThisImage.width > arguments.width ) {
					ImageResize(ThisImage,arguments.width,'',variables.instance.imageInterpolation);
					ImageWrite(ThisImage,arguments.image,variables.instance.imageQuality);
				}
			} else if ( ImageAspectRatio < NewAspectRatio ) {
				ImageResize(ThisImage,arguments.width,'',variables.instance.imageInterpolation);
				CropY = (ThisImage.height - arguments.height)/2;
				ImageCrop(ThisImage, 0, CropY, arguments.Width, arguments.height);
				ImageWrite(ThisImage,arguments.image,variables.instance.imageQuality);
			} else if ( ImageAspectRatio > NewAspectRatio ) {
				ImageResize(ThisImage,'',arguments.height,variables.instance.imageInterpolation);
				CropX = (ThisImage.width - arguments.width)/2;
				ImageCrop(ThisImage, CropX, 0, arguments.width, arguments.height);
				ImageWrite(ThisImage,arguments.image,variables.instance.imageQuality);
			}
		}
		return this;
	}

	public function fromPath2Binary(required string path, boolean delete="yes") output=false {
		var rtn="";
		cffile( variable="rtn", file=arguments.path, action="readbinary" );
		if ( arguments.delete ) {
			try {
				cffile( file=arguments.path, action="delete" );
			} catch (any cfcatch) {
			}
		}
		return rtn;
	}

	public struct function Process(file, siteID) {
		var fileStruct = structNew();
		var imageCFC="";
		var theFile="";
		var theSmall="";
		var theMedium="";
		var fileObj="";
		var fileObjSmall="";
		var fileObjMedium="";
		var fileObjSource="";
		var refused=false;
		var serverFilename=arguments.file.serverfilename;
		var serverDirectory=arguments.file.serverDirectory & "/";
		var site=variables.settingsManager.getSite(arguments.siteID);
		var pid=createUUID();
		fileStruct.fileObj = '';
		fileStruct.fileObjSmall = '';
		fileStruct.fileObjMedium =  '';
		fileStruct.fileObjSource =  '';
		touchDir("#variables.configBean.getFileDir()#/#arguments.siteID#");
		if ( listLen(serverfilename," ") > 1 ) {
			serverFilename=replace(serverFilename," ","-","ALL");
			if ( fileExists("#serverDirectory##serverFilename#.#arguments.file.serverFileExt#") ) {
				cffile( file="#serverDirectory##serverFilename#.#arguments.file.serverFileExt#", action="delete" );
			}
			cffile( source="#serverDirectory##arguments.file.serverfile#", destination="#serverDirectory##serverFilename#.#arguments.file.serverFileExt#", action="rename", attributes="normal" );
		}
		cffile( source="#serverDirectory##serverFilename#.#arguments.file.serverFileExt#", destination="#serverDirectory##pid#-#serverFilename#.#arguments.file.serverFileExt#", action="rename", attributes="normal" );
		fileStruct.fileObj = "#serverDirectory##pid#-#serverFilename#.#arguments.file.serverFileExt#";
		//  BEGIN IMAGE MANIPULATION 
		if ( listFindNoCase('jpg,jpeg,png,gif,webp',arguments.file.ServerFileExt) ) {
			if ( variables.configBean.getFileStore() == "fileDir" ) {
				fileStruct.fileObjSource = '#serverDirectory##getCustomImage(image=fileStruct.fileObj,height='Auto',width=variables.configBean.getMaxSourceImageWidth())#';
			} else {
				fileStruct.fileObjSource = fileStruct.fileObj;
			}
			//  Small 
			fileStruct.fileObjSmall = "#serverDirectory##getCustomImage(image=fileStruct.fileObjSource,height=site.getSmallImageHeight(),width=site.getSmallImageWidth())#";
			if ( variables.configBean.getFileStore() != "fileDir" ) {
				fileStruct.fileObjSmall=fromPath2Binary(fileStruct.fileObjSmall,false);
				try {
					cffile( file=fileStruct.fileObjSmall, action="delete" );
				} catch (any cfcatch) {
				}
			}
			//  Medium 
			fileStruct.fileObjMedium = "#serverDirectory##getCustomImage(image=fileStruct.fileObjSource,height=site.getMediumImageHeight(),width=site.getMediumImageWidth())#";
			if ( variables.configBean.getFileStore() != "fileDir" ) {
				fileStruct.fileObjMedium=fromPath2Binary(fileStruct.fileObjMedium,false);
				try {
					cffile( file=fileStruct.fileObjMedium, action="delete" );
				} catch (any cfcatch) {
				}
			}
			//  Large 
			fileStruct.fileObjLarge = "#serverDirectory##getCustomImage(image=fileStruct.fileObjSource,height=site.getLargeImageHeight(),width=site.getLargeImageWidth())#";
			try {
				cffile( file=fileStruct.fileObj, action="delete" );
			} catch (any cfcatch) {
			}
			variables.fileWriter.copyFile(source=fileStruct.fileObjLarge,destination=fileStruct.fileObj);
			try {
				cffile( file=fileStruct.fileObjLarge, action="delete" );
			} catch (any cfcatch) {
			}
			StructDelete(fileStruct,"fileObjLarge");
			if ( variables.configBean.getFileStore() != "fileDir" ) {
				//  clean up source
				cffile( file=fileStruct.fileObjSource, action="delete" );
			}
		}
		fileStruct.theFile=fileStruct.fileObj;
		if ( variables.configBean.getFileStore() != "fileDir" ) {
			fileStruct.fileObj=fromPath2Binary(fileStruct.fileObj,false);
			try {
				cffile( file=fileStruct.fileObj, action="delete" );
			} catch (any cfcatch) {
			}
		}
		//  END IMAGE MANIPULATION 
		return fileStruct;
	}

}
