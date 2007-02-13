use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Chart::HeatMap::Simple',
    VERSION_FROM      => 'lib/Chart/HeatMap/Simple.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Chart/HeatMap/Simple.pm', # retrieve abstract from module
       AUTHOR         => 'Thuan-Jin Kee <jinkee@(none)>') : ()),
);
