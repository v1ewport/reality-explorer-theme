#!/usr/bin/perl

use Switch;
use Text::Wrap;

my $what=$ARGV[0];

$user="<username>"; #username for gmail account
$pass="<pass>"; #password for gmail account
$file="/tmp/gmail.html"; #temporary file to store gmail

#wrap format for subject
$Text::Wrap::columns=65; #Number of columns to wrap subject at
$initial_tab=""; #Tab for first line of subject
$subsequent_tab="\t"; #tab for wrapped lines
$quote="\""; #put quotes around subject

#limit the number of emails to be displayed
$emails=4; #if -1 display all emails

&passwd; #give password the proper url character encoding

switch($what){ #determine what the user wants
	case "n" {&gmail; print "$new\n";} #print number of new emails
	case "s" { #print $from and $subj for new email
		&gmail;
		if ($new>0){
			my $size=@from;
			if ($emails!=-1 && $size>$emails){$size=$emails;} #limit number of emails displayed
			for(my $i=0; $i<$size; ++$i){
				print "From: $from[$i]\n"; #print from line
				$text=$quote.$subj[$i].$quote."\n";
				print wrap($initial_tab, $subsequent_tab, $text); #print subject with word wrap
			}
			$size=@from;
			if ($emails!=-1 && $size >$emails){print "$emails out of $size new emails displayed\n";}
		}
	} 	
	case "e" { #print number of new emails, $from, and $subj
		&gmail;
		if($new==0){print "You have no new emails.\n";}
		else{
			print "You have $new new email(s).\n";
			my $size=@from;
			if ($emails!=-1 && $size>$emails){$size=$emails;} #limit number of emails displayed
			for(my $i=0; $i<$size; ++$i){
				print "From: $from[$i]\n"; #print from line
				$text=$quote.$subj[$i].$quote;
				print wrap($initial_tab, $subsequent_tab, $text); #print subject with word wrap
			}
			$size=@from;
			if ($emails!=-1 && $size >$emails){print "$emails out of $size new emails displayed\n";}
		}
	}
	else {
		print "Usage Error: gmail.pl <option>\n";
		print "\tn displays number of new emails\n";
		print "\ts displays from line and subject line for each new email.\n";
		print "\te displays the number of new emails and from line plus \n";
		print "\t\tsubject line for each new email.\n";
	} #didn't give proper option
}

sub gmail{
	if(!(-e $file)){ #create file if it does not exists
		`touch $file`;
	} 

	#get new emails
	`wget -O - https://$user:$pass\@mail.google.com/mail/feed/atom --no-check-certificate> $file`;

	open(IN, $file); #open $file

	my $i=0; #initialize count
	$new=0; #initialize new emails to 0

	my $flag=0;

	while(<IN>){ #cycle through $file
		if(/<entry>/){$flag=1;}
		elsif(/<fullcount>(\d+)<\/fullcount>/){$new=$1;} #grab number of new emails
		elsif($flag==1){ 
			if(/<title>.+<\/title>/){push(@subj, &msg);} #grab new email titles
			elsif(/<name>(.+)<\/name>/){push(@from, $1); $flag=0;} #grab new email from lines
		}
	}

	close(IN); #close $file
}

