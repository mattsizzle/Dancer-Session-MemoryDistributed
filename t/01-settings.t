use strict;
use warnings;
use Test::More;
use Test::Exception;
use Dancer::Config 'setting';
use Dancer::Session::MemoryDistributed;

can_ok 'Dancer::Session::MemoryDistributed', qw(create retrieve flush destroy init MemoryDistributed);

# no settings
throws_ok { Dancer::Session::MemoryDistributed->create }
    qr/MemoryDistributed_session is not defined/, 'settings for backend is not found';

# invalid settings
setting MemoryDistributed_session => [];
throws_ok { Dancer::Session::MemoryDistributed->create }
    qr/MemoryDistributed_session must be a hash reference/, 'settings is not a hashref';

# incomplete settings
setting MemoryDistributed_session => {};
throws_ok { Dancer::Session::MemoryDistributed->create }
    qr/MemoryDistributed_session should.*either server or sock parameter/, 'connection param is not found in settings';

done_testing();