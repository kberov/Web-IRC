package WI::WWW::Mojo;
use Mojo::Base 'Mojolicious';
use 5.008001;
use strict;
use warnings;
use DateTime;
use JSON::XS qw|encode_json decode_json|;
use WI::Main;
use WI::WWW::Mojo::Nick;
use Mojo::Pg;
use WI::DB;

our $VERSION = "0.01";
my $channels = [];

sub startup {
    my $self = shift;
    $self->sessions->cookie_name( 'wi' );
    $self->sessions->default_expiration( 24*60*60*365 );#1 year

    my $r    = $self->routes;
    $r->namespaces( ['WI::WWW::Mojo::Controller'] );

    $r->route('/signup')->name('signup')
      ->to( controller => 'Auth', action => 'signup' );

    $r->route('/login')->name('login')
      ->to( controller => 'Auth', action => 'login' );

    $r->route('/')->name('index')
      ->to( controller => 'Page', action => 'index' );

    $r->route('/chat/')->name('chat_root')
      ->to( controller => 'Chat', action => 'root' );

    $r->route('/chat/:channel')->name('chat')
      ->to( controller => 'Chat', action => 'chat' );

#   $r->route('/enter')->name('chat_enter')
#     ->to( controller => 'Chat', action => 'chat_enter' );

    $r->websocket('/chat_ws/:channel')->name('chat_ws')
      ->to( controller => 'Chat', action => 'chat_ws' );

    $r->websocket('/irc_ws')->name('irc_ws')
      ->to( controller => 'Chat', action => 'irc_ws' );

    $r->route('/channel/list')->name('channel_list')
      ->to( controller => 'Channel', action => 'channel_list' );

    $self->helper( redis => sub { Redis->new } );

    $self->helper( channels => sub { $channels } );    #array with channels


    my $pg = Mojo::Pg->new( $ENV{WI_MOJO_PG_DSN} );
    $pg->max_connections(5);
    my $db = WI::DB->new( 
        pg => $pg, 
        _ref_main => $self, );

    $self->helper( wi_main => sub { WI::Main->new( _ref_main => $self, db => $db ) } );

    $self->helper(
        nick => sub { WI::WWW::Mojo::Nick->new( _ref_main => $self ) } );

    $self->helper(
        db => sub {
            $db
        }
    );
}

#get '/' => 'index';

sub user_channels {

    #returns an array with the channels the user is in
    my $self = shift;

    #query some database and see what chans are active.
}

sub lista_channels {

    #returns a sorted array with thte chanels avaliable
}

sub join_channel {

    #joins a given channel
    my $self    = shift;
    my $channel = shift;

    #   $self
}

sub part_channel {

    #parts a given channel
}

sub msg_chan {

    #sends a message to channel.Everyone in the channel can see it.
}

sub kick_user {

    #kicks a user from a channel. user must be operator in that channel
    #LOW PRIORITY
}

my $clients = {};

#websocket '/echo' => sub {
#   my $self = shift;
#   $self->inactivity_timeout(300);

#   app->log->debug(sprintf 'Client connected: %s', $self->tx);
#   my $id = sprintf "%s", $self->tx;
#   $clients->{$id} = $self->tx;

#   $self->on(message => sub {
#       my ($self, $msg) = @_;

#       my $dt   = DateTime->now( time_zone => 'Asia/Tokyo');

#       for (keys %$clients) {
#           $clients->{$_}->send({json => {
#               hms  => $dt->hms,
#               text => $msg,
#           }});
#       }
#   });

#   $self->on(finish => sub {
#       app->log->debug('Client disconnected');
#       delete $clients->{$id};
#   });
#};

#app->start;

1;
__END__

=encoding utf-8

=head1 NAME

WI::WWW::Mojo - It's new $module

=head1 SYNOPSIS

    use WI::WWW::Mojo;

=head1 DESCRIPTION

WI::WWW::Mojo is ...

=head1 LICENSE

Copyright (C) hernan604.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

hernan604 E<lt>E<gt>

=cut
