#!/usr/bin/perl -s
use strict;

use Test::More tests => 8;

BEGIN {
	use_ok( 'Amazon::SQS::Producer', 'use Amazon::SQS::Producer' );
}

BEGIN {
	use_ok( 'Amazon::SQS::Consumer', 'use Amazon::SQS::Consumer' );
}

if ( ! $ENV{AWS_PUBLIC_KEY} ) { diag( 'Did you set the env var AWS_PUBLIC_KEY?' ) && die }
if ( ! $ENV{AWS_SECRET_KEY} ) { diag( 'Did you set the env var AWS_SECRET_KEY?' ) && die }

my $in_queue = new Amazon::SQS::Consumer
	AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
	SecretAccessKey => $ENV{AWS_SECRET_KEY},
	queue => 'TestQueue',
	wait_seconds => 120;

if ( ! $in_queue ) { diag( 'Did you create the SQS queue TestQueue?' ) && die }

my $out_queue = new Amazon::SQS::Producer
	AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
	SecretAccessKey => $ENV{AWS_SECRET_KEY},
	queue => 'TestQueue';

my $n;

ITEM: while ( my $item = $in_queue->next ) {

	ok( $item ) || warn 'Out of messages' && last;

	$out_queue->publish( $item );
	last if ++$n == 5;
	sleep 1;

}

is( $n, 5, 'publish and consume 5 items');

done_testing();