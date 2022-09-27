#!/usr/bin/awk -f

# Nothing in this file should depend on $HOME or $USER (it is reused for all users), running dependencies with
# $USER or $HOME should be in rc/etc/ or rc/custome/ instead. This file is supposed to generated only at the installation
# of the system or rarely when host name changes.
# Can not be executed directly on busybox images since env does not support -S, and -S is required by debian to pass -f

# TODO: las de GIT CONFIG de system.sh viejas (mirar el credentials), meter las de brew aqui añadir paths de RC.. Dockerfile
# TODO: IPYTHONDIR
# TODO: variables de git config
# TODO: git credential
# TODO: prompt
# TODO: el paths.d
# TODO: el orden de source
# TODO: pythonstartup y console/site_customize.py IPYTHONDIR
# TODO: colors
# TODO: helper que había cambiado en media
# TODO: exportar funciones based on shell
# TODO: USER en profile.d ?
# TODO: GH global config variable y el credential tambien ?
# TODO: Si es install añadir comprobar los permisos aqui y hacer lo del chomp USER
# TODO: Mirar como dejo XDG_CONFIG_HOME si por usuario y symlink para los que son comunes y no se actualizan dinamicamente
#   o poner permisos de escritura a todos.
# TODO: Git url.ssh://git@github.com/.insteadO with command and based on USER and user key file
# TODO: sacar variables de path a vars_path y si eso las otras aunque se repita el if para que sea todo mas legible.
# TODO: "RC dotfiles for SSH keys, config (mirar si para authorized_keys o hay que poner todo con escritura y no funciona)
# TODO: Generate python stubs and var in PYTHONPATH y si hay variable de sitecustomize.py

