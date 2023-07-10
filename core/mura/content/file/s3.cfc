/* 
Copyright 2008 Barney Boisvert (bboisvert@gmail.com).

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
/**
 * deprecated, use app cfc level fileDir mapping
 */
component output="false" hint="deprecated, use app cfc level fileDir mapping" {

	public function init(required string awsKey, required string awsSecret, string localCacheDir, string awsEndpoint="s3.amazonaws.com") output=false {
		variables.awsEndpoint = awsEndpoint;
		variables.awsKey = awsKey;
		variables.awsSecret = awsSecret;
		variables.useLocalCache = structKeyExists(arguments, "localCacheDir");
		if ( useLocalCache ) {
			variables.localCacheDir = localCacheDir;
			if ( !directoryExists(localCacheDir) ) {
				cfdirectory( directory=localCacheDir, action="create" );
			}
		}
		return this;
	}

	public function s3Url(required string bucket, required string objectKey, string requestType="vhost", numeric timeout="900", string verb="GET") output=false {

		var expires = int(getTickCount() / 1000) + timeout;
			var signature = "";
			var destUrl = "";

			signature = getRequestSignature(
				uCase(verb),
				bucket,
				objectKey,
				expires
			);
			if (requestType EQ "ssl" OR requestType EQ "regular") {
				destUrl = "http" & iif(requestType EQ "ssl", de("s"), de("")) & "://#variables.awsEndpoint#/#bucket#/#objectKey#?AWSAccessKeyId=#variables.awsKey#&Signature=#urlEncodedFormat(signature)#&Expires=#expires#";
			} else if (requestType EQ "cname") {
				destUrl = "http://#bucket#/#objectKey#?AWSAccessKeyId=#variables.awsKey#&Signature=#urlEncodedFormat(signature)#&Expires=#expires#";
			} else { // vhost
				destUrl = "http://#bucket#.#variables.awsEndpoint#/#objectKey#?AWSAccessKeyId=#variables.awsKey#&Signature=#urlEncodedFormat(signature)#&Expires=#expires#";
			}

			return destUrl;
	}

	/**
	 * I put a file on S3, and return the HTTP response from the PUT
	 */
	public struct function putFileOnS3(required any binaryFileData, required string contentType, required string bucket, required string objectKey, boolean isPublic="true") output=false {
		var gmtNow = dateAdd("s", getTimeZoneInfo().utcTotalOffset, now());
		var dateValue = dateFormat(gmtNow, "ddd, dd mmm yyyy") & " " & timeFormat(gmtNow, "HH:mm:ss") & " GMT";
		var signature = getRequestSignature(
			"PUT",
			bucket,
			objectKey,
			dateValue,
			contentType,
			'',
			iif(isPublic, de('x-amz-acl:public-read'), '')
		);
		
		var result = "";
		
		if ( len(application.configBean.getProxyServer()) ) {
			cfhttp( proxyPort=application.configBean.getProxyPort(), proxyPassword=application.configBean.getProxyPassword(), proxyUser=application.configBean.getProxyUser(), url="http://#variables.awsEndpoint#/#bucket#/#objectKey#", proxyServer=application.configBean.getProxyServer(), result="result", method="PUT" ) {
				cfhttpparam( name="Date", type="header", value=dateValue );
				cfhttpparam( name="Authorization", type="header", value="AWS #variables.awsKey#:#signature#" );
				cfhttpparam( name="Content-Type", type="header", value=contentType );
				if ( isPublic ) {
					cfhttpparam( name="x-amz-acl", type="header", value="public-read" );
				}
				cfhttpparam( type="body", value=binaryFileData );
			}
		} else {
			cfhttp( url="http://#variables.awsEndpoint#/#bucket#/#objectKey#", result="result", method="PUT" ) {
				cfhttpparam( name="Date", type="header", value=dateValue );
				cfhttpparam( name="Authorization", type="header", value="AWS #variables.awsKey#:#signature#" );
				cfhttpparam( name="Content-Type", type="header", value=contentType );
				if ( isPublic ) {
					cfhttpparam( name="x-amz-acl", type="header", value="public-read" );
				}
				cfhttpparam( type="body", value=binaryFileData );
			}
		}
		deleteCacheFor(bucket, objectKey);
		return result;
	}

	public boolean function s3FileExists(required string bucket, required string objectKey) output=false {
		var result = "";
		if ( useLocalCache ) {
			if ( fileExists(cacheFilenameFromBucketAndKey(bucket, objectKey)) ) {
				return true;
			}
		}
		if ( len(application.configBean.getProxyServer()) ) {
			cfhttp( proxyPort=application.configBean.getProxyPort(), proxyPassword=application.configBean.getProxyPassword(), throwonerror=false, proxyUser=application.configBean.getProxyUser(), url=s3Url(bucket, objectKey, 'regular', 30, 'HEAD'), proxyServer=application.configBean.getProxyServer(), timeout=30, result="result", method="HEAD" );
		} else {
			cfhttp( throwonerror=false, url=s3Url(bucket, objectKey, 'regular', 30, 'HEAD'), timeout=30, result="result", method="HEAD" );
		}
		return val(trim(result.statusCode)) == 200;
	}

	public function deleteS3File(required string bucket, required string objectKey) output=false {
		deleteS3FileInternal(bucket, objectKey, 0);
	}

	private function deleteS3FileInternal(required string bucket, required string objectKey, required numeric attemptCount) output=false {
		var result = "";
		var retry = false;
		if ( len(application.configBean.getProxyServer()) ) {
			cfhttp( proxyPort=application.configBean.getProxyPort(), proxyPassword=application.configBean.getProxyPassword(), throwonerror=false, proxyUser=application.configBean.getProxyUser(), url=s3Url(bucket, objectKey, 'regular', 30, 'DELETE'), proxyServer=application.configBean.getProxyServer(), timeout=15, result="result", method="DELETE" );
		} else {
			cfhttp( throwonerror=false, url=s3Url(bucket, objectKey, 'regular', 30, 'DELETE'), timeout=15, result="result", method="DELETE" );
		}
		if ( result.statusCode < 200 || result.statusCode >= 300 ) {
			retry = attemptCount < 3 && (
				(isXml(result.fileContent)
					AND result.fileContent CONTAINS "<Code>InternalError</Code>"
				)
				OR (result.fileContent == "Connection Timeout"
				)
			);
			if ( retry ) {
				deleteS3FileInternal(bucket, objectKey, attemptCount + 1);
			} else {
				writeDump( var=arguments );
				writeDump( var=result );
				abort "error deleting file from S3";
			}
		}
		deleteCacheFor(bucket, objectKey);
	}

	/**
	 * Brings a file from S3 down local, and returns the fully qualified local path
	 */
	public function getFileFromS3(required string bucket, required string objectKey, string localFilePath) output=false {
		var filepath = "";
		var cachePath = "";
		if ( structKeyExists(arguments, "localFilePath") ) {
			filepath = localFilePath;
		} else {
			filepath = getTempFile(application.configBean.getTempDir(), "s3");
		}
		if ( useLocalCache ) {
			cachePath = cacheFilenameFromBucketAndKey(bucket, objectKey);
			if ( fileExists(cachePath) ) {
				fileCopy(cachePath, filepath);
				return filepath;
			}
		}
		try {
			if ( len(application.configBean.getProxyServer()) ) {
				cfhttp( proxyPort=application.configBean.getProxyPort(), getasbinary=true, proxyPassword=application.configBean.getProxyPassword(), throwonerror=true, proxyUser=application.configBean.getProxyUser(), path=getDirectoryFromPath(filepath), url=s3Url(bucket, objectKey, 'regular', 30), proxyServer=application.configBean.getProxyServer(), file=getFileFromPath(filepath), timeout=30 );
			} else {
				cfhttp( getasbinary=true, throwonerror=true, path=getDirectoryFromPath(filepath), url=s3Url(bucket, objectKey, 'regular', 30), file=getFileFromPath(filepath), timeout=30 );
			}
		} catch (any cfcatch) {
			//  try again, exactly the same 
			if ( len(application.configBean.getProxyServer()) ) {
				cfhttp( proxyPort=application.configBean.getProxyPort(), getasbinary=true, proxyPassword=application.configBean.getProxyPassword(), throwonerror=true, proxyUser=application.configBean.getProxyUser(), path=getDirectoryFromPath(filepath), url=s3Url(bucket, objectKey, 'regular', 30), proxyServer=application.configBean.getProxyServer(), file=getFileFromPath(filepath), timeout=30 );
			} else {
				cfhttp( getasbinary=true, throwonerror=true, path=getDirectoryFromPath(filepath), url=s3Url(bucket, objectKey, 'regular', 30), file=getFileFromPath(filepath), timeout=30 );
			}
		}
		if ( useLocalCache ) {
			fileCopy(filepath, cachePath);
		}
		return filepath;
	}

	public function deleteCacheFor(required string bucket, required string objectKey) output=false {
		var cachePath = "";
		if ( useLocalCache ) {
			cachePath = cacheFilenameFromBucketAndKey(bucket, objectKey);
			if ( fileExists(cachePath) ) {
				fileDelete(cachePath);
			}
		}
	}

	private function getRequestSignature(required string verb, required string bucket, required string objectKey, required string dateOrExpiration, string contentType="", string contentMd5="", string canonicalizedAmzHeaders="") output=false {

		var stringToSign = "";
			var algo = "HmacSHA1";
			var signingKey = "";
			var mac = "";
			var signature = "";

			stringToSign = uCase(verb) & chr(10)
				& contentMd5 & chr(10)
				& contentType & chr(10)
				& dateOrExpiration & chr(10)
				& iif(len(canonicalizedAmzHeaders) GT 0, de(canonicalizedAmzHeaders & chr(10)), de(''))
				& "/#bucket#/#objectKey#";
			signingKey = createObject("java", "javax.crypto.spec.SecretKeySpec").init(variables.awsSecret.getBytes(), algo);
			mac = createObject("java", "javax.crypto.Mac").getInstance(algo);
			mac.init(signingKey);
			signature = toBase64(mac.doFinal(stringToSign.getBytes()));

			return signature;
	}

	private function cacheFilenameFromBucketAndKey(required string bucket, required string objectKey) output=false {
		return localCacheDir & "/" & REReplace(bucket & "/" & objectKey, "[^a-zA-Z0-9.-]+", "_", "all");
	}
	

}
