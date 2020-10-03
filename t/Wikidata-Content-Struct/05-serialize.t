use strict;
use warnings;

use Test::More 'tests' => 3;
use Test::NoWarnings;
use Wikidata::Content::Struct;

# Test.
my $obj = Wikidata::Content::Struct->new;
my $input = Wikidata::Content->new;
my $ret_hr = $obj->serialize($input);
is_deeply(
	$ret_hr,
	{},
	'Blank structure.',
);

# Test.
$obj = Wikidata::Content::Struct->new;
$input = Wikidata::Content->new('entity' => 'Q42');
$ret_hr = $obj->serialize($input);
is_deeply(
	$ret_hr,
	{
		'title' => 'Q42',
	},
	'Only title in structure.',
);
