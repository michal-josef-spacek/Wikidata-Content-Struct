use strict;
use warnings;

use Test::More 'tests' => 2;
use Test::NoWarnings;
use Wikidata::Content::Struct;

# Test.
is($Wikidata::Content::Struct::VERSION, 0.01, 'Version.');
