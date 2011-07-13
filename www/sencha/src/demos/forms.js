demos.Forms = new Ext.TabPanel({
    items: [{
        title: 'Basic',
        xtype: 'form',
        id: 'basicform',
        scroll: 'vertical',
        items: [{
            xtype: 'fieldset',
            title: 'Personal Info',
            instructions: 'Please enter the information above.',
            defaults: {
                // labelAlign: 'right'
                labelWidth: '35%'
            },
            items: [{
                xtype: 'textfield',
                name: 'name',
                label: 'Name',
                placeHolder: 'Tom Roy',
                autoCapitalize : true,
                required: true,
                useClearIcon: true
            }, {
                xtype: 'passwordfield',
                name: 'password',
                label: 'Password',
                useClearIcon: true
            }, {
                xtype: 'emailfield',
                name: 'email',
                label: 'Email',
                placeHolder: 'me@sencha.com',
                useClearIcon: true
            }, {
                xtype: 'urlfield',
                name: 'url',
                label: 'Url',
                placeHolder: 'http://sencha.com',
                useClearIcon: true
            }, {
                xtype: 'checkboxfield',
                name: 'cool',
                label: 'Cool'
            }, {
                xtype: 'datepickerfield',
                name: 'birthday',
                label: 'Birthday',
                picker: { yearFrom: 1900 }
            }, {
                xtype: 'selectfield',
                name: 'rank',
                label: 'Rank',
                options: [{
                    text: 'Master',
                    value: 'master'
                }, {
                    text: 'Journeyman',
                    value: 'journeyman'
                }, {
                    text: 'Apprentice',
                    value: 'apprentice'
                }]
            }, {
                xtype: 'hiddenfield',
                name: 'secret',
                value: false
            }, {
                xtype: 'textareafield',
                name: 'bio',
                label: 'Bio'
            }]
        }, {
            xtype: 'fieldset',
            title: 'Favorite color',
            defaults: {
                xtype: 'radiofield',
                labelWidth: '35%'
            },
            items: [{
                name: 'color',
                value: 'red',
                label: 'Red'
            }, {
                name: 'color',
                label: 'Blue',
                value: 'blue'
            }, {
                name: 'color',
                label: 'Green',
                value: 'green'
            }, {
                name: 'color',
                label: 'Purple',
                value: 'purple'
            }]
        }, {
            layout: 'vbox',
            defaults: {xtype: 'button', flex: 1, style: 'margin: .5em;'},
            items: [{
                text: 'Disable fields',
                scope: this,
                hasDisabled: false,
                handler: function(btn){
                    var form = Ext.getCmp('basicform');

                    if (btn.hasDisabled) {
                        form.enable();
                        btn.hasDisabled = false;
                        btn.setText('Disable fields');                      
                    } else {
                        form.disable();
                        btn.hasDisabled = true;
                        btn.setText('Enable fields');
                    }
                }
            }, {
                text: 'Reset form',
                handler: function(){
                    Ext.getCmp('basicform').reset();
                }
            }]
        }]
    }, {
        title: 'Sliders',
        xtype: 'form',
        items: [{
            xtype: 'fieldset',
            defaults: {
                labelAlign: 'right'
            },
            items: [{
                xtype: 'sliderfield',
                name: 'value',
                label: 'Value'
            }, {
                xtype: 'togglefield',
                name: 'enable',
                label: 'Enable'
            }]
        }]
    }, {
        title: 'Toolbars',
        styleHtmlContent: true,
        xtype: 'form',
        scroll: 'vertical',
        html: "A human being should be able to change a diaper, plan an invasion, butcher a hog, conn a ship, design a building, write a sonnet, balance accounts, build a wall, set a bone, comfort the dying, take orders, give orders, cooperate, act alone, solve equations, analyze a new problem, pitch manure, program a computer, cook a tasty meal, fight efficiently, die gallantly. - RAH",
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'top',
            items: [{
                xtype: 'searchfield',
                placeHolder: 'Search',
                name: 'searchfield'
            }]
        },
        {
            xtype: 'toolbar',
            dock: 'top',
            items: [{
                xtype: 'textfield',
                placeHolder: 'Text',
                name: 'searchfield'
            }]
        },
        {
            xtype: 'toolbar',
            dock: 'top',
            items: [{
                xtype: 'selectfield',
                name: 'options',
                options: [
                    {text: 'This is just a big select',  value: '1'},
                    {text: 'Another select item', value: '2'}
                ]
            }]
        }]
    }]
});



// if (Ext.is.Android) {
//     demos.Forms.insert(0, {
//         xtype: 'component',
//         styleHtmlContent: true,
//         html: '<span style="color: red">Forms on Android are currently under development. We are working hard to improve this in upcoming releases.</span>'
//     });
// }