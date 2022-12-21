requires 'Symbol::Get';

on configure => sub {
    requires 'ExtUtils::MakeMaker::CPANfile';
    requires 'ExtUtils::PkgConfig';
};

on test => sub {
    requires 'Test::FailWarnings';
    requires 'Test::Deep';
    requires 'JSON::PP';
};
