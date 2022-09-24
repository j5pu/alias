#!/usr/bin/env awk -f

# Usage:
#   rc.awk env /tmp/homebrew_env_sorted.sh
#   rc.awk /usr/local/Homebrew/Library/Homebrew/brew.sh /tmp/homebrew_env_sorted.sh

BEGIN {
    if ( ARGV[1] == "env" ) {
        OFS="=";
        TMP=ARGV[2]".tmp";
        DEST=ARGV[2];
        for ( v in ENVIRON ) {
            if (v ~ /HOMEBREW_/ && v != "PATH" && v != "HOMEBREW_PATH" ) {
                printf("%s=\"%s\"\n", "export " v, ENVIRON[v]) >> TMP;
#                ARRAY[v]="export "v"=\""ENVIRON[v]"\"";
            }
        }
#        N=asort(ARRAY, SORTED);
#        for (I = 1; I <= N; I++) {
#            print SORTED[I] >> ARGV[2];
#        }
        if ( system("sort -u "TMP" > "DEST) ) {
            print "Error: failed to sort "TMP" > "DEST;
            exit 1;
        }
        exit;
    } else {
        FIRST="[ ! \"${1-}\" ] || { set -- ; . \"$0\"; exit; }";
        SCRIPT=ENVIRON["_"];
        BREW=ARGV[1];
        ORIGINAL=ARGV[1]".bak";
        TMP=ARGV[1]".tmp";
        HOMEBREW_SH=ARGV[2];
        ARGV[2]="";
        if (system("cp "BREW" "ORIGINAL) != 0) {
            print "Error: Could not create backup of "BREW;
            exit 1;
        }
        print FIRST > TMP;
    }
}

{
    if ( FILENAME == HOMEBREW_SH ) {
        exit;
    }
    if ( ARGV[1] != "env" ) {
       if ( $1 == "setup-ruby-path" )  {
            printf("%s; %s %s %s; %s\n", $0, SCRIPT, "env", HOMEBREW_SH, "return") >> TMP;
        } else {
            print $0 > TMP;
        }
    }
}

END {
    if ( ARGV[1] != "env" ) {
        if (system("mv "TMP" "BREW) != 0) {
            print "Error: Could not replace "BREW;
        } else {
            if (system("brew env") != 0) {
                print "Error: Could not get "BREW" environment";
            }
        }
        if (system("mv "ORIGINAL" "BREW) != 0) {
            print "Error: Could not replace "BREW;
            exit 1;
        }
    }
}
