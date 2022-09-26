#!/usr/bin/env -S awk -f

BEGIN {
    DESC["BASE_INFOPATH"] = "Initial $INFOPATH"
    DESC["BASE_MANPATH"] = "Initial $MANPATH"
    DESC["BASE_PATH"] = "Initial $PATH"
    DESC["BREW_PREFIX"] = "Brew Prefix directory where subdirectories (etc, Caskroom, Cellar, ...) are created, if brew install.sh script is used"
    DESC["BREW_SH"] = "Homebrew Library 'brew.sh' to be sourced by rc.awk via _generated_brew_sh() to get $HOMEBREW_* variables"
    DESC["CLT"] = "Command Line Tools HOME directory"
    DESC["DIST_ID"] = "Distribution ID, i.e: alpine, centos, debian. kali, macOS, ubuntu, etc."
    DESC["DIST_BUILD_ID"] = "Distribution Build ID, i.e: arch (rolling), etc. (default: $DIST_ID)"
    DESC["DIST_ID_LIKE"] = "Linux Distribution ID Like, i.e: alpine, debian, rhel_fedora, etc. (default: $DIST_ID)"
    DESC["DIST_NAME"] = "Linux Distribution Name, i.e: CentOS Linux, Kali GNU/Linux, etc. (default: $DIST_ID)"
    DESC["DIST_PRETTY_NAME"] = "Linux Distribution Pretty Name, i.e: CentOS Linux 8, Kali GNU/Linux Rolling, etc. (default: $DIST_ID)"
    DESC["DIST_VERSION"] = "Distribution Version, i.e: debian (11 (bullseye)), kali (2021.2), ubuntu (22.04.1 LTS (Jammy Jellyfish)), etc. (default: $DIST_VERSION_ID)"
    DESC["DIST_VERSION_CODENAME"] = "Distribution Codename, i.e: Catalina, kali-rolling, ubuntu (jammy), debian (bullseye), etc. (default: $DIST_VERSION_ID)"
    DESC["DIST_VERSION_ID"] = "Distribution Version, i.e: macOS (10.15.1, 10.16), kali (2021.2), ubuntu (20.04), etc."
    DESC["DOCKER_CONTAINER"] = "true (bool) if Running in a Docker Container"
    DESC["GITHUB_CI"] = "true (bool) if $GITHUB_ACTIONS is 'true' else false"
    DESC["INFOPATH"] = "$INFOPATH environment variable"
    DESC["HOMEBREW_PREFIX"] = "Brew Prefix directory where subdirectories (etc, Caskroom, Cellar, ...) are created, if brew install.sh script is used"
    DESC["MACOS"] = "true (bool) if $UNAME is 'Darwin' else false"
    DESC["MACHINE_HW"] = "Machine Hardware Name (uname -m), i.e: aarch64, arm64, x86_64, etc."
    DESC["MACHINE_HW_PLATFORM"] = "Machine Hardware Platform [Ubuntu only] (uname -i), i.e: aarch64, arm64, x86_64, etc. (default: unknown)"
    DESC["MACHINE_PROCESSOR_ARCH"] = "Machine Processor Architecture Name/Processor Type [Darwin only] (uname -p), i.e: i386, (default: unknown)"
    DESC["MANPATH"] = "$MANPATH environment variable"
    DESC["NODENAME"] = "Name that the system is known by to a communication network/Network Node Hostname (uname -n)"
    DESC["PATH"] = "$PATH environment variable"
    DESC["OS_RELEASE"] = "Operating System Release/Kernel Release (uname -r), i.e: Darwin (21.6.0), Linux (5.10.124-linuxkit), etc."
    DESC["OS_VERSION"] = "Operating System Version/Kernel Version (uname -v), includes i.e.: $OS_NAME, $OS_RELEASE, $MACHINE_HW, etc."
    DESC["PM"] = "Default Package Manager, i.e: apt, apk, brew, dnf, pacman, yum, etc."
    DESC["PM_INSTALL"] = "Default Package Manager Command with Install Options"
    DESC["PM_UPGRADE"] = "Default Package Manager Command with Upgrade and Cleanup, Quiet and no cache (for containers)"
    DESC["SUDO"] = "SUDO command path https://linuxhandbook.com/run-alias-as-sudo/"
    DESC["UNAME"] = "Operating System Name/Kernel Name (uname -s), i.e: Linux, Darwin, etc."
    DESC["UNAME_OS"] = "Operating System [Ubuntu only] (uname -o), i.e: ubuntu (GNU/Linux), alpine (Linux), etc."
    DESC["VGA"] = "true (bool) if haa an VGA card else false"

    MACOS_VERSIONS["1013"]="High Sierra"
    MACOS_VERSIONS["1014"]="Mojave"
    MACOS_VERSIONS["1015"]="Catalina"
    MACOS_VERSIONS["11"]="Big Sur"
    MACOS_VERSIONS["12"]="Monterey"
    MACOS_VERSIONS["13"]="Ventura"

    PMS["alpine"] = "apk"
    PMS["arch"] = "pacman"
    PMS["debian"] = "apt"
    PMS["fedora"] = "yum"
    PMS["macOS"] = "brew"

    for ( key in DESC ) { VALUES[key] = "" }

    VALUES["BASE_INFOPATH"] = "/usr/local/share/info:/usr/share/info"
    VALUES["BASE_MANPATH"] = "/usr/local/share/man:/usr/share/man:"
    VALUES["BASE_PATH"] = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    VALUES["CLT"] = "/Library/Developer/CommandLineTools"
    VALUES["BREW_PREFIX"] = "/usr/local"
    VALUES["DOCKER_CONTAINER"] = "false"; if ( system("test -f /.dockerenv") == 0 ) { VALUES["DOCKER_CONTAINER"] = "true" }
    VALUES["GITHUB_CI"] = "false"; if ( ENVIRON["GITHUB_ACTIONS"] == "true" ) { VALUES["GITHUB_CI"] = "true" }
    VALUES["INFOPATH"] = VALUES["BASE_INFOPATH"]
    VALUES["MACHINE_HW_PLATFORM"] = "unknown"
    VALUES["MACOS"] = "true"
    VALUES["MANPATH"] = VALUES["BASE_MANPATH"]
    VALUES["PATH"] = VALUES["BASE_PATH"]
    VALUES["PM"] = "brew"
    VALUES["PM_INSTALL"] = VALUES["PM"]" install"
    VALUES["PM_UPGRADE"] = VALUES["PM"]" upgrade"
    VALUES["SUDO"] = "/usr/bin/sudo"
    VALUES["UNAME_OS"] = "unknown"
    VALUES["VGA"]="true"

    if ( ARGC == 1 || ARGV[1] == "desc" ) {
        main()
        sort()

        while ((getline key < TMP) > 0) {
            if ( ARGV[1] == "desc") { printf("# %s\n# \n", DESC[key]) }
            printf("%s %s%s\"%s\"\n", "export", key, "=", VALUES[key])
            if ( ARGV[1] == "desc") { print }
        }
    }
}

