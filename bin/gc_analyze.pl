#!/usr/bin/perl
#pragma ident "@(#)gc_analyze.pl 1.1 02/05/03 gc_analyze.pl"
#
# Author: Nagendra Nagarajayya
#      	  MDE (IPE/CSI), Sun Microsystems, Inc.
#
# Usage: gc_analyze.pl [-d] gclogfile CPS active_call_duration cpus \
#				application_run_time_inms 
#
# 	parameters:
#		-d - print out detailed analysis along with summary
#		gclogifle - verbosegc log file
#		CPS - call-setups / second (defaults to 50)
#		active_call_duration - Duration call-setup is active 
#			(defaults to 32 secs)	
#		cpus - number of cpus on the system (defaults to 1)
#		application_run_time_inms - number of ms application was run
#			(calculated from GC time stamps )
#
# Description:
#	This program analyzes a verbosegc  log file on a time scale,
#	and prints various application, and GC metrics. See paper
#	for more details.
#
# DISCLAIMER  
# This is not the most efficient script aesthetically or performance
# wise, but it works   ;-)
#
#
use Time::Local;

$detailed = 0;
if ( $ARGV[0] =~ /-d/ ) {
	$detailed = 1;
}

$logname = $ARGV[ ( 0 + $detailed ) ];
open( GC, $logname )
  or die
"Usage: gc_analyze.pl gclogfile CPS active_call_duration cpus application_run_time_inms 

default values :
	CPS = 55
	active_call_duration = 32000 ms
	number of CPUS = 1
	appplication run time = calculated from gc time stamps

note: specify \"-\" to use default values on command line	

";

$CPS                       = $ARGV[ ( 1 + $detailed ) ];
$active_call_duration      = $ARGV[ ( 2 + $detailed ) ];
$cpus                      = $ARGV[ ( 3 + $detailed ) ];
$application_run_time_inms = $ARGV[ ( 4 + $detailed ) ];

print STDERR "\n\n";
print STDERR "Processing $logname ...\n\n";

if ( $CPS == "" ) {

	#	print STDERR "no CPS specified, will use default value of 55\n";
	$CPS = 55;
}
elsif ( $CPS == '-' ) {
	$CPS = 55;
}

if ( $active_call_duration == "" ) {

	#	print STDERR "no active call duration, will use default value of 32000 ms\n";
	$active_call_duration = 32000;
}
elsif ( $active_call_duration == '-' ) {
	$active_call_duration = 32000;
}

if ( $application_run_time_inms == "" ) {

	#	print STDERR "no application runtime in ms, will use gc duration as runtime from log \n";
}

if ( $cpus == "" ) {
	$cpus = 1;
}

if ( $application_run_time_inms == "" ) {

	#	print STDERR "no application runtime provided, will use GC duration as runtime from log \n";
}

print STDERR "Call rate = $CPS cps ...\n";
print STDERR "Active call-setup duration = $active_call_duration ms\n";
print STDERR sprintf "Number of CPUs = %d \n", $cpus;

$semi_space_size = ( 8 * 1024 );
$total_mem       = 504;
$begin_time      = 0;
$end_time        = 0;

$gen0_count               = 0;
$gen0_tenure_count        = 0;
$gen0_tenure_thresh_total = 0;
$gen0_tenure_thresh_avg   = 0;
$gen0_tenure_time_total   = 0;
$gen0_tenure_time_avg     = 0;
$gen0_tenure_free_total   = 0;
$gen0_tenure_free_avg     = 0;

$gen0_promoted_count         = 0;
$gen0_promoted_thresh_total  = 0;
$gen0_promoted_thresh_avg    = 0;
$gen0_promoted_time_total    = 0;
$gen0_promoted_time_avg      = 0;
$gen0_promoted_free_total    = 0;
$gen0_promoted_free_avg      = 0;
$gen0_promoted_objects_total = 0;
$gen0_promoted_objects_avg   = 0;
$gen0_promoted_size_total    = 0;
$gen0_promoted_size_avg      = 0;

$gen1_gcs_count                  = 0;
$gen1_resize_count               = 0;
$gen1_resize_time_total          = 0;
$gen1_resize_time_avg            = 0;
$gen1_resize_f_mem_size_total    = 0;
$gen1_resize_f_mem_size_avg      = 0;
$gen1_resize_f_mem_percent_total = 0;
$gen1_resize_f_mem_percent_avg   = 0;
$gen1_resize_app_time_total      = 0;
$gen1_resize_app_time_avg        = 0;

$gen1_remark_count               = 0;
$gen1_remark_time_total          = 0;
$gen1_remark_time_avg            = 0;
$gen1_remark_f_mem_size_total    = 0;
$gen1_remark_f_mem_size_avg      = 0;
$gen1_remark_f_mem_percent_total = 0;
$gen1_remark_f_mem_percent_avg   = 0;
$gen1_remark_app_time_total      = 0;
$gen1_remark_app_time_avg        = 0;

$gen1_initmark_count               = 0;
$gen1_initmark_time_total          = 0;
$gen1_initmark_time_avg            = 0;
$gen1_initmark_f_mem_size_total    = 0;
$gen1_initmark_f_mem_size_avg      = 0;
$gen1_initmark_f_mem_percent_total = 0;
$gen1_initmark_f_mem_percent_avg   = 0;
$gen1_initmark_app_time_total      = 0;
$gen1_initmark_app_time_avg        = 0;

$gen1_ms_count          = 0;
$gen1_ms_time_total     = 0;
$gen1_ms_mem_total      = 0;
$gen1_ms_app_time_total = 0;

# changes to incorporate concurrent gc cost
$total_conc_gc_time      = 0;
$conc_gc_track_time      = 0;
$conc_gc_time            = 0;
$total_conc_gc_time_inms = 0;

