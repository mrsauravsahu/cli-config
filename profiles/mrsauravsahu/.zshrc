# vim: set filetype=sh :
DISABLE_AUTO_UPDATE="true"
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_COMPFIX="true"

# Smarter completion initialization
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

# zmodload zsh/zprof

export PATH="${PATH}:/opt/homebrew/bin"

# add dotfiles script to the path
if [ -d "${HOME}/.mrsauravsahu/dotfiles/scripts" ]; then
  export PATH="${PATH}:${HOME}/.mrsauravsahu/dotfiles/scripts"
fi

GDK_SCALE=2

# case insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

currentOs=`uname -s | tr 'A-Z' 'a-z'`

CLI_CONFIG_ROOT=$(ls -la ~/.zshrc | sed "s/^.*\->//" | awk -F '/' 'NF{NF-=3}1' 'OFS=/' | xargs)
CLI_CONFIG_THEME='atomic'

XARGS_OPTIONS=$(if [ "${currentOs}" = "linux" ]; then echo '--no-run-if-empty'; else echo ''; fi)

# cleanup old zsh compiled files
# find ${CLI_CONFIG_ROOT}/current -maxdepth 2 -type f -regex '.*zwc$' | xargs ${XARGS_OPTIONS} rm

# loads cli-config env variables
. $CLI_CONFIG_ROOT/src/scripts/env.zsh

# runs the configuration for all installed programs
. $CLI_CONFIG_PROGRAMS_CONF

# create a secret.linux.zshrc or secret.darwin.zshrc to run your customizations
. ${CLI_CONFIG_ROOT}/profiles/mrsauravsahu/${currentOs}.zshrc 2> /dev/null || true
. ${CLI_CONFIG_ROOT}/profiles/mrsauravsahu/secret.${currentOs}.zshrc 2> /dev/null || true

SAVEHIST=100000  # Save most-recent 100000 lines
HISTFILE=~/.zsh_history

alias cat=bat
alias ll='ls -l'
alias l='ls'

# export APPLE_SSH_ADD_BEHAVIOR=macos
# ssh-add -K > /dev/null

export PATH="${PATH}:/Users/Saurav_Sahu/.dotnet/tools"
export PATH="${PATH}:/opt/homebrew/opt/ruby@3.2/bin"
export PATH="${PATH}:/opt/homebrew/lib/ruby/gems/3.2.0/bin"
export PATH="${PATH}:${CLI_CONFIG_ROOT}/current/path"

alias http-server='npx files-upload-server /Users/Saurav_Sahu/Desktop/local-http-server/'
# alias colima_start='colima start --mount-type virtiofs --cpu 12 --memory 20 --disk 256 --with-kubernetes'
alias colima_start='colima start --mount-type virtiofs --cpu 12 --memory 20 --disk 256 --with-kubernetes --vm-type vz --vz-rosetta'
alias vim=nvim

. "$HOME/.cargo/env"

# alias k='kubectl --kubeconfig /Users/Saurav_Sahu/.homelab-pi/config/pi.dory-char.ts.net.kubeconfig'
# alias h='helm --kubeconfig /Users/Saurav_Sahu/.homelab-pi/config/pi.dory-char.ts.net.kubeconfig'

alias h=helm; alias k=kubectl
export KUBECONFIG='/Users/Saurav_Sahu/.homelab-pi/config/192.168.0.184.kubeconfig'

export PATH="$HOME/.asdf/shims:${PATH}"
. ~/.asdf/plugins/dotnet/set-dotnet-env.zsh
. ~/.asdf/plugins/golang/set-env.zsh

alias work="code --user-data-dir '/Users/Saurav_Sahu/.config/vscode-manager/work/data' --extensions-dir '/Users/Saurav_Sahu/.config/vscode-manager/work/extensions'"

export p=/Users/Saurav_Sahu/Downloads/mrsauravsahu/code/payobills
export PATH="/Users/Saurav_Sahu/.cli-config/current/asdf:/Users/Saurav_Sahu/.asdf/installs/rust/1.79.0/bin:${PATH}"

# mrss

