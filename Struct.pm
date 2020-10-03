package Wikidata::Content::Struct;

use strict;
use warnings;

use Class::Utils qw(set_params);
use Error::Pure qw(err);
use Wikidata::Content;
use Wikidata::Datatype::Struct::Sitelink;
use Wikidata::Datatype::Struct::Statement;

our $VERSION = 0.01;

sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Process parameters.
	set_params($self, @params);

	return $self;
}

sub parse {
	my ($self, $struct_hr) = @_;

	# Title.
	my $content = Wikidata::Content->new(
		$struct_hr->{'title'} ? (
			'entity' => $struct_hr->{'title'},
		) : (),
	);

	# Claims.
	foreach my $claim_property (keys %{$struct_hr->{'claims'}}) {
		foreach my $claim_hr (@{$struct_hr->{'claims'}->{$claim_property}}) {
			$content->add_claim(
				$claim_hr->{'mainsnak'}->{'datatype'},
				# TODO Specific properties.
				{
					$claim_property => $claim_hr->{'mainsnak'}->{'datavalue'}->{'value'},
				},
			);
		}
	}

	# Descriptions.
	foreach my $descriptions_hr (values %{$struct_hr->{'descriptions'}}) {
		$content->add_descriptions({
			$descriptions_hr->{'language'} => $descriptions_hr->{'value'}
		});
	}

	# Labels.
	foreach my $label_hr (values %{$struct_hr->{'labels'}}) {
		$content->add_labels({
			$label_hr->{'language'} => $label_hr->{'value'}
		});
	}

	# Aliases.
	foreach my $alias_lang (keys %{$struct_hr->{'aliases'}}) {
		$content->add_aliases({
			$alias_lang => [
				map { $_->{'value'} }
					@{$struct_hr->{'aliases'}->{$alias_lang}}
			]
		});
	}

	# Sitelinks.
	foreach my $sitelink (keys %{$struct_hr->{'sitelinks'}}) {
		$content->add_sitelinks({
			$sitelink => $struct_hr->{'sitelinks'}->title,
		});
	}

	return $content;
}

sub serialize {
	my ($self, $content) = @_;

	if (! $content->isa('Wikidata::Content')) {
		err "Content must be a 'Wikidata::Content' instance.";
	}

	my $struct_hr = {};

	# Title
	if (defined $content->{'entity'}) {
		$struct_hr->{'title'} = $content->{'entity'};
	}

	# Aliases.
	foreach my $alias (@{$content->{'aliases'}}) {
		if (! exists $struct_hr->{'aliases'}) {
			$struct_hr->{'aliases'} = {};
		}
		if (! exists $struct_hr->{'aliases'}->{$alias->language}) {
			$struct_hr->{'aliases'}->{$alias->language} = [];
		}
		push @{$struct_hr->{'aliases'}->{$alias->language}}, {
			'value' => $alias->value,
			'language' => $alias->language,
		};
	}

	# Claims.
	foreach my $claim (@{$content->{'claims'}}) {
		if (! exists $struct_hr->{'claims'}->{$claim->snak->property}) {
			$struct_hr->{'claims'}->{$claim->snak->property} = [];
		}
		push @{$struct_hr->{'claims'}->{$claim->snak->property}},
			Wikidata::Datatype::Struct::Statement::obj2struct($claim);
	}

	# Descriptions.
	foreach my $description (@{$content->{'descriptions'}}) {
		$struct_hr->{'descriptions'}->{$description->language} = {
			'value' => $description->value,
			'language' => $description->language,
		};
	}

	# Labels.
	foreach my $label (@{$content->{'labels'}}) {
		$struct_hr->{'labels'}->{$label->language} = {
			'value' => $label->value,
			'language' => $label->language,
		};
	}

	# Sitelinks.
	foreach my $sitelink (@{$content->{'sitelinks'}}) {
		$struct_hr->{'sitelinks'}->{$sitelink->site} =
			Wikidata::Datatype::Struct::Sitelink::obj2struct($sitelink);
	}

	return $struct_hr;
}

1;
