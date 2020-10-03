use strict;
use warnings;

use Test::More 'tests' => 10;
use Test::NoWarnings;
use Wikidata::Content::Struct;

# Test.
my $obj = Wikidata::Content::Struct->new;
my $struct_hr = {};
my $ret = $obj->parse($struct_hr);
isa_ok($ret, 'Wikidata::Content');

# Test.
$struct_hr = {
	'title' => 'Q42',
};
$ret = $obj->parse($struct_hr);
isa_ok($ret, 'Wikidata::Content');
is($ret->entity, 'Q42', 'Get entity().');

# Test.
$struct_hr = {
	'title' => 'Q42',
	'claims' => {
		'P11' => [{
			'mainsnak' => {
				'datatype' => 'string',
				'datavalue' => {
					'value' => '1.1',
					'type' => 'string',
				},
				'property' => 'P11',
				'snaktype' => 'value',
			},
			'type' => 'statement',
			'rank' => 'normal',
		}],
	},
};
$ret = $obj->parse($struct_hr);
isa_ok($ret, 'Wikidata::Content');
is($ret->entity, 'Q42', 'Get entity().');
my ($claim) = $ret->claims;
is($claim->snak->property, 'P11', 'Get property.');
is($claim->snak->datavalue->value, '1.1', 'Get value.');
is($claim->snak->snaktype, 'value', 'Get snaktype.');
is($claim->snak->datatype, 'string', 'Get datatype.');
