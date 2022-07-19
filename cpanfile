requires 'Symbol::Get';

on configure => sub {
    requires 'ExtUtils::MakeMaker::CPANfile';
    requires 'ExtUtils::PkgConfig';
};
