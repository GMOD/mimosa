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
    });

    // sort sequence sets by title
    store.setDefaultSort('title', 'ASC');

    // create the Grid
    var xg = Ext.grid;
    var sm = new xg.CheckboxSelectionModel({
        listeners: {
            selectionchange: function(sm) {
                if (sm.getCount()) { // clicking an unselected checkbox
                    // This only gets the first selection
                    var selected_data = sm.getSelected().data;
                    jQuery("#mimosa_sequence_set_id").val( selected_data['mimosa_sequence_set_id'] );
                } else { // clicking an already selected checkbox
                    // Replace the default of 0, which means "no sequence sets are selected"
                    jQuery("#mimosa_sequence_set_id").val( 0 );
                }
                //alert( jQuery("#mimosa_sequence_set_id").html() );
            }
        }
    });
    var grid = new xg.GridPanel({
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
        title: 'Available Sequence Sets to BLAST against',
        autoWidth: true,
        autoHeight: true,
        stripeRows : true,

        // config options for stateful behavior
        stateful: true,
        stateId: 'grid'
    });

    // render the grid to the specified div in the page
    grid.render('mimosa-grid');

    // Make the program selector filter the grid

    jQuery("#program_selector").change(function() {
        var program = jQuery("#program_selector").val();

        // Which databases should we filter?
        if( program == "blastn" || program == "tblastn") {
            // only nucleotide databases should be show
            store.filter('alphabet', 'nucleotide');
        } else if (program == "tblastx") {
            // only protein databases
            store.filter('alphabet', 'protein');
        } else {
            store.filter();
        }
    });

});
