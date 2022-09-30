#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat bundling);
use List::Util qw(max);

sub usage {
    my $code = shift;
    my @messages = @_;
    for my $message (@messages) {
        $message =~ s/\s*$/\n/s;
        ($message =~ /\S/) and print $message;
    }
    print << "END";
usage: $0 [options] MAX_WEIGHT[:MAX_WEIGHT:...] FILE[S...]
options:
  -c, --cofficient  value (3つ目の値) を係数で指定する。
  -s, --sort=SORTBY number (default), original
  -n, --only-number ナップサックの番号のみ出力する。
  -v, --verbose     詳細な情報を出力する。
  -h, --help        このメッセージを表示する。

args:
  MAX_WEIGHT[:MAX_WEIGHT:...]   ナップサックの最大容量。`:` 区切りで複数個分指定できる。
END
    exit $code;
}

sub main {
    scalar @ARGV or usage(0);
    my $opts = {
        };
    GetOptions($opts,
               "cofficient|c",
               "sort|s=s",
               "only-number|n",
               "verbose|v",
               "help|h" => sub { usage(0) });
    scalar @ARGV or usage(0);
    $opts->{verbose} and print Data::Dumper->Dump([$opts], [qw(opts)]);
    my $max_weights = [split ':', shift @ARGV];
    map { s/,//g; /^\d+$/ or usage(1, "MAX_WEIGHTは数値で指定してください。") } @$max_weights;
    my $names = [];
    my $name2item = {};
    while (<>) {
        m!^\s*#.*$! and next;
        m!^(?<name>.*?)\t(?<weight>[\d\.,]+)(\t(?<value_or_cofficient>[\d\.,]+))?$! or next;
        my ($name, $weight, $value_or_cofficient) = ($+{name}, $+{weight}, $+{value_or_cofficient});
        push @$names, $name;
        $weight =~ s/,//;
        $weight > max(@$max_weights) and usage(1, "最大のMAX_WEIGHTを超えるweightが指定されています: $_");
        $value_or_cofficient =~ s/,//;
        my $value = $opts->{cofficient} ? $weight * $value_or_cofficient : ($value_or_cofficient or $weight);
        $name2item->{$name} = { name => $name, weight => $weight, value_or_cofficient => $value_or_cofficient, value => $value };
    }
    $opts->{verbose} and print Data::Dumper->Dump([$name2item], [qw(name2item)]);
    my $solved_name2items_by_number = [];
    my $solved_name2item = {};
    my $max_weight;
    for (my $i = 0; scalar keys %$name2item > 0; ++$i) {
        $max_weight = (shift @$max_weights or $max_weight);
        my $solved_names = solve($opts, $max_weight, $name2item);
        push @$solved_name2items_by_number, [];
        map {
            $name2item->{$_}->{number} = $i + 1;
            push @{$solved_name2items_by_number->[$i]}, $name2item->{$_};
            $solved_name2item->{$_} = $name2item->{$_};
            delete $name2item->{$_};
        } sort @$solved_names;
    }
    if ($opts->{sort} and $opts->{sort} eq 'original') {
        for my $name (@$names) {
            my $item = $solved_name2item->{$name};
            if ($opts->{'only-number'}) {
                printf "$item->{number}\n";
            }
            else {
                printf "$item->{number}\t$name\t$item->{weight}\t$item->{value_or_cofficient}\n";
            }
        }
    }
    else {
        while (my ($i, $items) = each @$solved_name2items_by_number) {
            map { printf "%s\t$_->{name}\t$_->{weight}\t$_->{value_or_cofficient}\n", $i + 1 } @$items;
        }
    }
}

sub solve {
    my ($opts, $max_weight, $name2item) = @_;
    my $names = [sort keys %$name2item];
    my $n = scalar(@$names);
    my $dp = [];
    my $rs = [];
    for (my $i = 0; $i <= $n; ++$i) {
        push @$dp, [];
        push @$rs, [];
        for (my $w = 0; $w <= $max_weight; ++$w) {
            push @{$dp->[$i]}, 0;
            push @{$rs->[$i]}, {};
        }
    }
    for (my $i = $n - 1; $i >= 0; --$i) {
        for (my $w = 0; $w <= $max_weight; ++$w) {
            my $item = $name2item->{$names->[$i]};
            if ($w < $item->{weight}) {
                $dp->[$i]->[$w] = $dp->[$i + 1]->[$w];
                push_values2hash($rs->[$i]->[$w], keys %{$rs->[$i + 1]->[$w]});
            }
            else {
                my $exclude_value = $dp->[$i + 1]->[$w];
                my $include_value = $dp->[$i + 1]->[$w - $item->{weight}] + $item->{value};
                if ($exclude_value > $include_value) {
                    $dp->[$i]->[$w] = $exclude_value;
                    push_values2hash($rs->[$i]->[$w], keys %{$rs->[$i + 1]->[$w]});
                }
                else {
                    $dp->[$i]->[$w] = $include_value;
                    push_values2hash($rs->[$i]->[$w], $names->[$i]);
                    push_values2hash($rs->[$i]->[$w], keys %{$rs->[$i + 1]->[$w - $item->{weight}]});
                }
#                $dp->[$i]->[$w] = max($dp->[$i + 1]->[$w],
#                                      $dp->[$i + 1]->[$w - $item->{weight}] + $item->{value});
            }
        }
    }
    return [sort keys %{$rs->[0]->[$max_weight]}];
}

sub push_values2hash {
    my $h = shift;
    map { $h->{$_} = $_ } @_;
}

main;