BEGIN {
    SCRIPT = "system.awk"
    rc()

    DESC["APT_UPGRADE"] = "APT Full Upgrade Command"
    DESC["BASH_COMPLETION_USER_DIR"] = "Dinamically loaded by __load_completion()/_completion_loader() functions, they add 'completions' to $BASH_COMPLETION_USER_DIR"
    DESC["BASH_SILENCE_DEPRECATION_WARNING"] = "BASH_SILENCE_DEPRECATION_WARNING for BASH version 3"
    DESC["BASE_INFOPATH"] = "Initial $INFOPATH"
    DESC["BASE_MANPATH"] = "Initial $MANPATH"
    DESC["BASE_PATH"] = "Initial $PATH"
    DESC["BREW_PREFIX"] = "Brew Prefix directory where subdirectories (etc, Caskroom, Cellar, ...) are created, if brew install.sh script is used"
    DESC["BREW_SH"] = "Homebrew Library 'brew.sh' to be sourced by rc.awk via _generated_brew_sh() to get $HOMEBREW_* variables"
    DESC["CLT"] = "Command Line Tools HOME directory"
    DESC["DEBIAN_FRONTEND"] = "true (bool) if Running in a Docker Container and $DEBIAN_LIKE is 'true' else false"
    DESC["DIST_ID"] = "Distribution ID, i.e: alpine, centos, debian, kali, macOS, ubuntu, etc."
    DESC["DIST_BUILD_ID"] = "Distribution Build ID, i.e: arch (rolling), etc. (default: $DIST_ID)"
    DESC["DIST_ID_LIKE"] = "Linux Distribution ID Like, i.e: alpine, debian, rhel_fedora, etc. (default: $DIST_ID)"
    DESC["DIST_IDS_LIKE"] = "Supported DIST_ID_LIKEs"
    DESC["DIST_IDS"] = "Supported DIST_IDs"
    DESC["DIST_NAME"] = "Linux Distribution Name, i.e: CentOS Linux, Kali GNU/Linux, etc. (default: $DIST_ID)"
    DESC["DIST_PRETTY_NAME"] = "Linux Distribution Pretty Name, i.e: CentOS Linux 8, Kali GNU/Linux Rolling, etc. (default: $DIST_ID)"
    DESC["DIST_VERSION"] = "Distribution Version, i.e: debian (11 (bullseye)), kali (2021.2), ubuntu (22.04.1 LTS (Jammy Jellyfish)), etc. (default: $DIST_VERSION_ID)"
    DESC["DIST_VERSION_CODENAME"] = "Distribution Codename, i.e: Catalina, kali-rolling, ubuntu (jammy), debian (bullseye), etc. (default: $DIST_VERSION_ID)"
    DESC["DIST_VERSION_ID"] = "Distribution Version, i.e: macOS (10.15.1, 10.16), kali (2021.2), ubuntu (20.04), etc."
    DESC["DOCKER_CONTAINER"] = "true (bool) if Running in a Docker Container"
    DESC["GIT_CONFIG_SYSTEM"] = "Git config system-level configuration /etc/gitconfig or /usr/local/etc/gitconfig (equal to: $RC_GIT_CONFIG) [https://git-scm.com/docs/git-config]"
    DESC["GIT_TEMPLATE_DIR"] = "Files and directories in the template directory whose name do not start with a dot will be copied to the $GIT_DIR after it is created (equal to: $RC_GIT_GENERATED_TEMPLATE_DIR) [https://git-scm.com/docs/git-init]"
    DESC["GITHUB_CI"] = "true (bool) if $GITHUB_ACTIONS is 'true' else false"
    DESC["HOST"] = "First part of $HOSTNAME withouth domain"
    DESC["HOST_UPPER"] = "First part of $HOSTNAME withouth domain in upper case"
    DESC["HOSTNAME"] = "$HOSTNAME including domain"
    DESC["HOSTNAME_DOMAIN"] = "$HOSTNAME domain only"
    DESC["HOSTS"] = "book imac mini1 mini512 msi pro"
    DESC["IGET"] = "Download Utility Path: curl, wget or git (default: '')"
    DESC["INFOPATH"] = "$INFOPATH environment variable"
    DESC["HOMEBREW_PREFIX"] = "Brew Prefix directory where subdirectories (etc, Caskroom, Cellar, ...) are created, if brew install.sh script is used"
    DESC["MACHINE_HW"] = "Machine Hardware Name (uname -m), i.e: aarch64, arm64, x86_64, etc."
    DESC["MACHINE_HW_PLATFORM"] = "Machine Hardware Platform [Ubuntu only] (uname -i), i.e: aarch64, arm64, x86_64, etc. (default: unknown)"
    DESC["MACHINE_PROCESSOR_ARCH"] = "Machine Processor Architecture Name/Processor Type [Darwin only] (uname -p), i.e: i386, (default: unknown)"
    DESC["MANPATH"] = "$MANPATH environment variable"
    DESC["NODENAME"] = "Name that the system is known by to a communication network/Network Node Hostname (uname -n), contains the domain"
    DESC["PATH"] = "$PATH environment variable"
    DESC["OS_RELEASE"] = "Operating System Release/Kernel Release (uname -r), i.e: Darwin (21.6.0), Linux (5.10.124-linuxkit), etc."
    DESC["OS_VERSION"] = "Operating System Version/Kernel Version (uname -v), includes i.e.: $OS_NAME, $OS_RELEASE, $MACHINE_HW, etc."
    DESC["PM"] = "Default Package Manager, i.e: apt, apk, brew, dnf, pacman, yum, etc."
    DESC["PM_INSTALL"] = "Default Package Manager Command with Install Options"
    DESC["RC"] = "RC Top Repository Path"
    DESC["RC_CONFIG"] = "RC 'config' directory for applications configuration that can be configured with a variable"
    DESC["RC_COMMON"] = "RC subdirectory and file stem name common to any platform, OS or host"
    DESC["RC_CUSTOM"] = "RC 'custom' directory .gitignore to install custom files under manpaths.d, paths.d, profile.d and rc.d. It is the 3rd and the last to be sourced."
    DESC["RC_CUSTOM_COMPLETIONS"] = "RC 'custom' 'completions' (dinamically loaded by __load_completion()/_completion_loader() functions using $BASH_COMPLETION_USER_DIR, they add 'completions' to $BASH_COMPLETION_USER_DIR. rc/src/completions are symlinked to $RC_CUSTOM_COMPLETIONS"
    DESC["RC_CUSTOM_PROFILE_D"] = "RC 'custom' 'profile.d' directory .gitignore to install exported data"
    DESC["RC_CUSTOM_RC_D"] = "RC 'custom' 'rc.d' directory .gitignore to install custom interactive shell data"
    DESC["RC_DOTFILES"] = "RC dotfiles for configuration files that can not be configured with a variable or are secret $XDG_CONFIG_HOME. Install at the same level as $RC"
    DESC["RC_DOTFILES_SSH"] = "RC dotfiles for SSH keys, config and optionally for authorized_keys"
    DESC["RC_ETC"] = "RC 'etc' directory to install functions (exported based on BASH4), global data under profile.d. It is the 2nd to be sourced."
    DESC["RC_ETC_FUNCTIONS_D"] = "RC 'etc' 'functions.d' to install functions (exported based on BASH4)"
    DESC["RC_ETC_PROFILE_D"] = "RC 'etc' 'profile.d' directory to install exported data"
    DESC["RC_ETC_RC_D"] = "RC 'custom' 'rc.d' directory to install custom interactive shell data"
    DESC["RC_FILE"] = "RC system-wide profile and $ENV file"
    DESC["RC_GENERATED"] = "RC 'generated' directory for data generated by this and other scripts (i.e.: colors). It is the 1st to be sourced."
    DESC["RC_GENERATED_BIN"] = "RC 'generated' 'bin' for generated"
    DESC["RC_GENERATED_COLOR"] = "RC 'generated' 'color' bin for generated color scripts"
    DESC["RC_GENERATED_PROFILE_D"] = "RC 'generated' 'profile.d' directory to install generated exported data (i.e.: colors.sh and hosts.d)"
    DESC["RC_GENERATED_PROFILE_D_HOSTS_D"] = "RC 'generated' 'profile.d' 'hosts.d' directory to install generated exported data for each host"
    DESC["RC_GENERATED_RC_D"] = "RC 'generated' 'rc.d' directory to install generated interactive shell data (i.e.: aliases.d)"
    DESC["RC_GIT_CONFIG"] = "RC 'config' 'git' directory for: gitconfig, gitignore and hooks"
    DESC["RC_GIT_DOTFILES"] = "RC 'dotfiles' 'git' directory for: gitcredentials (use in: 'git-credential-rc')"
    DESC["RC_GIT_GENERATED"] = "RC 'generated' 'git' for git init template (use in: rc)"
    DESC["RC_GIT_CONFIG_EXCLUDES"] = "RC 'generated' 'git' 'excludesFile' for git config core.excludesFile (use in: 'gitconfig')"
    DESC["RC_GIT_CONFIG_HOOKS"] = "Git hooks directory used in gitconfig core.hookspath (use in: 'gitconfig')"
    DESC["RC_GIT_CONFIG_SYSTEM"] = DESC["GIT_CONFIG_SYSTEM"]" (Official GIT variable $GIT_CONFIG_SYSTEM)"
    DESC["RC_GIT_CREDENTIALS_APP_CLIENT_ID"] = "Client ID for git-credential-rc command and GitCredentialRC GitHub app (use in: 'git-credential-rc)' [https://github.com/settings/apps/GitCredentialRC]"
    DESC["RC_GIT_DEFAULT_BRANCH"] = "Git default branch from git config to generate template, etc. (use in: rc)"
    DESC["RC_GIT_DEFAULT_USER"] = "Git Default User"
    DESC["RC_GIT_DOTFILES_CREDENTIALS"] = "Git Credential Store, (use in: 'git-credential-rc') [https://git-scm.com/docs/git-credential-store]"
    DESC["RC_GIT_GENERATED_TEMPLATE_DIR"] = DESC["GIT_TEMPLATE_DIR"]" (Official GIT variable $GIT_CONFIG_SYSTEM)"
    DESC["RC_GITHUB_DEFAULT_USER"] = "GitHub Default User (equal to: $RC_GIT_DEFAULT_USER until other servers are used)"
    DESC["RC_GENERATED_RC_D_ALIASES_D"] = "RC 'generated' 'rc.d' 'aliases.d' directory to install generated interactive shell aliases generated by this script"
    DESC["RC_SUPPORTED"] = "Search Vars: $RC_COMMON, $DIST_ID, $DIST_ID_LIKE, $HOST, $SH and $UNAME. Supported file stem takes precedence over excluded directory, i.e: Darwin/Linux.sh will be sourced"
    DESC["UNAME"] = "Operating System Name/Kernel Name (uname -s), i.e: Linux, Darwin, etc."
    DESC["UNAME_OS"] = "Operating System [Ubuntu only] (uname -o), i.e: ubuntu (GNU/Linux), alpine (Linux), etc."
    DESC["VGA"] = "true (bool) if haa an VGA card else false"

    MACOS_VERSIONS["10.13"]="High Sierra"
    MACOS_VERSIONS["10.14"]="Mojave"
    MACOS_VERSIONS["10.15"]="Catalina"
    MACOS_VERSIONS["11"]="Big Sur"
    MACOS_VERSIONS["12"]="Monterey"
    MACOS_VERSIONS["13"]="Ventura"

    PMS["alpine"] = "apk"
    PMS["arch"] = "pacman"
    PMS["debian"] = "apt-get"
    PMS["fedora"] = "yum"
    PMS["macOS"] = "brew"
    PMS["nix"] = "nix-env"

    PMS_INSTALL["alpine"] = "add -q --no-progress --no-cache"
    PMS_INSTALL["arch"] = "-S --noconfirm"
    PMS_INSTALL["debian"] = "-qq install -y"
    PMS_INSTALL["fedora"] = "install -y -q"
    PMS_INSTALL["macOS"] = "install --quiet"
    PMS_INSTALL["nix"] = "--install -A --quiet"

    for ( key in DESC ) { VALUES[key] = "" }

    VALUES["BASH_SILENCE_DEPRECATION_WARNING"] = 1
    VALUES["BASE_INFOPATH"] = "/usr/local/share/info:/usr/share/info"
    VALUES["BASE_MANPATH"] = "/usr/local/share/man:/usr/share/man:"
    VALUES["BASE_PATH"] = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    VALUES["CLT"] = "/Library/Developer/CommandLineTools"
    VALUES["BREW_PREFIX"] = "/usr/local"
    VALUES["DIST_IDS"] = "alpine arch busybox centos debian fedora kali macOS nix rhel ubuntu"
    for (key in PMS) { VALUES["DIST_IDS_LIKE"] = VALUES["DIST_IDS_LIKE"]" "key}; sub(" ", "", VALUES["DIST_IDS_LIKE"])
    VALUES["DOCKER_CONTAINER"] = "false"; if ( system("test -f /.dockerenv") == 0 ) { VALUES["DOCKER_CONTAINER"] = "true" }
    VALUES["GITHUB_CI"] = "false"; if ( ENVIRON["GITHUB_ACTIONS"] == "true" ) { VALUES["GITHUB_CI"] = "true" }
    VALUES["HOST"] = process("hostname -s 2>/dev/null || cut -d '.' -f 1 /etc/hostname")
    VALUES["HOST_UPPER"] = toupper(VALUES["HOST"])
    VALUES["HOSTS"] = "book imac mini1 mini512 msi pro"
    VALUES["HOSTNAME"] = process("hostname 2>/dev/null || cat /etc/hostname")
    VALUES["HOSTNAME_DOMAIN"] = process("hostname -d 2>/dev/null || cut -d '.' -f 2- /etc/hostname 2>/dev/null || hostname | cut -d '.' -f 2-")
    VALUES["INFOPATH"] = VALUES["BASE_INFOPATH"]
    VALUES["MACHINE_HW_PLATFORM"] = "unknown"
    VALUES["MACOS"] = "true"
    VALUES["MANPATH"] = VALUES["BASE_MANPATH"]
    VALUES["PATH"] = VALUES["BASE_PATH"]
    VALUES["RC"] = RC
    VALUES["RC_CONFIG"] = RC"/config"
    VALUES["RC_COMMON"] = "00-common"
    VALUES["RC_CUSTOM"] = RC"/custom"
    VALUES["RC_CUSTOM_COMPLETIONS"] = VALUES["RC_CUSTOM"]"/completions"
    VALUES["RC_CUSTOM_PROFILE_D"] = VALUES["RC_CUSTOM"]"/profile.d"
    VALUES["RC_CUSTOM_RC_D"] = VALUES["RC_CUSTOM"]"/rc.d"
    VALUES["RC_DOTFILES"] = dirname(RC)"/dotfiles"
    VALUES["RC_DOTFILES_SSH"] = VALUES["RC_DOTFILES"]"/.ssh"
    VALUES["RC_ETC"] = RC"/etc"
    VALUES["RC_ETC_FUNCTIONS_D"] = VALUES["RC_ETC"]"/functions.d"
    VALUES["RC_ETC_PROFILE_D"] = VALUES["RC_ETC"]"/profile.d"
    VALUES["RC_ETC_RC_D"] = VALUES["RC_ETC"]"/rc.d"
    VALUES["RC_FILE"] = RC"/."basename(RC)".sh"
    VALUES["RC_GENERATED"] = RC"/generated"
    VALUES["RC_GENERATED_BIN"] = VALUES["RC_GENERATED"]"/bin"
    VALUES["RC_GENERATED_COLOR"] = VALUES["RC_GENERATED"]"/color"
    VALUES["RC_GENERATED_PROFILE_D"] = VALUES["RC_GENERATED"]"/profile.d"
    VALUES["RC_GENERATED_PROFILE_D_HOSTS_D"] = VALUES["RC_GENERATED_PROFILE_D"]"/hosts.d"
    VALUES["RC_GENERATED_RC_D"] = VALUES["RC_GENERATED"]"/rc.d"
    VALUES["RC_GENERATED_RC_D_ALIASES_D"] = VALUES["RC_GENERATED_RC_D"]"/aliases.d"
    VALUES["RC_SUPPORTED"] = VALUES["RC_COMMON"]" bash bash-4 zsh Darwin Linux "VALUES["DIST_IDS"]" rhel_fedora "VALUES["HOST"]
    VALUES["SUDO"] = "/usr/bin/sudo"
    VALUES["UNAME_OS"] = "unknown"
    VALUES["VGA"]="true"

    VALUES["BASH_COMPLETION_USER_DIR"] = VALUES["RC_CUSTOM_COMPLETIONS"]

    # TODO: Ver si lo hago por usuario (symlink de comunes), o permisos de escritura para todos, hay que ver si las cambian las app o no.
    VALUES["XDG_CONFIG_HOME"] = VALUES["RC_DOTFILES"]

    SCRIPT = basename(ENVIRON["_"])
    VARS = 1
    for (i in ARGV) {
        if (i == 0) { continue }
        if (ARGV[i] == "desc") {
            DESCRIPTIONS = 1
        } else if (ARGV[i] == "save") {
            OUTPUT = ARGV[i+1]
            if ( OUTPUT == "" ) { die(1, 1, "Missing file to save output") }
        } else if (ARGV[i] == "hook") { HOOK = 1; break }
        else { die(1, 1, "Invalid argument: "ARGV[i]) }
    }
    if (VARS == 1) {
        vars_git()
        vars_system()
        if (HOOK == 1) { print VALUES["RC_FILE"] }
        else if (OUTPUT == 1) { output_desc_vars() > OUTPUT }
        else { output_desc_vars() }
    }
}