mrss_extract_audio() {
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: mrss_audio <input_video> [output_audio]"
    echo "Example: mrss_audio project_name.kdenlive.mp4 processed-audio/project_name.wav"
    return 1
  fi

  local input_video="$1"
  local output_audio="${2:-${input_video%.*}.wav}"

  mkdir -p "$(dirname "$output_audio")"

  ffmpeg -i "$input_video" -vn -acodec pcm_s16le -ar 44100 -ac 2 "$output_audio"

  echo "✅ Extracted audio to $output_audio"
}

mrss_new() {
  date_prefix="$(date +"%Y-%m-%d")"
  project_name="${date_prefix}-$1"
  base_dir="$(pwd)/$project_name"

    if [ -z "$project_name" ]; then
        echo "Usage: mrss_new <project-name>"
        return 1
    fi
    mkdir -p "$project_name"/{DJI,ScreenCasts}
    echo "Created project folder: $project_name with subfolders DJI and ScreenCasts"

  # Create project structure
  mkdir -p "$base_dir"/{DJI,ScreenCasts}

  # Generate Kdenlive project file
  kdenlive_file="$base_dir/$project_name.kdenlive"

  cat > "$kdenlive_file" <<EOF
<?xml version='1.0' encoding='utf-8'?>
<mlt LC_NUMERIC="en_US.UTF-8" producer="main_bin" root="$base_dir" version="7.30.0">
 <profile colorspace="709" description="HD 1080p 25 fps" display_aspect_den="9" display_aspect_num="16" frame_rate_den="1" frame_rate_num="25" height="1080" progressive="1" sample_aspect_den="1" sample_aspect_num="1" width="1920"/>
 <producer id="producer0" in="00:00:00.000" out="00:05:00.000">
  <property name="length">2147483647</property>
  <property name="eof">continue</property>
  <property name="resource">black</property>
  <property name="aspect_ratio">1</property>
  <property name="mlt_service">color</property>
  <property name="kdenlive:playlistid">black_track</property>
  <property name="mlt_image_format">rgba</property>
  <property name="set.test_audio">0</property>
 </producer>
 <playlist id="playlist0">
  <property name="kdenlive:audio_track">1</property>
 </playlist>
 <playlist id="playlist1">
  <property name="kdenlive:audio_track">1</property>
 </playlist>
 <tractor id="tractor0" in="00:00:00.000">
  <property name="kdenlive:audio_track">1</property>
  <property name="kdenlive:trackheight">57</property>
  <property name="kdenlive:timeline_active">1</property>
  <property name="kdenlive:collapsed">0</property>
  <property name="kdenlive:thumbs_format"/>
  <property name="kdenlive:audio_rec"/>
  <track hide="video" producer="playlist0"/>
  <track hide="video" producer="playlist1"/>
  <filter id="filter0">
   <property name="window">75</property>
   <property name="max_gain">20dB</property>
   <property name="mlt_service">volume</property>
   <property name="internal_added">237</property>
   <property name="disable">1</property>
  </filter>
  <filter id="filter1">
   <property name="channel">-1</property>
   <property name="mlt_service">panner</property>
   <property name="internal_added">237</property>
   <property name="start">0.5</property>
   <property name="disable">1</property>
  </filter>
  <filter id="filter2">
   <property name="iec_scale">0</property>
   <property name="mlt_service">audiolevel</property>
   <property name="dbpeak">1</property>
   <property name="disable">1</property>
  </filter>
 </tractor>
 <playlist id="playlist2">
  <property name="kdenlive:audio_track">1</property>
 </playlist>
 <playlist id="playlist3">
  <property name="kdenlive:audio_track">1</property>
 </playlist>
 <tractor id="tractor1" in="00:00:00.000">
  <property name="kdenlive:audio_track">1</property>
  <property name="kdenlive:trackheight">57</property>
  <property name="kdenlive:timeline_active">1</property>
  <property name="kdenlive:collapsed">0</property>
  <property name="kdenlive:thumbs_format"/>
  <property name="kdenlive:audio_rec"/>
  <track hide="video" producer="playlist2"/>
  <track hide="video" producer="playlist3"/>
  <filter id="filter3">
   <property name="window">75</property>
   <property name="max_gain">20dB</property>
   <property name="mlt_service">volume</property>
   <property name="internal_added">237</property>
   <property name="disable">1</property>
  </filter>
  <filter id="filter4">
   <property name="channel">-1</property>
   <property name="mlt_service">panner</property>
   <property name="internal_added">237</property>
   <property name="start">0.5</property>
   <property name="disable">1</property>
  </filter>
  <filter id="filter5">
   <property name="iec_scale">0</property>
   <property name="mlt_service">audiolevel</property>
   <property name="dbpeak">1</property>
   <property name="disable">1</property>
  </filter>
 </tractor>
 <playlist id="playlist4"/>
 <playlist id="playlist5"/>
 <tractor id="tractor2" in="00:00:00.000">
  <property name="kdenlive:trackheight">57</property>
  <property name="kdenlive:timeline_active">1</property>
  <property name="kdenlive:collapsed">0</property>
  <property name="kdenlive:thumbs_format"/>
  <property name="kdenlive:audio_rec"/>
  <track hide="audio" producer="playlist4"/>
  <track hide="audio" producer="playlist5"/>
 </tractor>
 <playlist id="playlist6"/>
 <playlist id="playlist7"/>
 <tractor id="tractor3" in="00:00:00.000">
  <property name="kdenlive:trackheight">57</property>
  <property name="kdenlive:timeline_active">1</property>
  <property name="kdenlive:collapsed">0</property>
  <property name="kdenlive:thumbs_format"/>
  <property name="kdenlive:audio_rec"/>
  <track hide="audio" producer="playlist6"/>
  <track hide="audio" producer="playlist7"/>
 </tractor>
 <tractor id="{1811df77-6093-4279-a807-3b60f327fa63}" in="00:00:00.000" out="00:05:00.000">
  <property name="kdenlive:uuid">{1811df77-6093-4279-a807-3b60f327fa63}</property>
  <property name="kdenlive:clipname">Sequence 1</property>
  <property name="kdenlive:sequenceproperties.hasAudio">1</property>
  <property name="kdenlive:sequenceproperties.hasVideo">1</property>
  <property name="kdenlive:sequenceproperties.activeTrack">2</property>
  <property name="kdenlive:sequenceproperties.tracksCount">4</property>
  <property name="kdenlive:sequenceproperties.documentuuid">{1811df77-6093-4279-a807-3b60f327fa63}</property>
  <property name="kdenlive:control_uuid">{1811df77-6093-4279-a807-3b60f327fa63}</property>
  <property name="kdenlive:duration">00:00:00:01</property>
  <property name="kdenlive:maxduration">1</property>
  <property name="kdenlive:producer_type">17</property>
  <property name="kdenlive:id">3</property>
  <property name="kdenlive:clip_type">0</property>
  <property name="kdenlive:file_size">0</property>
  <property name="kdenlive:folderid">2</property>
  <property name="kdenlive:sequenceproperties.audioTarget">1</property>
  <property name="kdenlive:sequenceproperties.disablepreview">0</property>
  <property name="kdenlive:sequenceproperties.position">0</property>
  <property name="kdenlive:sequenceproperties.scrollPos">0</property>
  <property name="kdenlive:sequenceproperties.tracks">4</property>
  <property name="kdenlive:sequenceproperties.verticalzoom">1</property>
  <property name="kdenlive:sequenceproperties.videoTarget">2</property>
  <property name="kdenlive:sequenceproperties.zonein">0</property>
  <property name="kdenlive:sequenceproperties.zoneout">75</property>
  <property name="kdenlive:sequenceproperties.zoom">8</property>
  <property name="kdenlive:sequenceproperties.groups">[
]
</property>
  <property name="kdenlive:sequenceproperties.guides">[
]
</property>
  <track producer="producer0"/>
  <track producer="tractor0"/>
  <track producer="tractor1"/>
  <track producer="tractor2"/>
  <track producer="tractor3"/>
  <transition id="transition0">
   <property name="a_track">0</property>
   <property name="b_track">1</property>
   <property name="mlt_service">mix</property>
   <property name="kdenlive_id">mix</property>
   <property name="internal_added">237</property>
   <property name="always_active">1</property>
   <property name="accepts_blanks">1</property>
   <property name="sum">1</property>
  </transition>
  <transition id="transition1">
   <property name="a_track">0</property>
   <property name="b_track">2</property>
   <property name="mlt_service">mix</property>
   <property name="kdenlive_id">mix</property>
   <property name="internal_added">237</property>
   <property name="always_active">1</property>
   <property name="accepts_blanks">1</property>
   <property name="sum">1</property>
  </transition>
  <transition id="transition2">
   <property name="a_track">0</property>
   <property name="b_track">3</property>
   <property name="compositing">0</property>
   <property name="distort">0</property>
   <property name="rotate_center">0</property>
   <property name="mlt_service">qtblend</property>
   <property name="kdenlive_id">qtblend</property>
   <property name="internal_added">237</property>
   <property name="always_active">1</property>
  </transition>
  <transition id="transition3">
   <property name="a_track">0</property>
   <property name="b_track">4</property>
   <property name="compositing">0</property>
   <property name="distort">0</property>
   <property name="rotate_center">0</property>
   <property name="mlt_service">qtblend</property>
   <property name="kdenlive_id">qtblend</property>
   <property name="internal_added">237</property>
   <property name="always_active">1</property>
  </transition>
  <filter id="filter6">
   <property name="window">75</property>
   <property name="max_gain">20dB</property>
   <property name="mlt_service">volume</property>
   <property name="internal_added">237</property>
   <property name="disable">1</property>
  </filter>
  <filter id="filter7">
   <property name="channel">-1</property>
   <property name="mlt_service">panner</property>
   <property name="internal_added">237</property>
   <property name="start">0.5</property>
   <property name="disable">1</property>
  </filter>
 </tractor>
 <playlist id="main_bin">
  <property name="kdenlive:folder.-1.2">Sequences</property>
  <property name="kdenlive:sequenceFolder">2</property>
  <property name="kdenlive:docproperties.audioChannels">2</property>
  <property name="kdenlive:docproperties.binsort">0</property>
  <property name="kdenlive:docproperties.browserurl">$base_dir</property>
  <property name="kdenlive:docproperties.documentid">1755340679327</property>
  <property name="kdenlive:docproperties.enableTimelineZone">0</property>
  <property name="kdenlive:docproperties.enableexternalproxy">0</property>
  <property name="kdenlive:docproperties.enableproxy">0</property>
  <property name="kdenlive:docproperties.externalproxyparams"/>
  <property name="kdenlive:docproperties.generateimageproxy">0</property>
  <property name="kdenlive:docproperties.generateproxy">0</property>
  <property name="kdenlive:docproperties.guidesCategories">[
    {
        "color": "#9b59b6",
        "comment": "Category 1",
        "index": 0
    },
    {
        "color": "#3daee9",
        "comment": "Category 2",
        "index": 1
    },
    {
        "color": "#1abc9c",
        "comment": "Category 3",
        "index": 2
    },
    {
        "color": "#1cdc9a",
        "comment": "Category 4",
        "index": 3
    },
    {
        "color": "#c9ce3b",
        "comment": "Category 5",
        "index": 4
    },
    {
        "color": "#fdbc4b",
        "comment": "Category 6",
        "index": 5
    },
    {
        "color": "#f39c1f",
        "comment": "Category 7",
        "index": 6
    },
    {
        "color": "#f47750",
        "comment": "Category 8",
        "index": 7
    },
    {
        "color": "#da4453",
        "comment": "Category 9",
        "index": 8
    }
]
</property>
  <property name="kdenlive:docproperties.kdenliveversion">24.12.3</property>
  <property name="kdenlive:docproperties.previewextension"/>
  <property name="kdenlive:docproperties.previewparameters"/>
  <property name="kdenlive:docproperties.profile">atsc_1080p_25</property>
  <property name="kdenlive:docproperties.proxyextension"/>
  <property name="kdenlive:docproperties.proxyimageminsize">2000</property>
  <property name="kdenlive:docproperties.proxyimagesize">800</property>
  <property name="kdenlive:docproperties.proxyminsize">1000</property>
  <property name="kdenlive:docproperties.proxyparams"/>
  <property name="kdenlive:docproperties.proxyresize">640</property>
  <property name="kdenlive:docproperties.seekOffset">30000</property>
  <property name="kdenlive:docproperties.sessionid">{b7dd78aa-d581-4be0-b993-a63f3ba42f03}</property>
  <property name="kdenlive:docproperties.uuid">{1811df77-6093-4279-a807-3b60f327fa63}</property>
  <property name="kdenlive:docproperties.version">1.1</property>
  <property name="kdenlive:expandedFolders"/>
  <property name="kdenlive:binZoom">4</property>
  <property name="kdenlive:extraBins">project_bin:-1:0</property>
  <property name="kdenlive:documentnotes"/>
  <property name="kdenlive:documentnotesversion">2</property>
  <property name="kdenlive:docproperties.opensequences">{1811df77-6093-4279-a807-3b60f327fa63}</property>
  <property name="kdenlive:docproperties.activetimeline">{1811df77-6093-4279-a807-3b60f327fa63}</property>
  <property name="xml_retain">1</property>
  <entry in="00:00:00.000" out="00:00:00.000" producer="{1811df77-6093-4279-a807-3b60f327fa63}"/>
 </playlist>
 <tractor id="tractor4" in="00:00:00.000" out="00:00:00.000">
  <property name="kdenlive:projectTractor">1</property>
  <track in="00:00:00.000" out="00:00:00.000" producer="{1811df77-6093-4279-a807-3b60f327fa63}"/>
 </tractor>
</mlt>

EOF

  echo "✅ Project '$project_name' created at $base_dir"
  echo "   - DJI/"
  echo "   - ScreenCasts/"
  echo "   - $project_name.kdenlive"
}

