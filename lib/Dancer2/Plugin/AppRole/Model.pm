package Dancer2::Plugin::AppRole::Model;

use strictures 2;

use Module::Runtime 'use_module';
use Types::Standard 'HashRef';

use Moo::Role;

# VERSION

# ABSTRACT: role for the gantry to hang a model layer onto Dancer2

# COPYRIGHT

has model =>    #
  is      => "rw",
  lazy    => 1,
  builder => sub {
    my ( $self ) = @_;

    for ( $self->setting( "parent_model" ) ) { return $_ if $_ }

    my %args  = %{ $self->model_args };
    my $model = use_module( $self->name . "::Model" )->new( %args );
    return $model;
  };

has model_args =>    #
  ( is => 'rw', isa => HashRef, lazy => 1, builder => sub { {} } );

1;
