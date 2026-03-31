# mention_report.pl - Caches nick mentions while away and reports on return.
#
# Copyright (c) 2026 Exaga - SAIRPi Project : https://sairpi.penthux.net/


use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "1.01";
%IRSSI = (
    authors     => 'Exaga',
    contact     => 'sairpiproject@gmail.com',
    name        => 'mention_report',
    description => 'caches highlights while away',
    license     => 'Public Domain'
);

my @msgs;

sub sig_print_text {
    my ($dest, $text, $stripped) = @_;
    return unless $dest->{server}->{usermode_away};
    
    if ($dest->{level} & (MSGLEVEL_HILIGHT | MSGLEVEL_MSGS)) {
        my $time = Irssi::settings_get_str('timestamp_format') || "%H:%M";
        push @msgs, " " . CORE::localtime() . " " . ($dest->{target} || "PM") . "> $stripped";
    }
}

sub event_away {
    my ($server, $away) = @_;
    return if $away; # only trigger when coming back
    
    if (@msgs) {
        Irssi::print("--- missed mentions ---");
        Irssi::print($_) for @msgs;
        Irssi::print("--- end ---");
        @msgs = ();
    }
}

Irssi::signal_add('print text', 'sig_print_text');
Irssi::signal_add('away mode changed', 'event_away');

# EOF<*>
