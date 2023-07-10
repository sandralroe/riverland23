
window.Mura.preInit(function(){
    window.Mura.Module.Pdfviewer=Mura.UI.extend({
        renderClient:function(){
            var self=this;
            Mura.loader()
                .loadcss(Mura.rootpath +'/core/modules/v1/pdfviewer/assets/css/pdfviewer.css')
                .loadjs(Mura.rootpath + '/core/modules/v1/pdfviewer/dist/pdf.viewer.bundle.js',
                function(){
                    self._render();
                }
            )
        },

        _render:function(){
            this.context.pdfurl=this.context.pdfurl || '';

            if(!this.context.pdfurl){
                return;
            }
            // Setting worker path to worker bundle.
            pdfjsLib.GlobalWorkerOptions.workerSrc = Mura.rootpath + "/core/modules/v1/pdfviewer/dist/pdf.worker.bundle.js";

            var pdfDoc = null,
            pageNum = 1,
            pageRendering = false,
            pageNumPending = null,
            scale = 1,
            pdfurl=this.context.pdfurl,
            fullscreen=false,
            instanceid=this.context.instanceid,
            pdffilename=this.context.pdffilename || '';

            var playerHTML='';
   
            playerHTML += '<div class="pdf-btn-container"><button id="pdf-btn-'+instanceid+'" class="btn btn-primary" style="display:none;">Preparing download...</button></div>';
            playerHTML+='<div class="mura-pdfcontainer" id="mura-pdfcontainer-' + instanceid + '">';
            playerHTML+='<div class="mura-pdfcontrols" id="mura-pdfviewer-' + instanceid + '">';

            playerHTML+='<span class="mura-pdfcontrols-group" id="mura-pdfpaging-group-' + instanceid + '">';
            playerHTML+='<button class="mura-pdfprev" id="mura-pdfprev-' + instanceid + '">&lt;</button>';
            playerHTML+='<span class="mura-pdfpaging">';
            playerHTML+='<span id="mura-pdfpagenum-' + instanceid + '">1</span>/<span class="mura-pdfpagecount" id="mura-pdfpagecount-' + instanceid + '">1</span>';
            playerHTML+='</span>';   
            playerHTML+='<button class="mura-pdfnext" id="mura-pdfnext-' + instanceid + '">&gt;</button>';
            playerHTML+='</span>';

            playerHTML+='<span class="mura-pdfcontrols-group">';
            playerHTML+='<button class="mura-pdfzoomout" id="mura-pdfzoomout-' + instanceid + '">-</button>';
            playerHTML+='<span class="mura-pdfzoom"><span id="mura-pdfpagezoom-' + instanceid + '">100%</span></span>';
            playerHTML+='<button class="mura-pdfzoomin" id="mura-pdfzoomin-' + instanceid + '">+</button>';
            playerHTML+='</span>';

            playerHTML+='<span class="mura-pdfcontrols-group">';
            playerHTML+='<button class="mura-pdffullscreentoggle mura-pdffullscreenopen" id="mura-pdffullscreenopen-' + instanceid + '">Fullscreen</button>';
            playerHTML+='<button class="mura-pdffullscreentoggle mura-pdffullscreenclose" id="mura-pdffullscreenclose-' + instanceid + '">Exit Fullscreen</button>';
            playerHTML+='</span>';

            playerHTML+='<span class="mura-pdfcontrols-group">';
            playerHTML+='<button class="mura-pdfprintpdf" id="mura-pdfprintpdf-' + instanceid + '">Print</button>';
            playerHTML+='</span>';
            playerHTML+='</div>';
            playerHTML+='<div class="mura-pdfviewer" id="mura-pdfviewer-' + instanceid + '">';            
            playerHTML+='<div class="mura-pdfloader" id="mura-pdfloader-' + instanceid + '">';
            playerHTML+='loading pdf...';
            playerHTML+='</div>';
            playerHTML+='<canvas class="mura-pdfcanvas" id="mura-pdfcanvas-' + instanceid + '" style="display:none;"></canvas>';
            playerHTML+='</div>';
            playerHTML+='<div class="mura-pdfcontrols mura-pdfcontrols-bottom" id="mura-pdfviewer-' + instanceid + '">';
            playerHTML+='<button class="mura-pdfdownload" id="mura-pdfdownload-' + instanceid + '">Download</button>';
            playerHTML+='<span class="mura-pdfreadablebytes" id="mura-pdfreadablebytes-' + instanceid + '"></span>';
            playerHTML+='</div>';
            playerHTML+='</div>';

            this.context.targetEl.innerHTML=playerHTML;

            var ui={
                canvas: document.getElementById('mura-pdfcanvas-' + instanceid),
                loader: document.getElementById('mura-pdfloader-' + instanceid),
                pagezoom: document.getElementById('mura-pdfpagezoom-' + instanceid),
                zoomin: document.getElementById('mura-pdfzoomin-' + instanceid),
                zoomout: document.getElementById('mura-pdfzoomout-' + instanceid),
                nextpage: document.getElementById('mura-pdfnext-' + instanceid),
                prevpage: document.getElementById('mura-pdfprev-' + instanceid),
                pagenum: document.getElementById('mura-pdfpagenum-' + instanceid),
                pagecontrols: document.getElementById('mura-pdfpaging-group-' + instanceid),
                pagecount: document.getElementById('mura-pdfpagecount-' + instanceid),
                download: document.getElementById('mura-pdfdownload-' + instanceid),
                fullscreenopen: document.getElementById('mura-pdffullscreenopen-' + instanceid),
                fullscreenclose: document.getElementById('mura-pdffullscreenclose-' + instanceid),
                readablebytes: document.getElementById('mura-pdfreadablebytes-' + instanceid),
                print: document.getElementById('mura-pdfprintpdf-' + instanceid)
            };

            onResize();

            var canvas = ui.canvas,
            ctx = canvas.getContext('2d');

            /**
             * Get page info from document, resize canvas accordingly, and render page.
             * @param num Page number.
             */
            function renderPage(num) {
                pageRendering = true;
                // Using promise to fetch the page
                pdfDoc.getPage(num).then(function(page) {
                    var viewport = page.getViewport({scale: scale});
                    canvas.height = viewport.height;
                    canvas.width = viewport.width;

                    // Render PDF page into canvas context
                    var renderContext = {
                    canvasContext: ctx,
                    viewport: viewport
                    };

                    Mura(ui.loader).hide();
                    Mura(ui.canvas).show();
                    var renderTask = page.render(renderContext);

                    // Wait for rendering to finish
                    renderTask.promise.then(function() {
                    pageRendering = false;
                    if (pageNumPending !== null) {
                        // New page rendering is pending
                        renderPage(pageNumPending);
                        pageNumPending = null;
                    }
                    });
                });

                // Update page counters
                ui.pagenum.textContent = num;
            }

            /**
             * If another page rendering in progress, waits until the rendering is
             * finised. Otherwise, executes rendering immediately.
             */
            function queueRenderPage(num) {
                if (pageRendering) {
                    pageNumPending = num;
                } else {
                    renderPage(num);
                }
            }

            /**
             * Displays previous page.
             */
            function onPrevPage() {
                if (pageNum <= 1) {
                    return;
                }
                pageNum--;
                queueRenderPage(pageNum);
            }

            /**
             * Displays next page.
             */
            function onNextPage() {
                if (pageNum >= pdfDoc.numPages) {
                    return;
                }
                pageNum++;
                queueRenderPage(pageNum);
            }

            function onPageZoomIn() {
                scale+= .2;

                queueRenderPage(pageNum);

                ui.pagezoom.textContent= Math.round(100-(100 - (scale * 100))) + '%'; 
            }

            function onPageZoomOut() {
                scale-= .2;
                
                queueRenderPage(pageNum);

                ui.pagezoom.textContent= Math.round(100-(100 - (scale * 100))) + '%'; 
            }

            function getFilename(){
                var filename=pdffilename.toString();
                
                if(!filename){
                    filename=pdfurl.split('?')[0].split("/");
                    /*
                        if the filename ended in '/' 
                        the last index could be undefined
                    */
                    if(filename[filename.length-1]){
                        filename=filename[filename.length-1];
                    } else {
                        filename=filename[filename.length-2];
                    }
                }
                
                if(filename=='file' && location.pathname != '/'){
                    var filename=location.pathname.split("/");

                    if(filename[filename.length-1]){
                        filename=filename[filename.length-1];
                    } else {
                        filename=filename[filename.length-2];
                    }
                }
                
                const filenameparts=filename.split('.');

                if(filenameparts[filenameparts.length-1] != 'pdf'){
                    filename += '.pdf';
                }
                return filename;
                
            }

            function onDownload(){
                pdfDoc.getData().then(function(arrayBuffer) {
                     // Create an invisible A element
                    const a = document.createElement("a");
                    a.style.display = "none";
                    document.body.appendChild(a);
                    
                    // Set the HREF to a Blob representation of the data to be downloaded
                    a.href = window.URL.createObjectURL(
                        new Blob([arrayBuffer], { type:"application/pdf" })
                    );

                    // Use download attribute to set set desired file name
                    a.setAttribute("download", getFilename());
                    
                    // Trigger the download by simulating click
                    a.click();
                    
                    // Cleanup
                    window.URL.revokeObjectURL(a.href);
                    document.body.removeChild(a);

                });
            }
            
            /* View in fullscreen */
            function openFullscreen() {
                var elem = document.getElementById('mura-pdfcontainer-' + instanceid);
                if (elem.requestFullscreen) {
                elem.requestFullscreen();
                } else if (elem.mozRequestFullScreen) { /* Firefox */
                elem.mozRequestFullScreen();
                } else if (elem.webkitRequestFullscreen) { /* Chrome, Safari and Opera */
                elem.webkitRequestFullscreen();
                } else if (elem.msRequestFullscreen) { /* IE/Edge */
                elem.msRequestFullscreen();
                }
                
            }
            
            /* Close fullscreen */
            function closeFullscreen() {
                if (document.exitFullscreen) {
                document.exitFullscreen();
                } else if (document.mozCancelFullScreen) { /* Firefox */
                document.mozCancelFullScreen();
                } else if (document.webkitExitFullscreen) { /* Chrome, Safari and Opera */
                document.webkitExitFullscreen();
                } else if (document.msExitFullscreen) { /* IE/Edge */
                document.msExitFullscreen();
                }
            }
            
            function onFullscreenToggle(){
                if(fullscreen){
                    closeFullscreen();
                    fullscreen=false;
                  // ui.fullscreentoggle.textContent='Fullscreen';
                } else {
                    openFullscreen();
                    fullscreen=true;
                   // ui.fullscreentoggle.textContent='Exit Fullscreen';
                }
            }
            
            /**
             * Converts a long string of bytes into a readable format e.g KB, MB, GB, TB, YB
             * 
             * @param {Int} num The number of bytes.
             */
            function readableBytes(bytes) {
                var i = Math.floor(Math.log(bytes) / Math.log(1024)),
                sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

                return (bytes / Math.pow(1024, i)).toFixed(2) * 1 + ' ' + sizes[i];
            }

            /**
             * Asynchronously downloads PDF.
             */
            pdfjsLib.getDocument(this.context.pdfurl).promise.then(function(pdfDoc_) {
                pdfDoc = pdfDoc_;
                ui.pagecount.textContent = pdfDoc.numPages;
                
                let downloadBtn = document.getElementById("pdf-btn-"+instanceid);
                downloadBtn.innerText = "Download PDF";
                downloadBtn.addEventListener('click',onDownload);

                if (pdfDoc.numPages <= 1){
                    Mura(ui.pagecontrols).hide();
                }

                // Initial/first page rendering
                renderPage(pageNum);

                pdfDoc.getDownloadInfo().then(function(data){
                    var rb=readableBytes(data.length);
                    if(rb){
                        ui.readablebytes.textContent=rb;
                    } else {
                        ui.readablebytes.textContent='';
                    }
                   
                })
            });
             
             function printPDF(){
                pdfDoc.getData().then(function(arrayBuffer) {
                    //var pdfraw = String.fromCharCode.apply(null, arrayBuffer);
                    var isIE11 = !!(window.navigator && window.navigator.msSaveOrOpenBlob); // or however you want to check it
                    var blob=new Blob([arrayBuffer], { type: 'application/pdf' });
                    try {
               
                        if(isIE11){
                            window.navigator.msSaveOrOpenBlob(blob, getFilename());
                        } else {
                            printJS(URL.createObjectURL(blob));
                        }
                    } catch (e) {
                      console.log(e);
                    }
                }); 
             }

            function onPrint(){
                printPDF();
            }

            ui.prevpage.addEventListener('click', onPrevPage);
            ui.nextpage.addEventListener('click', onNextPage);
            ui.zoomin.addEventListener('click', onPageZoomIn);
            ui.zoomout.addEventListener('click', onPageZoomOut);
            ui.fullscreenopen.addEventListener('click', openFullscreen);
            ui.fullscreenclose.addEventListener('click', closeFullscreen);
            ui.print.addEventListener('click', onPrint);
            ui.download.addEventListener('click', onDownload);

            function onResize () {
                let downloadBtn = document.getElementById("pdf-btn-"+instanceid);
                let pdfElement = document.getElementById('mura-pdfcontainer-' + instanceid);

                if (document.documentElement.clientWidth > 768){
                    Mura(downloadBtn).hide();
                    Mura(pdfElement).show();
                } else {
                    Mura(downloadBtn).show();
                    Mura(pdfElement).hide();
                }
            }

            window.onresize = function (){
                onResize();
            }
        }
    });
});
       
