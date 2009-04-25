<%doc>

=head1 NAME

B<Typogrify>


=head1 SYNOPSIS

  $m->comp('/path/to/typogrify.mc',
           text => $my_text,
           filters => 'all');

'filters' is optional (default value is 'all') and if used, must be either the word "all" or a combination of these letters:
  q : quotes
  b : backtick quotes (``double'' only)
  B : backtick quotes (``double'' and `single')
  d : dashes
  D : old school dashes
  i : inverted old school dashes
  e : ellipses
  w : convert &quot; entities to " for Dreamweaver users
  
  1 : all of the above
  2 : all of the above, using old school en- and em- dash shortcuts
  3 : all of the above, using inverted old school en and em- dash shortcuts

  A : run 'amp' filter to convert ampersands (&)
  W : run 'widont' widow/orphan filter
  C : run 'caps' filter to style words in all CAPS
  N : run 'initial quotes' filter to style leading quotation marks

The last four filters (ampersands, widont, caps, initial quotes) come from
typogrify; the rest are from SmartyPants.

For example:
* filters => 'qAe' will convert quotes, ampersands, and ellipses.
* filters => 'all' would be equivalent to filters => '1AWCN'.
* filters => '2' would just run SmartyPants in mode 2.


=head1 DESCRIPTION

Typogrify is a publishing utility to help format regular text to proper web
typography.

This version is specifically designed as a Bricolage utility template.


=head1 CREDITS

This code is a Bricolage/Perl port of the original typogrify, a set of
filters for the Django CMS. It also incorporates SmartyPants, another
command line/MT/BBEdit/Blosxom prettifier.

Original code by:
    John Gruber (SmartyPants)
    [http://daringfireball.net/projects/smartypants/]

    Christian Metts (Typogrify)
    [http://code.google.com/p/typogrify/]

Port and other assembly by:
    Greg Heo <greg@node79.com>


=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008 Greg Heo <greg@node79.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

The software is provided "as is", without warranty of any kind, express or
implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or copyright holders be liable for any claim, damages or other
liability, whether in an action of contract, tort or otherwise, arising from,
out of or in connection with the software or the use or other dealings in
the software.


=head1 SmartyPants License
    Copyright (c) 2003 John Gruber
    (http://daringfireball.net/)
    All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

*   Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

*   Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

*   Neither the name "SmartyPants" nor the names of its contributors may
    be used to endorse or promote products derived from this software
    without specific prior written permission.

This software is provided by the copyright holders and contributors "as is"
and any express or implied warranties, including, but not limited to, the 
implied warranties of merchantability and fitness for a particular purpose 
are disclaimed. In no event shall the copyright owner or contributors be 
liable for any direct, indirect, incidental, special, exemplary, or 
consequential damages (including, but not limited to, procurement of 
substitute goods or services; loss of use, data, or profits; or business 
interruption) however caused and on any theory of liability, whether in 
contract, strict liability, or tort (including negligence or otherwise) 
arising in any way out of the use of this software, even if advised of the
possibility of such damage.


=head1 Typogrify (original Django version) License
    Copyright (c) 2007, Christian Metts
    All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of the author nor the names of other
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
</%doc>
<%args>
$text
$filters => 'all'
</%args>
<%perl>
my $tags_to_skip = qr!<(/?)(?:pre|code|kbd|script|math)[\s>]!;


my $EducateSingleBackticks = sub {
#
#   Parameter:  String.
#   Returns:    The string, with `backticks' -style single quotes
#               translated into HTML curly quote entities.
#
#   Example input:  `Isn't this fun?'
#   Example output: &#8216;Isn&#8217;t this fun?&#8217;
#

    local $_ = shift;
    s/`/&#8216;/g;
    s/'/&#8217;/g;
    return $_;
};

my $EducateBackticks = sub {
#
#   Parameter:  String.
#   Returns:    The string, with ``backticks'' -style double quotes
#               translated into HTML curly quote entities.
#
#   Example input:  ``Isn't this fun?''
#   Example output: &#8220;Isn't this fun?&#8221;
#

    local $_ = shift;
    s/``/&#8220;/g;
    s/''/&#8221;/g;
    return $_;
};


my $EducateDashes = sub {
#
#   Parameter:  String.
#
#   Returns:    The string, with each instance of "--" translated to
#               an em-dash HTML entity.
#

    local $_ = shift;
    s/--/&#8212;/g;
    return $_;
};


my $EducateDashesOldSchool = sub {
#
#   Parameter:  String.
#
#   Returns:    The string, with each instance of "--" translated to
#               an en-dash HTML entity, and each "---" translated to
#               an em-dash HTML entity.
#

    local $_ = shift;
    s/---/&#8212;/g;    # em
    s/--/&#8211;/g;     # en
    return $_;
};


my $EducateDashesOldSchoolInverted = sub {
#
#   Parameter:  String.
#
#   Returns:    The string, with each instance of "--" translated to
#               an em-dash HTML entity, and each "---" translated to
#               an en-dash HTML entity. Two reasons why: First, unlike the
#               en- and em-dash syntax supported by
#               EducateDashesOldSchool(), it's compatible with existing
#               entries written before SmartyPants 1.1, back when "--" was
#               only used for em-dashes.  Second, em-dashes are more
#               common than en-dashes, and so it sort of makes sense that
#               the shortcut should be shorter to type. (Thanks to Aaron
#               Swartz for the idea.)
#

    local $_ = shift;
    s/---/&#8211;/g;    # en
    s/--/&#8212;/g;     # em
    return $_;
};


my $EducateEllipses = sub {
#
#   Parameter:  String.
#   Returns:    The string, with each instance of "..." translated to
#               an ellipsis HTML entity. Also converts the case where
#               there are spaces between the dots.
#
#   Example input:  Huh...?
#   Example output: Huh&#8230;?
#

    local $_ = shift;
    s/\.\.\./&#8230;/g;
    s/\. \. \./&#8230;/g;
    return $_;
};


my $StupefyEntities = sub {
#
#   Parameter:  String.
#   Returns:    The string, with each SmartyPants HTML entity translated to
#               its ASCII counterpart.
#
#   Example input:  &#8220;Hello &#8212; world.&#8221;
#   Example output: "Hello -- world."
#

    local $_ = shift;

    s/&#8211;/-/g;      # en-dash
    s/&#8212;/--/g;     # em-dash

    s/&#8216;/'/g;      # open single quote
    s/&#8217;/'/g;      # close single quote

    s/&#8220;/"/g;      # open double quote
    s/&#8221;/"/g;      # close double quote

    s/&#8230;/.../g;    # ellipsis

    return $_;
};


my $_tokenize = sub {
#
#   Parameter:  String containing HTML markup.
#   Returns:    Reference to an array of the tokens comprising the input
#               string. Each token is either a tag (possibly with nested,
#               tags contained therein, such as <a href="<MTFoo>">, or a
#               run of text between tags. Each element of the array is a
#               two-element array; the first is either 'tag' or 'text';
#               the second is the actual value.
#
#
#   Based on the _tokenize() subroutine from Brad Choate's MTRegex plugin.
#       <http://www.bradchoate.com/past/mtregex.php>
#

    my $str = shift;
    my $pos = 0;
    my $len = length $str;
    my @tokens;

    my $depth = 6;
    my $nested_tags = join('|', ('(?:<(?:[^<>]') x $depth) . (')*>)' x  $depth);
    my $match = qr/(?s: <! ( -- .*? -- \s* )+ > ) |  # comment
                   (?s: <\? .*? \?> ) |              # processing instruction
                   $nested_tags/x;                   # nested tags

    while ($str =~ m/($match)/g) {
        my $whole_tag = $1;
        my $sec_start = pos $str;
        my $tag_start = $sec_start - length $whole_tag;
        if ($pos < $tag_start) {
            push @tokens, ['text', substr($str, $pos, $tag_start - $pos)];
        }
        push @tokens, ['tag', $whole_tag];
        $pos = pos $str;
    }
    push @tokens, ['text', substr($str, $pos, $len - $pos)] if $pos < $len;
    \@tokens;
};

my $ProcessEscapes = sub {
#
#   Parameter:  String.
#   Returns:    The string, with after processing the following backslash
#               escape sequences. This is useful if you want to force a "dumb"
#               quote or other character to appear.
#
#               Escape  Value
#               ------  -----
#               \\      &#92;
#               \"      &#34;
#               \'      &#39;
#               \.      &#46;
#               \-      &#45;
#               \`      &#96;
#
    local $_ = shift;

    s! \\\\ !&#92;!gx;
    s! \\"  !&#34;!gx;
    s! \\'  !&#39;!gx;
    s! \\\. !&#46;!gx;
    s! \\-  !&#45;!gx;
    s! \\`  !&#96;!gx;

    return $_;
};


