---

Create a new desk as a publish desk within bricolage and call it whatever you want but auto publish works well for us, this is in addition to the main publish desk. Then run the following every X minutes as a cron job. It basically polls for all stories on the desk and publishes them if the cover date is in the past. Watch out for timezone changes between what the bric db thinks the time is and what datetime thinks the time is but apart from that it works really well and is easy for editors to be able to use it and understand how it works, plus stopping something publishing is as simple as taking it off the auto publish desk.

You'll need a shell script and a perl script

auto_publish.sh  :
----
#!/bin/sh

export BRICOLAGE_SERVER=IP:PORT
export BRICOLAGE_USERNAME=username
export BRICOLAGE_PASSWORD=password

./auto_publish.pl
----

and the perl script
----
#!/usr/bin/perl -w

use strict;
use DateTime;
use DateTime::Format::ISO8601;
use Mail::Send;

my $bric_soap = "/path/to/installed/bric_soap";

my $emailbody;

# get the list of stories on the auto pub desk, put the id of your auto pub desk here in place of 1024
my $desk_id = xxxx;

my $result = `$bric_soap --search desk_id=$desk_id story list_ids 2>&1`;
if (($result !~ /(story_\d+\n)/g) && ($result)) {
  $emailbody .= "Failed on story list pull - got $result\n";
}

my $now = scalar(localtime);
$now = DateTime->now();

my @stories = split(/\n/,$result);
foreach my $story (@stories) {
  # get the XML
  $result = `$bric_soap story export $story 2>&1`;
  # get the cover_date;
  my ($cover_date) = ($result =~ /<cover_date>([^<]+)<\/cover_date>/);
  my ($title) = ($result =~ /<name>([^<]+)<\/name>/);
  $cover_date =  DateTime::Format::ISO8601->parse_datetime($cover_date);

  if  (! $cover_date) {
      $emailbody .= "Could not retrieve cover date for $story ... skipping\n". $result ."\n";
      next;
  } else {
      my $difference = $cover_date - $now;
      if ($difference->is_zero || $difference->is_negative){
         # cover_date has passed let's publish
          $result = `$bric_soap workflow publish --with-related-stories --with-related-media $story 2>&1`;
          if ($result !~ /(Check the Apache error log for more detail)/) {
              $emailbody .= "$title with cover date of " . $cover_date->dmy . ' ' . $cover_date->hms . " was published at - " . $now->dmy . ' ' . $now->hms . "\n";
          } else {
             $emailbody .= "$title - $story FAILED TO PUBLISH at " . $now->dmy . ' ' . $now->hms . "\nERROR WAS \n\n" . $result ."\n\n\n";
         }
      } else {
         # $emailbody .= "$title has a cover date of " . $cover_date->dmy . ' ' . $cover_date->hms . ", not reached yet - " . $now->dmy . ' ' . $now->hms . "\n";
      }
  }
  @stories=split(/\n/,get_stories());
}

if ($emailbody) {
  my $msg = new Mail::Send;
  $msg->to('user@domain.com');
  $msg->subject('Auto Publish Result');
  my $fh = $msg->open;
  print $fh $emailbody;
  $fh->close;
 print $emailbody;
 print "######################################################################################\n";
}