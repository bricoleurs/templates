<%args>
$pic
</%args>
<%perl>
my %mediatypehash = %{$pic->get_media_type};
unless ($mediatypehash{'name'} eq "image/jpeg" || $mediatypehash{'name'} eq "image/jpg" || $mediatypehash{'name'} eq "image/gif" || $mediatypehash{'name'} eq "image/png") {
  $m->print('I was expecting a JPG, GIF, or PNG here. Got something else.');
}
if (($mediatypehash{'name'} eq "image/jpeg") || ($mediatypehash{'name'} eq "image/jpg")) {
  $burner->notes( ext => 'jpg' );
}
if ($mediatypehash{'name'} eq "image/gif") {
  $burner->notes( ext => 'gif' );
}
if ($mediatypehash{'name'} eq "image/png") {
  $burner->notes( ext => 'png' );
}
</%perl>