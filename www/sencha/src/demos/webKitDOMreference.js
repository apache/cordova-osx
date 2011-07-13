(function() {
    //var youTubeWidth = window.innerWidth - 560;
    //var youTubeHeight = window.innerHeight - 377;
    var phoneGapComWidth = window.innerWidth - 200;
    var iframeWidth = phoneGapComWidth - 12;
    var phoneGapComHeight = window.innerHeight - 130;
    var iframeHeight =  phoneGapComHeight - 12;
    var tapHandler = function(button, event) { var txt = "User tapped the '" + button.text + "' button."; Ext.getCmp('itAvoidIDsLikeThePlague').body.dom.innerHTML = txt; };
    
    var onReload = function(button, event) { window.hidden; window.location.reload(); };
 
    //ToDo
    /*
    var onYouTube = function(button, event) {
        if (!Ext.is.Desktop) {
            PhoneGap.exec("ChildBrowserCommand.showWebPage", "http://m.youtube.com/#/watch?v=JkT_UYXV-oY&key=AI39si5uWLRT16JtcIQCTvmSvpUmTzJxqCsceL6s4_LQj0FsJXSydWB0ccFWz7fddh5hJuF3zUcI7F_gu27ds9HHoisswEKuQA" );
        }
        else {
            if (!this.popup) {
                this.popup = new Ext.Panel({html:''});
                this.popup = new Ext.Panel({
                    floating: true,
                    modal: true,
                    centered: true,
                    width: window.innerWidth - 560,
                    height: window.innerHeight - 380,
                    styleHtmlContent: true,
                    html: '<p><object width=" ' + youTubeWidth + ' " height=" ' + youTubeHeight + ' "><param name="movie" value="https://www.youtube.com/v/obx2VOtx0qU?version=3&amp;hl=en_US&amp;rel=0"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="https://www.youtube.com/v/obx2VOtx0qU?version=3&amp;hl=en_US&amp;rel=0&autoplay=1&hd=1%loop=1&autohide=0&key=AI39si5uWLRT16JtcIQCTvmSvpUmTzJxqCsceL6s4_LQj0FsJXSydWB0ccFWz7fddh5hJuF3zUcI7F_gu27ds9HHoisswEKuQA" type="application/x-shockwave-flash" width="425" height="349" allowscriptaccess="never" allowfullscreen="true"></embed></object></p>',
                    //dockedItems: [{
                    //            dock: 'top',
                    //          xtype: 'toolbar',
                    //        title: 'Overlay Title'
                    //      }],
                    scroll: 'vertical'
                });
            }
            this.popup.show('pop');  
        }
    };
     
     */
    //ToDo
    var onPhoneGapCom = function(button, event) {
        if (!Ext.is.Desktop) {
            PhoneGap.exec("ChildBrowserCommand.showWebPage", "http://docs.phonegap.com/" );
        }
        else {
            if (!this.popup) {
                this.popup = new Ext.Panel({html:''});
                this.popup = new Ext.Panel({
                    floating: true,
                    modal: true,
                    centered: true,
                    width: phoneGapComWidth,
                    height: phoneGapComHeight,
                    cls:'PhoneGapCom',
                    styleHtmlContent: true,
                    html: '<p><iframe class="iframe" frameborder="no" overflow:auto SRC="http://docs.phonegap.com/" width=" ' + iframeWidth + ' " height=" ' + iframeHeight + ' "></iframe></p>',
                    //dockedItems: [{
                    //            dock: 'top',
                    //          xtype: 'toolbar',
                    //        title: 'Overlay Title'
                    //      }],
                    //scroll: 'vertical'
                });
            }
            this.popup.show('pop');  
        }
    };
    
    var buttonsGroup1 = [{
        text: 'Reload',
        ui: 'action',
        handler: onReload,allowDepress: false,
    }, {
        text: 'Default',
        hidden: true,
        badgeText: '2',
        handler: tapHandler
    }, {
        text: 'Round',
        hidden: true,
        ui: 'round',
        handler: tapHandler
    }];
    
    var buttonsGroup2 = [{
        xtype: 'segmentedbutton',
        items: [/*{
            text: 'PhoneGap API Docs',
            handler: onPhoneGapCom,allowDepress: false,
                hidden:true,
            },*/{
            text: 'PhoneGap API Docs',
            ui:'action',
            handler: onPhoneGapCom,allowDepress: false,
            },/*{
            text: 'PhoneGap API Docs',
            handler: onPhoneGapCom,allowDepress: false,
        }*/]
    }];
    
    var buttonsGroup3 = [{
        text: 'Action',
        hidden: true,
        ui: 'action',
        handler: tapHandler
    }, {
        text: 'Forward',
        hidden: true,
        ui: 'forward',
        handler: tapHandler
    }];
    
    if (!Ext.is.Phone) {
        buttonsGroup1.push({xtype: 'spacer'});
        buttonsGroup2.push({xtype: 'spacer'});
        
        var dockedItems = [new Ext.Toolbar({
            ui: 'light',
            dock: 'bottom',
            items: buttonsGroup1.concat(buttonsGroup2).concat(buttonsGroup3)
        })];
    }
    else {
        
        var dockedItems = [new Ext.Toolbar({
            ui: 'light',
            dock: 'bottom',
            items: buttonsGroup1.concat(buttonsGroup2).concat(buttonsGroup3)
        })];/* var dockedItems = [{
             xtype: 'toolbar',
             ui: 'light',
             items: buttonsGroup1,
             dock: 'bottom'
             }, {
             xtype: 'toolbar',
             ui: 'dark',
             items: buttonsGroup2,
             dock: 'bottom'
             }, {
             xtype: 'toolbar',
             ui: 'light',
             items: buttonsGroup3,
             dock: 'bottom'
             }];
             */
    }
    
    
    demos.webKitDOMreference = new Ext.Panel({
        //id:'itAvoidIDsLikeThePlague',
        cls: 'fullscreen',
        scroll: 'both',
        fullscreen: true,
        monitorOrientation:true,
        html: '<p><iframe frameborder="0" SRC="http://developer.apple.com/library/mac/#documentation/AppleApplications/Conceptual/SafariJSProgTopics/Tasks/ObjCFromJavaScript.html%23//apple_ref/doc/uid/30001215-BBCBFJCD" width="100%" height="100%"></iframe></p>',
        //dockedItems: dockedItems
    });
})(/* -@RandyMcMillan */);