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

    // sort sequence sets by title
    store.setDefaultSort('title', 'DESC');

    // create the Grid
    var xg = Ext.grid;
    var sm = new xg.CheckboxSelectionModel({
        listeners: {
            selectionchange: function(sm) {
                if (sm.getCount()) {
                    // clicking an unselected checkbox
                } else {
                    // clicking an already selected checkbox
                }
            }
        }
    });
    var grid = new xg.GridPanel({
        columns: [
            sm,
            {
                id       :'mimosa_sequence_set_id',
                header   : 'Sequence Set ID',
                sortable : true,
                dataIndex: 'mimosa_sequence_set_id'
            },
            {
                id       :'shortname',
                header   : 'Short Name',
                sortable : true,
                dataIndex: 'shortname'
            },
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
                width    : 250,
                dataIndex: 'description'
            },
            {
                id       :'alphabet',
                header   : 'Alphabet',
                sortable : true,
                dataIndex: 'alphabet'
            },
            {
                id       :'info_url',
                header   : 'Info URL',
                sortable : true,
                dataIndex: 'info_url'
            },
            {
                id       :'update_interval',
                header   : 'Update interval',
                sortable : true,
                dataIndex: 'update_interval'
            },
            {
                id       :'is_public',
                header   : 'Public?',
                sortable : true,
                dataIndex: 'is_public'
            },
        ],
        frame: true,
        iconCls:'icon-grid',
        store: store,
        sm: sm,
        columnLines: true,
        stripeRows: true,
        // autoExpandColumn: 'shortname',
        height: 350,
        width: '100%',
        title: 'Available Sequence Sets',
        // config options for stateful behavior
        stateful: true,
        stateId: 'grid'
    });

    // render the grid to the specified div in the page
    grid.render('mimosa-grid');

});