mrss_ss() {
  if [ $# -ne 2 ]; then
    echo "Usage: mrss_ss <input.mp4> <time in HH:MM:SS>"
    return 1
  fi

  local input="$1"
  local time="$2"
  local output="screenshot_${time//:/-}.png"

  ffmpeg -ss "$time" -i "$input" -frames:v 1 "$output"
  echo "✅ Screenshot saved to $output"
}

mrss_clip() {
  if [ $# -ne 4 ]; then
    echo "Usage: mrss_clip <input_file> <output_path> <start_time> <duration>"
    echo "Example: mrss_clip input.mp4 clip_5min.mp4 '00:05:00' '00:00:30'"
    return 1
  fi

  local input_file="$1"
  local output_path="$2"
  local start_time="$3"
  local duration="$4"

  ffmpeg -ss "$start_time" -i "$input_file" -t "$duration" -c copy "$output_path"

  echo "✅ Extracted $duration clip starting at $start_time → $output_path"
}

mrss_replace_audio() {
  if [ $# -ne 2 ]; then
    echo "Usage: mrss_replace_audio <video_file> <audio_file>"
    echo "Example: mrss_replace_audio project_name.kdenlive.mp4 processed-audio/project_name.denoised.wav"
    return 1
  fi

  local video_file="$1"
  local audio_file="$2"
  local output_file="${video_file%.*}.replaced_audio.mp4"

  ffmpeg -i "$video_file" -i "$audio_file" \
    -c:v copy -map 0:v:0 -map 1:a:0 -shortest "$output_file"

  echo "✅ Created: $output_file (video with replaced audio)"
}

function nvim() {
  if [[ "$#" -eq 0 ]]; then 
   CLI_CONFIG_ROOT="${CLI_CONFIG_ROOT}" env nvim .
  elif [[ -d "$1" ]]; then
   pushd "$1" > /dev/null
   CLI_CONFIG_ROOT="${CLI_CONFIG_ROOT}" env nvim $1
   popd > /dev/null
  else
   CLI_CONFIG_ROOT="${CLI_CONFIG_ROOT}" env nvim --cmd ":e $1"
  fi
}

SESSION_NAME="${PWD}"
eval tmux new-session -A -s "$SESSION_NAME" -c "$PWD"

# zprof

# if not in a Tmux session, start one
# if [[ -z "$TMUX" ]]; then 
#   exec tmux -u
# else
#   TMUX_SESSION_NAME="${PWD}"
#   tmux new-session -s "${TMUX_SESSION_NAME}" -c "${PWD}" -f "${XDG_CONFIG_HOME}/tmux/tmux.conf"
# fi

