package JSON::Schema::Validator::Attributes::Properties;
use strict;
use warnings;
use utf8;
use parent qw(JSON::Schema::Validator::Attributes);

use Carp qw(croak);
use List::MoreUtils qw(all);
use JSON::Schema::Validator;

sub attr_name { 'properties' }

sub is_valid {
    my ($class, $context, $schema, $data) = @_;
    $context->in_attr($class, sub {
        return 1 unless ref $data eq 'HASH'; # ignore

        my $properties = $schema->{properties};
        unless (ref $properties eq 'HASH') {
            croak sprintf '`properties` must be an object at %s', $context->position
        }

        my $is_valid = 1;
        for my $prop (keys %$properties) {
            next unless exists $data->{$prop}; # skip

            my $sub_data = $data->{$prop};
            my $sub_schema = $properties->{$prop};
            my $res = $context->in($prop, sub {
                $context->sub_validator($sub_schema)->validate($sub_data, $context);
            });

            if (!$res) {
                $is_valid = 0;
                last;
            }
        }

        $is_valid;
    });
}

1;