sub passwd{ #change to url escape codes in password
	#URL ESCAPE CODES
	$_=$pass;
	s/\%/\%25/g;
	s/\#/\%23/g;
	s/\$/\%24/g;
	s/\&/\%26/g;
	s/\//\%2F/g;
	s/\:/\%3A/g;
	s/\;/\%3B/g;
	s/\</\%3C/g;
	s/\=/\%3D/g;
	s/\>/\%3E/g;
	s/\?/\%3F/g;
	s/\@/\%40/g;
	s/\[/\%5B/g;
	s/\\/\%5C/g;
	s/\]/\%5D/g;
	s/\^/\%5E/g;
	s/\`/\%60/g;
	s/\{/\%7B/g;
	s/\|/\%7C/g;
	s/\}/\%7D/g;
	s/\~/\%7E/g;
	$pass=$_;
}

sub msg{
	#THE HTML CODED CHARACTER SET [ISO-8859-1]
	chomp; s/<title>(.+)<\/title>/$1/; #get just the subject
	#now replace any special characters
	s/\&\#33\;/!/g;        #Exclamation mark
	s/\&\#34\;/"/g; s/\&quot\;/"/g;      #Quotation mark
	s/\&\#35\;/#/g;        #Number sign
	s/\&\#36\;/\$/g;        #Dollar sign
	s/\&\#37\;/%/g;        #Percent sign
	s/\&\#38\;/&/g; s/\&amp\;/&/g;        #Ampersand
	s/\&\#39\;/'/g;        #Apostrophe
	s/\&\#40\;/(/g;        #Left parenthesis
	s/\&\#41\;/)/g;        #Right parenthesis
	s/\&\#42\;/*/g;        #Asterisk
	s/\&\#43\;/+/g;        #Plus sign
	s/\&\#44\;/,/g;        #Comma
	s/\&\#45\;/-/g;        #Hyphen
	s/\&\#46\;/./g;        #Period (fullstop)
	s/\&\#47\;/\//g;        #Solidus (slash)
	s/\&\#58\;/:/g;        #Colon
	s/\&\#59\;/\;/g;        #Semi-colon
	s/\&\#60\;/</g; s/\&lt\;/</g;        #Less than
	s/\&\#61\;/=/g;        #Equals sign
	s/\&\#62\;/>/g; s/\&gt\;/>/g;        #Greater than
	s/\&\#63\;/\?/g;        #Question mark
	s/\&\#64\;/\@/g;        #Commercial at
	s/\&\#91\;/\[/g;        #Left square bracket
	s/\&\#92\;/\\/g;        #Reverse solidus (backslash)
	s/\&\#93\;/\]/g;        #Right square bracket
	s/\&\#94\;/\^/g;        #Caret
	s/\&\#95\;/_/g;        #Horizontal bar (underscore)
	s/\&\#96\;/\`/g;        #Acute accent
	s/\&\#123\;/\{/g;        #Left curly brace
	s/\&\#124\;/|/g;        #Vertical bar
	s/\&\#125\;/\}/g;        #Right curly brace
	s/\&\#126\;/~/g;        #Tilde
	s/\&\#161\;/??/g;        #Inverted exclamation
	s/\&\#162\;/??/g;        #Cent sign
	s/\&\#163\;/??/g;        #Pound sterling
	s/\&\#164\;/??/g;        #General currency sign
	s/\&\#165\;/??/g;        #Yen sign
	s/\&\#166\;/??/g;        #Broken vertical bar
	s/\&\#167\;/??/g;        #Section sign
	s/\&\#168\;/??/g;        #Umlaut (dieresis)
	s/\&\#169\;/??/g; s/\&copy\;/??/g;        #Copyright
	s/\&\#170\;/??/g;        #Feminine ordinal
	s/\&\#171\;/??/g;        #Left angle quote, guillemotleft
	s/\&\#172\;/??/g;        #Not sign
	s/\&\#174\;/??/g;        #Registered trademark
	s/\&\#175\;/??/g;        #Macron accent
	s/\&\#176\;/??/g;        #Degree sign
	s/\&\#177\;/??/g;        #Plus or minus
	s/\&\#178\;/??/g;        #Superscript two
	s/\&\#179\;/??/g;        #Superscript three
	s/\&\#180\;/??/g;        #Acute accent
	s/\&\#181\;/??/g;        #Micro sign
	s/\&\#182\;/??/g;        #Paragraph sign
	s/\&\#183\;/??/g;        #Middle dot
	s/\&\#184\;/??/g;        #Cedilla
	s/\&\#185\;/??/g;        #Superscript one
	s/\&\#186\;/??/g;        #Masculine ordinal
	s/\&\#187\;/??/g;        #Right angle quote, guillemotright
	s/\&\#188\;/??/g; s/\&frac14\;/??/g;       # Fraction one-fourth
	s/\&\#189\;/??/g; s/\&frac12\;/??/g;       # Fraction one-half
	s/\&\#190\;/??/g; s/\&frac34\;/??/g;       # Fraction three-fourths
	s/\&\#191\;/??/g;        #Inverted question mark
	s/\&\#192\;/??/g;        #Capital A, grave accent
	s/\&\#193\;/??/g;        #Capital A, acute accent
	s/\&\#194\;/??/g;        #Capital A, circumflex accent
	s/\&\#195\;/??/g;        #Capital A, tilde
	s/\&\#196\;/??/g;        #Capital A, dieresis or umlaut mark
	s/\&\#197\;/??/g;        #Capital A, ring
	s/\&\#198\;/??/g;        #Capital AE dipthong (ligature)
	s/\&\#199\;/??/g;        #Capital C, cedilla
	s/\&\#200\;/??/g;        #Capital E, grave accent
	s/\&\#201\;/??/g;        #Capital E, acute accent
	s/\&\#202\;/??/g;        #Capital E, circumflex accent
	s/\&\#203\;/??/g;        #Capital E, dieresis or umlaut mark
	s/\&\#204\;/??/g;        #Capital I, grave accent
	s/\&\#205\;/??/g;        #Capital I, acute accent
	s/\&\#206\;/??/g;        #Capital I, circumflex accent
	s/\&\#207\;/??/g;        #Capital I, dieresis or umlaut mark   
	s/\&\#208\;/??/g;        #Capital Eth, Icelandic
	s/\&\#209\;/??/g;        #Capital N, tilde
	s/\&\#210\;/??/g;        #Capital O, grave accent
	s/\&\#211\;/??/g;        #Capital O, acute accent
	s/\&\#212\;/??/g;        #Capital O, circumflex accent
	s/\&\#213\;/??/g;        #Capital O, tilde
	s/\&\#214\;/??/g;        #Capital O, dieresis or umlaut mark
	s/\&\#215\;/??/g;        #Multiply sign
	s/\&\#216\;/??/g;        #Capital O, slash
	s/\&\#217\;/??/g;        #Capital U, grave accent
	s/\&\#218\;/??/g;        #Capital U, acute accent
	s/\&\#219\;/??/g;        #Capital U, circumflex accent
	s/\&\#220\;/??/g;        #Capital U, dieresis or umlaut mark
	s/\&\#221\;/??/g;        #Capital Y, acute accent
	s/\&\#222\;/??/g;        #Capital THORN, Icelandic
	s/\&\#223\;/??/g;        #Small sharp s, German (sz ligature)
	s/\&\#224\;/??/g;        #Small a, grave accent
	s/\&\#225\;/??/g;        #Small a, acute accent
	s/\&\#226\;/??/g;        #Small a, circumflex accent
	s/\&\#227\;/??/g;        #Small a, tilde
	s/\&\#228\;/??/g;        #Small a, dieresis or umlaut mark
	s/\&\#229\;/??/g;        #Small a, ring
	s/\&\#230\;/??/g;        #Small ae dipthong (ligature)
	s/\&\#231\;/??/g;        #Small c, cedilla
	s/\&\#232\;/??/g;        #Small e, grave accent
	s/\&\#233\;/??/g;        #Small e, acute accent
	s/\&\#234\;/??/g;        #Small e, circumflex accent
	s/\&\#235\;/??/g;        #Small e, dieresis or umlaut mark
	s/\&\#236\;/??/g;        #Small i, grave accent
	s/\&\#237\;/??/g;        #Small i, acute accent
	s/\&\#238\;/??/g;        #Small i, circumflex accent
	s/\&\#239\;/??/g;        #Small i, dieresis or umlaut mark
	s/\&\#240\;/??/g;        #Small eth, Icelandic
	s/\&\#241\;/??/g;        #Small n, tilde
	s/\&\#242\;/??/g;        #Small o, grave accent
	s/\&\#243\;/??/g;        #Small o, acute accent
	s/\&\#244\;/??/g;        #Small o, circumflex accent
	s/\&\#245\;/??/g;        #Small o, tilde
	s/\&\#246\;/??/g;        #Small o, dieresis or umlaut mark
	s/\&\#247\;/??/g;        #Division sign
	s/\&\#248\;/??/g;        #Small o, slash
	s/\&\#249\;/??/g;        #Small u, grave accent
	s/\&\#250\;/??/g;        #Small u, acute accent
	s/\&\#251\;/??/g;        #Small u, circumflex accent
	s/\&\#252\;/??/g;        #Small u, dieresis or umlaut mark
	s/\&\#253\;/??/g;        #Small y, acute accent
	s/\&\#254\;/??/g;        #Small thorn, Icelandic
	s/\&\#255\;/??/g;        #Small y, dieresis or umlaut mark
	s/^\s+//;
	return $_;
}