my $SmartQuotes = sub {
    # Paramaters:
    my $work = shift;   # text to be parsed
    my $attr = shift;   # value of the smart_quotes="" attribute
    my $ctx  = shift;   # MT context object (unused)

    my $do_backticks;   # should we educate ``backticks'' -style quotes?

    if ($attr == 0) {
        # do nothing;
        return $work;
    }
    elsif ($attr == 2) {
        # smarten ``backticks'' -style quotes
        $do_backticks = 1;
    }
    else {
        $do_backticks = 0;
    }

    # Special case to handle quotes at the very end of $work when preceded by
    # an HTML tag. Add a space to give the quote education algorithm a bit of
    # context, so that it can guess correctly that it's a closing quote:
    my $add_extra_space = 0;
    if ($work =~ m/>['"]\z/) {
        $add_extra_space = 1; # Remember, so we can trim the extra space later.
        $work .= " ";
    }

    my $tokens ||= $_tokenize->($work);
    my $result = '';
    my $in_pre = 0;  # Keep track of when we're inside <pre> or <code> tags

    my $prev_token_last_char = "";  # This is a cheat, used to get some context
                                    # for one-character tokens that consist of 
                                    # just a quote char. What we do is remember
                                    # the last character of the previous text
                                    # token, to use as context to curl single-
                                    # character quote tokens correctly.

    foreach my $cur_token (@$tokens) {
        if ($cur_token->[0] eq "tag") {
            # Don't mess with quotes inside tags
            $result .= $cur_token->[1];
            if ($cur_token->[1] =~ m/$tags_to_skip/) {
                $in_pre = defined $1 && $1 eq '/' ? 0 : 1;
            }
        } else {
            my $t = $cur_token->[1];
            my $last_char = substr($t, -1); # Remember last char of this token before processing.
            if (! $in_pre) {
                $t = $ProcessEscapes->($t);
                if ($do_backticks) {
                    $t = $EducateBackticks->($t);
                }

                if ($t eq q/'/) {
                    # Special case: single-character ' token
                    if ($prev_token_last_char =~ m/\S/) {
                        $t = "&#8217;";
                    }
                    else {
                        $t = "&#8216;";
                    }
                }
                elsif ($t eq q/"/) {
                    # Special case: single-character " token
                    if ($prev_token_last_char =~ m/\S/) {
                        $t = "&#8221;";
                    }
                    else {
                        $t = "&#8220;";
                    }
                }
                else {
                    # Normal case:                  
                    $t = &EducateQuotes($t);
                }

            }
            $prev_token_last_char = $last_char;
            $result .= $t;
        }
    }

    if ($add_extra_space) {
        $result =~ s/ \z//;  # Trim trailing space if we added one earlier.
    }
    return $result;
};


my $SmartDashes = sub {
    # Paramaters:
    my $work = shift;   # text to be parsed
    my $attr = shift;   # value of the smart_dashes="" attribute
    my $ctx  = shift;   # MT context object (unused)

    # reference to the subroutine to use for dash education, default to EducateDashes:
    my $dash_sub_ref = $EducateDashes;

    if ($attr == 0) {
        # do nothing;
        return $work;
    }
    elsif ($attr == 2) {
        # use old smart dash shortcuts, "--" for en, "---" for em
        $dash_sub_ref = $EducateDashesOldSchool; 
    }
    elsif ($attr == 3) {
        # inverse of 2, "--" for em, "---" for en
        $dash_sub_ref = $EducateDashesOldSchoolInverted; 
    }

    my $tokens;
    $tokens ||= &_tokenize($work);

    my $result = '';
    my $in_pre = 0;  # Keep track of when we're inside <pre> or <code> tags
    foreach my $cur_token (@$tokens) {
        if ($cur_token->[0] eq "tag") {
            # Don't mess with quotes inside tags
            $result .= $cur_token->[1];
            if ($cur_token->[1] =~ m/$tags_to_skip/) {
                $in_pre = defined $1 && $1 eq '/' ? 0 : 1;
            }
        } else {
            my $t = $cur_token->[1];
            if (! $in_pre) {
                $t = $ProcessEscapes->($t);
                $t = $dash_sub_ref->($t);
            }
            $result .= $t;
        }
    }
    return $result;
};


my $SmartEllipses = sub {
    # Paramaters:
    my $work = shift;   # text to be parsed
    my $attr = shift;   # value of the smart_ellipses="" attribute
    my $ctx  = shift;   # MT context object (unused)

    if ($attr == 0) {
        # do nothing;
        return $work;
    }

    my $tokens;
    $tokens ||= $_tokenize->($work);

    my $result = '';
    my $in_pre = 0;  # Keep track of when we're inside <pre> or <code> tags
    foreach my $cur_token (@$tokens) {
        if ($cur_token->[0] eq "tag") {
            # Don't mess with quotes inside tags
            $result .= $cur_token->[1];
            if ($cur_token->[1] =~ m/$tags_to_skip/) {
                $in_pre = defined $1 && $1 eq '/' ? 0 : 1;
            }
        } else {
            my $t = $cur_token->[1];
            if (! $in_pre) {
                $t = $ProcessEscapes->($t);
                $t = $EducateEllipses->($t);
            }
            $result .= $t;
        }
    }
    return $result;
};


my $EducateQuotes = sub {
#
#   Parameter:  String.
#
#   Returns:    The string, with "educated" curly quote HTML entities.
#
#   Example input:  "Isn't this fun?"
#   Example output: &#8220;Isn&#8217;t this fun?&#8221;
#

    local $_ = shift;

    # Tell perl not to gripe when we use $1 in substitutions,
    # even when it's undefined. Use $^W instead of "no warnings"
    # for compatibility with Perl 5.005:
    local $^W = 0;


    # Make our own "punctuation" character class, because the POSIX-style
    # [:PUNCT:] is only available in Perl 5.6 or later:
    my $punct_class = qr/[!"#\$\%'()*+,-.\/:;<=>?\@\[\\\]\^_`{|}~]/;

    # Special case if the very first character is a quote
    # followed by punctuation at a non-word-break. Close the quotes by brute force:
    s/^'(?=$punct_class\B)/&#8217;/;
    s/^"(?=$punct_class\B)/&#8221;/;


    # Special case for double sets of quotes, e.g.:
    #   <p>He said, "'Quoted' words in a larger quote."</p>
    s/"'(?=\w)/&#8220;&#8216;/g;
    s/'"(?=\w)/&#8216;&#8220;/g;

    # Special case for decade abbreviations (the '80s):
    s/'(?=\d{2}s)/&#8217;/g;

    my $close_class = qr![^\ \t\r\n\[\{\(\-]!;
    my $dec_dashes = qr/&#8211;|&#8212;/;

    # Get most opening single quotes:
    s {
        (
            \s          |   # a whitespace char, or
            &nbsp;      |   # a non-breaking space entity, or
            --          |   # dashes, or
            &[mn]dash;  |   # named dash entities
            $dec_dashes |   # or decimal entities
            &\#x201[34];    # or hex
        )
        '                   # the quote
        (?=\w)              # followed by a word character
    } {$1&#8216;}xg;
    # Single closing quotes:
    s {
        ($close_class)?
        '
        (?(1)|          # If $1 captured, then do nothing;
          (?=\s | s\b)  # otherwise, positive lookahead for a whitespace
        )               # char or an 's' at a word ending position. This
                        # is a special case to handle something like:
                        # "<i>Custer</i>'s Last Stand."
    } {$1&#8217;}xgi;

    # Any remaining single quotes should be opening ones:
    s/'/&#8216;/g;


    # Get most opening double quotes:
    s {
        (
            \s          |   # a whitespace char, or
            &nbsp;      |   # a non-breaking space entity, or
            --          |   # dashes, or
            &[mn]dash;  |   # named dash entities
            $dec_dashes |   # or decimal entities
            &\#x201[34];    # or hex
        )
        "                   # the quote
        (?=\w)              # followed by a word character
    } {$1&#8220;}xg;

    # Double closing quotes:
    s {
        ($close_class)?
        "
        (?(1)|(?=\s))   # If $1 captured, then do nothing;
                           # if not, then make sure the next char is whitespace.
    } {$1&#8221;}xg;

    # Any remaining quotes should be opening ones.
    s/"/&#8220;/g;

    return $_;
};



my $widont = sub {
    my $work = shift;

    $work =~ s/((?:<\/?(?:a|em|span|strong|i|b)[^>]*>)|[^<>\s])\s+([^<>\s]+\s*(<\/(a|em|span|strong|i|b)>\s*)*((<\/(p|h[1-6]|li|dt|dd)>)|$))/$1&nbsp;$2/g;

    return $work;
};

my $amp = sub {
    my $work = shift;

    # Wraps apersands in HTML with ``<span class="amp">`` so they can be
    # styled with CSS. Apersands are also normalized to ``&amp;``. Requires     # ampersands to have whitespace or an ``&nbsp;`` on both sides.
    # - It won't mess up & that are already wrapped, in entities or URLs    # - It should ignore standalone amps that are in attributes

    # tag_pattern from http://haacked.com/archive/2004/10/25/usingregularexpressionstomatchhtml.aspx    # it kinda sucks but it fixes the standalone amps in attributes bug
    my $tag_pattern = '(?:</?\w+(?:(?:\s+\w+(?:\s*=\s*(?:".*?"|\'.*?\'|[^\'">\s]+))?)+\s*|\s*)/?>|<!--.*?-->)';
    my $amp_finder = '(\s|&nbsp;)(&|&amp;|&\#38;)(\s|&nbsp;)';
    my $intra_tag_finder = '((?:'.$tag_pattern.')?)([^<]*)((?:'.$tag_pattern.')?)';
    my @matches = ($work =~ m/$intra_tag_finder/gs);

    my $output;
    my $counter = 0;
    foreach (@matches) {
        s/$amp_finder/$1<span class="amp">&amp;<\/span>$3/g if ($counter == 1);
        $output .= $_;        $counter = 0 if (++$counter == 3);
    }
    return $output;
};

my $initial_quotes = sub {
    my $work = shift;

    my $quo = '((?:<(?:p|h[1-6]|li|dt|dd)[^>]*>|^)\s*(?:<(?:a|em|span|strong|i|b)[^>]*>\s*)*)(\'|&lsquo;|&\#8216;)';
    my $dquo = '((?:<(?:p|h[1-6]|li|dt|dd)[^>]*>|^)\s*(?:<(?:a|em|span|strong|i|b)[^>]*>\s*)*)("|&ldquo;|&\#8220;)';

    $work =~ s/$quo/$1<span class="quo">$2<\/span>/gs;
    $work =~ s/$dquo/$1<span class="dquo">$2<\/span>/gs;

    return $work;
};

my $caps = sub {
    my $work = shift;
    my $in_skipped_tag = 0;
    
    my $cap_finder_1 = '(\b[A-Z\d]*[A-Z]\d*[A-Z][A-Z\d]*\b)';
    my $cap_finder_2 = '(\b[A-Z]+\.\s?(?:[A-Z]+\.\s?)+)';
    my $cap_finder = '(?:'.$cap_finder_1.'|'.$cap_finder_2.'(?:\s|\b|$))';
    my $tags_to_skip = '<(/)?(pre|code|kbd|script|math)[^>]*>';

    my $output;
    my $tokens = $_tokenize->($work);
    foreach my $token (@$tokens) {
        if ($token->[0] eq 'tag') {
            $output .= $token->[1];
            if ($token->[1] =~ m/$tags_to_skip/i) {
                if ($1 eq '/') {
                    $in_skipped_tag = 0;
                } else {
                    $in_skipped_tag = 1;
                }
            }
        } else {
            if ($in_skipped_tag) {
                $output .= $token->[1];
            } else {
                my @caps_found = ($token->[1] =~ m/$cap_finder/g);
                foreach (@caps_found) {
                    if (m/$cap_finder_1/) {
                        $token->[1] =~ s/($_)/<span class="caps">$1<\/span>/;
                    } elsif (m/$cap_finder_2/) {
                        my $replace;
                        if (substr($_, -1) eq ' ') {
                            $replace = '<span class="caps">'.substr($_, 0, -1).'</span> ';
                        } else {
                            $replace = '<span class="caps">'.$_.'</span>';
                        }
                        $token->[1] =~ s/$_/$replace/;
                    }
                }
                $output .= $token->[1];
            }
        }
    }

    return $output;

};

my $SmartyPants = sub {
    # Paramaters:
    my $work = shift;   # text to be parsed
    my $attr = shift;   # value of the smart_quotes="" attribute
    my $ctx  = shift;   # MT context object (unused)

    # Options to specify which transformations to make:
    my ($do_quotes, $do_backticks, $do_dashes, $do_ellipses, $do_stupefy);
    my $convert_quot = 0;  # should we translate &quot; entities into normal quotes?

    # Parse attributes:
    # 0 : do nothing
    # 1 : set all
    # 2 : set all, using old school en- and em- dash shortcuts
    # 3 : set all, using inverted old school en and em- dash shortcuts
    # 
    # q : quotes
    # b : backtick quotes (``double'' only)
    # B : backtick quotes (``double'' and `single')
    # d : dashes
    # D : old school dashes
    # i : inverted old school dashes
    # e : ellipses
    # w : convert &quot; entities to " for Dreamweaver users

    if ($attr eq "0") {
        # Do nothing.
        return $work;
    }
    elsif ($attr eq "1") {
        # Do everything, turn all options on.
        $do_quotes    = 1;
        $do_backticks = 1;
        $do_dashes    = 1;
        $do_ellipses  = 1;
    }
    elsif ($attr eq "2") {
        # Do everything, turn all options on, use old school dash shorthand.
        $do_quotes    = 1;
        $do_backticks = 1;
        $do_dashes    = 2;
        $do_ellipses  = 1;
    }
    elsif ($attr eq "3") {
        # Do everything, turn all options on, use inverted old school dash shorthand.
        $do_quotes    = 1;
        $do_backticks = 1;
        $do_dashes    = 3;
        $do_ellipses  = 1;
    }
    elsif ($attr eq "-1") {
        # Special "stupefy" mode.
        $do_stupefy   = 1;
    }
    else {
        my @chars = split(//, $attr);
        foreach my $c (@chars) {
            if    ($c eq "q") { $do_quotes    = 1; }
            elsif ($c eq "b") { $do_backticks = 1; }
            elsif ($c eq "B") { $do_backticks = 2; }
            elsif ($c eq "d") { $do_dashes    = 1; }
            elsif ($c eq "D") { $do_dashes    = 2; }
            elsif ($c eq "i") { $do_dashes    = 3; }
            elsif ($c eq "e") { $do_ellipses  = 1; }
            elsif ($c eq "w") { $convert_quot = 1; }
            else {
                # Unknown attribute option, ignore.
            }
        }
    }

    my $tokens ||= $_tokenize->($work);
    my $result = '';
    my $in_pre = 0;  # Keep track of when we're inside <pre> or <code> tags.

    my $prev_token_last_char = "";  # This is a cheat, used to get some context
                                    # for one-character tokens that consist of 
                                    # just a quote char. What we do is remember
                                    # the last character of the previous text
                                    # token, to use as context to curl single-
                                    # character quote tokens correctly.

    foreach my $cur_token (@$tokens) {
        if ($cur_token->[0] eq "tag") {
            # Don't mess with quotes inside tags.
            $result .= $cur_token->[1];
            if ($cur_token->[1] =~ m/$tags_to_skip/) {
                $in_pre = defined $1 && $1 eq '/' ? 0 : 1;
            }
        } else {
            my $t = $cur_token->[1];
            my $last_char = substr($t, -1); # Remember last char of this token before processing.
            if (! $in_pre) {
                $t = $ProcessEscapes->($t);

                if ($convert_quot) {
                    $t =~ s/&quot;/"/g;
                }

                if ($do_dashes) {
                    $t = $EducateDashes->($t)                  if ($do_dashes == 1);
                    $t = $EducateDashesOldSchool->($t)         if ($do_dashes == 2);
                    $t = $EducateDashesOldSchoolInverted->($t) if ($do_dashes == 3);
                }

                $t = $EducateEllipses->($t) if $do_ellipses;

                # Note: backticks need to be processed before quotes.
                if ($do_backticks) {
                    $t = $EducateBackticks->($t);
                    $t = $EducateSingleBackticks->($t) if ($do_backticks == 2);
                }

                if ($do_quotes) {
                    if ($t eq q/'/) {
                        # Special case: single-character ' token
                        if ($prev_token_last_char =~ m/\S/) {
                            $t = "&#8217;";
                        }
                        else {
                            $t = "&#8216;";
                        }
                    }
                    elsif ($t eq q/"/) {
                        # Special case: single-character " token
                        if ($prev_token_last_char =~ m/\S/) {
                            $t = "&#8221;";
                        }
                        else {
                            $t = "&#8220;";
                        }
                    }
                    else {
                        # Normal case:                  
                        $t = $EducateQuotes->($t);
                    }
                }

                $t = $StupefyEntities->($t) if $do_stupefy;
            }
            $prev_token_last_char = $last_char;
            $result .= $t;
        }
    }

    return $result;
};



my $smartypants_attr;
if (lc($filters) eq 'all') {
  $smartypants_attr = 1;
  $filters = 'all';
} else {
  $smartypants_attr = $filters;
  $smartypants_attr =~ s/[AWCN]//g;
  $filters =~ s/[^AWCN]//g;
}

$text = $amp->($text) if ($filters eq 'all' || $filters =~ m/A/);
$text = $widont->($text) if ($filters eq 'all' || $filters =~ m/W/);
$text = $SmartyPants->($text, $smartypants_attr) if ($filters eq 'all' || $smartypants_attr);
$text = $caps->($text) if ($filters eq 'all' || $filters =~ m/C/);
$text = $initial_quotes->($text) if ($filters eq 'all' || $filters =~ m/N/);

print $text;
</%perl>
