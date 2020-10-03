use strict;
use warnings;

use Test::More 'tests' => 2;
use Test::NoWarnings;
use Wikidata::Content::Struct;

# Test.
my $obj = Wikidata::Content::Struct->new;
isa_ok($obj, 'Wikidata::Content::Struct');