function die(code, help, msg) {
    if (msg != "") { print SCRIPT":", msg; print  }
    if (help == 1) {
        print "Usage: "SCRIPT" [options] [file]"
        print
        print "Generates system and RC variables for system-wide profile"
        print
        print "Commands:"
        print "  help       show help message and exit"
        print "  hook       show $RC_FILE: "VALUES["RC_FILE"]", hook path for /etc/profile.d"
        print "  install    install in generated directory"
        print "  desc       show output with variable descriptionss"
        print "  save       save output to file (file is mandatory)"
        print
        print "Arguments:"
        print "  file    file to save output (required if save option is used)"
    }
    exit code
}

function basename(path,   parts,total) { total = split(path, parts, "/"); return parts[total] }

function dirname(path) { return process("cd "path" && pwd -P") }

function helper_system_commands(   commands,commands_array,i,rv,upper) {
    commands="bash brew curl git sudo wget"
    split(commands, commands_array, " ")
    for (i in commands_array) {
        rv = process("PATH=\""VALUES["PATH"]"\" command -v "commands_array[i])
        upper = toupper(commands_array[i])
        DESC[upper] = upper" Command Path"
        VALUES[upper] = rv
    }

    if (VALUES["CURL"] ~ /curl$/ ) {
        VALUES["IGET"] = VALUES["CURL"]
    } else if  (VALUES["WGET"] ~ /wget$/  ) {
        VALUES["IGET"] = VALUES["WGET"]
    } else if  (VALUES["GIT"] ~ /git$/ ) {
        VALUES["IGET"] = VALUES["GIT"]
    }
}

