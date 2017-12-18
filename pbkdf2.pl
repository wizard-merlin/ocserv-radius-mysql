#!/usr/bin/perl
use strict;
use warnings;
use Crypt::PBKDF2;

sub usage {
	my $name = $0;
	$name =~ s,.*/,,;

	die "Usage: \n
  to generate encrypted password, run \n
  \t$name <plaintext password>\n
  to validate encrypted password, run\n
  \t$name --check <plaintext password> <crypted_password>\n";
}

my $pbkdf2 = Crypt::PBKDF2->new(
	hash_class => 'HMACSHA2',
	hash_args => {
		sha_size => 512,
	},
    iterations => 10000,
    salt_len => 10,
);

my $argc = @ARGV;
if ($argc == 1) {
  my $hash = $pbkdf2->generate($ARGV[0]);
  print $hash;
  print "\n";
} elsif ($argc == 3 && $ARGV[0] eq "--check") {
  my $password = $ARGV[1];
  my $hash = $ARGV[2];
  if ($pbkdf2->validate($hash, $password)) {
      print "correct password\n"
  } else {
      print "wrong password\n"
  }
} else {
  usage();
}
