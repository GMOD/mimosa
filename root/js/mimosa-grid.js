Ext.onReady(function(){
    Ext.QuickTips.init();

    // Apply a set of config properties to the singleton
    Ext.apply(Ext.QuickTips.getQuickTip(), {
        showDelay    : 0,
        trackMouse   : true,
        mouseOffset  : [-60,20], // otherwise Delete tt overruns browser win
        autoWidth    : true,
        dismissDelay : 0
    });

    var rowRecord = Ext.data.Record.create([
        { name: 'mimosa_sequence_set_id' },
        { name: 'name' },
        { name: 'description' },
        { name: 'alphabet' },
    ]);

    var writer = new Ext.data.JsonWriter({
        encode: false,
    });
    // create the Data Store
    var store = new Ext.data.JsonStore({
        url        : '/api/grid/json.json',
        root       : 'rows',
        fields     : rowRecord,
        autoSave   : false,
        autoDestroy: true,
        remoteSort : true,
        // Without this, ExtJS will be dumb and do a POST
        restful    : true,
        autoLoad   : true,
        writer     : writer,
        listeners  : {
        }
    });

    // sort sequence sets by title
    store.setDefaultSort('title', 'ASC');

    // create the Grid
    var xg = Ext.grid;
    var sm = new xg.CheckboxSelectionModel({
        listeners: {
            selectionchange: function(sm) {
                var ids = '';
                sm.getSelections().forEach(function(e){
                    ids = ids + e.data['mimosa_sequence_set_id'] + ",";
                });
                jQuery("#mimosa_sequence_set_ids").val( ids );
            },
        }
    });


    var grid = new xg.GridPanel({
        listeners: {
        },
        columns: [
            sm,
            {
                id       :'mimosa_sequence_set_id',
                header   : 'Id',
                sortable : true,
                dataIndex: 'mimosa_sequence_set_id'
            },
            {
                id       :'name',
                header   : 'Name',
                sortable : true,
                dataIndex: 'name'
            },
            {
                id       :'description',
                header   : 'Description',
                sortable : true,
                dataIndex: 'description',
            },
            {
                id       :'alphabet',
                header   : 'Alphabet',
                sortable : true,
                dataIndex: 'alphabet'
            }
        ],
        animCollapse: true,
        autoExpandColumn: 'description',
        collapsible: true,
        columnLines: true,
        frame: true,
        iconCls:'icon-grid',
        sm: sm,
        store: store,
        stripeRows: true,
        title: 'Search and select sequence sets to BLAST/Align',
        autoWidth: true,
        autoHeight: false,
        height: 200,
        stripeRows : true,

        // UI layout options
        region: 'center',
        layout: 'fit',

        // config options for stateful behavior
        stateful: true,
        stateId: 'grid'
    });

    store.on('load', function() {
        var default_id    = jQuery("#default_id").val();
        var default_index = store.find('mimosa_sequence_set_id', default_id );

        //console.log( 'default index ' + default_index );
        grid.getSelectionModel().selectRow(default_index);
    });


    // render the grid to the specified div in the page, if it exists
    if( jQuery('#mimosa-grid') ) {
        // grid.render('mimosa-grid');
    }
    var formpanel = new Ext.form.FormPanel({
        standardSubmit: true,
        frame:true,
        title: 'Align',
        width: '350',
        region: 'east',
        collapsible: true,
        defaults: {width: 350},
        defaultType: 'textfield',
        items: [
            {
                fieldLabel: 'Program',
                name: 'program',
                id: 'program_selector',
                fieldType: 'select',
                allowBlank:false
            },
            {
                fieldLabel: 'Name',
                name: 'search_name',
                allowBlank:false
            },
            {
                fieldLabel: 'Description',
                name: 'search_description',
                allowBlank:false
            },
            {
                fieldLabel: 'Query Sequence',
                name: 'sequence',
                allowBlank:false,
                type: 'textarea'
            },
            {
                fieldLabel: 'Advanced',
                type: 'checkbox',
                name: 'advanced',
                value: 0
            },
            {
                inputType: 'hidden',
                id: 'mimosa_sequence_set_ids',
                name: 'mimosa_sequnce_set_ids',
                value: '0'
            }

        ],
        buttons: [{
            text: 'Submit',
            handler: function() {
                formpanel.getForm().getEl().dom.action = '/submit';
                formpanel.getForm().getEl().dom.method = 'POST';
                formpanel.getForm().submit();
            }
        }]
    });


    var panel = new Ext.Panel({
        title: 'Mimosa - Miniature Model Organism Sequence Aligner',
        id: 'panel',
        layout: 'border',
        width: '100%',
        height:400,
        renderTo: 'mimosa-panel',
        items:[
            grid,
            formpanel
        ],
        /*{
            id: 'mimosa-panel-left',
            region:'center',
            layout:'fit',
            frame:true,
            border:false,
        },
        {
            id: 'mimosa-panel-right',
            region:'east',
            layout:'fit',
            frame:true,
            border:false,
            width:200,
            split:true,
            collapsible:true,
            collapseMode:'mini'
        }] */
    });

    // Add the grid panel
    panel.add(grid);

    // render the panel again
    panel.doLayout();

    // Make the program selector filter the grid

    var filter = function(){
        var program = jQuery("#program_selector").val();
        var alphabet = '';

        // Which databases should we filter?
        if( program == "blastn" || program == "tblastn") {
            alphabet = 'nucleotide';
        } else if (program == "tblastx") {
            alphabet = 'protein';
        } else {
        }
        store.filter([
        {
            property : 'name',
            value    : new RegExp(jQuery("#search_name").val()),
        },
        {
            property : 'description',
            value    : new RegExp(jQuery("#search_description").val()),
        },
        {
            property : 'alphabet',
            value    : new RegExp(alphabet),
        }
        ]);
    };

    jQuery("#program_selector").change(filter);

    jQuery("#search_name").keyup(filter);

    jQuery("#search_description").keyup(filter);
});