while ( $line = <GC> ) {
	if ( $line =~ /^Starting GC/ ) {
		( $a, $b, $c, $d, $e, $f, $g, $h ) = split ( ' ', $line );
		( $hr, $min, $sec ) = split ( ':', $g );
		($yr) = split ( ';', $h );
		$time = timelocal( $sec, $min, $hr, $f );
		if ( $begin_time == 0 ) {
			$begin_time     = $time;
			$begin_time_str = "$d $e $f $hr $min $sec $yr";
		}
		else {
			$end_time     = $time;
			$end_time_str = "$d $e $f $hr $min $sec $yr";
		}

		$conc_gc_track_time = $time;
	}

	if ( $line =~ /space\[0/ ) {
		( $a, $b ) = split ( '=', $line );
		if ( $b =~ /Mb/ ) {
			($semi_space_size) = split ( 'M', $b );
			$semi_space_size *= 1024;
		}
		elsif ( $b =~ /kb/ ) {
			($semi_space_size) = split ( 'k', $b );
		}
	}

	if ( $line =~ /Gen0/ ) {
		( $t, $gc_id, $tenure_thresh, $time, $free, $f, $p, $promoted, $size ) =
		  split ( ' ', $line );

		$gen0_count = $gc_id;
		if ( $p =~ /promoted/ ) {
			$gen0_promoted_count++;
			( $a, $b ) = split ( '=', $tenure_thresh );
			$gen0_promoted_thresh_total += $b;
			( $a, $b ) = split ( 'ms', $time );
			$gen0_promoted_time_total += $a;
			( $a, $b ) = split ( '>', $free );
			( $a, $c ) = split ( '%', $b );
			$gen0_promoted_free_total    += $a;
			$gen0_promoted_objects_total += $promoted;
			( $a, $b ) = split ( '/', $size );
			( $a, $c ) = split ( 'k', $b );
			$gen0_promoted_size_total += $a;
			$tenure = 1;
		}
		else {
			$gen0_tenure_count++;
			( $a, $b ) = split ( '=', $tenure_thresh );
			$gen0_tenure_thresh_total += $b;
			( $a, $b ) = split ( 'ms', $time );
			$gen0_tenure_time_total += $a;
			( $a, $b ) = split ( '>', $free );
			( $a, $c ) = split ( '%', $b );
			$gen0_tenure_free_total += $a;
			$tenure = 0;
		}
	}

	if ( $line =~ /GC\[0/ ) {
		if ( $line =~ /application/ ) {
			(
			  $a, $b, $c, $d, $time, $d1, $s_tmem, $per, $e, $f, $g, $k,
			  $app_time, $g, $h, $words
			  )
			  = split ( ' ', $line );
			$young_gc_app_time += $app_time;
			if ( $tenure == 0 ) {
				$total_tenure_time = $total_tenure_time + $c;
			}
			else {
				$total_promotion_time = $total_promotion_time + $c;
			}
		}
	}

	if ( $line =~ /GC\[1\] in/ ) {
		$gen1_ms_count++;
		(
		  $a, $b, $time, $d, $d1, $s_tmem, $per, $e, $f, $g, $h, $k, $app_time,
		  $i, $g, $h, $words
		  )
		  = split ( ' ', $line );
		( $free, $b ) = split ( '%', $s_tmem );
		$gen1_ms_time_total     += $time;
		$gen1_ms_mem_total      += $free;
		$gen1_ms_app_time_total += $app_time;
		$old_generation_mem = $s_tmem;
	}
	elsif ( $line =~ /GC\[1/ ) {
		if ( $line =~ /resize/ ) {
			$gen1_resize_count++;
			(
			  $a, $b, $c, $d, $time, $d1, $s_tmem, $per, $e, $f, $g, $h, $k, $i,
			  $app_time, $g, $h, $words
			  )
			  = split ( ' ', $line );
			$gen1_resize_time_total += $time;
			( $a, $p, $c ) = split ( ' ', $s_tmem );
			( $b, $c ) = split ( 'M',  $a );
			( $a, $c ) = split ( '\(', $b );
			$gen1_resize_f_mem_size_total += $c;
			( $a, $b ) = split ( '%', $per );
			$gen1_resize_f_mem_percent_total += $a;
			$gen1_resize_app_time_total      += $app_time;
			$conc_gc_time = $conc_gc_track_time - $conc_gc_time;
			$total_conc_gc_time += $conc_gc_time;
		}
		elsif ( $line =~ /remark/ ) {
			$gen1_remark_count++;
			(
			  $a, $b, $c, $time, $d1, $s_tmem, $per, $e, $f, $g, $h, $k, $i,
			  $app_time, $g, $h, $words
			  )
			  = split ( ' ', $line );
			$gen1_remark_time_total += $time;
			( $a, $p, $c ) = split ( ' ', $s_tmem );
			( $b, $c ) = split ( 'M',  $a );
			( $a, $c ) = split ( '\(', $b );
			$gen1_remark_f_mem_size_total += $c;
			( $a, $b ) = split ( '%', $per );
			$gen1_remark_f_mem_percent_total += $a;
			$gen1_remark_app_time_total      += $app_time;
		}
		elsif ( $line =~ /initial/ ) {
			$gen1_initmark_count++;
			(
			  $a, $b, $c, $d, $time, $d1, $s_tmem, $per, $e, $f, $g, $h, $k, $i,
			  $app_time, $g, $h, $words
			  )
			  = split ( ' ', $line );
			$gen1_initmark_time_total += $time;
			( $a, $p, $c ) = split ( ' ', $s_tmem );
			( $b, $c ) = split ( 'M',  $a );
			( $a, $c ) = split ( '\(', $b );
			$gen1_initmark_f_mem_size_total += $c;
			( $a, $b ) = split ( '%', $per );
			$gen1_initmark_f_mem_percent_total += $a;
			$gen1_initmark_app_time_total      += $app_time;
			$conc_gc_time = $conc_gc_track_time;
		}
	}
}

$tmp                      = $gen0_promoted_time_total;
$tmp1                     = $total_promotion_time;
$gen0_promoted_time_total = $tmp1;
$total_promotion_time     = $tmp;
$tmp                      = $gen0_tenure_time_total;
$tmp1                     = $total_tenure_time;
$gen0_tenure_time_total   = $tmp1;
$total_tenure_time        = $tmp;

$semi_space_size_inbytes = $semi_space_size * 1024;

#gen 0 stats
if ( $gen0_tenure_count > 0 ) {
	$gen0_tenure_thresh_avg = $gen0_tenure_thresh_total / $gen0_tenure_count;
	$gen0_tenure_free_avg   = $gen0_tenure_free_total / $gen0_tenure_count;
	$gen0_tenure_copy_time  = $total_tenure_time / $gen0_tenure_count;
	$gen0_tenure_time_avg   = $total_tenure_time / $gen0_tenure_count;
	$gen0_tenure_overhead   =
	  ( $gen0_tenure_time_total - $total_tenure_time ) / $gen0_tenure_count;
}

$gen0_promoted_free_avg    = $gen0_promoted_free_total / $gen0_promoted_count;
$gen0_promoted_objects_avg =
  $gen0_promoted_objects_total / $gen0_promoted_count;
$gen0_promoted_size_avg  = $gen0_promoted_size_total / $gen0_promoted_count;
$gen0_promoted_copy_time = $total_promotion_time / $gen0_promoted_count;
$gen0_promoted_time_avg  = $total_promotion_time / $gen0_promoted_count;
$gen0_promoted_overhead  =
  ( $gen0_promoted_time_total - $total_promotion_time ) / $gen0_promoted_count;

#gen1 stats

if ( $gen1_resize_count > 0 ) {
	$gen1_resize_time_avg       = $gen1_resize_time_total / $gen1_resize_count;
	$gen1_resize_f_mem_size_avg =
	  $gen1_resize_f_mem_size_total / $gen1_resize_count;
	$gen1_resize_f_mem_percent_avg =
	  $gen1_resize_f_mem_percent_total / $gen1_resize_count;
	$gen1_resize_app_time_avg =
	  $gen1_resize_app_time_total / $gen1_resize_count;
}

if ( $gen1_remark_count > 0 ) {
	$gen1_remark_time_avg       = $gen1_remark_time_total / $gen1_remark_count;
	$gen1_remark_f_mem_size_avg =
	  $gen1_remark_f_mem_size_total / $gen1_remark_count;
	$gen1_remark_f_mem_percent_avg =
	  $gen1_remark_f_mem_percent_total / $gen1_remark_count;
	$gen1_remark_app_time_avg =
	  $gen1_remark_app_time_total / $gen1_remark_count;
}

if ( $gen1_initmark_count > 0 ) {
	$gen1_initmark_time_avg = $gen1_initmark_time_total / $gen1_initmark_count;
	$gen1_initmark_f_mem_size_avg =
	  $gen1_initmark_f_mem_size_total / $gen1_initmark_count;
	$gen1_initmark_f_mem_percent_avg =
	  $gen1_initmark_f_mem_percent_total / $gen1_initmark_count;
	$gen1_initmark_app_time_avg =
	  $gen1_initmark_app_time_total / $gen1_initmark_count;
}

if ( $gen1_ms_count > 0 ) {
	$gen1_ms_time_avg     = $gen1_ms_time_total / $gen1_ms_count;
	$gen1_ms_mem_avg      = $gen1_ms_mem_total / $gen1_ms_count;
	$gen1_ms_app_time_avg = $gen1_ms_app_time_total / $gen1_ms_count;
}

$gen1_gcs_count =
  ( $gen1_initmark_count + $gen1_remark_count + $gen1_resize_count );
$total_mem         = $gen1_initmark_f_mem_size_avg;
$total_mem_inbytes = ( $gen1_initmark_f_mem_size_avg * 1024 * 1024 );

# Ratio calculations
# total run time in ms
$total_time      = $end_time - $begin_time;
$total_time_inms = $total_time * 1000;

#print STDERR "DEBUG timecalc: $begin_time $end_time $total_time $total_time_inms\n";
#print STDERR "DEBUG timestr: $begin_time_str $end_time_str\n";
if ( $application_run_time_inms == "" ) {
	$application_run_time_inms = $total_time_inms;
}

#number of young promoted gcs -> $gen0_promoted_count
#avg. young objects promoted  -> $gen0_promoted_size_avg
#avg. #of Objects promoted -> $gen0_promoted_objects_avg

#avg object size promoted 
$young_gc_promoted_objects_size_avg_inbytes =
  ( $gen0_promoted_size_avg * 1024 );

#total object promoted times ->  $gen0_promoted_time_avg,

#avg. object promoted times 
$young_gc_promoted_objects_times_avg_inms = $gen0_promoted_time_avg;

#Frequency of object promoted gcs
$freq_promoted_gcs_inms =
  ( $application_run_time_inms - $gen0_promoted_time_total ) /
  $gen0_promoted_count;
$percent_promoted_gc_pause =
  $gen0_promoted_time_total * 100 / $application_run_time_inms;

#Total tenure times -> $gen0_tenure_time_total
#Total tenure gcs -> $gen0_tenure_count
#avg. tenure gc -> $gen0_tenure_time_avg
#Frequency of tenure gcs 

if ( $gen0_tenure_count > 0 ) {
	$freq_tenure_gcs_inms =
	  ( $application_run_time_inms - $gen0_tenure_time_total ) /
	  $gen0_tenure_count;
	$tenure_gc_pause_inms    = $gen0_tenure_time_total / $gen0_tenure_count;
	$percent_tenure_gc_pause =
	  $gen0_tenure_time_total * 100 / $application_run_time_inms;
}

#Total # of young gcs
$young_gc_count = $gen0_tenure_count + $gen0_promoted_count;

#

#print STDERR "gen0_tenure_coutn=$gen0_tenure_count\n";
#Total time of young gc
$young_gc_time_total_inms_inms =
  $gen0_tenure_time_total + $gen0_promoted_time_total;
$percent_young_gc_pause =
  $young_gc_time_total_inms_inms * 100 / $application_run_time_inms;

# tradional mark - sweep  gc percent
$percent_ms_gc_pause = $gen1_ms_time_total / $application_run_time_inms;

# avg. young gc pauses
$young_gc_time_avg_inms_inms = $young_gc_time_total_inms_inms / $young_gc_count;
$young_gc_copy_time_inms     =
  ( $total_promotion_time + $total_tenure_time ) / $young_gc_count;
$young_gc_overhead_time_inms =
  $young_gc_time_avg_inms_inms - $young_gc_copy_time_inms;
$young_gc_total_overhead_time_inms = $young_gc_time_total_inms_inms -
  ( $total_promotion_time + $total_tenure_time );
$promotion_gc_total_overhead_time_inms =
  $gen0_promoted_total_times - $total_promotion_time;
$tenure_gc_total_overhead_time_inms =
  $gen0_tenure_total_times - $total_tenure_time;

#Frequency of young gcs 20640000 / 24184 = 853 ms
$freq_young_gcs_inms =
  ( $application_run_time_inms - $young_gc_time_total_inms_inms ) /
  $young_gc_count;
$count_of_young_gcs_inasec = 1000 / $freq_young_gcs_inms;

#Tenure rate information  
$freq_tenure_gcs_inms       = 0;
$count_of_tenure_gcs_inasec = 0;
if ( $gen0_tenure_count > 0 ) {
	$freq_tenure_gcs_inms =
	  ( $application_run_time_inms - $gen0_tenure_time_total ) /
	  $gen0_tenure_count;
	$count_of_tenure_gcs_inasec = 1000 / $freq_tenure_gcs_inms;
}

#Total old gen times 
$old_gc_time_total_inms_inms =
  $gen1_resize_time_total + $gen1_remark_time_total + $gen1_initmark_time_total;

#Total # of old gen gcs -> $gen1_gcs_count
#Total # of old gen pauses 
#$old_gc_0_size_pauses = $gen1_resize_count;
# to adjust code to reflect all three gcs 
$old_gc_0_size_pauses = 0;

#Total # of actual old gen gcs 
$actual_old_gc_count = $gen1_gcs_count - $old_gc_0_size_pauses;

#Total old gen gcs = 3 cycles -> 1 full gc 
$real_old_gc_count = abs( $gen1_gcs_count / 3 );

#Avg. old gen pauses 
if ( $gen1_gcs_count > 0 ) {
	$old_gc_time_avg_inms_inms = $old_gc_time_total_inms_inms / $gen1_gcs_count;
}

#Actual avg. old gen pauses 
$actual_old_gc_time_avg_inms_inms =
  $old_gc_time_total_inms_inms / $actual_old_gc_count;

#$real_old_gc_time_avg_inms_inms = $old_gc_time_total_inms_inms / $actual_old_gc_count;

#Frequency of old gen gc 
$freq_old_gc_inms = $application_run_time_inms / $gen1_gcs_count;

#Actual Frequency of old gen gc 
$actual_freq_old_gc_inms = $application_run_time_inms / $actual_old_gc_count;
$init_freq_old_gc_inms   = $application_run_time_inms / $gen1_initmark_count;

#Total gc time 
$gc_time_total_inms =
  $young_gc_time_total_inms_inms + $old_gc_time_total_inms_inms +
  gen1_ms_time_total;

#Avg. gc pause 
$gc_time_avg_inms =
  $gc_time_total_inms / ( $gen1_gcs_count + $young_gc_count + $gen1_ms_count );

#Actual avg. gc pause 
$actual_gc_time_avg_inms = $gc_time_total_inms /
  ( $actual_old_gc_count + $young_gc_count + $gen1_ms_count );

#threshold calculations

#total memory

#Live object thresh = 63%, $gen1_resize_f_mem_percent_avg
$resize_object_thresh_avg = ( $gen1_resize_f_mem_percent_avg / 100 );

#print "DEBUG resize = $resize_object_thresh_avg\n";
#Live object mb = 504 * .63 = 317 M
#print "DEBUG total_me = $total_mem\n";
$resize_object_size         = $total_mem * $resize_object_thresh_avg;
$resize_object_size_inbytes = ( $resize_object_size * 1024 * 1024 );

#print "DEBUG resize_object_size = $resize_object_size\n";

#Dead object thresh (init mark)= 32%, $gen1_initmark_f_mem_percent_avg
$init_object_thresh_avg = $gen1_initmark_f_mem_percent_avg / 100;

#Dead object mb 
$init_object_size_inmb    = $total_mem * $init_object_thresh_avg;
$init_object_size_inbytes = $init_object_size_inmb * 1024 * 1024;

#Dead object avg. thresh (remark)= 30%
$remark_object_thresh_avg = $gen1_remark_f_mem_percent_avg / 100;

#Dead object mb (with remark free size)
$remark_object_size_inmb    = $total_mem * $remark_object_thresh_avg;
$remark_object_size_inbytes = $remark_object_size_inmb * 1024 * 1024;

#Dead objects size 
#print "DEBBUG $resize_object_size - $remark_object_size\n";
$dead_old_gc_object_size_inmb = $resize_object_size - $remark_object_size_inmb;

#Live objects size after full gc = 504 - 317 = 187e
#print STDERR "$total_mem - $resize_object_size\n";
$live_old_gc_object_size_inmb = $total_mem - $resize_object_size;

#Ratio of short lived / long lived objects old GC = 156 / 187 = .832
$ratio_old_gc_sbyl_objects =
  $dead_old_gc_object_size_inmb / $live_old_gc_object_size_inmb;

#some verification
#Total size of objects promoted = 4.7 * 12091 = 56827 M
$total_size_objects_promoted_inkb = ($gen0_promoted_size_total);

#Total size of objects full GC collected thru appplication run = 156 M * 334  = 52104 M
$total_size_objects_collected_inkb =
  ( $dead_old_gc_object_size_inmb * $real_old_gc_count ) * 1024;

# avg. size of short live objects in young gc
# avg. long lived tenure size(c) = semi-space*((100% - avg. free tenure %)/100)
# avg. short lived tenure gc size(a) = semi-space - (long lived tenure size)
# avg. short lived promoted gc size(b) = semi-space - promoted size;
# avg. short lived objects, young gc = (a + b) / 2;
# avg. long lived objects, young gc = (c + promoted objects) / 3;
# the reason for / 3 by is due to the fact that tenure gc objects
# need to be accounted for
$times_copied = 1;
if ( $gen0_tenure_count > 0 ) {
	$times_copied = 2;
}
$c = $semi_space_size * ( ( 100 - $gen0_tenure_free_avg ) / 100 );
$a = $semi_space_size - $c;
$b = $semi_space_size - $gen0_promoted_size_avg;

#print "DEBUG $a $b $c\n";
#$young_gc_short_lived_objects_size_avg_inbytes = (($a + $b) / $times_copied) * 1024;
$young_gc_short_lived_objects_size_avg_inbytes =
  ( $semi_space_size * ( $gen0_tenure_free_avg / 100 ) ) * 1024;
$young_gc_long_lived_objects_size_avg_inbytes =
  ($gen0_promoted_size_avg) * 1024;
$young_gc_tenured_objects_size_avg_inbytes =
  ( $semi_space_size * ( $gen0_tenure_thresh_avg / 100 ) );
if ( $gen0_tenure_count == 0 ) {
	$young_gc_short_lived_objects_size_avg_inbytes =
	  $semi_space_size_inbytes - $young_gc_long_lived_objects_size_avg_inbytes;

}

# ratio of short lived to long lived objects 
$young_gc_sbyl_ratio = $young_gc_short_lived_objects_size_avg_inbytes /
  $young_gc_long_lived_objects_size_avg_inbytes;

## call rate info
#Call rate, 1 call every = 1000 / 55 = 18.18 ms
$call_rate = 1000 / $CPS;

# calls before young gen GC = 853 / 18.18 = 45 calls
$calls_before_young_gc = $freq_young_gcs_inms / $call_rate;

#$call_throughput_per_sec = $application_run_time -
$young_gc_time_total_inms_inms - $gen1_ms_time_total;
$call_throughput           = $calls_before_young_gc * $young_gc_count;
$calls_before_tenure_gc    = $freq_tenure_gcs_inms / $call_rate;
$calls_before_promotion_gc = $freq_promoted_gcs_inms / $call_rate;
$calls_per_promotion_gc    = 1000 / $freq_promoted_gcs_inms;
if ( $freq_tenure_gcs_inms > 0 ) {
	$calls_per_tenure_gc = 1000 / $freq_tenure_gcs_inms;
}

#Total size of objects created per young gen GC = (1.2 + 2.8 ) = 4 M
$avg_young_gc_objects_created_size_inbytes =
  $young_gc_short_lived_objects_size_avg_inbytes +
  $young_gc_long_lived_objects_size_avg_inbytes;

#Size of objects / call = 4 M / 45 = 91K
$total_objects_size_inbytes_per_call =
  $avg_young_gc_objects_created_size_inbytes / $calls_before_young_gc;

#Size of short lived objects / call = 1.2 M / 45 = 27K
$short_lived_objects_size_inbytes_per_call =
  $young_gc_short_lived_objects_size_avg_inbytes / $calls_before_young_gc;

#tenure objects 
if ( $calls_before_tenure_gc > 0 ) {
	$tenured_objects_size_inbytes_per_call =
	  $young_gc_tenured_objects_size_avg_inbytes / $calls_before_tenure_gc;
}

#Size of long live objects / call = 64K
$long_lived_objects_size_inbytes_per_call =
  $young_gc_long_lived_objects_size_avg_inbytes / $calls_before_young_gc;

#Avg. # short live objects / call = 64K / 70 bytes = 936 objects
$ratio_short_2_long_live_objects_inbytes_per_call =
  $short_lived_objects_size_inbytes_per_call /
  $long_lived_objects_size_inbytes_per_call;

##Tenure rate information  
#$freq_tenure_gcs_inms = $application_run_time_inms / $gen0_tenure_count;
#$count_of_tenure_gcs_inasec =  1000 / $freq_tenure_gcs_inms;

#Avg. # long live objects / call = 64K / 70 bytes = 936 objects
#$avg_long_live_objects_inbytes_per_call =  $long_lived_objects_size_inbytes_per_call / $young_gc_promoted_objects_size_avg_inbytes;

#Avg. # of Objects promoted = 68239
#Avg. # of calls /  promotion = (1702 / 18.18) = 90
#$avg_calls_per_young_gc_promotion = $freq_promoted_gcs_inms / $call_rate;

#Avg. # of Objects promoted / call = 68239 / 90 = 754
$avg_objects_promoted_per_call =
  $gen0_promoted_objects_avg / $calls_before_promotion_gc;

#....
#active durations calcualtions
# ..
#Active duration of each call =  $active_call_duration ms

# number of calls in active duration
$calls_in_active_duration = $active_call_duration / $call_rate;

# of promotions in active duration = 32000 / 1707 = 18.7
$promotions_in_active_duration =
  $active_call_duration / $freq_promoted_gcs_inms;

#Object sizes / active duration = 18.7 * 4.7M = 87.89 M
$long_lived_objects_sizes_in_active_duration_inbytes =
  $promotions_in_active_duration * ( $gen0_promoted_size_avg * 1024 );
$short_lived_objects_sizes_in_active_duration_inbytes =
  $short_lived_objects_size_inbytes_per_call * $calls_in_active_duration;
$total_objects_created_in_active_duration_inbytes =
  $long_lived_objects_sizes_in_active_duration_inbytes +
  $short_lived_objects_sizes_in_active_duration_inbytes;
$total_number_of_active_durations_processed =
  ( $total_size_objects_promoted_inkb * 1024 ) /
  $long_lived_objects_sizes_in_active_duration_inbytes;

$percent_of_long_lived_objects_in_active_duration =
  ( $long_lived_objects_sizes_in_active_duration_inbytes * 100 ) /
  $total_objects_created_in_active_duration_inbytes;
$percent_of_short_lived_objects_in_active_duration =
  ( $short_lived_objects_sizes_in_active_duration_inbytes * 100 ) /
  $total_objects_created_in_active_duration_inbytes;

# these are for verifications for projection routines
my $memory_size_when_init_might_take_place_inbytes =
  $total_mem_inbytes - $init_object_size_inbytes;
my $memory_size_when_remark_might_take_place_inbytes =
  $total_mem_inbytes - $remark_object_size_inbytes;

# this should tell how many promotions before you hit the intitial old GC 
#  mark
my $so_how_many_promotions_before_init_gc =
  $memory_size_when_init_might_take_place_inbytes /
  $young_gc_promoted_objects_size_avg_inbytes;
my $so_how_many_promotions_before_remark_gc =
  $memory_size_when_remark_might_take_place_inbytes /
  $young_gc_promoted_objects_size_avg_inbytes;
my $so_how_many_promotions_before_resize_gc =
  $resize_object_size_inbytes / $young_gc_promoted_objects_size_avg_inbytes;

#find out frequency of promotions, we know this
# find out frequency of old gc,  frequency of promtion * times promotion
my $so_how_many_ms_before_old_init_gc =
  $freq_promoted_gcs_inms * $so_how_many_promotions_before_init_gc;
my $so_how_many_ms_before_old_remark_gc =
  $freq_promoted_gcs_inms * $so_how_many_promotions_before_remark_gc;
my $so_how_many_ms_before_old_resize_gc =
  $freq_promoted_gcs_inms * $so_how_many_promotions_before_resize_gc;

# find out how many active durations are active or inactive at the moment 
# frequency of a old gen gc / active duration = #of active durations
$this_many_active_durations_before_init_gc =
  $so_how_many_ms_before_old_init_gc / $active_call_duration;
$this_many_active_durations_before_remark_gc =
  $so_how_many_ms_before_old_remark_gc / $active_call_duration;

#of active durations that was resized, (active_durations till remark * active_duration_size ) / avg_resize_size;
$active_durations_freed = $resize_object_size_inbytes /
  $long_lived_objects_sizes_in_active_duration_inbytes;

$ratio_live_2_freed_data =
  ( $this_many_active_durations_before_remark_gc *
	  $long_lived_objects_sizes_in_active_duration_inbytes ) /
  $resize_object_size_inbytes;

# divide old remark gc ms by 2 to account for init gc numbers
my $freq_of_old_gc_with_resize_size = $so_how_many_ms_before_old_resize_gc;
my $freq_of_old_gc                  = $freq_of_old_gc_with_resize_size;

#how much of active duration data is present in the old heap
# active duration  + (active duration * # of active durations)

# of full GCs / active duration = 32000 / 67196 = .4762
# active durations / full GCs = 67196 / 32000 = 2.099
# of active durations during run = 20640000 / 32000 = 645
# of full GCs in total active durations = 645 * .4762 = 307
#Total object size in total active duration = 87.89 * 645 = 56695.6

$old_gc_app_time = $gen1_remark_app_time_total + $gen1_resize_app_time_total +
  $gen1_initmark_app_time_total;
$total_gc_app_time =
  $young_gc_app_time + $old_gc_app_time + $gen1_ms_app_time_total;
$total_gc_calc_app_time_inms = $application_run_time_inms - $gc_time_total_inms;
$total_conc_gc_time_inms     = $total_conc_gc_time * 1000;
$percent_conc_gc_time        =
  $total_conc_gc_time_inms * 100 / $total_gc_calc_app_time_inms;

#print STDERR "DEBUG $young_gc_time_total_inms_inms  $young_gc_app_time\n";
$ratio_young_gc_by_gc_app_time =
  $young_gc_time_total_inms_inms / $young_gc_app_time;

# Ratio of (young gc_time/total gc_app_time) = $young_gc_time_total_inms_inms / $total_gc_app_time;
$ratio_young_gc_by_gc_app_run_time =
  $young_gc_time_total_inms_inms / $total_gc_app_time;
$ratio_young_gc_by_app_run_time =
  $young_gc_time_total_inms_inms / $application_run_time_inms;

# Ratio of old (gc_time/gc_app_time) = $old_gc_time_total_inms_inms / $old_gc_app_time;
$ratio_old_gc_by_gc_app_time = $old_gc_time_total_inms_inms / $old_gc_app_time;

# Ratio of (old gc_time/total gc_app_time) = $old_gc_time_total_inms_inms / $total_gc_app_time;
$ratio_old_gc_by_total_gc_app_time =
  $old_gc_time_total_inms_inms / $total_gc_app_time;
$ratio_old_gc_by_app_run_time =
  $old_gc_time_total_inms_inms / $application_run_time_inms;
$ratio_ms_gc_by_total_gc_app_time = $gen1_ms_time_total / $total_gc_app_time;
$ratio_ms_gc_by_app_run_time = $gen1_ms_time_total / $application_run_time_inms;

# Ratio of total (gc_time/gc_app_time) = $gc_time_total_inms / $total_gc_app_time;
$ratio_total_gc_time_by_total_gc_app_time =
  $gc_time_total_inms / $total_gc_app_time;
$ratio_total_gc_time_by_app_run_time =
  $gc_time_total_inms / $application_run_time_inms;

#Execution efficiency and Scalability calculations
# scalability is limited by the stop the world pauses
# so in our case it would be younggc time, and old gc ms times
# Speedup (s) = 1 / f + ((1 -f) / n )
# 	f = serial percentage of the app
# 	n is the number of CPUs
#
# Execution efficiency = s / n 
# 	s = speedup 
#
# CPU utilization = Execution efficiency * 100;
#
my $f = ($gc_time_total_inms) / $application_run_time_inms;
$serial_portion_of_application = $f * 100;
my $n_cpu = $cpus;

#if ($n_cpu > 1) {
#	$n_cpu = $n_cpu - 1;
#}
my $s_d = ( $f + ( ( 1 - $f ) / $cpus ) );
$speedup              = 1 / $s_d;
$execution_efficiency = $speedup / $cpus;
$cpu_utilization      = $execution_efficiency * 100;
##

$p_application_run_time_inms    = sprintf "%s", $application_run_time_inms;
$p_gen1_initmark_f_mem_size_avg = sprintf "%d", $gen1_initmark_f_mem_size_avg;
$p_semi_space_size              = sprintf "%d", $semi_space_size;
$p_gen0_tenure_count            = sprintf "%d", $gen0_tenure_count;
$p_young_gc_tenured_objects_size_avg_inbytes = sprintf "%d",
  $young_gc_tenured_objects_size_avg_inbytes;
$p_freq_tenure_gcs_inms      = sprintf "%d", $freq_tenure_gcs_inms;
$p_gen0_tenure_copy_time     = sprintf "%d", $gen0_tenure_copy_time;
$p_percent_tenure_gc_pause   = sprintf "%d", $percent_tenure_gc_pause;
$p_gen0_promoted_count       = sprintf "%d", $gen0_promoted_count;
$p_gen0_promoted_objects_avg = sprintf "%d", $gen0_promoted_objects_avg;
$p_young_gc_long_lived_objects_size_avg_inbytes = sprintf "%d",
  $young_gc_long_lived_objects_size_avg_inbytes;
$p_freq_promoted_gcs_inms      = sprintf "%9.2f", $freq_promoted_gcs_inms;
$p_gen0_promoted_copy_time     = sprintf "%9.2f", $gen0_promoted_copy_time;
$p_percent_promoted_gc_pause   = sprintf "%9.2f", $percent_promoted_gc_pause;
$p_young_gc_count              = sprintf "%d",    $young_gc_count;
$p_young_gc_time_avg_inms_inms = sprintf "%9.2f", $young_gc_time_avg_inms_inms;
$p_young_gc_copy_time_inms     = sprintf "%9.2f", $young_gc_copy_time_inms;
$p_young_gc_overhead_time_inms = sprintf "%9.2f", $young_gc_overhead_time_inms;
$p_freq_young_gcs_inms         = sprintf "%9.2f", $freq_young_gcs_inms;
$p_percent_young_gc_pause      = sprintf "%9.2f", $percent_young_gc_pause;
$p_old_gc_time_total_inms_inms = sprintf "%9.2f", $old_gc_time_total_inms_inms;
$p_actual_old_gc_count         = sprintf "%d",    $actual_old_gc_count;
$p_actual_old_gc_time_avg_inms_inms = sprintf "%9.2f",
  $actual_old_gc_time_avg_inms_inms;
$p_actual_freq_old_gc_inms = sprintf "%9.2f", $actual_freq_old_gc_inms;

$p_gen1_ms_time_total = sprintf "%d",    $gen1_ms_time_total;
$p_gen1_ms_count      = sprintf "%d",    $gen1_ms_count;
$p_gen1_ms_time_avg   = sprintf "%9.2f", $gen1_ms_time_avg;

$p_total_conc_gc_time_inms = sprintf "%9.2f", $total_conc_gc_time_inms;
$p_percent_conc_gc_time    = sprintf "%5.2f", $percent_conc_gc_time;
$p_gc_time_total_inms      = sprintf "%9.2f", $gc_time_total_inms;
$p_actual_gc_time_avg_inms = sprintf "%9.2f", $actual_gc_time_avg_inms;
$p_CPS                     = sprintf "%d",    $CPS;
$p_call_rate               = sprintf "%d",    $call_rate;

$p_calls_before_young_gc = sprintf "%d",    $calls_before_young_gc;
$p_call_throughput       = sprintf "%9.2f", $call_throughput;
$p_total_objects_size_inbytes_per_call = sprintf "%d",
  $total_objects_size_inbytes_per_call;
$p_short_lived_objects_size_inbytes_per_call = sprintf "%d",
  $short_lived_objects_size_inbytes_per_call;

$p_long_lived_objects_size_inbytes_per_call = sprintf "%d",
  $long_lived_objects_size_inbytes_per_call;
$p_avg_young_gc_objects_created_size_inbytes = sprintf "%d",
  $avg_young_gc_objects_created_size_inbytes;
$p_avg_objects_promoted_per_call = sprintf "%d", $avg_objects_promoted_per_call;

$p_serial_portion_of_application = sprintf "%5.2f",
  $serial_portion_of_application;
$p_speedup              = sprintf "%5.2f", $speedup;
$p_execution_efficiency = sprintf "%5.2f", $execution_efficiency;
$p_cpu_utilization      = sprintf "%5.2f", $cpu_utilization;

print STDERR "\n\n";
print STDERR "  
---- GC Analyzer Summary : $logname   ----


Application info:

	Application run time = $p_application_run_time_inms ms
	Memory = $p_gen1_initmark_f_mem_size_avg MB
	Semispace = $p_semi_space_size KB

Young GC --------- (Tenured GC + Promoted GC ) ---

 Tenured gc info:

	Total number# of tenure GCs = $p_gen0_tenure_count
	Avg. object size tenured = $p_young_gc_tenured_objects_size_avg_inbytes  bytes
	Periodicity of tenure GC  =  $p_freq_tenure_gcs_inms ms
	Copy time = $p_gen0_tenure_copy_time ms
	Percent of app. time = $p_percent_tenure_gc_pause %

 Promoted gc info:

	Total number# of promoted GCs = $p_gen0_promoted_count
	Avg. number# of Objects promoted = $p_gen0_promoted_objects_avg
	Avg. objects size promoted = $p_young_gc_long_lived_objects_size_avg_inbytes bytes
	Periodicity of promoted GC  =  $p_freq_promoted_gcs_inms ms
	Promotion time = $p_gen0_promoted_copy_time ms
	Percent of app. time = $p_percent_promoted_gc_pause %

 Young GC info:

	Total number# of young GCs = $p_young_gc_count
	Avg. GC pause = $p_young_gc_time_avg_inms_inms ms
	Copy/Promotion time = $p_young_gc_copy_time_inms ms
	Overhead(suspend,restart threads) time  = $p_young_gc_overhead_time_inms ms
	Periodicity of GCs = $p_freq_young_gcs_inms ms 
	Percent of app. time = $p_percent_young_gc_pause %

Old concurrent GC info:

	Total GC time = $p_old_gc_time_total_inms_inms ms
	Total number# of GCs = $p_actual_old_gc_count
	Avg. pause = $p_actual_old_gc_time_avg_inms_inms ms
	Periodicity of GC = $p_actual_freq_old_gc_inms ms

Old traditionl mark-sweep GC info:

	Total GC time = $p_gen1_ms_time_total ms
	Total number# of GCs = $p_gen1_ms_count 
	Avg. pause = $p_gen1_ms_time_avg ms

Total old (concurrent + ms) GC info:

	Cost of concurrent GC = $p_total_conc_gc_time_inms ms
	Percent of app. time = $p_percent_conc_gc_time %

Total (young and old) GC info:

	Total GC time =  $p_gc_time_total_inms ms
	Avg. pause = $p_actual_gc_time_avg_inms ms

Call control info:

	Call-setups per second (CPS) = $p_CPS
	Call rate, 1 call every = $p_call_rate ms
	Number# call-setups / young GC = $p_calls_before_young_gc
	Total call throughput = $p_call_throughput
	Total size of objects / call = $p_total_objects_size_inbytes_per_call  bytes
	Total size of short lived objects / call-setup = $p_short_lived_objects_size_inbytes_per_call  bytes
	Total size of long live objects / call-setup = $p_long_lived_objects_size_inbytes_per_call bytes
	Total size of objects created per young gen GC = $p_avg_young_gc_objects_created_size_inbytes  bytes
	Avg. number# of Objects promoted / call = $p_avg_objects_promoted_per_call


Execution efficiency of application:

	GC Serial portion of application = $p_serial_portion_of_application%
	Speedup = $p_speedup
	Execution efficiency = $p_execution_efficiency
	CPU Utilization = $p_cpu_utilization %

\n";

print STDERR " --- GC Analyzer End Summary ---------------- ";
print STDERR "\n\n";

if ( !$detailed ) {
	close(GC);
	exit 0;
}

print STDERR "

#--- Detailed and confusing calculations; dig into this if you need more info about what is happening above ----\n";

print STDERR "\n\n";
print STDERR "---- GC Log stats ... 


totals gc0: gcs=$gen0_count, #young_tenure_gcs=$gen0_tenure_count, #young_promoted_gcs=$gen0_promoted_count\n  tenure avgs: thresh=$gen0_tenure_thresh_avg, time=$gen0_tenure_time_avg, free=$gen0_tenure_free_avg\n  promoted avgs: thresh=$gen0_promoted_thresh_avg, time=$gen0_promoted_time_avg, free=$gen0_promoted_free_avg, objects=$gen0_promoted_objects_avg, size=$gen0_promoted_size_avg:
promoted totals: size_total=$gen0_promoted_size_total\n";

print STDERR "

totals gc1: gcs=$gen1_gcs_count, #initmark_gcs=$gen1_initmark_count, #remark_gcs=$gen1_remark_count #resize_gcs=$gen1_resize_count\ninitmark avgs: time=$gen1_initmark_time_avg, totalmem=$gen1_initmark_f_mem_size_avg, %=$gen1_initmark_f_mem_percent_avg, app_time=$gen1_initmark_app_time_avg\nremark avgs: time=$gen1_remark_time_avg, totalmem=$gen1_remark_f_mem_size_avg, %=$gen1_remark_f_mem_percent_avg, app_time=$gen1_remark_app_time_avg\nresize avgs: time=$gen1_resize_time_avg, totalmem=$gen1_resize_f_mem_size_avg, %=$gen1_resize_f_mem_percent_avg, app_time=$gen1_resize_app_time_avg\n";

print STDERR "

totals ms gc1: gcs=$gen1_ms_count\nms avgs: time=$gen1_ms_time_avg, %=$gen1_ms_mem_avg, app_time=$gen1_ms_app_time_avg\n";

print STDERR "\n\n";
print STDERR " ---- Young generation calcs ... 

Avg. young gen dead objects size  / GC = $young_gc_short_lived_objects_size_avg_inbytes bytes
Avg. young gen live objects size / GC cycle = $young_gc_long_lived_objects_size_avg_inbytes bytes
Ratio of short lived / long lived for young GC = $young_gc_sbyl_ratio

Avg. young gen object size promoted = $young_gc_promoted_objects_size_avg_inbytes  bytes
Avg. number# of Objects promoted = $gen0_promoted_objects_avg
Total object promoted times  = $gen0_promoted_time_total ms
Avg. object promoted times = $young_gc_promoted_objects_times_avg_inms ms
Total object promoted gcs = $gen0_promoted_count
Frequency of object promoted gcs = $freq_promoted_gcs_inms ms

Total tenure times = $gen0_tenure_time_total ms
Total tenure gcs = $gen0_tenure_count
Avg. tenure gc time = $gen0_tenure_time_avg ms
Frequency of tenure gcs = $freq_tenure_gcs_inms ms

Total number# of young gcs = $young_gc_count
Total time of young gc  = $young_gc_time_total_inms_inms  ms
Avg. young gc pause = $young_gc_time_avg_inms_inms ms
Frequency of young gcs = $freq_young_gcs_inms ms 
";

print STDERR "\n\n";
print STDERR "--- Old generation calcs .... 

Total concurrent old gen times = $old_gc_time_total_inms_inms ms
Total number# of old gen gcs = $gen1_gcs_count
Total number# of old gen pauses with 0 ms = $gen1_resize_count
Total number# of old gen gcs = $actual_old_gc_count
Total old gen gcs = 3 cycles -> 1 full gc = $real_old_gc_count
Avg. old gen pauses = $old_gc_time_avg_inms_inms ms
Actual avg. old gen pauses = $actual_old_gc_time_avg_inms_inms ms
Frequency of old gen gc = $freq_old_gc_inms ms
Actual Frequency of old gen gc = $actual_freq_old_gc_inms
";

print STDERR "\n\n";
print STDERR "--- Traditional MS calcs ... 

Total number# mark sweep old gcs =$gen1_ms_count 
Total mark sweep old gen time =$gen1_ms_time_total ms
Avg. mark sweep pauses = $gen1_ms_time_avg ms
Avg. free threshold  = $gen1_ms_mem_avg %;
Total mark sweep old gen application time = $gen1_ms_app_time_total ms;
Avg. mark sweep apps time = $gen1_ms_app_time_avg ms
";

print STDERR "\n\n";
print STDERR " ---- GC as a whole  ....

Total gc time =  $gc_time_total_inms
Avg. gc pause = $gc_time_avg_inms
Actual avg. gc pause = $actual_gc_time_avg_inms
";

print STDERR "\n\n";
print STDERR "--- Memory or Heap calcs ... 

Total memory = $gen1_initmark_f_mem_size_avg MB
Resize GC thresh = $gen1_resize_f_mem_percent_avg %
Remark GC thresh = $gen1_remark_f_mem_percent_avg %
Initmark GC thresh (init mark)= $gen1_initmark_f_mem_percent_avg %

Live objects per old gc  = $live_old_gc_object_size_inmb  MB
Dead objects per old gc = $dead_old_gc_object_size_inmb MB
Ratio of (short/long) lived objects per old GC = $ratio_old_gc_sbyl_objects
";

print STDERR "\n\n";
print STDERR " --- Memory leak verification ...

 Total size of objects promoted = $total_size_objects_promoted_inkb KB
 Total size of objects full GC collected thru appplication run = $total_size_objects_collected_inkb KB
";

print STDERR "\n\n";
print STDER "--- Call rate calcs ...

CPS = $CPS
Call rate, 1 call every = $call_rate ms
Number# calls before young gen GC = $calls_before_young_gc
Size of objects / call = $total_objects_size_inbytes_per_call  bytes
Size of short lived objects / call = $short_lived_objects_size_inbytes_per_call  bytes
Size of tenure objects / call = $tenured_objects_size_inbytes_per_call  bytes
Size of long live objects / call = $long_lived_objects_size_inbytes_per_call bytes
Ratio of young GC (short/long) objects / call  = $ratio_short_2_long_live_objects_inbytes_per_call bytes
Avg. number# of Objects promoted / call = $avg_objects_promoted_per_call
";

print STDERR "\n\n";
print STDERR "--- Active duration  calcs ... 

Active duration of each call =  $active_call_duration ms
Number# number of calls in active duration = $calls_in_active_duration 
Number# of promotions in active duration = $promotions_in_active_duration 
Long lived objects(promoted objects) / active duration = $long_lived_objects_sizes_in_active_duration_inbytes bytes
Short lived objects (tenured or not promoted) / active duration =  $short_lived_objects_sizes_in_active_duration_inbytes bytes
Total objects created / active duration = $total_objects_created_in_active_duration_inbytes bytes
Percent% long lived in active duration = $percent_of_long_lived_objects_in_active_duration %
Percent% short lived in active duration = $percent_of_short_lived_objects_in_active_duration %
Number# of active durations freed by old gc = $active_durations_freed;
Ratio of live to freed data = $ratio_live_2_freed_data;
Avg. resized memory size = $resize_object_size_inbytes;
Time when init gc might take place = $so_how_many_ms_before_old_init_gc ms
Time when remark gc might take place = $so_how_many_ms_before_old_remark_gc ms
Frequency of initial old gc = $init_freq_old_gc_inms ms
Frequency of old gc = $freq_of_old_gc ms
Frequency of resize gc = $freq_of_old_gc_with_resize_size ms
";

print STDERR "\n\n";
print STDERR " --- Application run times  calcs ... 

 Total application run times during young gc = $young_gc_app_time ms
 Total application run times during old gc = $old_gc_app_time ms
 Total application run time = $total_gc_app_time ms
 Calculated or specified app run time = $application_run_time_inms ms
 Ratio of young (gc_time/gc_app_time) = $ratio_young_gc_by_gc_app_time
 Ratio of young (gc_time/app_run_time) = $ratio_young_gc_by_app_run_time
 Ratio of old (gc_time/gc_app_time) = $ratio_old_gc_by_gc_app_time
 Ratio of (old gc_time/total gc_app_time) = $ratio_old_gc_by_total_gc_app_time
 Ratio of (old gc_time/app_run_time) = $ratio_old_gc_by_app_run_time
 Ratio of total (gc_time/gc_app_time) = $ratio_total_gc_time_by_total_gc_app_time
 Ratio of total (gc_time/app_run_time) = $ratio_total_gc_time_by_app_run_time
";

close(GC);

