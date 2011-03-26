Ext.onReady(function(){
    Ext.QuickTips.init();
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
        totalProperty : 'total',
    });
       // create the Grid
    var grid = new Ext.grid.GridPanel({
        store: store,
        columns: [
            {
                id       :'mimosa_sequence_set_id',
                header   : 'mimosa_sequence_set_id',
                width    : 8,
                sortable : true,
                dataIndex: 'mimosa_sequence_set_id'
            },
            {
                id       :'shortname',
                header   : 'shortname',
                sortable : true,
                dataIndex: 'shortname'
            },
            {
                id       :'title',
                header   : 'title',
                sortable : true,
                dataIndex: 'title'
            },
            {
                id       :'description',
                header   : 'description',
                sortable : true,
                dataIndex: 'description'
            },
            {
                id       :'alphabet',
                header   : 'alphabet',
                sortable : true,
                dataIndex: 'alphabet'
            },
            {
                id       :'source_spec',
                header   : 'source_spec',
                width    : 8,
                sortable : true,
                dataIndex: 'source_spec'
            },
            {
                id       :'lookup_spec',
                header   : 'lookup_spec',
                width    : 8,
                sortable : true,
                dataIndex: 'lookup_spec'
            },
            {
                id       :'info_url',
                header   : 'info_url',
                width    : 8,
                sortable : true,
                dataIndex: 'info_url'
            },
            {
                id       :'update_interval',
                header   : 'update_interval',
                width    : 8,
                sortable : true,
                dataIndex: 'update_interval'
            },
            {
                id       :'is_public',
                header   : 'is_public',
                width    : 8,
                sortable : true,
                dataIndex: 'is_public'
            },
        ],
        stripeRows: true,
        autoExpandColumn: 'shortname',
        height: 350,
        width: 600,
        title: 'Available BLAST Databases',
        // config options for stateful behavior
        stateful: true,
        stateId: 'grid'
    });

    // render the grid to the specified div in the page
    grid.render('mimosa-grid');

});
