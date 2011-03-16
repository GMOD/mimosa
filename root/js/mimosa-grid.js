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
        { name: 'is_public' },
        { name: 'sequence_set_organisms' }
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
                id       :'company',
                header   : 'Company', 
                width    : 160, 
                sortable : true, 
                dataIndex: 'company'
            },
            {
                header   : 'Price', 
                width    : 75, 
                sortable : true, 
                renderer : 'usMoney', 
                dataIndex: 'price'
            },
            {
                header   : 'Change', 
                width    : 75, 
                sortable : true, 
                dataIndex: 'change'
            },
            {
                header   : '% Change', 
                width    : 75, 
                sortable : true, 
                dataIndex: 'pctChange'
            },
            {
                header   : 'Last Updated', 
                width    : 85, 
                sortable : true, 
                renderer : Ext.util.Format.dateRenderer('m/d/Y'), 
                dataIndex: 'lastChange'
            },
            {
                xtype: 'actioncolumn',
                width: 50,
                items: [{
                    icon   : '../shared/icons/fam/delete.gif',  // Use a URL in the icon config
                    tooltip: 'Sell stock',
                    handler: function(grid, rowIndex, colIndex) {
                        var rec = store.getAt(rowIndex);
                        alert("Sell " + rec.get('company'));
                    }
                }, {
                    getClass: function(v, meta, rec) {          // Or return a class from a function
                        if (rec.get('change') < 0) {
                            this.items[1].tooltip = 'Do not buy!';
                            return 'alert-col';
                        } else {
                            this.items[1].tooltip = 'Buy stock';
                            return 'buy-col';
                        }
                    },
                    handler: function(grid, rowIndex, colIndex) {
                        var rec = store.getAt(rowIndex);
                        alert("Buy " + rec.get('company'));
                    }
                }]
            }
        ],
        stripeRows: true,
        autoExpandColumn: 'company',
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