function helper_system_dist_bools (array, suffix,  key,upper) {
    if ( suffix == "" ) { split(VALUES["DIST_IDS"], array, " ") }
    for (key in array) {
        if (suffix == "") { key = array[key] }
        upper = toupper(key)suffix
        DESC[upper] = "true (bool) if $DIST_ID"suffix" is "key" else false"
        if (VALUES["DIST_ID"suffix] == key) {
            VALUES[upper] = "true"
            if (suffix == "_LIKE") { VALUES["PM_INSTALL"] = PMS_INSTALL[key] }
        } else {
            VALUES[upper] = "false"
        }
    }
}

function helper_system_pm() {
    VALUES["PM"] = PMS[VALUES["DIST_ID_LIKE"]]
    if ( VALUES["PM"] != "brew" && VALUES["SUDO"] != "") { VALUES["PM"] = VALUES["SUDO"]" "VALUES["PM"] }
    VALUES["PM_INSTALL"] = VALUES["PM"]" "PMS_INSTALL[VALUES["DIST_ID_LIKE"]]
    if ( VALUES["PM"] ~ /apt-get/ ) {
        VALUES["APT_UPGRADE"] = VALUES["PM"]" -qq full-upgrade -y && "VALUES["PM"]" -qq auto-remove -y && "VALUES["PM"]" -qq clean"
        VALUES["PM_INSTALL"] = VALUES["PM"]" -qq update -y && "VALUES["PM_INSTALL"]
        if (VALUES["DOCKER_CONTAINER"] == "true") { VALUES["DEBIAN_FRONTEND"] = "noninteractive" }
    } else if ( VALUES["PM"] ~ /nix/ ) {
        VALUES["PM_INSTALL"] = "nix-channel --update --quiet && "VALUES["PM_INSTALL"]
    } else if ( VALUES["PM"] ~ /pacman/ ) {
        VALUES["PM_INSTALL"] = VALUES["PM"]" -Sy && "VALUES["PM_INSTALL"]
    } else if ( VALUES["DIST_ID_LIKE"] ~ /fedora/ || /rhel/) {
        VALUES["PM"] = PMS["fedora"]
        VALUES["PM_INSTALL"] = VALUES["PM"]" "PMS_INSTALL["fedora"]
    }
}

