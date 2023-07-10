// todo: audit for resource bundle keys
MuraFileBrowser = {

  config: {
      resourcepath: "User_Assets",
      directory: "",
      height: 600,
      selectMode: 0,
      endpoint: '',
      completepath: false,
      displaymode: 2, // 1: grid, 2: list
      selectCallback: function() {}
  }
  
  , prettify: function( tgt ) {
  
  }
  
  , render: function( config ) {
    var self = this;
    var target =  "_" + Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
  
    var folderState=Mura.readCookie( 'mura_fbfolder');
    if(folderState){
      try{
        folderState=JSON.parse(folderState);
        if(folderState.resourcepath != MuraFileBrowser.config.resourcepath || folderState.siteid != Mura.siteid){
          Mura.createCookie( 'mura_fbfolder','');
        }
      }catch(e){}
    }
  
    this.config=Mura.extend(config,this.config);
    this.endpoint =  Mura.apiEndpoint + "filebrowser/";
    this.container = Mura("#MuraFileBrowserContainer");
    this.container.append("<div id='" + target + "'><component :is='currentView'></component></div>");
    this.target = target;
    this.main(); // Delegating to main()
    Mura.loader()
      .loadcss(
  //      Mura.corepath + '/vendor/codemirror/codemirror.css',
        Mura.corepath + '/vendor/cropper/cropper.min.css'
      )
      .loadjs(
        Mura.adminpath + '/assets/js/vue.min.js',
        Mura.corepath + '/vendor/cropper/cropper.min.js',
        // Mura.corepath + '/vendor/codemirror/addon/formatting/formatting.js',
        // Mura.corepath + '/vendor/codemirror/mode/htmlmixed/htmlmixed.js',
      function() {
        self.mountbrowser();
       } ) ;
  
       this.getURLVars();
  }
  
  , main: function( config ) {
    var self = this;
  }
  
  , onError: function(msg) {
    console.log( msg );
  }
  
  , getURLVars: function() {
      var vars = {};
      var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
          vars[key] = value;
      });
  
      if(vars['CKEditorFuncNum'])
        this.callback = vars['CKEditorFuncNum'];
  }
  
  , validate: function() {
    return true;
  }
  
  , moveFile: function( currentFile,source,destination,onSuccess ) {
  
    //var baseurl = this.endpoint + "/move?directory=" + source + "&destination=" + destination + "&resourcepath=" + this.config.resourcepath + "&filename=" + currentFile.fullname;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'move',
      {
        directory:source,
        destination:destination,
        resourcepath:this.config.resourcepath,
        filename:currentFile.fullname,
        completepath:this.config.completepath
      },
      'post'
    ).then(
      //success
      function(response) {
        onSuccess(response);
      },
      //fail
      function(response) {
        this.onError(response);
      }
    );
  
  }
  
  , getChildDirectory: function( dir,onSuccess,fileViewer) {
    var baseurl = this.endpoint + "/childdir?directory=" + dir + "&resourcepath=" + this.config.resourcepath + "&completepath=" + this.config.completepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    Mura.get( baseurl )
      .then(
        //success
        function(response) {
          onSuccess(response);
        },
        //fail
        function(response) {
          this.onError(response);
        }
      );
  }
  
  
  , getEditFile: function( directory,currentFile,onSuccess) {
    var dir = directory == undefined ? "" : directory;
    var baseurl = this.endpoint + "/edit?directory=" + dir + "&filename=" + currentFile.fullname + "&resourcepath=" + this.config.resourcepath+ "&completepath=" + this.config.completepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    Mura.get( baseurl )
      .then(
        //success
        function(response) {
          onSuccess(response);
        },
        //fail
        function(response) {
          this.onError(response);
        }
      );
  }
  
  , doDeleteFile: function( directory,currentFile,onSuccess,onError) {
    var dir = directory == undefined ? "" : directory;
    //var baseurl = this.endpoint + "/delete?directory=" + dir + "&filename=" + currentFile.fullname + "&resourcepath=" + this.config.resourcepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'delete',
      {
        directory:dir,
        resourcepath:this.config.resourcepath,
        filename:currentFile.fullname
      },
      'post'
    )
      .then(
        //success
        function(response) {
          onSuccess(response);
        },
        //fail
        function(response) {
          this.onError(response);
        }
      );
  }
  
  , doDuplicateFile: function( directory,currentFile,onSuccess,onError) {
    var dir = directory == undefined ? "" : directory;
    //var baseurl = this.endpoint + "/duplicate?directory=" + dir + "&resourcepath=" + this.config.resourcepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'duplicate',
      {
        directory:dir,
        resourcepath:this.config.resourcepath,
        file:currentFile,
        completepath:this.config.completepath
      },
      'post'
    ).then(
        //success
        function(response) {
          onSuccess(response);
        },
        //fail
        function(response) {
          this.onError(response);
        }
    );
  }
  
  , doUpdateContent: function( directory,currentFile,content,onSuccess,onError) {
    var dir = directory == undefined ? "" : directory;
    //var baseurl = this.endpoint + "/update?directory=" + dir + "&filename=" + currentFile.fullname + "&resourcepath=" + this.config.resourcepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'update',
      {
        directory:dir,
        resourcepath:this.config.resourcepath,
        filename:currentFile.fullname,
        content:content,
        completepath:this.config.completepath
      },
      'post'
    ).then(
      //success
      function(response) {
        onSuccess(response);
      },
      //fail
      function(response) {
        this.onError(response);
      }
    );
  }
  
  , doRenameFile: function( directory,currentFile,onSuccess,onError) {
    var dir = directory == undefined ? "" : directory;
    //var baseurl = this.endpoint + "/rename?directory=" + dir + "&filename=" + currentFile.fullname + "&name=" + currentFile.name + "&resourcepath=" + this.config.resourcepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'rename',
      {
        directory:dir,
        resourcepath:this.config.resourcepath,
        filename:currentFile.fullname,
        name:currentFile.name,
        completepath:this.config.completepath
      },
      'post'
    ).then(
      //success
      function(response) {
        onSuccess(response);
      },
      //fail
      function(response) {
        this.onError(response);
      }
    );
  }
  
  , doNewFolder: function( directory,newfolder,onSuccess ) {
    var dir = directory == undefined ? "" : directory;
    //var baseurl = this.endpoint + "/addfolder?directory=" + dir + "&name=" + newfolder + "&resourcepath=" + this.config.resourcepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'addfolder',
      {
        directory:dir,
        resourcepath:this.config.resourcepath,
        name:newfolder,
        completepath:this.config.completepath
      },
      'post'
    ).then(
      //success
      function(response) {
        onSuccess(response);
      },
      //fail
      function(response) {
        onError(response);
      }
    );
  }
  
  , loadDirectory: function( directory,pageindex,onSuccess,onError,filterResults,sortOn,sortDir,itemsper ) {
    var self = this;
  
    var dir = directory == undefined ? "" : directory;
  
    var baseurl = this.endpoint + "browse?directory=" + dir + "&resourcepath=" + this.config.resourcepath + "&completepath=" + this.config.completepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    if(pageindex) {
      baseurl += "&pageindex=" + pageindex;
    }
  
    if(itemsper) {
      baseurl += "&itemsperpage=" + itemsper;
    }
  
    if(filterResults.length) {
      baseurl += "&filterResults=" + filterResults;
    }
  
    Mura.get( baseurl )
      .then(
        //success
        function(response) {
          onSuccess(response);
        },
        //fail
        function(response) {
          onError(response);
        }
      );
  }
  
  , loadBaseDirectory: function( onSuccess,onError,directory ) {
    var self = this;
  
    var dir = directory ? directory : this.config.directory;
  
    var baseurl = this.endpoint + "/browse" + "?resourcepath=" + this.config.resourcepath + "&directory=" + dir + "&settings=1&completepath=" + this.config.completepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    Mura.get( baseurl )
      .then(
        //success
        function(response) {
          onSuccess(response, directory);
        },
        //fail
        function(response) {
          onError(response);
        }
      );
  }
  
  , doUpload: function( formData,success,fail ) {
    var self = this;
    //var baseurl = this.endpoint + "/upload" + "?resourcepath=" + this.config.resourcepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    formData.append('resourcepath',this.config.resourcepath);
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'upload',
      formData,
      'post'
    ).then(
      function doSuccess( response ) {
        success( response, fail );
      },
      function doonError( response ) {
        this.onError(response);
      }
    );
  }
  , rotate: function( currentFile,direction,success,error) {
    var self = this;
    //var baseurl = this.endpoint + "rotate" + "?resourcepath=" + this.config.resourcepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    var formData = {};
  
    formData.file = JSON.parse(JSON.stringify(currentFile));
    formData.direction = direction;
    formData.resourcepath=this.config.resourcepath;
    formData.completepath=this.config.competepath;
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'rotate',
      formData,
      'post'
    ).then(
      function doSuccess( response ) {
        success( response );
      },
      function doonError( response ) {
        this.onError(response);
      }
    );
  
  }
  
  , performResize: function( currentFile,dimensions,success,error ) {
    var self = this;
    //var baseurl = this.endpoint + "resize" + "?resourcepath=" + this.config.resourcepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    var formData = {};
  
    formData.file = JSON.parse(JSON.stringify(currentFile));
    formData.dimensions = dimensions;
    formData.resourcepath=this.config.resourcepath;
    formData.completepath=this.config.competepath;
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'resize',
      formData,
      'post'
    ).then(
      function doSuccess( response ) {
        success( response );
      },
      function doonError( response ) {
        this.onError(response);
      }
    );
  }
  
  , doSaveImage: function( currentFile,formData,success,error ) {
    var self = this;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    formData.append('file',JSON.stringify(currentFile));
    formData.append('resourcepath',this.config.resourcepath);
    formData.append('completepath',this.config.completepath);
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'saveImage',
      formData,
      'post'
    ).then(
      function doSuccess( response ) {
        success( response );
      },
      function doonError( response ) {
        this.onError(response);
      }
    );
  }
  
  
  , performCrop: function( currentFile,success,error ) {
    var self = this;
    //var baseurl = this.endpoint + "processCrop" + "?resourcepath=" + this.config.resourcepath;
  
    if(!this.validate()) {
      return error("No Access");
    }
  
    var formData = {};
  
    // bounding container
    var container = document.getElementById('imagediv');
    // crop rect
    var cropRect = document.getElementById('croprectangle');
    // crop rect bounds
    var rect = cropRect.getBoundingClientRect();
    // original image dimensions
    var source = {
        width: currentFile.info.width,
        height: currentFile.info.height
    };
  
    // size of container
    var size = {
      width: container.clientWidth,
      height: container.clientHeight
    };
    // crop rect size
    var crop = {
        x: 0,
        y: 0,
        width: 0,
        height: 0
    };
  
    crop.x = cropRect.offsetLeft;
    crop.y = cropRect.offsetTop;
    crop.width = rect.width;
    crop.height = rect.height;
  
    formData.file = JSON.parse(JSON.stringify(currentFile));
    formData.crop = crop;
    formData.size = size;
  
    formData.resourcepath=this.config.resourcepath;
    formData.completepath=this.config.completepath;
  
    Mura.getEntity('filebrowser').invokeWithCSRF(
      'processCrop',
      formData,
      'post'
    ).then(
      function doSuccess( response ) {
        success( response );
      },
      function doonError( response ) {
        this.onError(response);
      }
    );
  }
  
  , crop: function( canvas,clear ) {
  
    if(clear == true) {
      var cropRect = document.getElementById('croprectangle');
      if(cropRect)
        cropRect.parentNode.removeChild(cropRect);
      return;
    }
  
    var corners = {
        x: 0,
        y: 0,
        startX: 0,
        startY: 0
    };
    var element = null;
  
    function setCornerPosition(e) {
        var ev = e || window.event; //Moz || IE
        var rect = canvas.getBoundingClientRect();
  
        if (ev.pageX) { //Moz
            if(e.target != document.getElementById('imagediv')) {
              corners.x = e.offsetX + e.target.offsetLeft;
              corners.y = e.offsetY + e.target.offsetTop;
            }
            else {
              corners.x = ev.offsetX;
              corners.y = ev.offsetY;
            }
        } else if (ev.clientX) { //IE
            corners.x = ev.offsetX;
            corners.y = ev.offsetY;
        }
      };
  
      canvas.onmousemove = function (e) {
        if (element !== null) {
          setCornerPosition(e);
  //        element.pointer = 'none';
          element.style.width = Math.abs(corners.x - corners.startX) + 'px';
          element.style.height = Math.abs(corners.y - corners.startY) + 'px';
          element.style.left = (corners.x - corners.startX < 0) ? corners.x + 'px' : corners.startX + 'px';
          element.style.top = (corners.y - corners.startY < 0) ? corners.y + 'px' : corners.startY + 'px';
        }
      }
  
      canvas.onmouseup = function( e ) {
        element = null;
        canvas.style.cursor = "default";
      }
  
      canvas.onmousedown = function (e) {
        if (element !== null) {
        }
        else {
          var cropRect = document.getElementById('croprectangle');
          if(cropRect)
            cropRect.parentNode.removeChild(cropRect);
  
          setCornerPosition(e);
          corners.startX = corners.x;
          corners.startY = corners.y;
  
          var rect = canvas.getBoundingClientRect();
  
          element = document.createElement('div');
          element.className = 'rectangle';
          element.id = 'croprectangle';
          element.style.width = Math.abs(corners.x - corners.startX) + 'px';
          element.style.height = Math.abs(corners.y - corners.startY) + 'px';
          element.style.left = (corners.x - corners.startX < 0) ? corners.x + 'px' : corners.startX + 'px';
          element.style.top = (corners.y - corners.startY < 0) ? corners.y + 'px' : corners.startY + 'px';
  
          canvas.appendChild(element);
          canvas.style.cursor = "crosshair";
        }
    }
  }
  
  , mountbrowser: function() {
    var self = this;
  
    Vue.directive('click-outside', {
      bind: function (el, binding, vnode) {
        el.clickOutsideEvent = function (event) {
          // here I check that click was outside the el and his childrens
          if (!(el == event.target || el.contains(event.target))) {
            // and if it did, call method provided in attribute value
            vnode.context[binding.expression](event);
          }
        };
        document.body.addEventListener('click', el.clickOutsideEvent)
      },
      unbind: function (el) {
        document.body.removeEventListener('click', el.clickOutsideEvent)
      },
    });
  
    Vue.component('contextmenu', {
      props: ["currentFile","menuy","menux"],
      template: `
      <div id="newContentMenu" class="addNew fileviewer-menu-pop" v-bind:style="{  'white-space': 'initial !important' }">
          <ul id="newContentOptions">
            <li v-if="checkIsFile() && checkSelectMode()"><a href="#" @click.prevent="selectFile()"><i class="mi-check"></i>Select</a></li>
            <li v-if="checkIsFile() && checkFileEditable()"><a href="#" @click.prevent="editFile()"><i class="mi-pencil"></i>Edit</a></li>
            <li v-if="checkIsFile() && checkImageType()"><a href="#" @click.prevent="viewFile()"><i class="mi-image"></i>View</a></li>
            <li v-if="checkIsFile() || checkImageType()"><a href="#" @click.prevent="moveFile()"><i class="mi-move"></i>Move</a></li>
            <li v-if="checkIsFile() || checkImageType()"><a href="#" @click.prevent="duplicateFile()"><i class="mi-copy"></i>Duplicate</a></li>
            <li v-if="checkIsFile() || checkImageType()"><a href="#" @click.prevent="copyUrl()"><i class="mi-copy"></i>CopyUrl</a></li>
            <li><a href="#" @click.prevent="renameFile()"><i class="mi-edit"> Rename</i></a></li>
            <li v-if="checkIsFile()"><a href="#" @click="downloadFile()"><i class="mi-download"> Download</i></a></li>
            <li class="delete"><a href="#" @click.prevent="deleteFile()"><i class="mi-trash"> Delete</i></a></li>
          </ul>
        </div>
      `,
      data() {
          return {
            posx: 0,
            posy: 0
          };
      }
      , computed: {
  
      }
      , mounted: function() {
          if(window.gridMode) {
            //It is necessary to change the overflow property of the modal
            //because the contextmenu stays inside the modal and is not possible
            //to see all  options and we want to avoid that
            //******only when you deploy site bundle******
            if (document.getElementById('MuraFileBrowserContainer')){
              if (document.getElementById('MuraFileBrowserContainer').parentNode == document.getElementById('alertDialogMessage')) {
                var modal = document.getElementsByClassName('ui-dialog')[0];
                modal.style.overflow = 'initial';
              }
            }
  
            var a    = document.getElementById('fileitem-'+window.index);
            var div  = a.parentElement.parentElement.parentElement;
            div.style.overflow = 'visible';
            var menu = this.$el;
            menu.className = 'addNew fileviewer-menu-grid';
            div.appendChild(menu);
            var menuHeight = menu.getBoundingClientRect().height;
            var divBottom  = div.getBoundingClientRect().bottom;
            if( (divBottom + menuHeight ) > window.innerHeight ) {
              menu.style.bottom = '0px';
            }else {
              menu.style.top = div.getBoundingClientRect().height + 'px';
            }
  
          }else {
            var a        = document.getElementById('fileitem-'+window.index);
            var td       = a.parentElement;
            var tr       = td.parentElement;
            tr.className = 'fileviewer-selected-row';
            window.tr    = tr;
            var menu     = this.$el;
            td.appendChild(menu);
            var tdBottom   = td.getBoundingClientRect().bottom;
            var menuHeight = menu.getBoundingClientRect().height;
            var trHeight   = tr.getBoundingClientRect().height;
            if( (tdBottom + menuHeight ) > window.innerHeight ) {
              var bottom = trHeight ;
              menu.style.marginBottom = '0';
              menu.style.bottom =  bottom + 'px';
            }else {
              var height = trHeight;
              menu.style.top =  height + 'px';
  
            }
        }
      }, destroyed() {
        if(typeof window.tr !== 'undefined') {
          if(window.tr.nodeName === 'DIV') {
            window.tr.className = 'fileviewer-item-meta';
          }
        }
  
        if(window.gridMode) {
          var div = document.querySelector('.gridmode-wrapper')
          var menu = this.$el;
          menu.remove();
        }else {
          var div = document.querySelector('.listmode-wrapper')
          var menu = this.$el;
          menu.remove();
        }
      }
      , methods: {
        compstyle: function() {
          this.posx = this.menux;
          this.posy = this.menuy;
          return ;
        }
        , getTop: function() {
          return this.menuy + window.pageYOffset;
        }
       , selectFile: function() {
          if(MuraFileBrowser.config.selectMode == 1) {
            window.opener.CKEDITOR.tools.callFunction(self.callback,fileViewer.currentFile.url);
            window.close();
          }
          else {
            return MuraFileBrowser.config.selectCallback( fileViewer.currentFile );
          }
        }
        ,copyUrl: function() {
          var url = fileViewer.currentFile.url;
          var obj = document.createElement('textarea');
          obj.id = "::urlcopy";
  //        obj.style.cssText = 'display: none';
          document.getElementById("MuraFileBrowserContainer").appendChild(obj);
          var temp = document.getElementById("::urlcopy");
          temp.value = url;
          temp.select();
          document.execCommand("copy");
          temp.remove();
          fileViewer.isDisplayContext = "";
  //        console.log("Copied the text: " + temp.value);
  
  
        }
        , moveFile: function() {
          fileViewer.isDisplayWindow = "MOVE";
        }
        , editFile: function() {
          fileViewer.editFile(this.successEditFile);
        }
        , duplicateFile: function() {
          fileViewer.duplicateFile(fileViewer.refresh, fileViewer.displayError);
        }
        , viewFile: function() {
          fileViewer.isDisplayWindow = "VIEW";
          fileViewer.viewFile();
        }
        , successEditFile: function( response ) {
          this.currentFile.content = response.data.content;
          fileViewer.isDisplayWindow = "EDIT";
        }
        , renameFile: function() {
          fileViewer.isDisplayWindow = "RENAME";
        }
        , downloadFile: function() {
            window.open(fileViewer.currentFile.url, '_blank');
        }
        , deleteFile: function() {
          fileViewer.isDisplayWindow = "DELETE";
        }
        , checkSelectMode: function() {
            return fileViewer.checkSelectMode();
        }
        , checkFileEditable: function() {
            return fileViewer.checkFileEditable();
        }
        , checkImageType: function() {
          return fileViewer.checkImageType();
        }
        , checkIsFile: function() {
          return fileViewer.checkIsFile();
        }
      }
    });
  
    Vue.component('actionwindow', {
      props: ["isDisplayWindow","foldertree","currentFile","currentIndex","error"],
      template: `
        <div>
          <div id="actionwindow-wrapper" class="editwindow" v-if="isDisplayWindow=='EDIT'">
            <editwindow v-if="isDisplayWindow=='EDIT'" :currentFile="currentFile"></editwindow>
          </div>
          <div v-else id="actionwindow-wrapper">
            <renamewindow v-if="isDisplayWindow=='RENAME'" :currentFile="currentFile"></renamewindow>
            <movewindow v-if="isDisplayWindow=='MOVE'" :foldertree="foldertree" :currentFile="currentFile"></movewindow>
            <addfolderwindow v-if="isDisplayWindow=='ADDFOLDER'" :currentFile="currentFile"></addfolderwindow>
            <downloadwindow v-if="isDisplayWindow=='DOWNLOAD'" :currentFile="currentFile"></downloadwindow>
            <deletewindow v-if="isDisplayWindow=='DELETE'" :foldertree="foldertree" :currentFile="currentFile"></deletewindow>
            <errorwindow v-if="isDisplayWindow=='ERROR'" :currentFile="currentFile" :error="error"></errorwindow>
          </div>
        </div>
      `,
      data() {
          return {};
      },
      methods: {
      }
    });
  
    Vue.component('movewindow', {
      props: ["currentFile","foldertree"],
      template: `
      <div class="ui-dialog dialog-info actionwindow-formwrapper actionwindow-long">
        <div class="block block-constrain">
          <div class="block-content">
            <div class="mura-header">
              <h1>Move File</h1>
            </div>
            <div class="mura-control-group">
              <label>Name: <span>{{currentFile.fullname}}</span></label>
              <label>Location: <span>{{this.$root.resourcepath}}</span><span v-for="(item, index) in foldertree"> / {{item}}</span> </label>
            </div>
            <div class="mura-control-group">
              <label>
                Move to:
                <span><a @click="setDirDepth(-1)" class="folder-item">{{this.$root.resourcepath}}</a></span>
                  <span v-for="(item,index) in sourcefolders" @click="setDirDepth(index)"> / <a class="folder-item">{{item}}</a></span>
                <span>
                  <select v-if="childFolders.length" v-model="folderName">
                    <option v-if="item.length" v-for="item in childFolders" :value="item">/{{item}}</option>
                  </select>
                </span>
              </label>
            </div>
  <!--
            <div class="mura-control-group">
              <label>
                Destination:
                <input type="text" v-model="destinationFolder" style="width: 80%"></input>
                <span class="small">{{invalid}}</span>
              </label>
            </div>
  -->
            <div class="buttonset">
              <button @click="moveFile()"><i class="mi-check"></i>Move</button>
              <button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>Cancel</button>
            </div>
          </div>
        </div>
      </div>
      `,
      data() {
          return {
            resourcename: '',
            folderName: '',
            sourcefolders: [],
            childFolders: [],
            invalid: ''
          };
      },
      watch: {
        /*
        destinationFolder: function(val) {
          // delay for typing
          setTimeout(() => {
            var tf = this.destinationFolder;
  
            if(val == tf && this.folderPath != '')
              MuraFileBrowser.getChildDirectory(this.destinationFolder,this.updateDirectory,fileViewer);
            }, 1000);
        }
        ,
        */
        folderName: function(val) {
          if(this.folderPath != '') {
            this.sourcefolders.push(this.folderName);
  
            var destination = "";
  
            for(i in this.sourcefolders) {
              destination += "/" + this.sourcefolders[i];
            }
            this.childFolders = [];
            MuraFileBrowser.getChildDirectory(destination,this.updateDirectory,fileViewer);
          }
        }
      },
      methods: {
        moveFile: function() {
          var source = "";
          var destination = "";
  
          for(i in fileViewer.foldertree) {
            source += "/" + fileViewer.foldertree[i];
          }
  
          for(i in this.sourcefolders) {
            destination += "/" + this.sourcefolders[i];
          }
  
          fileViewer.spinnermodal = 1;
          MuraFileBrowser.moveFile(this.currentFile,source,destination,this.fileMoved);
        }
        , fileMoved: function() {
          fileViewer.isDisplayWindow = '';
          fileViewer.refresh();
        }
        , updateDirectory: function(result) {
          if(parseInt(result.data.valid)) {
            this.invalid = "";
            this.childFolders = result.data.folders;
          }
          else {
            this.childFolders = [];
            this.invalid = "(This does not appear to be a valid directory)";
          }
        }
        , setDirDepth: function(val) {
          val +=1;
          this.sourcefolders.length = val;
          var destination = "";
  
          for(i in this.sourcefolders) {
            destination += "/" + this.sourcefolders[i];
          }
          this.childFolders = [];
          MuraFileBrowser.getChildDirectory(destination,this.updateDirectory,fileViewer);
        }
        , cancel: function() {
          fileViewer.isDisplayWindow = '';
        }
      },
      mounted: function() {
        this.sourcefolders = this.foldertree.slice(0);
  
        this.filename = this.currentFile.name;
        fileViewer.isDisplayContext = 0;
  
        var destination = "";
  
        for(i in this.sourcefolders) {
          destination += "/" + this.sourcefolders[i];
        }
  
        MuraFileBrowser.getChildDirectory(destination,this.updateDirectory,fileViewer);
  
        switch(MuraFileBrowser.config.resourcepath) {
          case "Site_Files":
            this.resourcename = "Site Files";
            break;
          case "Application_Root":
            this.resourcename = "Application Root";
            break;
          default:
            this.resourcename = "User Assets";
        }
  
  
      }
    });
  
    Vue.component('renamewindow', {
      props: ["currentFile"],
      template: `
        <div class="ui-dialog dialog-info actionwindow-formwrapper">
          <div class="block block-constrain">
            <div class="block-content">
              <div class="mura-header">
                <h1 v-if="parseInt(currentFile.isfolder)">Rename Folder</h1>
                <h1 v-else>Rename File</h1>
              </div>
              <div class="mura-control-group">
                <label v-if="parseInt(currentFile.isfolder)">Folder Name: <span>{{currentFile.name}}</span></label>
                <label v-else>Filename: <span>{{currentFile.name}}</span><span v-if="currentFile.ext != currentFile.name">.{{currentFile.ext}}</span></label>
                <label v-if="parseInt(currentFile.isfolder)">New Name: <span><input type="text" v-model="filename"></input></span></label>
                <label v-else>New Name: <input type="text" v-model="filename"></input><span v-if="currentFile.ext != currentFile.name">.{{currentFile.ext}}</span></label>
                <em class="mura-input-error" v-if="error.length > 0">{{error}}</em>
              </div>
              <div class="buttonset">
                <button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>Cancel</button>
                <button @click="updateRename()"><i class="mi-check"></i>Save</button>
              </div>
            </div>
          </div>
        </div>
      `,
      data() {
          return {
            filename: '',
            error:'',
          };
      },
      methods: {
        updateRename() {
          this.error = '';
  
          this.filename = this.filename.trim();
          if (!this.filename.length){
            this.error = 'File name cannot be empty';
            return;
          }
  
          if (this.filename.indexOf('.') == 0){
            this.error = 'File name cannot start with a dot "."';
            return;
          }
  
          this.currentFile.name = this.filename;
          fileViewer.renameFile();
  
          fileViewer.isDisplayWindow = '';
        }
        , cancel: function() {
          fileViewer.isDisplayWindow = '';
        }
      },
      mounted: function() {
        this.filename = this.currentFile.name;
        fileViewer.isDisplayContext = 0;
      }
    });
  
    Vue.component('errorwindow', {
      props: ['error'],
      template: `
        <div class="ui-dialog dialog-warning actionwindow-formwrapper">
          <div class="block block-constrain">
            <div class="block-content">
              <div class="mura-header">
                <h1>Error</h1>
              </div>
              <div class="mura-control-group">
                <label>{{error}}</label>
              </div>
              <div class="buttonset">
                <button @click="cancel()"><i class="mi-close"></i>Close</button>
              </div>
            </div>
          </div>
        </div>
      `,
      data() {
          return {
            filename: ''
          };
      },
      methods: {
        cancel: function() {
          fileViewer.isDisplayWindow = '';
        }
      }
    });
  
    Vue.component('addfolderwindow', {
      props: ["currentFile"],
      template: `
        <div class="ui-dialog dialog-info actionwindow-formwrapper">
          <div class="block block-constrain">
            <div class="block-content">
              <div class="mura-header">
                <h1>Add Folder</h1>
              </div>
              <div class="mura-control-group">
                <label>Folder Name: <span><input type="text" v-model="foldername"></input></span></label>
              </div>
              <div class="buttonset">
                <button @click="newFolder()"><i class="mi-check"></i>Save</button>
                <button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>Cancel</button>
              </div>
            </div>
          </div>
        </div>
      `,
      data() {
          return {
            foldername: ''
          };
      },
      methods: {
        newFolder: function() {
          fileViewer.newFolder(this.foldername);
  
          fileViewer.isDisplayWindow = '';
        }
        , cancel: function() {
          fileViewer.isDisplayWindow = '';
        }
      },
      mounted: function() {
  
      }
    });
  
    Vue.component('gallerywindow', {
      props: ["currentFile","currentIndex","total"],
      template: `
      <div class="fileviewer-modal" v-if="currentFile.ext.toLowerCase()=='svg' || currentFile.info.width">
        <div class="fileviewer-gallery" v-click-outside="closewindow">
          <div class="fileviewer-image" :style="{ 'background-image': 'url(' + encodeURI(currentFile.url) + '?' + Math.ceil(Math.random()*100000) + ')','background-size': currentFile.backgroundSize }"></div>
          <div class="actionwindow-left" @click="lastimage"><i class="mi-caret-left"></i></div>
          <div class="actionwindow-right" @click="nextimage"><i class="mi-caret-right"></i></div>
          <div class="fileviewer-gallery-menu mura-actions">
            <label class="fileinfo">{{currentFile.fullname}} ({{currentFile.size}}kb <span v-if="checkImageType()">{{currentFile.info.width}}x{{currentFile.info.height}}</span>)</label>
            <div class="form-actions">
              <a v-if="checkImageType() && checkSelectMode()" class="btn mura-primary" @click="selectFile()"><i class="mi-check"></i>Select</a>
              <a v-if="checkImageType() && currentFile.ext.toLowerCase() !='svg'" class="btn mura-primary" @click="editImage()"><i class="mi-crop"></i>Edit Image</a>
              <a v-if="checkFileEditable()" class="btn mura-primary" @click="editFile()"><i class="mi-pencil"></i>Edit</a>
              <a class="btn mura-primary" @click="renameFile()"><i class="mi-edit"></i>Rename</a>
              <a v-if="checkIsFile()" class="btn mura-primary" @click="downloadFile()"><i class="mi-download"></i>Download</a>
              <a class="btn" @click="deleteFile()"><i class="mi-trash"></i>Delete</a>
              <a class="btn" @click="closewindow()"><i class="mi-times"></i>Close</a>
            </div>
          </div>
        </div>
      </div>
      `,
      data() {
          return {};
      }
      , mounted: function() {
  
        if(fileViewer.checkImageType() && fileViewer.currentFile.ext.toLowerCase()!='svg' && typeof fileViewer.currentFile.info.width == 'undefined'){
          var dir = "";
         
          for(var i=0;i<fileViewer.foldertree.length;i++) {
            dir = dir + "/" + fileViewer.foldertree[i];
          }
  
          console.log("DEETS");
          console.log(dir);
          console.log(fileViewer.currentFile);
  
          Mura.getEntity('filebrowser').invoke(
            'getImageInfo',
            {
              directory:dir,
              resourcepath:MuraFileBrowser.config.resourcepath,
              filename:fileViewer.currentFile.fullname
            }).then(function(info){
              fileViewer.currentFile.info=info;
              fileViewer.adjustImage();
            })
        }
    
        this.$root.isDisplayContext = 0;
       
      }
      , methods: {
        lastimage: function() {
          fileViewer.previousFile(1);
        }
        , nextimage: function() {
          fileViewer.nextFile(1);
        }
        , closewindow: function( event ) {
          this.$root.isDisplayWindow = "";
        }
        , renameFile: function() {
          fileViewer.isDisplayWindow = "RENAME";
        }
        , editImage: function() {
          fileViewer.isDisplayWindow = "EDITIMAGE";
        }
        , selectFile: function() {
           if(MuraFileBrowser.config.selectMode == 1) {
             window.opener.CKEDITOR.tools.callFunction(self.callback,fileViewer.currentFile.url);
             window.close();
           }
           else {
             return MuraFileBrowser.config.selectCallback( fileViewer.currentFile );
           }
         }
        , downloadFile: function() {
            window.open(fileViewer.currentFile.url, '_blank');
        }
        , deleteFile: function() {
          fileViewer.isDisplayWindow = "DELETE";
        }
        , checkSelectMode: function() {
            return fileViewer.checkSelectMode();
        }
        , checkFileEditable: function() {
            return fileViewer.checkFileEditable();
        }
        , checkImageType: function() {
          return fileViewer.checkImageType();
        }
        , checkIsFile: function() {
          return fileViewer.checkIsFile();
        }
  
      }
    });
  
    Vue.component('imageeditwindow', {
      props: ["currentFile","currentIndex","total","settings"],
      template: `
      <div class="fileviewer-modal">
        <imageeditmenu class="fileviewer-gallery" :settings="settings" :currentFile="currentFile" :currentIndex="currentIndex" v-click-outside="closewindow"></imageeditmenu>
      </div>
      `, data() {
        return {
        };
      }
      , mounted: function() {
      }
      , methods: {
        closewindow: function( event ) {
          this.$root.isDisplayWindow = "";
        }
      }
    });
  
    Vue.component('imageeditmenu', {
      props: ["currentFile","currentIndex","imageEditTarget","settings"],
      template: `
         <div>
         <div v-if="this.editmode  == 'RESIZE'" class="fileviewer-image" id="imagediv" :style="{ 'background-image': 'url(' + encodeURI(currentFile.url) + '?' + Math.ceil(Math.random()*100000) + ')' }"></div>
         <div v-if="this.editmode == ''" class="fileviewer-image-edit"><img style="min-height: 100%" id="fileviewer-image-editable" :src="currentFile.url"></div>
          <div class="fileviewer-edit-menu mura-actions">
            <label class="fileinfo">{{currentFile.fullname}} ({{currentFile.size}}kb {{currentFile.info.width}}x{{currentFile.info.height}})</label>
            <!-- MAIN -->
            <div class="form-actions" v-if="editmode==''">
  
              <a class="btn mura-primary" @click="resize()"><i class="mi-expand"></i>Resize</a>
              <a class="btn mura-primary" @click="saveImage()"><i class="mi-check"></i>Confirm</a>
              <a class="btn" @click="cancel()"><i class="mi-ban"></i>Cancel</a>
  
              <div class="form-actions-toolbar">
  
                <div class="btn-group d-flex flex-nowrap">
                  <a class="btn mura-primary" title="Zoom In" @click="zoomIn()"><i class="mi-search-plus"></i></a>
                  <a class="btn mura-primary" title="Zoom Out" @click="zoomOut()"><i class="mi-search-minus"></i></a>
                  <a class="btn mura-primary" title="Rotate Right" @click="rotateRight()"><i class="mi-rotate-right"></i></a>
                  <a class="btn mura-primary" title="Rotate Left" @click="rotateLeft()"><i class="mi-rotate-left"></i></a>
                </div>
  
                <div class="btn-group d-flex flex-nowrap">
                  <a class="btn mura-primary" title="Move" @click="moveMode()"><i class="mi-move"></i></a>
                  <a class="btn mura-primary" title="Crop" @click="cropMode()"><i class="mi-crop"></i></a>
                </div>
  
                <div class="btn-group d-flex flex-nowrap">
                  <label v-for="aspect in settings.aspectratios" class="btn mura-primary" title="Aspect Ratio: {{aspect[0]}} / {{aspect[1]}}" :class="{ 'active': cropaspect == aspect[2] }">
                    <input type="radio" class="sr-only" id="cropaspect1" name="cropaspect" v-model="cropaspect" :value="aspect[2]">
                    <span class="docs-tooltip" data-toggle="tooltip" title="" data-original-title="aspectRatio: {{aspect[0]}} / {{aspect[1]}}">
                      {{aspect[0]}}:{{aspect[1]}}
                      </label>
                    </span>
                  </label>
                  <label class="btn mura-primary" title="Aspect Ratio: Fixed" :class="{ 'active': cropaspect == fixedwidth }">
                    <input type="radio" class="sr-only" id="cropaspect5" name="cropaspect" v-model="cropaspect" :value="fixedwidth">
                    <span class="docs-tooltip" data-toggle="tooltip" title="" data-original-title="aspectRatio: Fixed">
                      Fixed
                    </span>
                  </label>
                  <label class="btn mura-primary" title="Aspect Ratio: Free" :class="{ 'active': cropaspect == NaN }">
                    <input type="radio" class="sr-only" id="cropaspect5" name="cropaspect" v-model="cropaspect" value="NaN">
                    <span class="docs-tooltip" data-toggle="tooltip" title="" data-original-title="aspectRatio: Free">
                      Free
                    </span>
                  </label>
                </div>
              </div> <!-- /.form-actions-toolbar -->
  
            </div>
            <!-- RESIZE -->
            <div class="form-actions" v-if="editmode=='RESIZE'">
              <label>Width: <input class="numeric" :disabled="resizedimensions.aspect == 'height'" name="resize-width" @keyup="changedAspectWidth" v-model="resizedimensions.width"></label>
              <label>Height: <input class="numeric" :disabled="resizedimensions.aspect == 'width'" name="resize-height" @keyup="changedAspectHeight" v-model="resizedimensions.height"></label>
              <label>Aspect:
                <select name="resize-aspect" v-model="resizedimensions.aspect" @change="changedAspect">
                  <option value="none">None</option>
                  <option value="height">Height</option>
                  <option value="width">Width</option>
                  <option value="within">Within</option>
                </select>
              </label>
              <a class="btn mura-primary" @click="confirmResize()"><i class="mi-check"></i>Confirm</a>
              <a class="btn" @click="cancelResize()"><i class="mi-ban"></i>Cancel</a>
            </div>
          </div>
          <div class="preview-window" v-if="this.showpreview">
            <div class="preview-mast"></div>
            <div class="preview-image">
            </div>
          </div>
        </div>
      `
      , data() {
          return {
            editmode: '',
            resizedimensions: {
              width: 0,
              height: 0,
              backup: 0,
              aspect: 'none',
            },
            showpreview: 0,
            cropaspect: "4:3",
            fixedwidth: 1
          };
      }
      , watch: {
        cropaspect: function( val ) {
          this.setAspectRatio(val);
        }
      }
      , mounted: function() {
        this.resizedimensions.width = this.currentFile.info.width;
        this.resizedimensions.height = this.currentFile.info.height;
        this.$root.isDisplayContext = 0;
        this.editmode = '';
        this.fixedwidth = Math.ceil( this.currentFile.info.width / this.currentFile.info.height * 10000 ) / 10000;
        this.initCropper();
  
      }
      , methods: {
        updateData( data ) {
          this.imageEditCropMode = data;
        }
        , changedAspect: function() {
        }
        , changedAspectWidth: function() {
          if(this.resizedimensions.aspect == 'width' && this.resizedimensions.width > 0) {
            this.resizedimensions.height = Math.ceil(this.resizedimensions.width/this.currentFile.info.width * this.currentFile.info.height);
          }
        }
        , changedAspectHeight: function() {
          if(this.resizedimensions.aspect == 'height' && this.resizedimensions.height > 0) {
            this.resizedimensions.width = Math.ceil(this.resizedimensions.height/this.currentFile.info.height * this.currentFile.info.width);
          }
        }
        , destroyCropper: function() {
          imageEditTarget.destroy();
        }
        , initCropper: function() {
          const image = document.getElementById('fileviewer-image-editable');
          var initaspect = this.cropaspect;
  
          imageEditTarget = new Cropper(image, {
            aspectRatio: initaspect,
            crop(event) {
              /*
              console.log(event.detail.x);
              console.log(event.detail.y);
              console.log(event.detail.width);
              console.log(event.detail.height);
              console.log(event.detail.rotate);
              console.log(event.detail.scaleX);
              console.log(event.detail.scaleY);
              */
    //          fileViewer.$refs.imageeditmenuref.updateData(event.detail.width);
            },
          });
        }
        , saveImage: function() {
          var self = this;
          var dir = "";
  
          for(var i=0;i<fileViewer.foldertree.length;i++) {
            dir = dir + "/" + fileViewer.foldertree[i];
          }
  
          imageEditTarget.getCroppedCanvas().toBlob(function(blob) {
            var newImg = document.createElement('img'),url = URL.createObjectURL(blob);
  
            newImg.onload = function() {
              // no longer need to read the blob so it's revoked
              URL.revokeObjectURL(url);
            };
  
            var formData = new FormData();
            formData.append('croppedImage', blob, self.currentFile.fullname);
            formData.append('dir', dir);
  
            newImg.src = url;
            MuraFileBrowser.doSaveImage( self.currentFile,formData,self.fileSaved );
          });
        }
        , fileSaved: function() {
          this.$root.isDisplayWindow = "VIEW";
          this.editmode = '';
          fileViewer.refresh();
        }
        , zoomIn: function() {
          imageEditTarget.zoom(0.1);
        }
        , zoomOut: function() {
          imageEditTarget.zoom(-0.1);
        }
        , setAspectRatio: function( val ) {
          imageEditTarget.setAspectRatio(val);
        }
        , rotateLeft: function() {
          imageEditTarget.rotate(-15);
        }
        , rotateRight: function() {
          imageEditTarget.rotate(15);
        }
        , resize() {
          this.editmode = "RESIZE";
          this.destroyCropper();
        }
        , cropMode: function() {
            imageEditTarget.setDragMode('crop');
        }
        , moveMode: function() {
          imageEditTarget.setDragMode('move');
        }
        , closewindow: function( event ) {
          this.$root.isDisplayWindow = "";
        }
        , cancel: function( event ) {
          this.destroyCropper();
          this.$root.isDisplayWindow = "VIEW";
          this.editmode = '';
        }
        , confirmResize() {
          MuraFileBrowser.performResize(this.currentFile,this.resizedimensions,this.resizeComplete);
        }
        , resizeComplete() {
          this.$root.refresh();
          this.$root.isDisplayWindow = "";
        }
        , cancelResize: function( event ) {
          this.editmode = '';
          this.$nextTick(function () {
            this.initCropper();
          });
        }
      }
    });
  
    Vue.component('deletewindow', {
      props: ["currentFile","foldertree"],
      template: `
      <div class="ui-dialog dialog-warning actionwindow-formwrapper">
        <div class="block block-constrain">
          <div class="block-content">
            <div class="mura-header">
              <h1 v-if="parseInt(currentFile.isfolder)">Delete Folder</h1>
              <h1 v-else>Delete File</h1>
            </div>
            <div class="mura-control-group">
              <label v-if="parseInt(currentFile.isfolder)">Are you sure you want to delete this folder?</label>
              <label v-else>Are you sure you want to delete this file?</label>
            </div>
            <div class="mura-control-group">
              <label v-if="parseInt(currentFile.isfolder)">Folder: <span>{{this.$root.resourcepath}}</span><span v-for="(item, index) in foldertree">/{{item}}</span>/<span>{{currentFile.fullname}}</span></label>
              <label v-else>File: <span>{{this.$root.resourcepath}}</span><span v-for="(item, index) in foldertree">/{{item}}</span>/<span>{{currentFile.fullname}}</span></label>
              <label>Modified: <span>{{currentFile.lastmodified.substring(0, currentFile.lastmodified.lastIndexOf(" ") )}}</span></label>
            </div>
            <div class="buttonset">
              <button @click="doDelete()"><i class="mi-check"></i>Delete</button>
              <button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>Cancel</button>
            </div>
          </div>
        </div>
      </div>
      `,
      data() {
          return {};
      },
      methods: {
        doDelete: function() {
          fileViewer.deleteFile(  fileViewer.refresh, fileViewer.displayError );
          fileViewer.isDisplayWindow = '';
        }
        , cancel: function() {
          fileViewer.isDisplayWindow = '';
        }
      },
      mounted() {
        fileViewer.isDisplayContext = 0;
      }
    });
  
    Vue.component('editwindow', {
      props: ["currentFile"],
      template: `
      <div class="ui-dialog dialog-nobg actionwindow-formwrapper">
        <div class="block block-constrain">
          <div class="block-content">
            <div class="mura-header">
              <h1>Edit File</h1>
            </div>
            <div class="mura-control-group">
              <label>Filename: <span>{{currentFile.name}}.{{currentFile.ext}}</span></label>
            </div>
            <textarea id="contenteditfield" class="editwindow" v-model="filecontent"></textarea>
            <div class="buttonset">
              <button @click="updateContent()"><i class="mi-check"></i>Update</button>
              <button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>Cancel</button>
            </div>
          </div>
        </div>
      </div>
      `,
      data() {
          return {
            filecontent: ''
          };
      },
      methods: {
        updateContent: function() {
          fileViewer.updateContent(this.filecontent);
          fileViewer.isDisplayWindow = '';
        }
        , cancel: function() {
          fileViewer.isDisplayWindow = '';
        }
        , selectAll: function() {
          editor.commands["selectAll"](this.editor);
        },
        autoFormat: function() {
          /*
          editor.setCursor(0,0);
          CodeMirror.commands["selectAll"](editor);
          editor.autoFormatRange(editor.getCursor(true), editor.getCursor(false));
          editor.setSize(500, 500);
          editor.setCursor(0,0);
          */
        }
      }
      , mounted: function() {
        this.filecontent = this.currentFile.content;
        /*
            editor = CodeMirror.fromTextArea(document.getElementById('contenteditfield'), {
            value: this.currentFile.content,
            mode:  "html",
            extraKeys: {"Ctrl-Space": "autocomplete"},
            lineNumbers: true,
            autoCloseTags: true,
            indentWithTabs: true,
            theme: 'monokai'
          }
        );
  
        editor.getDoc().setValue(this.currentFile.content);
        this.autoFormat();
        ed = this;
        editor.on('change', function(cm) {
          ed.filecontent = cm.getValue();
        });
  */
      }
    });
  
    Vue.component('appbar', {
      props: ["links","isbottomnav","response","itemsper","location","showbar"],
      template: `
        <div :class="[showbar ? 'filewindow-appbar' : 'filewindow-hideappbar']">
            <navmenu :links="links" :response="response" :itemsper="itemsper" :isbottomnav="isbottomnav"></navmenu>
            <modemenu v-if="location"></modemenu>
        </div>
      `,
      data: function() {
        return {
        }
      },
      computed: {
  
      },
      methods: {
        applyPage: function(goto) {
            var pageindex = 1;
  
            if(goto == 'last') {
              pageindex = parseInt(fileViewer.response.totalpages);
            }
            else if(goto == 'next') {
              pageindex = parseInt(fileViewer.response.pageindex) + 1;
            }
            else if(goto == 'previous') {
              pageindex = parseInt(fileViewer.response.pageindex) - 1;
            }
  
            this.$parent.refresh('',pageindex)
        }
        , applyItemsPer: function() {
          this.$parent.itemsper = this.itemsper;
        }
      }
  
    });
  
    Vue.component('modemenu', {
      props: ["links","isbottomnav","response","itemsper","displaymode"],
      template: `
          <div class="filewindow-modemenu">
            <div class="btn-group btn-group-toggle" data-toggle="buttons">
              <a class="btn btn-secondary" v-bind:class="{ highlight: viewmode == 1 }" @click="switchMode(1)">
                <i class="mi-th" title="Grid View"></i>
              </a>
              <a class="btn btn-secondary" v-bind:class="{ highlight: viewmode == 2 }" @click="switchMode(2)">
                <i class="mi-bars" title="List View"></i>
              </a>
            </div>
            <a @click="newFolder" class="btn btn-secondary">
              <i class="mi-folder" title="Add Folder"></i>
            </a>
            <input class="filebrowser-filter" placeholder="Type to filter" v-model="filterResults" v-on:input="filterChange">
            <select name="filter-depth">
              <option value="0">Folder</option>
              <option value="1">All</option>
            </select>
          </div>
      `,
      data() {
          return {
            viewmode: this.$root.displaymode,
            filterResults: '',
            timeout: undefined
          };
      },
      methods: {
        switchMode: function(mode) {
  
          var fdata = {
            displaymode: JSON.parse(JSON.stringify(mode))
          }
  
          Mura.createCookie('mura_fbdisplaymode',JSON.stringify(fdata),1000);
  
          this.$root.displaymode = this.viewmode = mode;
        }
        , newFolder: function() {
          fileViewer.isDisplayWindow = 'ADDFOLDER';
        }
        , filterChange: function(e,value) {
          // timeout to allow for typing and not fire immediately
          if(this.timeout)
            window.clearTimeout(this.timeout);
  
          this.$root.filterResults = this.filterResults;
          this.timeout = window.setTimeout(this.$root.refresh, 500);
        }
      }
  
    });
  
    Vue.component('navmenu', {
      props: ["links","isbottomnav","response","itemsper"],
      template: `
          <div class="filewindow-navmenu">
            <p v-if="isbottomnav">
            {{response.pageindex}} of {{response.totalpages}}
            </p>
          <ul class="pagination" v-if="response.totalitems>=25">
            <li class="paging" v-if="links && (links.previous || links.next)">
              <a href="#" v-if="links.first" @click.prevent="applyPage('first')">
                <i class="mi-angle-double-left"></i>
              </a>
              <a v-else class="disabled">
                <i class="mi-angle-double-left"></i>
              </a>
            </li>
            <li class="paging" v-if="links && (links.previous || links.next)">
              <a href="#" v-if="links.previous" @click.prevent="applyPage('previous')">
                <i class="mi-angle-left"></i>
              </a>
              <a v-else class="disabled">
                <i class="mi-angle-left"></i>
              </a>
            </li>
            <li class="paging" v-if="links && (links.previous || links.next)">
              <a href="#" v-if="links.next" @click.prevent="applyPage('next')">
                <i class="mi-angle-right"></i>
              </a>
              <a v-else class="disabled">
                <i class="mi-angle-right"></i>
              </a>
            </li>
            <li class="paging paging-last" v-if="links && (links.previous || links.next)">
              <a href="#" v-if="links.last" @click.prevent="applyPage('last')">
                <i class="mi-angle-double-right"></i>
              </a>
              <a v-else class="disabled">
                <i class="mi-angle-double-right"></i>
              </a>
            </li>
  
            <li class="pull-right">
              <select class="itemsper" @change="applyItemsPer" v-model="itemsper">
                <option value='25' :selected="itemsper == 25 ? 'selected' : null">25</option>
                <option value='50' :selected="itemsper == 50 ? 'selected' : null">50</option>
                <option value='100' :selected="itemsper == 100 ? 'selected' : null">100</option>
                <option value='9999' :selected="itemsper == 9999 ? 'selected' : null">All</option>
              </select>
            </li>
            <li class="pull-right"><label class="itemsper-label">View in groups of </label></li>
  
          </ul>
        </div>
      `,
      data() {
        return {}
      },
      methods: {
        applyPage: function(goto) {
            var pageindex = 1;
  
            if(goto == 'last') {
              pageindex = parseInt(fileViewer.response.totalpages);
            }
            else if(goto == 'next') {
              pageindex = parseInt(fileViewer.response.pageindex) + 1;
            }
            else if(goto == 'previous') {
              pageindex = parseInt(fileViewer.response.pageindex) - 1;
            }
  
            this.$root.refresh('',pageindex)
        }
        , applyItemsPer: function() {
          this.$root.itemsper = this.itemsper;
          this.$root.refresh();
        }
      }
  
    });
  
    Vue.component('listmode', {
      props: ['files','folders','foldertree','isDisplayContext','currentFile','settings'],
      template: `
        <div class="listmode-wrapper">
          <table class="mura-table-grid">
            <thead>
              <tr>
                <th class="actions">
                  <a v-if="foldertree.length" class="folder-back" href="#" @click.prevent="back()">
                    &nbsp;
                    <i class="mi-arrow-circle-o-left"></i>
                  </a>
                </th>
                <th class="var-width">{{settings.rb.filebrowser_filename}}</th>
                <th>{{settings.rb.filebrowser_size}}</th>
                <th>{{settings.rb.filebrowser_modified}}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="files.length==0">
                <td class="actions"></td>
                <td class="var-width">No Results</td>
                <td></td>
                <td></td>
              </tr>
              <tr v-for="(file,index) in files">
                <td class="actions">
                  <a href="#" :id="'fileitem-'+index" class="show-actions" @click.prevent="openMenu($event,file,index)"><i class="mi-ellipsis-v"></i></a>
                  <div class="actions-menu hide">
                    <ul class="actions-list">
                      <li class="edit"><a @contextmenu="openMenu($event,file,index)"><i class="mi-pencil"></i>View</a></li>
                    </ul>
                  </div>
                </td>
                <td class="var-width">
                  <a v-if="parseInt(file.isfile)" href="#" @click.prevent="viewFile(file,index)"><i v-if="parseInt(file.isimage)" class="mi-picture"></i><i v-else class="mi-file"></i> {{file.fullname}}</a>
                  <a v-else href="#" @click.prevent="refresh(file.name)"><i class="mi-folder"></i> {{file.fullname}}</a>
                </td>
                <td>
                  <div v-if="parseInt(file.isfile)">
                    {{file.size}}kb
                  </div>
                  <div v-else>
                    --
                  </div>
                </td>
                <td>
                    {{file.lastmodifiedshort}}
                </td>
              </tr>
  
            </tbody>
          </table>
          <contextmenu :currentFile="this.$parent.currentFile" :isDisplayContext="this.$root.isDisplayContext" v-if="isDisplayContext" :menux="menux" :menuy="menuy"></contextmenu>
        </div>`,
      data() {
        return {
          menux: 0,
          menuy: 0
        }
      }
      , mounted: function() {
        this.$root.isDisplayContext = 0;
      }
      , methods: {
        refresh: function( directory,index ) {
          this.$root.refresh( directory,index );
        }
        , displayError: function( e ) {
          this.$root.displayError( e );
        }
        ,back: function( ) {
          this.$root.back( );
        }
        , viewFile: function( file,index ) {
          this.$root.currentFile = file;
          this.$root.currentIndex = index;
  
          if(this.checkImageType(file,index)) {
            fileViewer.isDisplayWindow = "VIEW";
          }
          else if(this.checkFileEditable(file,index)) {
            fileViewer.editFile(this.successEditFile);
          }
        }
        , successEditFile: function( response ) {
          this.currentFile.content = response.data.content;
          fileViewer.isDisplayWindow = "EDIT";
        }
        , isViewable: function(file,index){
          this.$root.currentFile = file;
          this.$root.currentIndex = index;
          return fileViewer.isViewable();
        }
        , checkFileEditable: function(file,index) {
          this.$root.currentFile = file;
          this.$root.currentIndex = index;
          return fileViewer.checkFileEditable();
        }
        , checkImageType: function(file,index) {
          this.$root.currentFile = file;
          this.$root.currentIndex = index;
          return fileViewer.checkImageType();
        }
        , checkIsFile: function() {
          return fileViewer.checkIsFile();
        }
        , openMenu: function(e,file,index,ref) {
  
          if (typeof window.tr !== 'undefined' ) {
            window.tr.className = '';
          }
          window.index    = index;
          window.gridMode = false;
          // listmode actions menu
          this.$root.isDisplayContext = 0;
  
          var offsetLeft = 33;
          var offsetTop = 10;
  
          // offset positioning relative to parent 
          if (document.getElementById('MuraFileBrowserContainer')){
            if (document.getElementById('MuraFileBrowserContainer').parentNode == document.getElementById('alertDialogMessage')){
              offsetTop += 70;
              offsetLeft += Math.floor(document.getElementById('MuraFileBrowserContainer').getBoundingClientRect().left);
            }
          }
  
          var parentLeft = Math.floor(document.getElementById('fileitem-'+index).getBoundingClientRect().left);
          var parentTop =  Math.floor(document.getElementById('fileitem-'+index).getBoundingClientRect().top);
  
          var left = parentLeft - offsetLeft;
          var top = parentTop - offsetTop;
  
          //largest menu  height I found so far in pixels plus 10 px
          //also somehow it prints style top: ### with a different top value as local top's variable
          //const height = 520;
          //diff with the style
          //const height = 95;
          /*
          if( (top + height) > document.body.clientHeight ) {
            top = document.body.clientHeight - height;
            console.log('topp: '+top);
          }
  */
  
  
          this.$nextTick(function () {
            this.$root.isDisplayContext = 1;
          });
  
          this.$root.isDisplayWindow = '';
          this.$root.currentFile = file;
          this.$root.currentFile.index = index;
          this.$root.currentIndex = index;
          this.menux = left;
          this.menuy = top;
          e.preventDefault();
        }
      }
    });
  
    Vue.component('gridmode', {
      props: ['files','folders','foldertree','isDisplayContext','currentFile'],
      template: `
        <div class="gridmode-wrapper">
          <div v-if="foldertree.length" class="fileviewer-back fileviewer-item" @click="back()">
            <div class="fileviewer-item-icon">
              <i class="mi-arrow-circle-o-left"></i>
            </div>
          </div>
          <div v-for="(file,index) in files">
            <!-- files -->
            <div class="fileviewer-item" v-if="parseInt(file.isfile)">
              <div class="fileviewer-item-image">
                <!-- image -->
                <div v-if="parseInt(file.isimage)" class="fileviewer-item-icon" :style="{ 'background-image': 'url(' + encodeURI(file.url) + '?' + Math.ceil(Math.random()*100000) + ')' }" @click.prevent="viewFile(file,index)"></div>
                <!-- file with icon -->
                <div v-else class="fileviewer-item-icon" :class="['fileviewer-item-icon-' + file.type]" @click="openMenu($event,file,index)">
                  <i class="mi-file"></i>
                </div>
              </div>
              <div class="fileviewer-item-meta" @click="openMenu($event,file,index)">
                <div class="fileviewer-item-label">
                  {{file.fullname}}
                </div>
                <div class="fileviewer-item-meta-details">
                  <div v-if="parseInt(file.isfile)" class="fileviewer-item-meta-size">
                    {{file.size}}kb
                  </div>
                  <div class="fileviewer-item-meta-date">
                    {{file.lastmodifiedshort}}
                  </div>
                </div>
                <div class="fileviewer-item-actions">
                  <a href="#" :id="'fileitem-'+index" class="show-actions" @click="openMenu($event,file,index)"><i class="mi-ellipsis-v"></i></a>
                </div>
              </div>
            </div>
            <!-- folders -->
            <div class="fileviewer-item" v-else>
              <div class="fileviewer-item-icon" @click="refresh(file.name)">
                <i class="mi-folder-open"></i>
              </div>
              <div class="fileviewer-item-meta">
                <div class="fileviewer-item-label">
                  {{file.fullname}}
                </div>
                <div class="fileviewer-item-meta-details">
                  <div v-if="parseInt(file.isfile)" class="fileviewer-item-meta-size">
                    {{file.size}}kb
                  </div>
                </div>
                <div class="fileviewer-item-actions">
                  <a href="#" :id="'fileitem-'+index" class="show-actions" @click.prevent="openMenu($event,file,index)"><i class="mi-ellipsis-v"></i></a>
                </div>
              </div>
            </div>
          </div>
          <div class="clearfix"></div>
          <contextmenu :currentFile="this.$parent.currentFile" :isDisplayContext="isDisplayContext" v-if="isDisplayContext" :menux="menux" :menuy="menuy"></contextmenu>
        </div>`,
      data() {
        return {
            menux: 0,
            menuy: 0,
            offsetx: 0,
            offsety: 0
        }
      }
      , mounted: function() {
        this.$root.isDisplayContext = 0;
      }
      , methods: {
        refresh: function( directory,index ) {
          this.$root.refresh( directory,index );
        }
        , back: function( ) {
          this.$root.back( );
        }
  
        , viewFile: function( file,index ) {
          this.$root.currentFile = file;
          this.$root.currentIndex = index;
  
          if(this.checkImageType(file,index)) {
            fileViewer.isDisplayWindow = "VIEW";
          }
          else if(this.checkFileEditable(file,index)) {
            fileViewer.editFile(this.successEditFile);
          }
        }
        , checkFileEditable: function(file,index) {
          this.$root.currentFile = file;
          this.$root.currentIndex = index;
          return fileViewer.checkFileEditable();
        }
        , checkImageType: function(file,index) {
          this.$root.currentFile = file;
          this.$root.currentIndex = index;
          return fileViewer.checkImageType();
        }
        , checkIsFile: function() {
          return fileViewer.checkIsFile();
        }
        , successEditFile: function( response ) {
          this.currentFile.content = response.data.content;
          fileViewer.isDisplayWindow = "EDIT";
        }
        , openMenu: function(e,file,index) {
  
          window.index    = index;
          window.gridMode = true;
  
          // gridmode
          var offsetLeft = 0;
          var offsetTop = 10;
  
          // offset positioning relative to parent
          if (document.getElementById('MuraFileBrowserContainer')){
            if (document.getElementById('MuraFileBrowserContainer').parentNode == document.getElementById('alertDialogMessage')){
              offsetTop += 70;
              offsetLeft += Math.floor(document.getElementById('MuraFileBrowserContainer').getBoundingClientRect().left);
            }
          }
  
          this.menux = Math.floor(document.getElementById('fileitem-'+index).getBoundingClientRect().left) - 28 - offsetLeft;
          this.menuy = Math.floor(document.getElementById('fileitem-'+index).getBoundingClientRect().top) - offsetTop;
  
          this.$root.currentFile = file;
          this.$root.currentIndex = index;
  
          this.$root.isDisplayContext = 0;
  
          this.$nextTick(function () {
            this.$root.isDisplayContext = 1;
          })
  
          this.$root.isDisplayWindow = '';
          this.$root.currentFile = file;
          this.$root.currentFile.index = index;
          this.$root.currentIndex = index;
  
          e.preventDefault();
        }
  
      }
    });
  
    Vue.component('filewindow', {
      props: ['files','folders','foldertree','isDisplayContext','currentFile','settings','displaymode'],
      template: `
        <div class="filewindow-wrapper" id="mura-filewindow-wrapper">
          <gridmode v-if="displaymode==1" :currentFile="currentFile"   :foldertree="foldertree" :files="files" :folders="folders" :isDisplayContext="isDisplayContext"></gridmode>
          <listmode  v-if="displaymode==2" :settings="settings" :currentFile="currentFile" :foldertree="foldertree" :files="files" :folders="folders" :isDisplayContext="isDisplayContext"></listmode>
        </div>`,
      data() {
        return {};
      },
      methods: {
  
      }
    });
  
    Vue.component('spinner', {
      template: `
        <div id="spinner">
  
        </div>`,
      data() {
        return {};
      }
      , mounted: function() {
        $("#spinner").spin(null);
        if($('.ui-dialog-title').length){
					$('.mura-modal-only').remove();
				}
      }
      , destroyed:  function() {
        $("#spinner").spin(!1);
      }
      , methods: {
  
      }
    });
  
    const IS_START = 0, IS_SAVE = 1, IS_SUCCESS = 2, IS_FAIL = 3;
  
    var fileViewer = new Vue({
      el: "#" + self.target,
      template: `
        <div class="fileviewer-wrapper">
          <spinner v-if="spinnermodal"></spinner>
          {{message}}
          <gallerywindow v-if="isDisplayWindow=='VIEW'" :settings="settings" :currentFile="currentFile" :currentIndex="currentIndex"></gallerywindow>
          <imageeditwindow v-if="isDisplayWindow=='EDITIMAGE'" :settings="settings" :currentFile="currentFile" :currentIndex="currentIndex"></imageeditwindow>
          <actionwindow v-if="isDisplayWindow != ''" :foldertree="foldertree" :settings="settings" :isDisplayWindow="isDisplayWindow" :currentIndex="currentIndex" :currentFile="currentFile" :error="error"></actionwindow>
          <div class="mura-header">
            <h1 class="mura-modal-only">File Manager</h1>
            <ul class="breadcrumb">
              <li @click="setDirDepth(-1)"><a><i class="mi-home"></i>{{resourcepath}}</a></li>
              <li v-for="(item,index) in foldertree" @click="setDirDepth(index)"><a><i class="mi-folder-open"></i>{{item}}</a></li>
            </ul>
          </div>
          <div class="fileviewer-droptarget">
            <form enctype="multipart/form-data" novalidate v-if="isStart || isSave">
              <input type="file" multiple :name="uploadField" :disabled="isSave" @change="filesChanged($event.target.name, $event.target.files);" accept="*.*" class="file-input-field">
              <p v-if="isStart" class="upload-icon"><i class="mi-upload"></i>
                {{settings.rb.filebrowser_draghere}}
              </p>
              <p v-if="isSave" class="download-icon">
                {{settings.rb.filebrowser_uploading}} ({{fileCount}})
              </p>
            </form>
          </div>
          <appbar v-if="response.links" :showbar=1 :settings="settings" :location=1 :links="response.links" :itemsper="itemsper" :response="response"></appbar>
          <filewindow :settings="settings" :currentFile="currentFile" :isDisplayContext="isDisplayContext" :foldertree="foldertree" :files="files" :folders="folders" :displaymode="displaymode"></filewindow>
          <appbar v-if="response.links" :showbar=showfooter :settings="settings" :location=0 :links="response.links" :itemsper="itemsper" :response="response"></appbar>
        </div>`
      ,
      data: {
        currentView: 'fileviewer',
        currentState: null,
        currentFile: null,
        currentIndex: 0,
        foldertree: [],
        fileCount: 0,
        files: [],
        folders: [],
        spinnermodal: 0,
        error: "",
        showfooter: 0,
        settings: { rb: {} },
        displaymode: this.config.displaymode,
        uploadedFiles: [],
        isDisplayContext: 0,
        isDisplayWindow: '',
        uploadField: "uploadFiles",
        filterResults: '',
        sortOn: '',
        sortDir: 'ASC',
        itemsper: 25,
        message: '',
        editfilelist: self.editfilelist,
        resourcepath: this.config.resourcepath.replace('_',' '),
        response: {pageindex: 0}
      },
      ready: function() {
        console.log("ready: isDisplayContext",isDisplayContext);
      },
      computed: {
        isStart() {
          return this.currentState === IS_START;
        },
        isSave() {
          return this.currentState === IS_SAVE;
        },
        isSuccess() {
          return this.currentState === IS_SUCCESS;
        },
        isonError() {
          return this.currentState === IS_FAIL;
        }
      },
      methods: {
        updateDelete: function() {
            self.updateDelete(currentFile);
        }
        , updateContent: function( content ) {
          var dir = "";
  
          for(var i=0;i<this.foldertree.length;i++) {
            dir = dir + "/" + this.foldertree[i];
          }
  
          self.doUpdateContent( dir,this.currentFile,content,this.refresh );
        }
        , renameFile: function() {
          var dir = "";
  
          for(var i=0;i<this.foldertree.length;i++) {
            dir = dir + "/" + this.foldertree[i];
          }
          self.doRenameFile( dir,this.currentFile,this.refresh );
        }
        , newFolder: function(foldername) {
          var dir = "";
  
          for(var i=0;i<this.foldertree.length;i++) {
            dir = dir + "/" + this.foldertree[i];
          }
          self.doNewFolder( dir,foldername,this.refresh );
        }
        , updateEdit: function() {
            self.updateEdit(currentFile);
        }
        , displayResults: function(response, dir) {
          this.response = response.data
          this.files = response.data.items;
          this.folders = response.data.folders;
  
          if (dir && dir != response.data.directory){
            //clean folder tree cookie           
            const directories = response.data.directory.split('/').shift();
            this.$root.foldertree = directories && directories.length ? directories : [];
  
            var fdata = {
              siteid: Mura.siteid,
              foldertree: JSON.parse(JSON.stringify(this.foldertree)),
              itemsper: this.itemsper,
                        resourcepath: MuraFileBrowser.config.resourcepath
            }
    
            Mura.eraseCookie( 'mura_fbfolder');
            Mura.createCookie( 'mura_fbfolder',JSON.stringify(fdata));
          }
  
          if(response.data.settings) {
            this.settings = response.data.settings;
          }
          this.$nextTick(function () {
            this.spinnermodal = 0;
          });
  
          this.showfooter = this.response.totalpages-1;
  
        }
        , displayError: function( e ) {
          if(e.message) {
            this.message = message;
          }
        }
        ,adjustImage(){
          const windowWidth = window.innerWidth;
          const windowHeight = window.innerHeight;
          const marginTop = windowWidth * .005;
          const margintBottom = windowWidth * .03;
          const paddingTop = windowWidth * .02;
  
          fileViewer.currentFile.backgroundSize = fileViewer.currentFile.info.width < (windowWidth*.8) 
            && fileViewer.currentFile.info.height < (windowHeight*.8) - (paddingTop + marginTop + margintBottom) ? 'auto' : 'contain';
  
          console.log(fileViewer.currentFile.backgroundSize)
        }
        , previousFile( img ) {
          img = img ? img : 0;
          index = this.currentIndex;
  
          index--;
  
          if(index+1 <= 0) {
            return;
          }
  
          if(!parseInt(this.files[index].isfile)) {
            return;
          }
  
          this.currentFile = this.files[index];
          this.currentIndex = index;
          if(img && this.checkImageType() || !img) {
  
            if(this.currentFile.ext.toLowerCase()!='svg' && typeof fileViewer.currentFile.info.width == 'undefined'){
              var dir = "";
      
              for(var i=0;i<this.foldertree.length;i++) {
                dir = dir + "/" + this.foldertree[i];
              }
  
              this.spinnermodal = 1;
      
              console.log("DEETS 1");
              console.log(dir);
              console.log(fileViewer.currentFile);
      
  
              Mura.getEntity('filebrowser').invoke(
                'getImageInfo',
                {
                  directory:dir,
                  resourcepath:MuraFileBrowser.config.resourcepath,
                  filename:fileViewer.currentFile.fullname
                }).then((info) => {
                      this.spinnermodal = 0;
                      fileViewer.currentFile.info=info;
                      this.adjustImage();
                })
            }
  
            return;
          }
          else {
            this.previousFile(img);
          }
  
        }
        , nextFile( img ) {
          img = img ? img : 0;
          index = this.currentIndex;
  
          index++;
  
          if(index >= this.files.length) {
            return;
          }
  
          this.currentFile = this.files[index];
          this.currentIndex = index;
          if(img && this.checkImageType() || !img) {
  
            if(this.currentFile.ext.toLowerCase()!='svg' && typeof fileViewer.currentFile.info.width == 'undefined'){
              var dir = "";
      
              for(var i=0;i<this.foldertree.length;i++) {
                dir = dir + "/" + this.foldertree[i];
              }
  
              this.spinnermodal = 1;
  
              Mura.getEntity('filebrowser').invoke(
                'getImageInfo',
                {
                  directory:dir,
                  resourcepath:MuraFileBrowser.config.resourcepath,
                  filename:fileViewer.currentFile.fullname
                }).then((info) => {
                  this.spinnermodal = 0;
                  fileViewer.currentFile.info=info;
                  this.adjustImage();
                })
            }
  
            return;
          }
          else {
            this.nextFile(img);
          }
        }
        , upload: function() {
        }
        , uploadReset() {
          this.currentState = IS_START;
          this.uploadedFiles = [];
          this.error = null;
        }
        , setDirDepth: function( depth ) {
            this.foldertree = this.foldertree.slice(0,depth+1);
            this.refresh();
        }
        , editFile: function( onSuccess,onError ) {
          var dir = "";
  
          for(var i=0;i<this.foldertree.length;i++) {
            dir = dir + "/" + this.foldertree[i];
          }
  
          self.getEditFile(dir,this.currentFile,onSuccess);
  
        }
        , viewFile: function( direction ) {
        }
        , deleteFile: function( onSuccess, onError) {
          var dir = "";
  
          for(var i=0;i<this.foldertree.length;i++) {
            dir = dir + "/" + this.foldertree[i];
          }
  
          self.doDeleteFile(dir,this.currentFile,onSuccess,onError);
  
        }
        , duplicateFile: function( onSuccess, onError) {
          var dir = "";
  
          for(var i=0;i<this.foldertree.length;i++) {
            dir = dir + "/" + this.foldertree[i];
          }
  
          self.doDuplicateFile(dir,this.currentFile,onSuccess,onError);
  
        }
        , refresh: function( folder,pageindex,displaywindow ) {
          if(displaywindow) {
            this.isDisplayWindow = "";
            this.$nextTick(function () {
              this.$root.isDisplayWindow = displaywindow;
            });
          }
          else
            this.isDisplayWindow = '';
  
          if(folder && folder.length)
            this.foldertree.push(folder);
  
          var dir = "";
  
          isNaN(pageindex) ? 0 : pageindex;
  
          for(var i=0;i<this.foldertree.length;i++) {
            dir = dir + "/" + this.foldertree[i];
          }
          this.isDisplayContext = "";
          this.spinnermodal = 1;
  
          var fdata = {
            siteid: Mura.siteid,
            foldertree: JSON.parse(JSON.stringify(this.foldertree)),
            itemsper: this.itemsper,
            resourcepath: MuraFileBrowser.config.resourcepath
          }
  
          Mura.createCookie( 'mura_fbfolder',JSON.stringify(fdata));
  
          self.loadDirectory(dir,pageindex,this.displayResults,this.displayError,this.filterResults,this.sortOn,this.sortDir,this.itemsper,displaywindow);
        }
        , back: function() {
          this.foldertree.splice(-1);
          var folder = this.foldertree.length ? "" : this.foldertree[this.foldertree.length-1];
          this.refresh();
        }
        , closeMenu: function( e ) {
          this.isDisplayContext = 0;
          e.preventDefault();
        }
        , filesChanged: function(fieldName, fileList) {
          // handle file changes
  
          this.uploadedFiles = fileList;
  
          const formData = new FormData();
          const invalidFiles = new Array()
  
          var dir = "";
  
          if (!fileList.length) return;
  
          // append the files to FormData
  
          this.fileCount = fileList.length;
  
          Array
            .from(Array(fileList.length).keys())
            .map(x => {
              if (fileList[x].name.indexOf('.')!=0){
                formData.append(fieldName, fileList[x], fileList[x].name);
              }else {
                invalidFiles.push('"'+fileList[x].name+'"');
              }
            });
  
          for(var i=0;i<this.foldertree.length;i++) {
            dir = dir + "/" + this.foldertree[i];
          }
  
          formData.append("directory",dir);
  
          // save it
          this.save(formData, invalidFiles);
        }
        , save: function( formData, errors ) {
            this.currentState = IS_SAVE;
  
            self.doUpload( formData,this.saveComplete, errors );
        }
        , saveComplete: function(response, fail ) {
          this.uploadReset();
          this.refresh();
          if (fail.length){
            fileViewer.isDisplayWindow = 'ERROR'
            fileViewer.error = 'File names that start with a dot "." are not valid. The following file(s) were not uploaded ' +fail.join(',')
          }
        }
        , checkSelectMode: function() {
          return MuraFileBrowser.config.selectMode;
        }
        , isViewable: function() {
            var editlist = this.settings.editfilelist;
            var imagelist = this.settings.imagelist;
            for(var i = 0;i<editlist.length;i++) {
              if(this.currentFile.ext.toLowerCase() == editlist[i]) {
                return true;
              }
            }
            for(var i = 0;i<imagelist.length;i++) {
              if(this.currentFile.ext.toLowerCase() == imagelist[i]) {
                return true;
              }
            }
            return false;
        }
        , checkFileEditable: function() {
          var editlist = this.settings.editfilelist;
  
          for(var i = 0;i<editlist.length;i++) {
            if(this.currentFile.ext.toLowerCase() == editlist[i]) {
              return true;
            }
          }
          return false;
        }
        , checkImageType: function() {
          var imagelist = this.settings.imagelist;
            for(var i = 0;i<imagelist.length;i++) {
              if(this.currentFile.ext.toLowerCase() == imagelist[i]) {
                return true;
              }
            }
            return false;
        }
        , checkIsFile: function() {
  
          if(Math.floor(this.currentFile.isfile)) {
            return true;
          }
          return false;
        }
      },
      mounted: function() {
          this.uploadReset();
          this.$nextTick(function () {
            this.spinnermodal = 1;
          });
          this.selectMode = self.config.selectMode;
  // folder cookie
  
          var dir = "";
  
          var cFolder = Mura.readCookie( 'mura_fbfolder');
          if(cFolder) {
            try{
              var cFolderJSON = JSON.parse(cFolder);
  
              if(cFolderJSON.itemsper)
                this.itemsper = cFolderJSON.itemsper;
  
              if(cFolderJSON.resourcepath != self.config.resourcepath || cFolderJSON.siteid != mura.siteid) {
                var fdata = {
                  siteid: Mura.siteid,
                  foldertree: [],
                  itemsper: this.itemsper,
                  resourcepath: self.config.resourcepath
                }
                Mura.createCookie( 'fbFolderTree',JSON.stringify(fdata),1);
              }
              else if(cFolderJSON.foldertree) {
                this.$root.foldertree = cFolderJSON.foldertree;
  
                for(var i=0;i<this.foldertree.length;i++) {
                  dir = dir + "/" + this.foldertree[i];
                }
              }
            } catch(e){
              console.log("error reading cookie json:" + cFolderJSON);
              Mura.createCookie( 'fbFolderTree','',1);
            }
          }
  
  // displaymode cookie
          var cDisplay = Mura.readCookie( 'mura_fbdisplaymode' );
  
          if(cDisplay) {
            var fbDisplayJSON = JSON.parse(cDisplay);
  
            if(fbDisplayJSON.displaymode)
              this.$root.displaymode = this.viewmode = fbDisplayJSON.displaymode;
          }
  
          self.loadBaseDirectory(this.displayResults,this.displayError,dir);
  
          window.addEventListener('mouseup', function(event) {
  //        fileViewer.isDisplayContext = 0;
          });
          var vm = this;
      }
    });
  }
  
  };