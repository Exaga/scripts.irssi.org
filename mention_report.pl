# mention_report.pl
# buffers hilights and PMs while away and reports them on return.

use strict;
use warnings;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = '1.10';
%IRSSI = (
    authors     => 'Exaga',
    contact     => 'sairpiproject@gmail.com',
    name        => 'mention_report',
    description => 'Buffers hilights and PMs while away, then prints them on return.',
    license     => 'Public Domain',
);

my @buffer;

Irssi::settings_add_bool('mention_report', 'mention_report_show_privmsg', 1);
Irssi::settings_add_bool('mention_report', 'mention_report_show_hilight', 1);
Irssi::settings_add_int('mention_report',  'mention_report_max_lines', 50);
Irssi::settings_add_str('mention_report',  'mention_report_time_format', '%Y-%m-%d %H:%M:%S');
Irssi::settings_add_str('mention_report',  'mention_report_header', '--- missed messages while away ---');
Irssi::settings_add_str('mention_report',  'mention_report_footer', '--- end ---');

sub _is_away {
    my ($server) = @_;
    return 0 unless $server;
    return $server->{usermode_away} ? 1 : 0;
}

sub _should_store {
    my ($dest) = @_;
    return 0 unless $dest;
    return 0 unless _is_away($dest->{server});

    my $want_hilight = Irssi::settings_get_bool('mention_report_show_hilight');
    my $want_privmsg = Irssi::settings_get_bool('mention_report_show_privmsg');

    return 1 if $want_hilight && ($dest->{level} & MSGLEVEL_HILIGHT);
    return 1 if $want_privmsg && ($dest->{level} & MSGLEVEL_MSGS);

    return 0;
}

sub _timestamp {
    my $fmt = Irssi::settings_get_str('mention_report_time_format');
    return Irssi::strftime($fmt, localtime(time()));
}

sub _trim_buffer {
    my $max = Irssi::settings_get_int('mention_report_max_lines');
    $max = 1 if $max < 1;

    while (@buffer > $max) {
        shift @buffer;
    }
}

sub sig_print_text {
    my ($dest, $text, $stripped) = @_;
    return unless _should_store($dest);

    my $server_tag = $dest->{server} ? $dest->{server}->{tag} : '-';
    my $target     = $dest->{target} || 'PM';
    my $line       = sprintf('[%s] [%s] %s> %s', _timestamp(), $server_tag, $target, $stripped);

    push @buffer, $line;
    _trim_buffer();
}

sub event_away_mode_changed {
    my ($server, $away) = @_;

    return if $away;      # only act when coming back
    return unless @buffer;

    my $header = Irssi::settings_get_str('mention_report_header');
    my $footer = Irssi::settings_get_str('mention_report_footer');

    Irssi::print($header);
    Irssi::print($_) for @buffer;
    Irssi::print($footer);

    @buffer = ();
}

sub cmd_mention_report {
    if (!@buffer) {
        Irssi::print('mention_report: buffer is empty.');
        return;
    }

    Irssi::print('mention_report: buffered lines: ' . scalar(@buffer));
    Irssi::print($_) for @buffer;
}

sub cmd_mention_report_clear {
    @buffer = ();
    Irssi::print('mention_report: buffer cleared.');
}

Irssi::signal_add('print text', 'sig_print_text');
Irssi::signal_add('away mode changed', 'event_away_mode_changed');

Irssi::command_bind('mention_report', 'cmd_mention_report');
Irssi::command_bind('mention_report_clear', 'cmd_mention_report_clear');