function helper_VALUES_default(key, value) { if ( VALUES[key] == "" ) { VALUES[key] = value } }

function output_desc_vars(   key) {
    sort_desc_keys()

    if (DESCRIPTIONS == 1) {
        printf("# %s\n\n#\n# %s\n#\n# %s\n\n\n", "shellcheck shell=sh", "OS/system Generated Variables", "Generated by: '"SCRIPT"' script, on: "process("date '+%F %T %z'"))
    }
    while ((getline key < TMP) > 0) {
        if (DESCRIPTIONS == 1) { printf("# %s\n# \n", DESC[key]) }
        printf("%s %s%s\"%s\"\n", "export", key, "=", VALUES[key])
        if (DESCRIPTIONS == 1) { print }
    }
}

function process(command,   stdout ) { command | getline stdout; close(command); return stdout }  # Shows only first line

function rc(   tmp) {
    RC = ENVIRON["_"]
    if ( RC == "" ) {
        tmp = process("mktemp")
        system("tr \"\\000\" \"\\n\" < /proc/$PPID/cmdline | grep "SCRIPT" > "tmp)
        RC = process("cat "tmp)
    }
    rc_die()
    RC = process("cd \"$(dirname \""RC"\")/..\" && pwd -P")
    rc_die()
}

function rc_die() { if ( RC == "" ) { die(1, 0, "Unable to find script path") } }

