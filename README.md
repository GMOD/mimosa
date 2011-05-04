# Mimosa - Miniature Model Organism Sequence Aligner

## What is Mimosa?

Mimosa is a application which provides an web interface to various sequence
alignment programs and sequence databases. At first, only BLAST will be
supported, but the Mimosa framework will eventually support multiple sequence
alignment programs.

## What will Mimosa do?

Mimosa will allow researchers to run sequence alignment programs on nucleotides
or proteins, and request sequences from various sequence databases, all from
a friendly web interface.

## Why does Mimosa exist? Aren't there a lot of things that already do this?

Mimosa exists to solve the problem of making a standalone sequence alignment
web interface. All existing sequence alignment web interfaces are either tightly
coupled to legacy codebases, difficult to deploy, or just plain *unfriendly* to
end users.

Mimosa plans on being an easy-to-install standalone sequence aligner, which
can be integrated into an existing website via a REST interface.

## How do I get Mimosa?

Currently, Mimosa does not have distribution packages, so you must use git. This
will change as Mimosa gets closer to a public release.

If you have cpanminus:

    git clone git://github.com/GMOD/mimosa.git
    cd mimosa
    cpanm --installdeps . # install necessary dependencies
    perl Build.PL
    ./Build

If you don't have cpanminus:

    git clone git://github.com/GMOD/mimosa.git
    cd mimosa
    perl Build.PL
    ./Build --installdeps # install necessary dependencies
    ./Build

## How do I run the Mimosa test suite ?

After you have run the command

    perl Build.PL

you can either type:

    ./Build test

or use prove:

    prove -Ilib -rv t/

to run the Mimosa test suite.

## How do I start Mimosa ?

To start Mimosa on the default port of 3000 :

    perl script/mimosa_server.pl

If you want to run it on a specific port, then pass the -p param :

    perl script/mimosa_server.pl -p 8080

## How do I configure Mimosa ?

The file called "app_mimosa.conf" contaings your configuration. In it, you can
tell Mimosa what your database backend is (SQLite, MySQL, PostgreSQL, Oracle, and
anything else that DBI supports) and set various paramters. Here is a partial list:

###  min_sequence_input_length 6

This sets the smallest sequence input length. If a sequence smaller than this length
is submitted, an exception is thrown and an error page is shown to the user.

### allow_anonymous 1

Whether to allow anonymous people (those that have not authenticated) to submit
jobs for reports.

### disable_qsub 1

Disable qsub job queueing support, which means jobs will be run on the local machine.

### tmp_dir /tmp/mimosa

The temporary directory that Mimosa can use.

### sequence_data_dir examples/data

The directory where sequence data can be found.

### <Model::BCS>

This Config key is a container for Bio::Chado::Schema-related
configuration. It has:

### schema_class App::Mimosa::Schema::BCS

The schema class.

### traits undef

A trait, such as "Caching", which is good for production, but
not testing.

The <Model::BCS> container has a <connect_info> container,
which contains the "dsn" config key.

### dsn dbi:SQLite:./mimosa.db

The default is to deploy to a SQLite database in the current
directory, but if you want to use this with a
currently-existing Chado installation, you should but the
connection information in this config key.


## What is Mimosa written in?

Mimosa is written in Perl 5, HTML, CSS, and JavaScript.  On the server side, it
uses Moose, BioPerl and the Catalyst web framework.  On the client side, it uses
JQuery, JQuery UI.


## How do I get involved?

Please join our mailing list at <http://groups.google.com/group/gmod-mimosa> and
take a look at our Github issues for ideas about what we need help with:
<https://github.com/GMOD/mimosa/issues> . You are also welcome to join the #gmod
IRC channel on irc.freenode.net, where many GMOD developers hang out and talk
about various GMOD projects.
