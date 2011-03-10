
{
  'schema_class' => 'App::Mimosa::Schema::BCS',
  'connect_info' => App::Mimosa::Test::app->model('BCS')->connect_info,

  'resultsets' => [],
  # 'resultsets' => [
  #       'Person',
  #       'Job',
  #       'Person' => { '-as' => 'NotTeenager', search => {age=>{'>'=>18}}},
  # ],

  'fixture_sets' => {

      #basic set of test data: a few sequence sets, a few organisms
        'basic' => {
            'Mimosa::SequenceSet' => [
                [qw/ mimosa_sequence_set_id shortname title description alphabet source_spec lookup_spec info_url update_interval is_public /],
                [ 1, 'solanum_peruvianum_mrna', 'Solanum peruvianum mRNA sequences', 'mRNA sequences for S. peruvianum', 'nucleotide', '', '', ,'', 30, 1    ],
              ],
        },
  },
}