function process(command,   stdout ) { command | getline stdout; close(command); return stdout }

function update(key, value) { if ( VALUES[key] == "" ) { VALUES[key] = value } }

function os(   i, line) {
    if (system("test -f /etc/os-release") == 0) {
        while ((getline i < "/etc/os-release") > 0) {
            split(i, line, "=")
            if ( line[1] !~ /(_URL|_COLOR)/ ) {
                if ( line[2] == "rhel_fedora" ) { gsub(" ", "_", line[2]) }
                gsub("\"", "", line[2]); VALUES["DIST_"line[1]] = line[2]
            }
        }
    } else { VALUES["DIST_ID"] = "busybox"; VALUES["DIST_ID_LIKE"] = "alpine"; }
}

function sort(   command,key) {
    TMP=process("mktemp")

    command = "printf '%s\\n'"
    for (key in DESC) { command = command" "key }
    command=command" | sort > "TMP
    process(command)
}

function main(   brew_path,i,id,max,paths,repo,total,uname) {
    total = split(process("uname -a"), uname, " ")
    max = total -1
    repo = "/Homebrew"

    if (uname[1] == "Darwin") {
        VALUES["BASE_PATH"] = VALUES["BASE_PATH"]":"VALUES["CLT"]
        VALUES["PATH"] = VALUES["BASE_PATH"]

        paths = process("pathsd /etc/paths.d")
        if ( paths != "" ) { VALUES["PATH"] = VALUES["PATH"]":"paths }

        paths = process("pathsd /etc/manpaths.d")
        if ( paths != "" ) { VALUES["MANPATH"] = VALUES["MANPATH"]paths":" }

        VALUES["DIST_ID"] = process("sw_vers -ProductName")
        VALUES["DIST_VERSION_ID"] = process("sw_vers -ProductVersion")

        split(VALUES["DIST_VERSION_ID"], id, ".")
        if (id[1] == "10") {
            VALUES["DIST_VERSION_CODENAME"] = MACOS_VERSIONS[id[1]"."id[2]]
        } else {
            VALUES["DIST_VERSION_CODENAME"] = MACOS_VERSIONS[id[1]]
        }
        VALUES["MACHINE_HW"] = uname[total]
        if (VALUES["MACHINE_HW"] == "arm64") { brew_path = 1; repo=""; VALUES["BREW_PREFIX"] = "/opt/homebrew" }
    } else {
        brew_path = 1
        max = total - 2

        VALUES["BREW_PREFIX"] = "/home/linuxbrew/.linuxbrew"
        VALUES["CLT"] = ""
        VALUES["MACHINE_HW_PLATFORM"] = process("uname -i")

        VALUES["MACOS"] = "false"

        VALUES["MACHINE_HW"] = uname[total-1]
        VALUES["UNAME_OS"] = uname[total]
        if (system("lspci 2>/dev/null | grep -q VGA") != 0) { VALUES["VGA"] = "false" }

        os()
    }
    if (brew_path == 1) {
        VALUES["INFOPATH"] = VALUES["BREW_PREFIX"]"/share/info:"VALUES["INFOPATH"]
        VALUES["MANPATH"] = VALUES["BREW_PREFIX"]"/share/man:"VALUES["MANPATH"]
        VALUES["PATH"] = VALUES["BREW_PREFIX"]"/bin:"VALUES["PATH"]
    }
    VALUES["BREW_SH"] = BREW_PREFIX repo "/Library/Homebrew/brew.sh"

    update("DIST_BUILD_ID", VALUES["DIST_ID"])
    update("DIST_ID_LIKE", VALUES["DIST_ID"])
    update("DIST_NAME", VALUES["DIST_ID"])
    update("DIST_PRETTY_NAME", VALUES["DIST_ID"])
    update("DIST_VERSION", VALUES["DIST_VERSION_ID"])
    update("DIST_VERSION_CODENAME", VALUES["DIST_VERSION_ID"])
    update("HOMEBREW_PREFIX", VALUES["BREW_PREFIX"])

    VALUES["MACHINE_PROCESSOR_ARCH"] = process("uname -p")

    VALUES["NODENAME"] = uname[2]

    VALUES["OS_RELEASE"] = uname[3]

    VALUES["OS_VERSION"] = uname[4]
    for (i=5; i<=max; i++) { VALUES["OS_VERSION"] = VALUES["OS_VERSION"]" "uname[i] }
    VALUES["OS_VERSION"] = VALUES["OS_VERSION"]

    split(VALUES["DIST_ID_LIKE"], id, "_")
    VALUES["PM"] = PMS[id[1]]

    if (system("test -f "VALUES["SUDO"]) != 0) { VALUES["SUDO"] = "" }

    VALUES["UNAME"] = uname[1]
    if (ENVIRON["CI"] != "" ) { VALUES["CI"] = "false" }
}
