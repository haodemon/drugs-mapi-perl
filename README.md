# Drugs::Mapi

Drugs::Mapi - Wrapper module for http://mapi-us.iterar.co/

# SYNOPSIS

```perl
use Drugs::Mapi;

my $d = Drugs::Mapi->new();

$d->get_drugs('Ibuprofen')
# [ 'Ibuprofen', 'Ibuprofen and diphenhydramine citrate', <...> ]

$d->get_dosages('Aspirin')
# [ '25MG', '200MG', '325MG' ]

$d->get_ingredients('Propecia');
# [ 'Finasteride' ]
```
