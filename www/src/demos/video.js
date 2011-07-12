demos.Video = new Ext.Panel({
    layout: {
        type: 'vbox',
        pack: 'center'
    },
    items: [{
        xtype: 'video',
        url: 'http://dev.sencha.com/deploy/touch/examples/video/space.mp4',
        loop: true,
        width: 500,
        height: 400,
        posterUrl: 'resources/video/Screenshot.png'
    }]
});


//These can be hosted locally but I have pointed them to the sencha example to reduce the Download of MacGap @RandyMcMillan