function sort_desc_keys(   command,key) {
    TMP=process("mktemp")

    command = "printf '%s\\n'"
    for (key in DESC) { command = command" "key }
    command=command" | sort > "TMP
    process(command)
}

function vars_git() {
    VALUES["RC_GIT_CONFIG"] = VALUES["RC_CONFIG"]"/git"
    VALUES["RC_GIT_DOTFILES"] = VALUES["RC_DOTFILES"]"/git"
    VALUES["RC_GIT_GENERATED"] = VALUES["RC_GENERATED"]"/git"

    VALUES["RC_GIT_CONFIG_EXCLUDES"] = VALUES["RC_GIT_CONFIG"]"/gitignore"  # Used in gitconfig
    VALUES["RC_GIT_CONFIG_HOOKS"] = VALUES["RC_GIT_CONFIG"]"/hooks"  # Used in gitconfig
    VALUES["RC_GIT_CONFIG_SYSTEM"] = VALUES["RC_GIT_CONFIG"]"/gitconfig"  # Official GIT variable GIT_CONFIG_SYSTEM
    VALUES["RC_GIT_CREDENTIALS_APP_CLIENT_ID"] = "Iv1.7bafcceb3f25cce5"  # Used in git-credential-rc
    VALUES["RC_GIT_DEFAULT_BRANCH"] = process("awk -F= '/defaultBranch/ { gsub(\" \", \"\"); print $2 }' "VALUES["RC_GIT_CONFIG_SYSTEM"])  # Used in rc
    VALUES["RC_GIT_DEFAULT_USER"] = "j5pu"
    VALUES["RC_GIT_DOTFILES_CREDENTIALS"] = VALUES["RC_GIT_DOTFILES"]"/.git-credentials"  # Used in git-credential-rc
    VALUES["RC_GIT_GENERATED_TEMPLATE_DIR"] = VALUES["RC_GIT_GENERATED"]"/template"  # Official GIT variable GIT_TEMPLATE_DIR
    VALUES["RC_GITHUB_DEFAULT_USER"] = VALUES["RC_GIT_DEFAULT_USER"]

    VALUES["GIT_CONFIG_SYSTEM"] = VALUES["RC_GIT_CONFIG_SYSTEM"]
    VALUES["GIT_TEMPLATE_DIR"] = VALUES["RC_GIT_GENERATED_TEMPLATE_DIR"]
}

