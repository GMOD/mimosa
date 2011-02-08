package App::Mimosa::Job;
use Moose;

has command => (
    isa => 'Str',
    required => 1,
);

1;
