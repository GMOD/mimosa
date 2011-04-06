Ext.onReady(function(){
    Ext.QuickTips.init();

    // Apply a set of config properties to the singleton
    Ext.apply(Ext.QuickTips.getQuickTip(), {
        showDelay: 0
        ,trackMouse: true
        ,mouseOffset: [-60,20] // otherwise Delete tt overruns browser win
        ,autoWidth: true
        ,dismissDelay: 0
    });

    var rowRecord = Ext.data.Record.create([
        { name: 'mimosa_sequence_set_id' },
        { name: 'shortname' },
        { name: 'title' },
        { name: 'description' },
        { name: 'alphabet' },
        { name: 'source_spec' },
        { name: 'lookup_spec' },
        { name: 'info_url' },
        { name: 'update_interval' },
        { name: 'is_public' }
    ]);

    // create the Data Store
    var store = new Ext.data.JsonStore({
        url: '/autocrud/site/default/schema/bcs/source/mimosa_sequence_set/list',
        root          : 'rows',
        fields        : rowRecord,
        remoteSort    : true,
        autoLoad      : true,
    });
    store.filter('is_public', 1, false, false);

    // sort sequence sets by title
    store.setDefaultSort('title', 'DESC');

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
                id       :'title',
                header   : 'Title',
                sortable : true,
                dataIndex: 'title'
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
            // This should only be shown if the current user is logged in
            // and can view private sets
            //{
            //    id       :'is_public',
            //    header   : 'Public?',
            //    sortable : true,
            //    dataIndex: 'is_public'
            //},
        ],
        animCollapse: true,
        // autoExpandColumn: 'shortname',
        collapsible: true,
        columnLines: true,
        frame: true,
        iconCls:'icon-grid',
        sm: sm,
        store: store,
        stripeRows: true,
        title: 'Available Sequence Sets',
        autoWidth: true,
        autoHeight: true,

        // config options for stateful behavior
        stateful: true,
        stateId: 'grid'
    });

    // render the grid to the specified div in the page
    grid.render('mimosa-grid');

});
