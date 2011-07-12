demos.Audio = new Ext.Panel({
    layout: {
        type: 'vbox',
        pack: 'center'
    },
    items: [{
        xtype: 'audio',
        url: 'http://dev.sencha.com/deploy/touch/examples/audio/crash.mp3',
        loop: true
    }]
});


//These can be hosted locally but I have pointed them to the sencha example to reduce the Download of MacGap @RandyMcMillan