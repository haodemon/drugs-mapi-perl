# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Drugs-Mapi.t'

#########################

use strict;
use warnings;

use Test::More;
use Test::Deep;

BEGIN {
	plan   'tests' => 7;
	use_ok 'Drugs::Mapi';
};

#########################

my @data = (
	{
		drug    => 'Ibuprofen',
		matched => [
			'Ibuprofen',
			'Ibuprofen and pseudoephedrine hydrochloride',
			'Ibuprofen and diphenhydramine citrate',
			'Ibuprofen and diphenhydramine hydrochloride'
		],
		dosages => [
			'EQ 200MG FREE ACID AND POTASSIUM SALT',
			'25MG;EQ 200MG FREE ACID AND POTASSIUM SALT',
			'38MG;200MG',
			'40MG/ML',
			'50MG',
			'100MG/5ML;15MG/5ML',
			'100MG/5ML',
			'100MG',
			'200MG',
			'200MG;30MG',
			'300MG',
			'400MG',
			'600MG',
			'800MG'
		],
		ingredients => [
			'Diphenhydramine citrate; ibuprofen',
			'Diphenhydramine hydrochloride; ibuprofen',
			'Ibuprofen',
			'Ibuprofen; pseudoephedrine hydrochloride'
		],
	},
	{
		drug        => 'Propecia',
		matched     => [ 'Propecia' ],
		dosages     => [ '1MG' ],
		ingredients => [ 'Finasteride' ],
	},
);

my $drugs = Drugs::Mapi->new();

for my $data (@data) {
	my $drug = $data->{drug};

	cmp_deeply($data->{matched},     [$drugs->get_drugs($drug)],       "drugs for '$drug'");
	cmp_deeply($data->{dosages},     [$drugs->get_dosages($drug)],     "dosages for '$drug'");
	cmp_deeply($data->{ingredients}, [$drugs->get_ingredients($drug)], "ingredients for '$drug'")
};
