package Chart::HeatMap::Simple;

use 5.008008;
use strict;
use warnings;
use PostScript::Simple;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

#our %EXPORT_TAGS = ( 'all' => [ qw(
#	
#) ] );

#our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = (
	'new',
        'render_heatmap',
        'compare_to_first_column'
);

our $VERSION = '0.02';


# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.


my $compare_to_first_column = sub {
    my $self = shift;
    my $raw_array = $self->{_input_array};
    my $processed_array;
    if (1==$self->{_headings}){
        my $headings = shift @$raw_array;
        push @$processed_array,$headings;
    }
    for my $line (@$raw_array){
        my @result_row;
        if (1==$self->{_row_names}){
            my $label = shift @$line;
            push @result_row, $label;
        }
        push @result_row, colourdiff($line);
        push @$processed_array, \@result_row;
    }
    return $processed_array;
};

sub new {

    my $class = shift;
    my %params = @_;

    my $self ={
        _headings=> 1,
        _row_names=> 1,
        _input_array=>undef,
        _origin_x=>0.5,
        _origin_y=>10,
        _label_x=>1.5,
        _step=>0.25,
        _colour_distribution_function=>$compare_to_first_column,
       };
    #print $self->{_colour_distribution_function};
    foreach my $key (sort keys %params){
        $self->{$key}=$params{$key};
    }

    bless $self,$class;
    return $self;
}

sub render_heatmap{
    my ($self) = shift;
    my $p = new PostScript::Simple(papersize => "A4",
        colour => 1,
        eps => 0,
        units => "in");
    $p->newpage;

    #my $raw_array = $self->{_input_array}; 
    my $final_function = $self->{_colour_distribution_function};
    my $input_array = &$final_function($self);
    my $heading_array = shift @$input_array;

    if(1==$self->{_headings}){
#    print "making headings";
        my $xpos = $self->{_origin_x} + $self->{_label_x};
        my $ypos = $self->{_origin_y};
        my $first_col_heading = shift @$heading_array;
    
        $p->setcolour("black");
        $p->setfont("Times-Roman", 20);
        $p->text($self->{_origin_x},$ypos, $first_col_heading);

        for my $i (@$heading_array){
            $p->setcolour("black");
            $p->setfont("Times-Roman", 20);
            $p->text({rotate=>90},$xpos,$ypos, $i);
            $xpos = $xpos + $self->{_step};
        }
    } 

#    print "going over array";
    my $xpos = $self->{_origin_x} + $self->{_label_x};
    my $ypos = $self->{_origin_y};

    for my $line (@$input_array){

        if(1==$self->{_row_names}){
            $xpos = $self->{_origin_x} + $self->{_label_x};
            $ypos -= $self->{_step};

            my $line_label = shift @$line;
            $p->setcolour("black");
            $p->setfont("Times-Roman", 20);
            $p->text(
                $self->{_origin_x},
                $ypos, 
                $line_label
            );
        }
#        my $outarrayline = colourdiff($line);
        my $outarrayline = $line;
        for my $colourbox (@$outarrayline){
#            $p->setcolour(colour_from_number($colourbox));
#SCAFFOLDING
#            for my $scaffold (@$colourbox){my ($r, $g, $b)=@$scaffold;print "($r, $g, $b)";}
#            print "Next";
#SCAFFOLDING
            for my $colour (@$colourbox){
                my ($r,$g,$b) = @$colour;
                $p->setcolour($r,$g,$b);
    #            $p->setcolour(0,0,0);
                $p->box(
                    {filled=>1},
                    ($xpos - $self->{_step}),
                    ($ypos + $self->{_step}),
                    $xpos,
                    $ypos,
                );
                $xpos += $self->{_step};
            }
        } 
        
    } 
#http://www.unix.org.ua/orelly/perl/prog/ch03_102.htm
    $p->output(">-");
}

sub colour_from_number{
    my $number = shift;
#    my $p = shift;
    if (0>$number){
#        $p->setcolour(0,0,$number);
        return (0,0,abs ($number));
    }
    elsif (0<$number){
#        $p->setcolour($number,0,0);
        return ($number,0,0);
    }else{
#        $p->setcolour(0,0,0);
        return (0,0,0);
        
    }
}

sub colourdiff{
    my $i = shift;
#    my @outarray;
    my @outarrayline;
    my @sorted = sort{abs($a)<=>abs($b)} @$i;
    my $greatest = abs($sorted[$#sorted]);
#    print $greatest ,"\n";
    for my $j (@$i){
#        print "$j = ", (($j-@$i[0])/$greatest * 255);
        my @value = colour_from_number((($j-@$i[0])/$greatest * 255));
#        push @outarrayline, (($j-@$i[0])/$greatest * 255);
#        push @outarrayline, \@value;
        push @outarrayline, \@value;
#        print $j;
    }
   return \@outarrayline;
}


1;
__END__
=head1 NAME

Chart::HeatMap::Simple - Perl extension for producing a simple heatmap graph

=head1 SYNOPSIS

  use Chart::HeatMap::Simple;

  my @array;

  while (<STDIN>){
     my @line = split (/[,\t]/,$_);
     push @array, \@line;
  }


  my $HeatMap = new Chart::HeatMap::Simple(_input_array=>\@array);
  $HeatMap->render_heatmap();


=head1 DESCRIPTION

Chart::HeatMap::Simple is an easy way to produce heatmaps from arbitary 2D arrays. 
It uses only one dependency PostScript::Simple and features a programmer replacable colour distribution.

=head2 EXPORT

new
render_heatmap
compare_to_first_column




=head1 SEE ALSO

=head1 AUTHOR

Thuan-Jin Kee, E<lt>jin.kee@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Thuan-Jin Kee

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