function vars_homebrew() {}

function vars_paths() {}

function vars_system(   brew_path,i,id,max,os_release,paths,repo,total,uname) {
    total = split(process("uname -a"), uname, " ")
    max = total -1
    repo = "/Homebrew"

    if (uname[1] == "Darwin") {
        VALUES["BASE_PATH"] = VALUES["BASE_PATH"]":"VALUES["CLT"]
        VALUES["PATH"] = VALUES["BASE_PATH"]

        paths = process(RC"/bin/pathsd /etc/paths.d")
        if ( paths != "" ) { VALUES["PATH"] = VALUES["PATH"]":"paths }

        paths = process(RC"/bin/pathsd /etc/manpaths.d")
        if ( paths != "" ) { VALUES["MANPATH"] = VALUES["MANPATH"]paths":" }

        VALUES["DIST_ID"] = process("/usr/bin/sw_vers -productName")
        sub("Mac OS X", "macOS", VALUES["DIST_ID"])
        VALUES["DIST_VERSION_ID"] = process("/usr/bin/sw_vers -productVersion")

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

        if (system("test -f /etc/os-release") == 0) {
            while ((getline i < "/etc/os-release") > 0) {
                split(i, os_release, "=")
                if ( os_release[1] !~ /(_URL|_COLOR)/ ) {
                    if ( os_release[2] ~ /rhel / ) { gsub(" ", "_", os_release[2]) }
                    gsub("\"", "", os_release[2]); VALUES["DIST_"os_release[1]] = os_release[2]
                }
            }
        } else if (system("test -d /etc/nix") == 0) {
            VALUES["DIST_ID"] = "nix"
            VALUES["INFOPATH"] = ENVIRON["HOME"]"/.nix-profile/share/info:/nix/var/nix/profiles/default/share/info:/nix/var/nix/profiles/default/share/info:"VALUES["INFOPATH"]
            VALUES["MANPATH"] = ENVIRON["HOME"]"/.nix-profile/share/man:/nix/var/nix/profiles/default/share/info:/nix/var/nix/profiles/default/share/man:"VALUES["MANPATH"]
            VALUES["PATH"] = ENVIRON["HOME"]"/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:"VALUES["PATH"]
        }
        else { VALUES["DIST_ID"] = "busybox"; VALUES["DIST_ID_LIKE"] = "alpine"; }

        if (system("lspci 2>/dev/null | grep -q VGA") != 0) { VALUES["VGA"] = "false" }
    }
    if (brew_path == 1) {
        VALUES["INFOPATH"] = VALUES["BREW_PREFIX"]"/share/info:"VALUES["INFOPATH"]
        VALUES["MANPATH"] = VALUES["BREW_PREFIX"]"/share/man:"VALUES["MANPATH"]
        VALUES["PATH"] = VALUES["BREW_PREFIX"]"/bin:"VALUES["PATH"]
    }

    VALUES["INFOPATH"] = VALUES["RC_CUSTOM"]"/share/info:"VALUES["RC_CUSTOM"]"/share/info:"VALUES["INFOPATH"]
    VALUES["MANPATH"] = VALUES["RC_CUSTOM"]"/share/man:"VALUES["RC_CUSTOM"]"/share/man:"VALUES["MANPATH"]
    VALUES["PATH"] = VALUES["RC_CUSTOM"]"/bin:"RC"/bin:"VALUES["RC_GENERATED_COLOR"]":"VALUES["PATH"]

    VALUES["BREW_SH"] = VALUES["BREW_PREFIX"] repo "/Library/Homebrew/brew.sh"

    helper_VALUES_default("DIST_BUILD_ID", VALUES["DIST_ID"])
    helper_VALUES_default("DIST_ID_LIKE", VALUES["DIST_ID"])
    helper_VALUES_default("DIST_NAME", VALUES["DIST_ID"])
    helper_VALUES_default("DIST_PRETTY_NAME", VALUES["DIST_ID"])
    helper_VALUES_default("DIST_VERSION", VALUES["DIST_VERSION_ID"])
    helper_VALUES_default("DIST_VERSION_CODENAME", VALUES["DIST_VERSION_ID"])
    helper_VALUES_default("HOMEBREW_PREFIX", VALUES["BREW_PREFIX"])

    VALUES["MACHINE_PROCESSOR_ARCH"] = process("uname -p")

    VALUES["NODENAME"] = uname[2]

    VALUES["OS_RELEASE"] = uname[3]

    VALUES["OS_VERSION"] = uname[4]
    for (i=5; i<=max; i++) { VALUES["OS_VERSION"] = VALUES["OS_VERSION"]" "uname[i] }
    VALUES["OS_VERSION"] = VALUES["OS_VERSION"]

    VALUES["UNAME"] = uname[1]
    if (ENVIRON["CI"] != "" ) { VALUES["CI"] = "false" }

    helper_system_dist_bools(PMS, "_LIKE")
    helper_system_commands()
    helper_system_pm()
    helper_system_dist_bools()
}

