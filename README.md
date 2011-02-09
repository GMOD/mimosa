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
coupled to legacy codebases, difficult to deploy, or just plain *suck*.

Mimosa plans on being an easy-to-install standalone sequence aligner, which
can be integrated into an existing website via a REST interface.

## What is Mimosa written in?

Mimosa is written in Perl 5 and uses Moose, Bio::Perl and the Dancer web framework.
