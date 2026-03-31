# mention_report.pl - Caches nick mentions while away and reports on return.
#
# Copyright (c) 2026 Exaga - SAIRPi Project : https://sairpi.penthux.net/
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


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
