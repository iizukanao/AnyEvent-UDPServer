use inc::Module::Install;
name 'AnyEvent-UDPServer';
all_from 'lib/AnyEvent/UDPServer.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
