#!/usr/bin/perl -w
use CGI;
use DBI;

my $q = new CGI;
my $name;
my $color;
my $pet;
my $bgcolorname="white";
my $bgcolorpet="white";
my $bgcolorcolor="white";
my $msg;
my $noerror = 0;

my $driver = "mysql"; 
my $database = "{{ db_name }}";
my $dbhost = "{{ db_hostname }}";
my $dsn = "DBI:$driver:database=$database;host=$dbhost;port=3306";
my $userid = "{{ db_username }}";
my $password = "{{ db_password }}";

sub get_param {
  if ($q->param()) {
    $name = $q->param("Name");
    $color = $q->param("Favorite Color");
    $pet = $q->param("Cats or Dogs");
    if (!$name) { 
      $bgcolorname="red";
      $msg.="Please enter a name<BR>";
    } 
    if (!$color) {
      $bgcolorcolor="red";
      $msg.="Please enter a favorite color<BR>";
    }
    if (!$pet) {
      $bgcolorpet="red";
      $msg.="Please enter cats or dogs<BR>";
    }
  } else {
    $noerror=1
  }
  return $msg;
}

sub display_form {
  my $msg = shift;
  print "Content-type: text/html\r\n\r\n";
  print << "EOF";
  
  <HTML>
  <HEAD>
  <TITLE>Did I forget HTML?</TITLE>
  </HEAD>
  <BODY BGCOLOR=WHITE ALIGN=CENTER>
  <FORM METHOD=POST ACTION="/index.cgi">
  <TABLE>
  <TR BGCOLOR=$bgcolorname>
  <TD>Name:</TD><TD> <INPUT TYPE=TEXT NAME="Name" VALUE="$name"></TD>
  </TR>
  <TR BGCOLOR=$bgcolorcolor>
  <TD>Favorite Color: </TD><TD><INPUT TYPE=TEXT NAME="Favorite Color" VALUE="$color"></TD>
  </TR>
  <TR BGCOLOR=$bgcolorpet>
  <TD>Cats or Dogs:</TD><TD> <INPUT TYPE=TEXT NAME="Cats or Dogs" VALUE="$pet"></TD>
  </TR>
  <TR>
  <TD COLSPAN=2 ALIGN=CENTER>
  <INPUT TYPE=SUBMIT>
EOF
  if ($name&&$color&&$pet) {
    if (!$msg) {
      print "<TR><TD COLSPAN=2 ALIGN=CENTER>Data saved</TD></TR>";
    } else {
      print "<TR BGCOLOR=red><TD COLSPAN=2 ALIGN=CENTER>$msg</TD></TR>";
    }
  } elsif ($noerror) {
    print "<TR><TD COLSPAN=2 ALIGN=CENTER>Please fill the form</TD></TR>";
  } else {
    print "<TR BGCOLOR=RED><TD COLSPAN=2 ALIGN=CENTER>$msg</TD></TR>";
  }
  print << "EOF";
  </TD>
  </TR>
  </FORM>
  </BODY>
  </HTML>
EOF
}

sub insert_data {
  my $rows;
  my $dbh = shift;
  my $sth = $dbh->prepare("show tables like '{{ db_table }}';");
  $sth->execute() or $msg=$DBI::errstr;
  $rows=$sth->rows;
  $sth->finish();
  if (!$rows&&!$msg) {
    $sth = $dbh->prepare("create table {{ db_table }} (name varchar(255) unique, color varchar(255), pet varchar(255))");
    $sth->execute() or $msg=$DBI::errstr;
    $rows=$sth->rows;
    $sth->finish();  
  }
  if (!$msg) {
    $sth = $dbh->prepare("insert into {{ db_table }} values('$name', '$color', '$pet');");
    $sth->execute() or $msg=$DBI::errstr;
    $rows=$sth->rows;
  }
  return $msg;
}
sub save_data {
  my $msg = shift;
  my $dbh = DBI->connect($dsn, $userid, $password ) or $msg=$DBI::errstr;
  $msg .=  insert_data($dbh);
  return $msg;
}

$msg=get_param();
if (!$name||!$color||!$pet) {
  display_form($msg);
} else {
  $msg=save_data($msg);
  display_form($msg);
}
